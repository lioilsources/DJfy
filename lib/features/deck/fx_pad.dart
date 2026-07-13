import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/deck_config.dart';
import '../../models/fx.dart';
import 'deck_cubit.dart';

/// Pacemaker-style FX section: effect selector chips + a momentary XY pad.
/// The effect is audible only while a finger is on the pad; X drives the
/// main parameter, Y the intensity/mix.
class FxSection extends StatelessWidget {
  final DeckConfig config;
  final DeckCubit cubit;

  const FxSection({super.key, required this.config, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final enabled = config.hasDsp;
    return Tooltip(
      message: enabled ? '' : 'DSP nedostupné (HLS stream)',
      child: Opacity(
        opacity: enabled ? 1.0 : 0.4,
        child: Column(
          children: [
            _FxSelector(config: config, cubit: cubit, enabled: enabled),
            const SizedBox(height: 4),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _FxPad(config: config, cubit: cubit, enabled: enabled),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FxSelector extends StatelessWidget {
  final DeckConfig config;
  final DeckCubit cubit;
  final bool enabled;

  const _FxSelector({
    required this.config,
    required this.cubit,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: FxType.values.map((type) {
          final selected = config.selectedFx == type;
          final available = enabled &&
              (!type.needsBpm || config.track?.bpm != null);
          final chip = GestureDetector(
            onTap: available ? () => cubit.selectFx(type) : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: selected ? type.color.withAlpha(50) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: selected
                      ? type.color
                      : (available ? Colors.white24 : Colors.white12),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    type.icon,
                    size: 12,
                    color: selected
                        ? type.color
                        : (available ? Colors.white38 : Colors.white12),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    type.label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: selected
                          ? type.color
                          : (available ? Colors.white38 : Colors.white12),
                    ),
                  ),
                ],
              ),
            ),
          );
          if (type.needsBpm && enabled && config.track?.bpm == null) {
            return Tooltip(message: 'BPM neznámé', child: chip);
          }
          return chip;
        }).toList(),
      ),
    );
  }
}

class _FxPad extends StatelessWidget {
  final DeckConfig config;
  final DeckCubit cubit;
  final bool enabled;

  const _FxPad({
    required this.config,
    required this.cubit,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);

        (double, double) norm(Offset local) => (
              (local.dx / size.width).clamp(0.0, 1.0),
              (1 - local.dy / size.height).clamp(0.0, 1.0),
            );

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanDown: enabled
              ? (d) {
                  final (x, y) = norm(d.localPosition);
                  cubit.fxStart(x, y);
                }
              : null,
          onPanUpdate: enabled
              ? (d) {
                  final (x, y) = norm(d.localPosition);
                  cubit.fxUpdate(x, y);
                }
              : null,
          onPanEnd: enabled ? (_) => cubit.fxEnd() : null,
          onPanCancel: enabled ? () => cubit.fxEnd() : null,
          child: CustomPaint(
            size: Size.infinite,
            painter: FxPadPainter(
              fx: config.selectedFx,
              active: config.fxActive,
              x: config.fxX,
              y: config.fxY,
            ),
          ),
        );
      },
    );
  }
}

class FxPadPainter extends CustomPainter {
  final FxType fx;
  final bool active;
  final double x;
  final double y;

  FxPadPainter({
    required this.fx,
    required this.active,
    required this.x,
    required this.y,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(12),
    );
    canvas.clipRRect(rrect);

    // Background
    canvas.drawRRect(
      rrect,
      Paint()..color = kDeckBg,
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = (active ? fx.color : Colors.white24).withAlpha(120),
    );

    // Faint grid
    final gridPaint = Paint()
      ..color = Colors.white.withAlpha(12)
      ..strokeWidth = 1;
    for (var i = 1; i < 4; i++) {
      final dx = size.width * i / 4;
      canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), gridPaint);
      final dy = size.height * i / 4;
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), gridPaint);
    }

    // FX-specific zones
    switch (fx) {
      case FxType.hiLo:
        // Center dead zone stripe
        final dead = Rect.fromLTRB(
          size.width * 0.45,
          0,
          size.width * 0.55,
          size.height,
        );
        canvas.drawRect(dead, Paint()..color = Colors.white.withAlpha(16));
      case FxType.echo || FxType.roll:
        _drawBuckets(canvas, size, 4, _bucketLabels());
      case FxType.beatskip:
        _drawBuckets(canvas, size, 6, _bucketLabels());
      case FxType.reverb || FxType.eightBit:
        break;
    }

    // Axis captions
    final captionStyle = TextStyle(
      color: Colors.white.withAlpha(90),
      fontSize: 8,
      letterSpacing: 1,
    );
    _drawText(
      canvas,
      fx.xAxisLabel,
      Offset(size.width / 2, size.height - 10),
      captionStyle,
      center: true,
    );
    if (fx.yAxisLabel.isNotEmpty) {
      canvas.save();
      canvas.translate(8, size.height / 2);
      canvas.rotate(-1.5708);
      _drawText(canvas, fx.yAxisLabel, Offset.zero, captionStyle,
          center: true);
      canvas.restore();
    }

    // Crosshair + glow dot while touched
    if (active) {
      final px = x * size.width;
      final py = (1 - y) * size.height;
      final linePaint = Paint()
        ..color = fx.color.withAlpha(70)
        ..strokeWidth = 1;
      canvas.drawLine(Offset(px, 0), Offset(px, size.height), linePaint);
      canvas.drawLine(Offset(0, py), Offset(size.width, py), linePaint);
      canvas.drawCircle(
        Offset(px, py),
        16,
        Paint()
          ..color = fx.color.withAlpha(60)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
      canvas.drawCircle(Offset(px, py), 6, Paint()..color = fx.color);
    }
  }

  List<String> _bucketLabels() => switch (fx) {
        FxType.echo => ['1/4', '1/2', '3/4', '1'],
        FxType.roll => ['1/2', '1/4', '1/8', '1/16'],
        FxType.beatskip => ['-4', '-2', '-1', '+1', '+2', '+4'],
        _ => const [],
      };

  void _drawBuckets(Canvas canvas, Size size, int count, List<String> labels) {
    final sepPaint = Paint()
      ..color = Colors.white.withAlpha(30)
      ..strokeWidth = 1;
    for (var i = 1; i < count; i++) {
      final dx = size.width * i / count;
      canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), sepPaint);
    }
    final style = TextStyle(
      color: fx.color.withAlpha(150),
      fontSize: 10,
      fontWeight: FontWeight.bold,
    );
    for (var i = 0; i < count && i < labels.length; i++) {
      final cx = size.width * (i + 0.5) / count;
      _drawText(canvas, labels[i], Offset(cx, size.height * 0.45), style,
          center: true);
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset at,
    TextStyle style, {
    bool center = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    final offset = center
        ? at - Offset(tp.width / 2, tp.height / 2)
        : at;
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(FxPadPainter old) =>
      old.fx != fx || old.active != active || old.x != x || old.y != y;
}
