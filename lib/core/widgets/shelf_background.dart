import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// The warm "softly lit night shelf" backdrop: a deep gradient with a warm
/// light glowing from the top.
class ShelfBackground extends StatelessWidget {
  const ShelfBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final pp = context.pp;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [pp.shelfTop, pp.shelfBottom],
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -1.1),
            radius: 1.1,
            colors: [pp.shelfGlow, pp.shelfGlow.withValues(alpha: 0)],
          ),
        ),
        child: child,
      ),
    );
  }
}

/// A glowing wooden plank the glasses stand on.
class ShelfPlank extends StatelessWidget {
  const ShelfPlank({super.key});

  @override
  Widget build(BuildContext context) {
    final pp = context.pp;
    return Container(
      height: 14,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(pp.plank, Colors.white, 0.18)!,
            pp.plank,
            Color.lerp(pp.plank, Colors.black, 0.35)!,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: pp.shelfGlow,
            blurRadius: 24,
            spreadRadius: 1,
            offset: const Offset(0, -6),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
    );
  }
}
