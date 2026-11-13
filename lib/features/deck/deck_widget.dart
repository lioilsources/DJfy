import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../app/theme.dart';
import '../../core/extensions.dart';
import '../../models/deck_config.dart';
import '../../models/track.dart';
import 'deck_cubit.dart';
import 'deck_state.dart';
import 'fx_pad.dart';
import 'vinyl_painter.dart';

const _kColorLow = Color(0xFFE53935);
const _kColorMid = Color(0xFF43A047);
const _kColorHigh = Color(0xFF1E88E5);

class DeckWidget extends StatefulWidget {
  final bool isDropTarget;
  final VoidCallback? onClose;

  const DeckWidget({super.key, this.isDropTarget = false, this.onClose});

  @override
  State<DeckWidget> createState() => _DeckWidgetState();
}

class _DeckWidgetState extends State<DeckWidget> {
  bool _showFx = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeckCubit, DeckState>(
      builder: (context, state) {
        final cubit = context.read<DeckCubit>();
        final config = state.config;
        final track = config.track;
        final totalMs = config.duration.inMilliseconds;
        final progress =
            totalMs > 0 ? config.position.inMilliseconds / totalMs : 0.0;

        return DragTarget<Track>(
          onWillAcceptWithDetails: (_) => config.partyRole == null,
          onAcceptWithDetails: (details) => cubit.loadTrack(details.data),
          builder: (ctx, candidates, rejected) {
            final hovering = candidates.isNotEmpty || widget.isDropTarget;
            return ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 200, minHeight: 300),
              child: Container(
              margin: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: kCardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: hovering ? kNeonPurple : kNeonCyan.withAlpha(40),
                  width: hovering ? 2 : 1,
                ),
                boxShadow: hovering
                    ? [
                        BoxShadow(
                          color: kNeonPurple.withAlpha(80),
                          blurRadius: 16,
                          spreadRadius: 2,
                        )
                      ]
                    : null,
              ),
              child: Column(
                children: [
                  _Header(
                    track: track,
                    deckId: cubit.deckId,
                    onClose: config.partyRole == null ? widget.onClose : null,
                    state: state,
                    showFx: _showFx,
                    onToggleFx: (v) => setState(() => _showFx = v),
                  ),
                  Expanded(
                    child: _showFx
                        ? FxSection(config: config, cubit: cubit)
                        : _VinylArea(
                            progress: progress,
                            track: track,
                            config: config,
                            cubit: cubit,
                          ),
                  ),
                  _SeekSlider(config: config, cubit: cubit),
                  _Controls(config: config, cubit: cubit, state: state),
                ],
              ),
            ),
            );
          },
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  final Track? track;
  final int deckId;
  final VoidCallback? onClose;
  final DeckState state;
  final bool showFx;
  final ValueChanged<bool> onToggleFx;

  const _Header({
    required this.track,
    required this.deckId,
    required this.onClose,
    required this.state,
    required this.showFx,
    required this.onToggleFx,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 4),
      child: Row(
        children: [
          Text(
            'DECK $deckId',
            style: const TextStyle(
              color: kNeonCyan,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(width: 6),
          _ModeToggle(showFx: showFx, onChanged: onToggleFx),
          const SizedBox(width: 6),
          if (state.config.partyRole case final role?) ...[
            _PartyBadge(role),
            const SizedBox(width: 6),
          ],
          Expanded(
            child: Text(
              track != null
                  ? '${track!.artist} — ${track!.title}'
                  : state.config.partyRole == null
                      ? 'Přetáhni track sem'
                      : 'Čeká na frontu',
              style: const TextStyle(color: Colors.white70, fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (track?.bpm != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: kNeonPurple.withAlpha(40),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: kNeonPurple.withAlpha(100)),
              ),
              child: Text(
                '${track!.bpm} BPM',
                style: const TextStyle(
                  color: kNeonPurple,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (onClose != null)
            IconButton(
              icon: const Icon(Icons.close, size: 16),
              onPressed: onClose,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            ),
        ],
      ),
    );
  }
}

class _PartyBadge extends StatelessWidget {
  final PartyDeckRole role;

  const _PartyBadge(this.role);

  @override
  Widget build(BuildContext context) {
    final live = role == PartyDeckRole.live;
    final color = live ? kNeonPurple : Colors.white38;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: live ? kNeonPurple.withAlpha(60) : null,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Text(
        live ? 'PARTY · LIVE' : 'PARTY · NEXT',
        style: TextStyle(color: live ? Colors.white : color, fontSize: 9, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _VinylArea extends StatefulWidget {
  final double progress;
  final Track? track;
  final DeckConfig config;
  final DeckCubit cubit;

  const _VinylArea({
    required this.progress,
    required this.track,
    required this.config,
    required this.cubit,
  });

  @override
  State<_VinylArea> createState() => _VinylAreaState();
}

/// The platter: turns at 33⅓ rpm with the track, stops under a finger and
/// scratches as the finger moves (one revolution = 1.8 s of track).
class _VinylAreaState extends State<_VinylArea> with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker((_) => _updateAngle());
  final _angle = ValueNotifier<double>(0);
  int? _pointer;
  double? _lastAngle;
  Duration? _lastTime;
  double _size = 0;

  bool get _enabled => widget.cubit.canScratch;

  @override
  void initState() {
    super.initState();
    _syncTicker();
  }

  @override
  void didUpdateWidget(covariant _VinylArea old) {
    super.didUpdateWidget(old);
    _syncTicker();
  }

  void _updateAngle() {
    _angle.value = widget.cubit.platterAngle;
    if (!widget.config.isPlaying && _pointer == null && widget.cubit.platterIdle) _ticker.stop();
  }

  /// Ticks only while the record can move, so an idle deck costs no frames.
  void _syncTicker() {
    final moving = widget.config.isPlaying || _pointer != null || !widget.cubit.platterIdle;
    if (moving && !_ticker.isActive) {
      _ticker.start();
    } else if (!moving) {
      _angle.value = widget.cubit.platterAngle;
    }
  }

  ({double angle, double distance}) _polar(Offset local) {
    final v = local - Offset(_size / 2, _size / 2);
    return (angle: math.atan2(v.dy, v.dx), distance: v.distance);
  }

  void _down(PointerDownEvent e) {
    if (!_enabled || _pointer != null) return;
    _pointer = e.pointer;
    _lastAngle = _polar(e.localPosition).angle;
    _lastTime = e.timeStamp;
    widget.cubit.platterTouch();
    _syncTicker();
  }

  void _move(PointerMoveEvent e) {
    if (e.pointer != _pointer) return;
    final p = _polar(e.localPosition);
    final last = _lastAngle!;
    final dt = (e.timeStamp - _lastTime!).inMicroseconds / 1e6;
    _lastAngle = p.angle;
    _lastTime = e.timeStamp;
    // Near the spindle a tiny move swings the angle wildly.
    if (p.distance < _size * 0.08) return;
    var delta = p.angle - last;
    // Unwrap the ±π discontinuity so crossing it doesn't jump a turn.
    if (delta > math.pi) delta -= 2 * math.pi;
    if (delta < -math.pi) delta += 2 * math.pi;
    widget.cubit.platterDrag(delta, dt);
  }

  void _up(PointerEvent e) {
    if (e.pointer != _pointer) return;
    _pointer = null;
    _lastAngle = null;
    widget.cubit.platterRelease();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _angle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final track = widget.track;
    return LayoutBuilder(
      builder: (ctx, constraints) {
        _size = math.min(constraints.maxWidth, constraints.maxHeight).clamp(80.0, 200.0);
        final size = _size;
        final record = Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: VinylPainter(
                    progressFraction: widget.progress,
                    accentColor: kNeonCyan,
                    angle: _angle,
                  ),
                ),
              ),
            ),
            if (track?.artworkUrl != null)
              ValueListenableBuilder<double>(
                valueListenable: _angle,
                builder: (_, angle, child) => Transform.rotate(angle: angle, child: child),
                child: ClipOval(
                  child: SizedBox(
                    width: size * 0.25,
                    height: size * 0.25,
                    child: CachedNetworkImage(
                      imageUrl: track!.artworkUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (ctx, url, err) => const Icon(Icons.music_note, size: 16),
                    ),
                  ),
                ),
              ),
          ],
        );

        return Center(
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Listener(
                  behavior: HitTestBehavior.opaque,
                  onPointerDown: _down,
                  onPointerMove: _move,
                  onPointerUp: _up,
                  onPointerCancel: _up,
                  // Claim the touch at once so the deck grid doesn't scroll.
                  child: _enabled
                      ? RawGestureDetector(
                          gestures: {
                            EagerGestureRecognizer: GestureRecognizerFactoryWithHandlers<EagerGestureRecognizer>(
                              EagerGestureRecognizer.new,
                              (_) {},
                            ),
                          },
                          child: record,
                        )
                      : record,
                ),
                Positioned(
                  right: -6,
                  top: -6,
                  child: _SlipToggle(
                    on: widget.config.slip,
                    onTap: widget.config.track == null ? null : widget.cubit.toggleSlip,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SlipToggle extends StatelessWidget {
  final bool on;
  final VoidCallback? onTap;

  const _SlipToggle({required this.on, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Slip: po scratchi skladba pokračuje, jako by nebyl',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: BoxDecoration(
            color: on ? kNeonPurple.withAlpha(60) : Colors.black54,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: on ? kNeonPurple : Colors.white24),
          ),
          child: Text(
            'SLIP',
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: on ? kNeonPurple : Colors.white38,
            ),
          ),
        ),
      ),
    );
  }
}

class _SeekSlider extends StatelessWidget {
  final DeckConfig config;
  final DeckCubit cubit;

  const _SeekSlider({required this.config, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final totalMs = config.duration.inMilliseconds;
    final sliderVal = totalMs > 0
        ? (config.position.inMilliseconds / totalMs).clamp(0.0, 1.0)
        : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight: 2,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
        ),
        child: Slider(
          value: sliderVal,
          min: 0,
          max: 1,
          onChanged: totalMs > 0
              ? (v) => cubit.seekTo(
                    Duration(milliseconds: (v * totalMs).round()),
                  )
              : null,
        ),
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  final DeckConfig config;
  final DeckCubit cubit;
  final DeckState state;

  const _Controls({
    required this.config,
    required this.cubit,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final canPlay = state is DeckReady && config.partyRole != PartyDeckRole.next;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: Column(
        children: [
          // Playback row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.fast_rewind, size: 18),
                onPressed: canPlay
                    ? () => cubit.seekTo(Duration(
                          seconds: (config.position.inSeconds - 10)
                              .clamp(0, config.duration.inSeconds),
                        ))
                    : null,
                padding: EdgeInsets.zero,
                constraints:
                    const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: canPlay ? () => cubit.togglePlayPause() : null,
                // Long press while playing: cut the motor, the record coasts.
                onLongPress: canPlay && config.isPlaying ? () => cubit.brake() : null,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: canPlay ? kNeonCyan : Colors.white24,
                  ),
                  child: Icon(
                    config.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.black,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.fast_forward, size: 18),
                onPressed: canPlay
                    ? () => cubit.seekTo(Duration(
                          seconds: (config.position.inSeconds + 10)
                              .clamp(0, config.duration.inSeconds),
                        ))
                    : null,
                padding: EdgeInsets.zero,
                constraints:
                    const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${config.position.toMmSs()} / ${config.duration.toMmSs()}',
                  style: const TextStyle(color: Colors.white54, fontSize: 10),
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.fade,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          _SliderRow(
            icon: Icons.speed,
            label: '${config.speed.toStringAsFixed(2)}×',
            value: config.speed,
            min: 0.7,
            max: 1.3,
            onChanged: cubit.setSpeed,
            leading: _NudgeButton(icon: Icons.remove, onHold: canPlay ? (on) => cubit.nudge(on ? -1 : 0) : null),
            trailing: _NudgeButton(icon: Icons.add, onHold: canPlay ? (on) => cubit.nudge(on ? 1 : 0) : null),
          ),
          _SliderRow(
            icon: Icons.volume_up,
            label: '${(config.volume * 100).round()}%',
            value: config.volume,
            min: 0.0,
            max: 1.0,
            onChanged: cubit.setVolume,
          ),
          _EqKillRow(config: config, cubit: cubit),
          if (state is DeckLoading)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: LinearProgressIndicator(),
            ),
          if (state is DeckError)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                (state as DeckError).message,
                style:
                    const TextStyle(color: Colors.redAccent, fontSize: 10),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  final bool showFx;
  final ValueChanged<bool> onChanged;

  const _ModeToggle({required this.showFx, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    Widget tab(String label, bool isFx) {
      final selected = showFx == isFx;
      return GestureDetector(
        onTap: () => onChanged(isFx),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: selected ? kNeonCyan.withAlpha(40) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              color: selected ? kNeonCyan : Colors.white38,
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [tab('DECK', false), tab('FX', true)],
      ),
    );
  }
}

class _EqKillRow extends StatelessWidget {
  final DeckConfig config;
  final DeckCubit cubit;

  const _EqKillRow({required this.config, required this.cubit});

  static const _bands = [
    (EqBand.low, 'LOW', Icons.speaker, _kColorLow),
    (EqBand.mid, 'MID', Icons.equalizer, _kColorMid),
    (EqBand.high, 'HIGH', Icons.music_note, _kColorHigh),
  ];

  @override
  Widget build(BuildContext context) {
    final enabled = config.hasDsp;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _bands.map((s) {
          final (type, label, icon, color) = s;
          final active = enabled && (config.eqBands[type] ?? true);
          return Tooltip(
            message: enabled ? '' : 'DSP nedostupné (HLS stream)',
            child: GestureDetector(
              onTap: enabled ? () => cubit.toggleEqBand(type) : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: active
                      ? color.withAlpha(50)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: active
                        ? color
                        : (enabled ? Colors.white24 : Colors.white12),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 12,
                      color: active
                          ? color
                          : (enabled ? Colors.white38 : Colors.white12),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: active
                            ? color
                            : (enabled ? Colors.white38 : Colors.white12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Pitch bend: holding it speeds the deck up or slows it down a few percent.
class _NudgeButton extends StatelessWidget {
  final IconData icon;
  final ValueChanged<bool>? onHold;

  const _NudgeButton({required this.icon, required this.onHold});

  @override
  Widget build(BuildContext context) {
    final hold = onHold;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: hold == null ? null : (_) => hold(true),
      onTapUp: hold == null ? null : (_) => hold(false),
      onTapCancel: hold == null ? null : () => hold(false),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Icon(icon, size: 14, color: hold == null ? Colors.white12 : Colors.white54),
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final Widget? leading;
  final Widget? trailing;

  const _SliderRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.white54),
        ?leading,
        Expanded(
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
        ?trailing,
        SizedBox(
          width: 36,
          child: Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 10),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
