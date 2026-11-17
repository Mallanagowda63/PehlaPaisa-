import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Timing for "coins drop into the Savings glass, one by one".
///
/// Everything is a function of one progress value `t` (0..1) so a single
/// AnimationController drives the whole scene.
class CoinDropTimeline {
  const CoinDropTimeline({
    this.coins = 7,
    this.firstStart = 0.0,
    this.gap = 0.10,
    this.fall = 0.24,
    this.settle = 0.08,
    this.startLevel = 0.12,
    this.endLevel = 0.88,
  });

  final int coins;
  final double firstStart;

  /// Time between one coin starting and the next.
  final double gap;

  /// How long a coin takes to fall into the glass.
  final double fall;

  /// How long the liquid takes to rise after a coin lands.
  final double settle;
  final double startLevel;
  final double endLevel;

  double startOf(int i) => firstStart + i * gap;
  double landOf(int i) => startOf(i) + fall;

  /// 0 before coin [i] starts, 1 when it lands.
  double fallProgress(int i, double t) =>
      ((t - startOf(i)) / fall).clamp(0.0, 1.0);

  /// 0..1 after coin [i] lands (ripple / sinking).
  double afterLanding(int i, double t) {
    final v = ((t - landOf(i)) / settle).clamp(0.0, 1.0);
    // Snap tiny floating-point leftovers so the end state is exact.
    return v > 1 - 1e-6 ? 1 : v;
  }

  /// Liquid level: every landed coin adds an equal, eased step.
  double level(double t) {
    var filled = 0.0;
    for (var i = 0; i < coins; i++) {
      filled += Curves.easeOutCubic.transform(afterLanding(i, t));
    }
    return startLevel + (endLevel - startLevel) * (filled / coins);
  }

  /// When the last coin has settled (as a fraction of the animation).
  double get end => landOf(coins - 1) + settle;
}

/// Paints gold ₹ coins falling and spinning into a glass, with a ripple and
/// a soft sink where each one lands.
///
/// The canvas is the glass area extended upward by [dropHeight]; the glass
/// occupies the bottom [glassHeight] of it.
class CoinRainPainter extends CustomPainter {
  CoinRainPainter({
    required this.t,
    required this.timeline,
    required this.glassHeight,
    required this.dropHeight,
    required this.coinColor,
  });

  final double t;
  final CoinDropTimeline timeline;
  final double glassHeight;
  final double dropHeight;
  final Color coinColor;

  /// Horizontal offsets (fraction of glass width) so coins don't stack.
  static const _xs = [0.0, -0.16, 0.14, -0.06, 0.18, -0.18, 0.06, 0.1];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final glassTop = dropHeight + glassHeight * 0.06;
    final innerH = glassHeight * 0.94;
    final r = w * 0.11;

    for (var i = 0; i < timeline.coins; i++) {
      final fall = timeline.fallProgress(i, t);
      if (fall <= 0) continue;
      final after = timeline.afterLanding(i, t);
      if (after >= 1) continue;

      // Where the liquid surface is when this coin lands.
      final levelAtLand = timeline.level(timeline.landOf(i));
      final surfaceY = glassTop + innerH * (1 - levelAtLand);
      final x = w / 2 + _xs[i % _xs.length] * w;

      if (fall < 1) {
        // Falling: gravity-like ease-in, spinning (coin flip).
        final y = -r + (surfaceY + r) * Curves.easeIn.transform(fall);
        final spin = math.cos(fall * math.pi * 3);
        _coin(canvas, Offset(x, y), r, spin.abs().clamp(0.15, 1.0), 1);
      } else {
        // Landed: coin sinks and fades while a ripple spreads.
        final sink = Curves.easeOut.transform(after);
        _coin(canvas, Offset(x, surfaceY + r * 0.8 * sink), r, 1, 1 - sink);
        final ripple = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1.2, w * 0.012)
          ..color = Colors.white.withValues(alpha: 0.55 * (1 - after));
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(x, surfaceY),
            width: r * 2 * (1 + after * 1.6),
            height: r * 0.7 * (1 + after * 1.2),
          ),
          ripple,
        );
      }
    }
  }

  /// A gold coin with rim, shine and a ₹ mark. [squash] narrows it to fake
  /// the flip; [opacity] fades it.
  void _coin(Canvas canvas, Offset c, double r, double squash, double opacity) {
    if (opacity <= 0) return;
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.scale(squash, 1);
    final rect = Rect.fromCircle(center: Offset.zero, radius: r);
    canvas.drawCircle(
      Offset.zero,
      r,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.3),
          colors: [
            Color.lerp(
              coinColor,
              Colors.white,
              0.45,
            )!.withValues(alpha: opacity),
            coinColor.withValues(alpha: opacity),
            Color.lerp(
              coinColor,
              Colors.brown,
              0.45,
            )!.withValues(alpha: opacity),
          ],
          stops: const [0, 0.55, 1],
        ).createShader(rect),
    );
    canvas.drawCircle(
      Offset.zero,
      r * 0.78,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.1
        ..color = Color.lerp(
          coinColor,
          Colors.brown,
          0.35,
        )!.withValues(alpha: 0.8 * opacity),
    );
    if (squash > 0.45) {
      final tp = TextPainter(
        text: TextSpan(
          text: '₹',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: r * 1.05,
            fontWeight: FontWeight.w700,
            color: Color.lerp(
              coinColor,
              Colors.brown,
              0.6,
            )!.withValues(alpha: opacity),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(CoinRainPainter old) =>
      old.t != t || old.coinColor != coinColor;
}
