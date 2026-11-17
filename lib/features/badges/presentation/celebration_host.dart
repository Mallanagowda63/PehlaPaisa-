import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/l10n.dart';
import '../../../app/router.dart';
import '../../../app/theme.dart';
import '../../../core/money.dart';
import '../../jars/presentation/widgets/glass_jar.dart';
import '../../share/domain/share_card_data.dart';
import '../data/badge.dart';
import '../domain/celebration.dart';
import 'badge_texts.dart';
import 'celebration_queue.dart';

/// Wraps the app and shows queued celebrations one at a time as a
/// full-screen modal with confetti, haptics and a Share button.
class CelebrationHost extends ConsumerStatefulWidget {
  const CelebrationHost({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<CelebrationHost> createState() => _CelebrationHostState();
}

class _CelebrationHostState extends ConsumerState<CelebrationHost> {
  bool _showing = false;

  Future<void> _show(Celebration c) async {
    final nav = rootNavigatorKey.currentState;
    if (_showing || nav == null) return;
    _showing = true;
    HapticFeedback.heavyImpact();
    final share = await nav.push<ShareCardData>(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black54,
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, _, _) => _CelebrationPage(celebration: c),
        transitionsBuilder: (_, a, _, child) => FadeTransition(
          opacity: a,
          child: ScaleTransition(
            scale: Tween(begin: 0.92, end: 1.0).animate(a),
            child: child,
          ),
        ),
      ),
    );
    _showing = false;
    ref.read(celebrationQueueProvider.notifier).pop();
    if (share != null) {
      await ref.read(routerProvider).push(Routes.share, extra: share);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<CelebrationQueueState>(celebrationQueueProvider, (_, next) {
      final c = next.next;
      if (c != null && !_showing) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _show(c));
      }
    });
    return widget.child;
  }
}

class _CelebrationPage extends StatefulWidget {
  const _CelebrationPage({required this.celebration});

  final Celebration celebration;

  @override
  State<_CelebrationPage> createState() => _CelebrationPageState();
}

class _CelebrationPageState extends State<_CelebrationPage> {
  final _confetti = ConfettiController(duration: const Duration(seconds: 2));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Respect "reduce motion" (the confetti package animates by wall clock).
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (!reduce && _confetti.state != ConfettiControllerState.playing) {
      _confetti.play();
    }
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = Theme.of(context).textTheme;
    final pp = context.pp;
    final c = widget.celebration;

    late final String title;
    late final String body;
    late final Widget hero;
    ShareCardData? share;

    switch (c.kind) {
      case CelebrationKind.badge:
        title = l.celebrateBadge;
        body = '${badgeName(l, c.badge!)}\n${badgeDescription(l, c.badge!)}';
        hero = Text(
          badgeEmoji[c.badge!]!,
          style: const TextStyle(fontSize: 72),
        );
        share = ShareCardData.badge(c.badge!);
      case CelebrationKind.goal:
        title = l.celebrateGoal;
        body = l.celebrateGoalBody('${c.goalEmoji} ${c.goalName}');
        hero = GlassJar(level: 1, color: pp.success, width: 100, height: 130);
        share = ShareCardData.goal(
          name: c.goalName!,
          emoji: c.goalEmoji!,
          amount: c.amount!,
        );
      case CelebrationKind.streak:
        title = l.celebrateStreak;
        body = l.streakLong(c.streak!);
        hero = const Text('🔥', style: TextStyle(fontSize: 72));
        share = ShareCardData.streak(c.streak!);
      case CelebrationKind.savingsFilled:
        title = l.celebrateSavings;
        body = l.salaryDoneBody(formatRupees(c.amount ?? 0));
        hero = GlassJar(level: 1, color: pp.savings, width: 100, height: 130);
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Material(
              color: Theme.of(context).dialogTheme.backgroundColor,
              borderRadius: BorderRadius.circular(28),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        title,
                        style: t.headlineSmall?.copyWith(color: pp.savings),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 18),
                    ExcludeSemantics(child: hero),
                    const SizedBox(height: 18),
                    Text(body, style: t.bodyLarge, textAlign: TextAlign.center),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        key: const Key('celebrate_continue'),
                        onPressed: () => Navigator.pop(context),
                        child: Text(l.celebrateContinue),
                      ),
                    ),
                    if (share != null) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.pop(context, share),
                          icon: const Icon(Icons.ios_share),
                          label: Text(l.commonShare),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confetti,
            blastDirectionality: BlastDirectionality.explosive,
            numberOfParticles: 30,
            gravity: 0.2,
            colors: [pp.savings, pp.jar, pp.fun, pp.success],
          ),
        ),
      ],
    );
  }
}
