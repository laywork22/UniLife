import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../state/pomodoro_provider.dart';

/// Countdown circolare animato del Pomodoro (UC-9).
/// L'anello e il numero del timer seguono il `secondary` del tema scelto,
/// così cambiando preset stagionale tutto il widget si tinge di conseguenza.
class PomodoroTimer extends StatelessWidget {
  const PomodoroTimer({
    super.key,
    required this.display,
    required this.progress,
    required this.state,
  });

  final String display;
  final double progress;
  final PomodoroState state;

  @override
  Widget build(BuildContext context) {
    const size = 260.0;
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(progress: progress, color: scheme.secondary),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                display,
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w700,
                  color: scheme.secondary,
                  letterSpacing: 2,
                ),
              ),
              Text(
                switch (state) {
                  PomodoroState.idle => 'Pronto',
                  PomodoroState.running => 'In corso',
                  PomodoroState.paused => 'In pausa',
                  PomodoroState.done => 'Completato!',
                },
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide / 2) - 14;
    const stroke = 14.0;

    final bg = Paint()
      ..color = AppColors.divider
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final fg = Paint()
      ..color = color
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bg);
    final sweep = 2 * math.pi * progress.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweep,
      false,
      fg,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress || old.color != color;
}
