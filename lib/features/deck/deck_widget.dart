import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../app/theme.dart';
import '../../core/extensions.dart';
import '../../models/deck_config.dart';
import '../../models/track.dart';
import 'deck_cubit.dart';
import 'deck_state.dart';
import 'vinyl_painter.dart';

const _kColorDrums = Color(0xFFE53935);
const _kColorMelody = Color(0xFF43A047);
const _kColorVocals = Color(0xFF1E88E5);

class DeckWidget extends StatelessWidget {
  final bool isDropTarget;
  final VoidCallback? onClose;

  const DeckWidget({super.key, this.isDropTarget = false, this.onClose});

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
          onAcceptWithDetails: (details) => cubit.loadTrack(details.data),
          builder: (ctx, candidates, rejected) {
            final hovering = candidates.isNotEmpty || isDropTarget;
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
                    onClose: onClose,
                    state: state,
                  ),
                  Expanded(
                    child: _VinylArea(
                      progress: progress,
                      track: track,
                      config: config,
                      cubit: cubit,
                    ),
                  ),
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

  const _Header({
    required this.track,
    required this.deckId,
    required this.onClose,
    required this.state,
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
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              track != null
                  ? '${track!.artist} — ${track!.title}'
                  : 'Přetáhni track sem',
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

class _VinylArea extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final size = constraints.maxWidth.clamp(80.0, 200.0);
        final totalMs = config.duration.inMilliseconds;
        final sliderVal = totalMs > 0
            ? (config.position.inMilliseconds / totalMs).clamp(0.0, 1.0)
            : 0.0;

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: size,
                  height: size,
                  child: CustomPaint(
                    painter: VinylPainter(
                      progressFraction: progress,
                      accentColor: kNeonCyan,
                      isPlaying: config.isPlaying,
                    ),
                  ),
                ),
                if (track?.artworkUrl != null)
                  ClipOval(
                    child: SizedBox(
                      width: size * 0.25,
                      height: size * 0.25,
                      child: CachedNetworkImage(
                        imageUrl: track!.artworkUrl!,
                        fit: BoxFit.cover,
                        errorWidget: (ctx, url, err) =>
                            const Icon(Icons.music_note, size: 16),
                      ),
                    ),
                  ),
              ],
            ),
            // Seek slider
            Padding(
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
            ),
          ],
        );
      },
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
    final canPlay = state is DeckReady;
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
              const Spacer(),
              Text(
                '${config.position.toMmSs()} / ${config.duration.toMmSs()}',
                style: const TextStyle(color: Colors.white54, fontSize: 10),
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
          ),
          _SliderRow(
            icon: Icons.volume_up,
            label: '${(config.volume * 100).round()}%',
            value: config.volume,
            min: 0.0,
            max: 1.0,
            onChanged: cubit.setVolume,
          ),
          _StemFilterRow(config: config, cubit: cubit),
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

class _StemFilterRow extends StatelessWidget {
  final DeckConfig config;
  final DeckCubit cubit;

  const _StemFilterRow({required this.config, required this.cubit});

  static const _stems = [
    (StemType.drums, 'DRUMS', Icons.music_note, _kColorDrums),
    (StemType.melody, 'MELODY', Icons.piano, _kColorMelody),
    (StemType.vocals, 'VOCALS', Icons.mic, _kColorVocals),
  ];

  @override
  Widget build(BuildContext context) {
    final enabled = config.hasDsp;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _stems.map((s) {
          final (type, label, icon, color) = s;
          final active = enabled && (config.stemFilters[type] ?? true);
          return Tooltip(
            message: enabled ? '' : 'DSP nedostupné (HLS stream)',
            child: GestureDetector(
              onTap: enabled ? () => cubit.toggleStem(type) : null,
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

class _SliderRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const _SliderRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.white54),
        Expanded(
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
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
