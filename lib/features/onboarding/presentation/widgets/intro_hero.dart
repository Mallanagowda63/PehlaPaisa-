import 'package:flutter/material.dart';

import '../../../../app/l10n.dart';
import '../../../../app/theme.dart';
import '../../../../core/constants.dart';
import '../../../jars/presentation/widgets/glass_jar.dart';
import 'coin_drop.dart';

/// The welcome hero: a glowing shelf where ₹ coins drop one by one into the
/// Savings glass (filling it), next to an everyday glass and the Fun glass.
/// Tap the Savings glass to drop the coins again.
class IntroHero extends StatefulWidget {
  const IntroHero({super.key, required this.height});

  final double height;

  @override
  State<IntroHero> createState() => _IntroHeroState();
}

class _IntroHeroState extends State<IntroHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3200),
  );
  static const _timeline = CoinDropTimeline();

  void _replay() {
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (!reduce) _c.forward(from: 0);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduce) {
      _c.value = 1;
    } else if (!_c.isAnimating && _c.value == 0) {
      _c.forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final pp = context.pp;
    final t = Theme.of(context).textTheme;
    // Fit both the height and the width: three glasses (0.77 wide per unit
    // of height; the side ones are 68% size) + label margins + gaps.
    final maxWidth = MediaQuery.sizeOf(context).width - 40;
    final byWidth = (maxWidth - 64) / (0.77 * (1 + 2 * 0.68));
    final big = (widget.height * 0.62).clamp(90.0, 190.0).clamp(0.0, byWidth);
    final small = big * 0.68;

    Widget glass({
      required double level,
      required Color color,
      Color? glow,
      required double h,
      required String label,
      double pour = 0,
      bool animate = true,
    }) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GlassJar(
          level: level,
          color: color,
          glow: glow,
          width: h * 0.77,
          height: h,
          pour: pour,
          animateLevel: animate,
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: h * 0.77 + 12,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(label, style: t.labelMedium?.copyWith(color: pp.muted)),
          ),
        ),
      ],
    );

    return ExcludeSemantics(
      child: SizedBox(
        height: widget.height,
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            // Map the controller onto the coin timeline's own length.
            final p = _c.value * _timeline.end;
            return Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // Warm spotlight behind the shelf.
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(0, 0.2),
                        radius: 0.75,
                        colors: [
                          pp.savings.withValues(alpha: 0.22),
                          pp.savings.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 8,
                  right: 8,
                  bottom: 22,
                  child: _Plank(color: pp.plank, glow: pp.shelfGlow),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      glass(
                        level: 0.55,
                        color: pp.jar,
                        h: small,
                        label: l.jarFood,
                      ),
                      const SizedBox(width: 14),
                      GestureDetector(
                        key: const Key('intro_savings_glass'),
                        onTap: _replay,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            glass(
                              level: _timeline.level(p),
                              color: pp.savings,
                              h: big,
                              label: l.jarSavings,
                              animate: false,
                            ),
                            // Coins fall from above the glass into it.
                            Positioned(
                              left: 0,
                              top: -big * 0.55,
                              width: big * 0.77,
                              height: big * 1.55,
                              child: IgnorePointer(
                                child: CustomPaint(
                                  painter: CoinRainPainter(
                                    t: p,
                                    timeline: _timeline,
                                    glassHeight: big,
                                    dropHeight: big * 0.55,
                                    coinColor: PPColors.savingsAmber,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      glass(
                        level: 0.35,
                        color: pp.fun,
                        glow: PPColors.funPurple,
                        h: small,
                        label: l.jarFun,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Plank extends StatelessWidget {
  const _Plank({required this.color, required this.glow});

  final Color color;
  final Color glow;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 12,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(color, Colors.white, 0.25)!,
            Color.lerp(color, Colors.black, 0.3)!,
          ],
        ),
        boxShadow: [BoxShadow(color: glow, blurRadius: 30, spreadRadius: 2)],
      ),
    );
  }
}

/// One "why" card on the welcome screen.
class IntroFeature extends StatelessWidget {
  const IntroFeature({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer
            .withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.16),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: t.titleSmall),
                const SizedBox(height: 2),
                Text(body, style: t.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
