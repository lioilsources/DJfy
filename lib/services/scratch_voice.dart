import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:djfy_decoder/djfy_decoder.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

import '../core/scratch_renderer.dart';

/// One deck played from decoded PCM through a SoLoud [BufferStream]: the
/// playhead lives here ([ScratchRenderer]), so the record can stop, go
/// backwards and loop sample-accurately. SoLoud only mixes and runs filters.
///
/// Never `setPause` this voice: SoLoud pauses and resumes buffer streams on
/// its own while buffering. Pausing is the renderer fading out.
class ScratchVoice {
  static const _blockFrames = 256;

  /// Lead of what's pushed over what SoLoud has played; grows after an
  /// underrun. 40 ms survived 30 ms main-isolate stalls on macOS (spike).
  static const minAhead = Duration(milliseconds: 40);
  static const maxAhead = Duration(milliseconds: 120);

  final DecodedPcm pcm;
  final ScratchRenderer renderer;
  final AudioSource source;
  late final SoundHandle handle;

  final void Function() onEnded;

  Timer? _timer;
  int _pushedFrames = 0;
  Duration _ahead = minAhead;
  int underruns = 0;
  bool _endedSent = false;
  bool _disposed = false;

  /// Output frame index → playhead at the start of each pushed block, so the
  /// position reported is the one being heard, not the one being rendered.
  final _marks = <({int out, double frame, double rate})>[];

  ScratchVoice._(this.pcm, this.source, this.onEnded)
      : renderer = ScratchRenderer(pcm.samples, channels: pcm.channels, sampleRate: pcm.sampleRate);

  /// Creates the stream; [prepareFilters] activates the source's filters,
  /// which must happen before the voice starts.
  static Future<ScratchVoice> start(
    DecodedPcm pcm, {
    required double volume,
    required void Function(AudioSource source) prepareFilters,
    required void Function() onEnded,
  }) async {
    late final ScratchVoice voice;
    final source = SoLoud.instance.setBufferStream(
      maxBufferSizeDuration: const Duration(seconds: 2),
      bufferingType: BufferingType.released,
      bufferingTimeNeeds: 0.01,
      sampleRate: pcm.sampleRate,
      channels: Channels.stereo,
      format: BufferType.s16le,
      onBuffering: (isBuffering, handle, time) {
        if (isBuffering) voice._underrun();
      },
    );
    voice = ScratchVoice._(pcm, source, onEnded);
    prepareFilters(source);
    voice.handle = await SoLoud.instance.play(source, volume: volume);
    // Data has to arrive after play(): only an add wakes a buffering handle.
    voice._fill();
    voice._timer = Timer.periodic(const Duration(milliseconds: 4), (_) => voice._fill());
    return voice;
  }

  Duration get duration => pcm.duration;

  /// What the listener hears right now.
  Duration get position => _toDuration(_heardFrame());

  set playing(bool on) => renderer.playing = on;
  bool get playing => renderer.playing;

  /// Signed rate; 1 = normal, < 0 = backwards.
  set rate(double r) => renderer.rate = r;

  void seek(Duration to) {
    renderer.seek(_toFrame(to));
    _endedSent = false;
  }

  /// The finger holds the record at [at], moving at [rate]; null lets go.
  void follow(Duration? at, double rate) => renderer.follow(at == null ? null : _toFrame(at), rate);

  /// Repeats [start, start + length) until [endLoop].
  void loop(Duration start, Duration length) =>
      renderer.loop(_toFrame(start), _toFrame(start + length));
  void endLoop() => renderer.loop(null, null);

  double _toFrame(Duration d) => d.inMicroseconds / 1e6 * pcm.sampleRate;
  Duration _toDuration(double frame) => Duration(microseconds: (frame / pcm.sampleRate * 1e6).round());

  double _consumedFrames() =>
      SoLoud.instance.getStreamTimeConsumed(source).inMicroseconds / 1e6 * pcm.sampleRate;

  double _heardFrame() {
    if (_marks.isEmpty) return renderer.position;
    final consumed = _consumedFrames();
    var mark = _marks.first;
    for (final m in _marks) {
      if (m.out > consumed) break;
      mark = m;
    }
    final into = math.max(0.0, consumed - mark.out);
    return (mark.frame + into * mark.rate).clamp(0, math.max(0, pcm.frames - 1)).toDouble();
  }

  void _fill() {
    if (_disposed) return;
    final consumed = _consumedFrames();
    final aheadFrames = _ahead.inMicroseconds / 1e6 * pcm.sampleRate;
    while (_pushedFrames - consumed < aheadFrames) {
      _push();
    }
    // Keep marks for what's still in flight, plus one before it.
    while (_marks.length > 2 && _marks[1].out <= consumed) {
      _marks.removeAt(0);
    }
    if (renderer.ended && !_endedSent && _heardFrame() >= pcm.frames - 2) {
      _endedSent = true;
      onEnded();
    }
  }

  void _push() {
    _marks.add((out: _pushedFrames, frame: renderer.position, rate: renderer.currentRate));
    final block = Int16List(_blockFrames * 2);
    renderer.render(block);
    SoLoud.instance.addAudioDataStream(source, block.buffer.asUint8List());
    _pushedFrames += _blockFrames;
  }

  /// SoLoud ran dry and paused the voice: lead more from now on, and push
  /// past its resume threshold right away, or it stays paused.
  void _underrun() {
    if (_disposed) return;
    // Every stream starts out buffering; that one isn't a stall.
    if (_consumedFrames() <= 0) return;
    underruns++;
    _ahead = Duration(microseconds: math.min(maxAhead.inMicroseconds, _ahead.inMicroseconds + 10000));
    debugPrint('[ScratchVoice] underrun #$underruns, lead now ${_ahead.inMilliseconds} ms');
    scheduleMicrotask(() {
      for (var i = 0; i < 8 && !_disposed; i++) {
        _push();
      }
    });
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _timer?.cancel();
    await SoLoud.instance.stop(handle);
    SoLoud.instance.disposeSource(source);
  }
}
