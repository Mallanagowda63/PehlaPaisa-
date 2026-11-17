import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants.dart';
import 'liquid_glass_painter.dart';

/// An animated glass of liquid.
///
/// The surface waves continuously (unless the platform asks to reduce
/// motion), and any change to [level] animates smoothly over 800 ms with
/// easeOutCubic so spending visibly drains the glass.
class GlassJar extends StatefulWidget {
  const GlassJar({
    super.key,
    required this.level,
    required this.color,
    this.glow,
    this.width = 90,
    this.height = 120,
    this.pour = 0,
    this.glowStrength = 1,
    this.fillFromEmpty = true,
    this.animateLevel = true,
  });

  final double level;
  final Color color;
  final Color? glow;
  final double width;
  final double height;

  /// 0..1 progress of a pour animation (0 = no stream).
  final double pour;
  final double glowStrength;

  /// Animate from empty on first build (a nice "filling" entrance).
  final bool fillFromEmpty;

  /// When false, [level] is painted as-is (the caller animates it).
  final bool animateLevel;

  @override
  State<GlassJar> createState() => _GlassJarState();
}

class _GlassJarState extends State<GlassJar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _wave = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3200),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Respect "reduce motion" (and keeps widget tests settle-able).
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduce) {
      _wave.stop();
    } else if (!_wave.isAnimating) {
      _wave.repeat();
    }
  }

  @override
  void dispose() {
    _wave.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final outline = context.pp.glassOutline;
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    Widget paint(double level) => AnimatedBuilder(
      animation: _wave,
      builder: (context, _) => CustomPaint(
        size: Size(widget.width, widget.height),
        painter: LiquidGlassPainter(
          level: level,
          phase: _wave.value,
          color: widget.color,
          glow: widget.glow ?? widget.color,
          outline: outline,
          pour: widget.pour,
          glowStrength: widget.glowStrength,
        ),
      ),
    );
    if (!widget.animateLevel) {
      return RepaintBoundary(child: paint(widget.level));
    }
    return RepaintBoundary(
      child: TweenAnimationBuilder<double>(
        tween: Tween(
          begin: widget.fillFromEmpty && !reduce ? 0 : widget.level,
          end: widget.level,
        ),
        duration: reduce ? Duration.zero : PPMotion.level,
        curve: PPMotion.levelCurve,
        builder: (context, level, _) => paint(level),
      ),
    );
  }
}
