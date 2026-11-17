import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/l10n.dart';
import '../../../app/router.dart';
import '../../../app/state/budget_controller.dart';
import '../../../app/theme.dart';
import '../../../core/money.dart';
import '../../../core/widgets/shelf_background.dart';
import '../../share/domain/share_card_data.dart';
import '../data/badge.dart';
import 'badge_texts.dart';

/// Level card with progress to the next level, then the badge grid.
class BadgesScreen extends ConsumerWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final t = Theme.of(context).textTheme;
    final pp = context.pp;
    final s = ref.watch(budgetProvider);
    final level = s.level;
    final unlocked = s.badges;
    final locale = Localizations.localeOf(context).toString();

    return Scaffold(
      appBar: AppBar(title: Text(l.badgesTitle)),
      body: ShelfBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          children: [
            Card(
              color: pp.savings.withValues(alpha: 0.14),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.levelTitle, style: t.labelMedium),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          levelEmoji[level.level]!,
                          style: const TextStyle(fontSize: 34),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            levelName(l, level.level),
                            style: t.headlineSmall,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l.homeTotalSaved(formatRupees(s.totalSaved)),
                      style: t.bodyMedium?.copyWith(color: pp.savings),
                    ),
                    const SizedBox(height: 10),
                    Semantics(
                      value: '${(level.progress * 100).round()}%',
                      child: LinearProgressIndicator(
                        value: level.progress,
                        minHeight: 10,
                        borderRadius: BorderRadius.circular(5),
                        color: pp.savings,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      level.next == null
                          ? l.levelMax
                          : l.levelToNext(
                              formatRupees(level.toNext),
                              levelName(l, level.next!),
                            ),
                      style: t.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l.badgesCount(unlocked.length, BadgeKey.values.length),
              style: t.titleMedium,
            ),
            const SizedBox(height: 10),
            LayoutBuilder(
              builder: (context, c) {
                final cols = c.maxWidth > 520 ? 3 : 2;
                final w = (c.maxWidth - (cols - 1) * 10) / cols;
                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final k in BadgeKey.values)
                      SizedBox(
                        width: w,
                        child: _BadgeTile(
                          badge: k,
                          unlockedAt: unlocked[k],
                          locale: locale,
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({
    required this.badge,
    required this.unlockedAt,
    required this.locale,
  });

  final BadgeKey badge;
  final DateTime? unlockedAt;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = Theme.of(context).textTheme;
    final pp = context.pp;
    final on = unlockedAt != null;
    final name = badgeName(l, badge);
    final status = on
        ? l.badgeUnlockedOn(DateFormat.yMMMd(locale).format(unlockedAt!))
        : l.badgeLocked;

    return Semantics(
      label: '$name. ${badgeDescription(l, badge)}. $status',
      button: on,
      excludeSemantics: true,
      child: Card(
        color: on ? pp.savings.withValues(alpha: 0.12) : null,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: on
              ? () => context.push(
                  Routes.share,
                  extra: ShareCardData.badge(badge),
                )
              : null,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Opacity(
                      opacity: on ? 1 : 0.3,
                      child: Container(
                        width: 64,
                        height: 64,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: on
                              ? pp.savings.withValues(alpha: 0.25)
                              : Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                          boxShadow: on
                              ? [
                                  BoxShadow(
                                    color: pp.savings.withValues(alpha: 0.4),
                                    blurRadius: 18,
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          badgeEmoji[badge]!,
                          style: const TextStyle(fontSize: 30),
                        ),
                      ),
                    ),
                    if (!on) Icon(Icons.lock, size: 20, color: pp.muted),
                  ],
                ),
                const SizedBox(height: 8),
                Text(name, style: t.titleSmall, textAlign: TextAlign.center),
                const SizedBox(height: 2),
                Text(
                  badgeDescription(l, badge),
                  style: t.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: t.labelSmall?.copyWith(color: on ? pp.savings : null),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
