import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Paints a glowing glass tumbler with liquid inside.
///
/// * [level] 0..1 is the liquid height.
/// * [phase] 0..1 drives the sine-wave surface (animated by the caller).
/// * [pour] 0..1 draws a falling stream into the glass (salary day).
///
/// The glass is slightly wider at the top than the bottom. The liquid is
/// clipped to the glass interior, has two layered sine waves on its surface,
/// a vertical gradient, and an inner glow; the glass gets an outline, a
/// highlight streak and an outer halo in [glow].
class LiquidGlassPainter extends CustomPainter {
  LiquidGlassPainter({
    required this.level,
    required this.phase,
    required this.color,
    required this.glow,
    required this.outline,
    this.pour = 0,
    this.waveHeight = 1,
    this.glowStrength = 1,
  });

  final double level;
  final double phase;
  final Color color;
  final Color glow;
  final Color outline;
  final double pour;

  /// Scales the wave amplitude (1 = default).
  final double waveHeight;

  /// Scales the outer glow (0 = none).
  final double glowStrength;

  /// Interior outline of the glass for a given canvas size.
  static Path glassPath(Size size) {
    final w = size.width;
    final h = size.height;
    final topInset = w * 0.04;
    final bottomInset = w * 0.12;
    final top = h * 0.06;
    final r = w * 0.14;
    return Path()
      ..moveTo(topInset, top)
      ..lineTo(w - topInset, top)
      ..lineTo(w - bottomInset, h - r)
      ..quadraticBezierTo(w - bottomInset - r * 0.2, h, w - bottomInset - r, h)
      ..lineTo(bottomInset + r, h)
      ..quadraticBezierTo(bottomInset + r * 0.2, h, bottomInset, h - r)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final glass = glassPath(size);
    final top = h * 0.06;
    final innerHeight = h - top;
    final lvl = level.clamp(0.0, 1.0);

    // Soft contact shadow where the glass stands on the shelf.
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w / 2, h + h * 0.01),
        width: w * 0.86,
        height: h * 0.06,
      ),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.35)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.05),
    );

    // Outer halo, stronger when fuller.
    if (glowStrength > 0) {
      final halo = Paint()
        ..color = glow.withValues(alpha: (0.10 + 0.30 * lvl) * glowStrength)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.16);
      canvas.drawPath(glass, halo);
    }

    // Glass body tint.
    canvas.drawPath(glass, Paint()..color = outline.withValues(alpha: 0.06));

    canvas.save();
    canvas.clipPath(glass);

    // Pouring stream from above the glass.
    if (pour > 0 && pour < 1) {
      final streamW = w * 0.12 * (1 - (pour - 0.85).clamp(0.0, 0.15) / 0.15);
      final streamPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: 0.95), color.withValues(alpha: 0.7)],
        ).createShader(Rect.fromLTWH(0, 0, w, h));
      final wobble = math.sin(phase * math.pi * 2 * 3) * w * 0.01;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w / 2 - streamW / 2 + wobble, 0, streamW, h),
          Radius.circular(streamW / 2),
        ),
        streamPaint,
      );
    }

    if (lvl > 0) {
      final surfaceY = top + innerHeight * (1 - lvl);
      // Waves are calmer when the glass is nearly empty or full.
      final amp =
          h * 0.018 * waveHeight * (0.4 + 0.6 * math.sin(lvl * math.pi));
      final t = phase * math.pi * 2;

      Path wave(double offset, double ampScale) {
        final p = Path()..moveTo(0, h);
        const steps = 32;
        for (var i = 0; i <= steps; i++) {
          final x = w * i / steps;
          final y =
              surfaceY +
              math.sin((x / w) * math.pi * 2 * 1.2 + t + offset) *
                  amp *
                  ampScale;
          p.lineTo(x, y);
        }
        p
          ..lineTo(w, h)
          ..close();
        return p;
      }

      // Back wave (lighter), then front wave with the main gradient.
      canvas.drawPath(
        wave(math.pi * 0.8, 0.8),
        Paint()..color = color.withValues(alpha: 0.35),
      );
      final liquidRect = Rect.fromLTWH(
        0,
        surfaceY - amp,
        w,
        h - surfaceY + amp,
      );
      canvas.drawPath(
        wave(0, 1),
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.lerp(color, Colors.white, 0.25)!,
              color,
              Color.lerp(color, Colors.black, 0.25)!,
            ],
            stops: const [0, 0.35, 1],
          ).createShader(liquidRect),
      );

      // Inner glow: a soft radial light from inside the liquid.
      canvas.drawCircle(
        Offset(w / 2, surfaceY + (h - surfaceY) * 0.45),
        w * 0.55,
        Paint()
          ..shader =
              RadialGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.30),
                  Colors.white.withValues(alpha: 0),
                ],
              ).createShader(
                Rect.fromCircle(
                  center: Offset(w / 2, surfaceY + (h - surfaceY) * 0.45),
                  radius: w * 0.55,
                ),
              ),
      );

      // Bright meniscus line along the surface.
      final surface = Path();
      const steps = 32;
      for (var i = 0; i <= steps; i++) {
        final x = w * i / steps;
        final y = surfaceY + math.sin((x / w) * math.pi * 2 * 1.2 + t) * amp;
        i == 0 ? surface.moveTo(x, y) : surface.lineTo(x, y);
      }
      canvas.drawPath(
        surface,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1.2, w * 0.015)
          ..color = Colors.white.withValues(alpha: 0.45),
      );
    }
    // Little bubbles drifting up through the liquid (driven by [phase]).
    if (lvl > 0.08) {
      final surfaceY = top + innerHeight * (1 - lvl);
      final depth = h - surfaceY;
      final bubble = Paint()..color = Colors.white.withValues(alpha: 0.28);
      const seeds = [0.22, 0.47, 0.68, 0.81, 0.35];
      for (var i = 0; i < seeds.length; i++) {
        final travel = (phase + i / seeds.length) % 1.0;
        final y = h - depth * 0.08 - travel * depth * 0.85;
        final x =
            w * seeds[i] + math.sin((travel + i) * math.pi * 2) * w * 0.02;
        final r = w * (0.012 + 0.008 * ((i % 3) / 2));
        canvas.drawCircle(Offset(x, y), r, bubble);
      }
    }

    // Glass body sheen: light catching both curved edges.
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.16),
            Colors.white.withValues(alpha: 0.02),
            Colors.white.withValues(alpha: 0),
            Colors.white.withValues(alpha: 0.03),
            Colors.white.withValues(alpha: 0.12),
          ],
          stops: const [0, 0.18, 0.5, 0.82, 1],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // Thick glass base.
    canvas.drawRect(
      Rect.fromLTWH(0, h - h * 0.045, w, h * 0.045),
      Paint()..color = Colors.white.withValues(alpha: 0.18),
    );
    canvas.restore();

    // Glass highlight streak on the left.
    final streak = Path()
      ..moveTo(w * 0.17, h * 0.14)
      ..lineTo(w * 0.23, h * 0.14)
      ..lineTo(w * 0.27, h * 0.78)
      ..lineTo(w * 0.22, h * 0.78)
      ..close();
    canvas.drawPath(
      streak,
      Paint()..color = Colors.white.withValues(alpha: 0.13),
    );

    // Glass outline + thicker rim.
    canvas.drawPath(
      glass,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.5, w * 0.022)
        ..color = outline,
    );
    canvas.drawLine(
      Offset(w * 0.04, top),
      Offset(w * 0.96, top),
      Paint()
        ..strokeWidth = math.max(2, w * 0.035)
        ..strokeCap = StrokeCap.round
        ..color = outline.withValues(alpha: 0.9),
    );
  }

  @override
  bool shouldRepaint(LiquidGlassPainter old) =>
      old.level != level ||
      old.phase != phase ||
      old.pour != pour ||
      old.color != color ||
      old.glow != glow ||
      old.outline != outline ||
      old.waveHeight != waveHeight ||
      old.glowStrength != glowStrength;
}
