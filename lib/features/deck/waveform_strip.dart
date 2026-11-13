import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../app/theme.dart';
import '../../core/platter.dart';
import '../../core/track_analysis.dart';
import '../../models/deck_config.dart';
import 'deck_cubit.dart';

/// The track around the needle: ±[span] of waveform scrolling past a fixed
/// playhead, with the beat grid on top. Dragging it scratches like the
/// platter; TAP sets the grid on the beat you hear.
class WaveformStrip extends StatefulWidget {
  final DeckConfig config;
  final DeckCubit cubit;

  const WaveformStrip({super.key, required this.config, required this.cubit});

  static const span = Duration(seconds: 3);

  @override
  State<WaveformStrip> createState() => _WaveformStripState();
}

class _WaveformStripState extends State<WaveformStrip> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final _position = ValueNotifier<Duration>(Duration.zero);
  int? _pointer;
  double _width = 1;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((_) => _tick()); // not lazily: dispose() would create it too late
    _sync();
  }

  @override
  void didUpdateWidget(covariant WaveformStrip old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _tick() {
    _position.value = widget.cubit.displayPosition;
    if (!widget.config.isPlaying && _pointer == null && widget.cubit.platterIdle) _ticker.stop();
  }

  void _sync() {
    if (widget.config.isPlaying || _pointer != null || !widget.cubit.platterIdle) {
      if (!_ticker.isActive) _ticker.start();
    } else {
      _position.value = widget.cubit.displayPosition;
    }
  }

  void _down(PointerDownEvent e) {
    if (_pointer != null || !widget.cubit.canScratch) return;
    _pointer = e.pointer;
    widget.cubit.platterTouch();
    _sync();
  }

  void _move(PointerMoveEvent e) {
    if (e.pointer != _pointer) return;
    // Dragging right pulls the track back, like pushing a record backwards.
    final seconds = -e.delta.dx / _width * 2 * WaveformStrip.span.inMicroseconds / 1e6;
    final radians = seconds / Platter.secondsPerRevolution * 2 * math.pi;
    widget.cubit.platterDrag(radians, math.max(e.delta.distance, 1) / 1000 + 0.008);
  }

  void _up(PointerEvent e) {
    if (e.pointer != _pointer) return;
    _pointer = null;
    widget.cubit.platterRelease();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _position.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.config;
    final bpm = c.track?.bpm;
    return SizedBox(
      height: 30,
      child: Row(
        children: [
          Expanded(
            child: LayoutBuilder(builder: (context, constraints) {
              _width = constraints.maxWidth;
              return Listener(
                behavior: HitTestBehavior.opaque,
                onPointerDown: _down,
                onPointerMove: _move,
                onPointerUp: _up,
                onPointerCancel: _up,
                child: RawGestureDetector(
                  gestures: {
                    EagerGestureRecognizer: GestureRecognizerFactoryWithHandlers<EagerGestureRecognizer>(
                      EagerGestureRecognizer.new,
                      (_) {},
                    ),
                  },
                  child: RepaintBoundary(
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: WaveformPainter(
                        peaks: c.waveform,
                        position: _position,
                        beat: bpm == null ? null : widget.cubit.beatDuration,
                        beatOffset: c.beatOffset,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          if (bpm != null)
            GestureDetector(
              onTap: widget.cubit.tapBeat,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                child: Text('TAP', style: TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }
}

class WaveformPainter extends CustomPainter {
  final Uint8List? peaks;
  final ValueListenable<Duration> position;
  final Duration? beat;
  final Duration beatOffset;

  WaveformPainter({required this.peaks, required this.position, required this.beat, required this.beatOffset})
      : super(repaint: position);

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(6));
    canvas.clipRRect(rrect);
    canvas.drawRRect(rrect, Paint()..color = kDeckBg);

    final spanUs = WaveformStrip.span.inMicroseconds;
    final pxPerUs = size.width / (2 * spanUs);
    final now = position.value.inMicroseconds;
    final start = now - spanUs;
    double x(num us) => (us - start) * pxPerUs;
    final mid = size.height / 2;

    final peaks = this.peaks;
    if (peaks != null && peaks.isNotEmpty) {
      final windowUs = TrackAnalysis.peakWindow.inMicroseconds;
      final first = math.max(0, start ~/ windowUs);
      final last = math.min(peaks.length - 1, (now + spanUs) ~/ windowUs);
      final barWidth = math.max(1.0, windowUs * pxPerUs - 1);
      final played = Paint()..color = kNeonCyan.withAlpha(110);
      final ahead = Paint()..color = kNeonCyan.withAlpha(220);
      for (var i = first; i <= last; i++) {
        final h = peaks[i] / 255 * (mid - 2);
        final left = x(i * windowUs);
        canvas.drawRect(
          Rect.fromLTRB(left, mid - h, left + barWidth, mid + h),
          i * windowUs < now ? played : ahead,
        );
      }
    }

    final beat = this.beat;
    if (beat != null && beat > Duration.zero) {
      final beatUs = beat.inMicroseconds;
      final offsetUs = beatOffset.inMicroseconds;
      final firstBeat = ((start - offsetUs) / beatUs).ceil();
      final tick = Paint()..color = Colors.white.withAlpha(60);
      final bar = Paint()
        ..color = Colors.white.withAlpha(150)
        ..strokeWidth = 1.5;
      for (var k = firstBeat; offsetUs + k * beatUs <= now + spanUs; k++) {
        final bx = x(offsetUs + k * beatUs);
        final downbeat = k % 4 == 0;
        canvas.drawLine(Offset(bx, 0), Offset(bx, downbeat ? size.height : size.height * 0.25), downbeat ? bar : tick);
      }
    }

    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(WaveformPainter old) =>
      old.peaks != peaks || old.beat != beat || old.beatOffset != beatOffset || old.position != position;
}
