import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/l10n.dart';
import '../../../app/router.dart';
import '../../../app/state/budget_controller.dart';
import '../../../app/theme.dart';
import '../../../core/widgets/shelf_background.dart';
import '../../jars/presentation/widgets/glass_jar.dart';
import 'widgets/coin_drop.dart';

/// Logo + a glass filling up, then on to the right first screen.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fill = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..forward();
  Timer? _timer;

  /// A quick 4-coin drop (the intro screen uses the full 7-coin version).
  static const _coins = CoinDropTimeline(
    coins: 4,
    gap: 0.16,
    fall: 0.30,
    settle: 0.10,
    startLevel: 0.08,
    endLevel: 0.82,
  );

  /// A random money tip shown while the app loads.
  final int _tip = math.Random().nextInt(8);

  @override
  void initState() {
    super.initState();
    // Just long enough to see the glass fill; tap anywhere to skip.
    _timer = Timer(const Duration(milliseconds: 1450), _next);
  }

  String _tipText(AppLocalizations l) => [
    l.splashTip1,
    l.splashTip2,
    l.splashTip3,
    l.splashTip4,
    l.splashTip5,
    l.splashTip6,
    l.splashTip7,
    l.splashTip8,
  ][_tip];

  bool _left = false;

  void _next() {
    if (!mounted || _left) return;
    _left = true;
    _timer?.cancel();
    final s = ref.read(budgetProvider);
    if (!s.isOnboarded) {
      context.go(Routes.onboarding);
    } else if (s.needsFunding) {
      context.go(Routes.home);
      context.push(Routes.salary);
    } else {
      context.go(Routes.home);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _fill.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = Theme.of(context).textTheme;
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _next,
        child: ShelfBackground(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ₹ coins drop into the Savings glass and fill it.
                AnimatedBuilder(
                  animation: _fill,
                  builder: (context, _) {
                    final p = _fill.value * _coins.end;
                    return SizedBox(
                      width: 110,
                      height: 140,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          GlassJar(
                            level: _coins.level(p),
                            color: context.pp.savings,
                            width: 110,
                            height: 140,
                            fillFromEmpty: false,
                            animateLevel: false,
                          ),
                          Positioned(
                            left: 0,
                            top: -80,
                            width: 110,
                            height: 220,
                            child: CustomPaint(
                              painter: CoinRainPainter(
                                t: p,
                                timeline: _coins,
                                glassHeight: 140,
                                dropHeight: 80,
                                coinColor: context.pp.savings,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
                Text(l.appName, style: t.displaySmall),
                const SizedBox(height: 8),
                Text(
                  l.tagline,
                  style: t.titleMedium?.copyWith(color: context.pp.savings),
                ),
                const SizedBox(height: 40),
                // Money tip, faded in while the glass fills.
                FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _fill,
                    curve: const Interval(0, 0.5, curve: Curves.easeOut),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainer
                            .withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: context.pp.savings.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '💡 ${l.splashTipLabel}',
                            style: t.labelMedium?.copyWith(
                              color: context.pp.savings,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _tipText(l),
                            textAlign: TextAlign.center,
                            style: t.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
