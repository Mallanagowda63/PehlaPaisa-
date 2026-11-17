import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/l10n.dart';
import '../../../app/router.dart';
import '../../../app/state/budget_controller.dart';
import '../../../app/state/budget_state.dart';
import '../../../app/theme.dart';
import '../../../core/money.dart';
import '../../ads/ads.dart';
import '../../../core/widgets/shelf_background.dart';
import '../../alerts/domain/alert_engine.dart';
import '../../settings/presentation/settings_controller.dart';
import '../../share/domain/share_card_data.dart';
import '../../transactions/presentation/add_expense_sheet.dart';
import '../data/jar.dart';
import 'jar_labels.dart';
import 'widgets/jar_tile.dart';

/// The hero screen: glowing glasses on a softly lit night shelf.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final t = Theme.of(context).textTheme;
    final pp = context.pp;
    final s = ref.watch(budgetProvider);
    final range = s.range;
    final locale = Localizations.localeOf(context).toString();
    final family = s.profile?.livesWithFamily ?? false;
    final irregular = s.profile?.isIrregular ?? false;
    final streak = s.streak.current;

    final savings = s.jars.where((j) => j.isSavings).firstOrNull;
    final dismissed = ref.watch(settingsProvider).dismissedAlerts.toSet();
    final others = s.jars.where((j) => !j.isSavings).toList();

    return Scaffold(
      floatingActionButton: FloatingActionButton.large(
        key: const Key('home_add_expense'),
        tooltip: l.homeAddExpense,
        shape: const CircleBorder(),
        onPressed: () => showAddExpenseSheet(context, ref),
        child: const Icon(Icons.add, size: 36),
      ),
      body: ShelfBackground(
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
            children: [
              // Month + streak + share.
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (range != null)
                          Text(
                            DateFormat.yMMMM(locale).format(range.start),
                            style: t.titleLarge,
                          ),
                        if (range != null)
                          Text(
                            l.homeDaysLeft(range.daysLeft(s.now)),
                            style: t.bodySmall,
                          ),
                        if (range != null)
                          Text(
                            l.nextSalaryOn(
                              DateFormat.yMMMd(locale).format(range.nextStart),
                            ),
                            style: t.labelMedium?.copyWith(color: pp.savings),
                          ),
                      ],
                    ),
                  ),
                  Semantics(
                    label: l.streakLong(streak),
                    excludeSemantics: true,
                    child: ActionChip(
                      key: const Key('streak_chip'),
                      label: Text(l.streakChip(streak)),
                      backgroundColor: pp.savings.withValues(alpha: 0.15),
                      side: BorderSide(
                        color: pp.savings.withValues(alpha: 0.5),
                      ),
                      onPressed: () => context.go(Routes.badges),
                    ),
                  ),
                  IconButton(
                    tooltip: l.homeShare,
                    icon: const Icon(Icons.ios_share),
                    onPressed: () => context.push(
                      Routes.share,
                      extra: ShareCardData.streak(streak),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Total left to spend.
              Semantics(
                container: true,
                child: Column(
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        formatRupees(s.leftToSpend),
                        style: t.displayMedium,
                      ),
                    ),
                    Text(l.homeLeftToSpend, style: t.bodyMedium),
                    const SizedBox(height: 4),
                    Text(
                      l.streakLong(streak),
                      textAlign: TextAlign.center,
                      style: t.labelMedium?.copyWith(color: pp.savings),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              if (s.needsFunding || irregular) _FundingBanner(state: s),
              for (final a in s.alerts.where(
                (a) =>
                    a.kind != AlertKind.fillSalary &&
                    !dismissed.contains(a.key(s.activeCycle!.id)),
              ))
                _AlertCard(
                  key: ValueKey(a.key(s.activeCycle!.id)),
                  alert: a,
                  state: s,
                  onClose: () => _dismissAlert(ref, s, a),
                ),

              const SizedBox(height: 12),
              // Shelves.
              LayoutBuilder(
                builder: (context, c) {
                  final rows = _rowsFor(others);
                  final perRow = rows.map((r) => r.length).fold(1, math.max);
                  // A tile is its glass width + 28 (label overhang, padding,
                  // selection border); leave a little air between tiles.
                  final w = math.min(96.0, c.maxWidth / perRow - 36);
                  return Column(
                    children: [
                      if (savings != null) ...[
                        JarTile(
                          key: const Key('glass_savings'),
                          jar: savings,
                          family: family,
                          width: math.min(124, c.maxWidth * 0.34),
                          onTap: () => context.push(Routes.jar(savings.id)),
                          onLongPress: () => showAddExpenseSheet(
                            context,
                            ref,
                            jarId: savings.id,
                          ),
                        ),
                        const ShelfPlank(),
                        const SizedBox(height: 20),
                      ],
                      for (final row in rows) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            for (final j in row)
                              JarTile(
                                key: Key('glass_${j.type.name}_${j.id}'),
                                jar: j,
                                family: family,
                                width: w,
                                onTap: () => context.push(Routes.jar(j.id)),
                                onLongPress: () => showAddExpenseSheet(
                                  context,
                                  ref,
                                  jarId: j.id,
                                ),
                              ),
                          ],
                        ),
                        const ShelfPlank(),
                        const SizedBox(height: 20),
                      ],
                    ],
                  );
                },
              ),
              if (!s.needsFunding) _WeeklyLimitsCard(state: s),
              const SizedBox(height: 8),
              _WeeklyCard(state: s),
              const SizedBox(height: 16),
              const AdSpot(AdSlot.shelfBanner),
            ],
          ),
        ),
      ),
    );
  }

  /// Hides a warning (✕). Only this month's hidden keys are kept.
  static Future<void> _dismissAlert(
    WidgetRef ref,
    BudgetState s,
    BudgetAlert a,
  ) {
    final cycleId = s.activeCycle!.id;
    return ref
        .read(settingsProvider.notifier)
        .update(
          (x) => x.copyWith(
            dismissedAlerts: [
              ...x.dismissedAlerts.where((k) => k.startsWith('$cycleId:')),
              a.key(cycleId),
            ],
          ),
        );
  }

  /// Glasses per shelf: 4 → 2+2, otherwise rows of 3.
  static List<List<Jar>> _rowsFor(List<Jar> jars) {
    if (jars.length == 4) return [jars.sublist(0, 2), jars.sublist(2)];
    final rows = <List<Jar>>[];
    for (var i = 0; i < jars.length; i += 3) {
      rows.add(jars.sublist(i, math.min(i + 3, jars.length)));
    }
    return rows;
  }
}

class _FundingBanner extends StatelessWidget {
  const _FundingBanner({required this.state});

  final BudgetState state;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = Theme.of(context).textTheme;
    final pp = context.pp;
    final needs = state.needsFunding;
    return Card(
      color: needs ? pp.savings.withValues(alpha: 0.18) : null,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                needs
                    ? l.homeFillBanner
                    : l.salaryReceivedSoFar(
                        formatRupees(state.activeCycle?.income ?? 0),
                      ),
                style: needs ? t.titleSmall : t.bodyMedium,
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              key: const Key('home_fill'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(48, 48),
                padding: const EdgeInsets.symmetric(horizontal: 14),
              ),
              onPressed: () => context.push(Routes.salary),
              child: Text(
                state.profile?.isIrregular ?? false
                    ? l.homeIncomeButton
                    : l.homeFillButton,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({
    super.key,
    required this.alert,
    required this.state,
    required this.onClose,
  });

  final BudgetAlert alert;
  final BudgetState state;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final pp = context.pp;
    final jar = alert.jarId == null ? null : state.jarById(alert.jarId!);
    final family = state.profile?.livesWithFamily ?? false;
    final name = jar == null
        ? ''
        : jarName(l, jar.type, jar.name, family: family);
    final text = alert.kind == AlertKind.lowJar
        ? l.alertLow(name, alert.percentEmpty, alert.daysLeft)
        : l.alertFoodWeekly(
            formatRupees(alert.spent),
            formatRupees(alert.limit),
          );
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Card(
        color: pp.warning.withValues(alpha: 0.14),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: jar == null ? null : () => context.push(Routes.jar(jar.id)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 6, 2, 6),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: pp.warning),
                const SizedBox(width: 10),
                Expanded(child: Text(text)),
                IconButton(
                  key: const Key('alert_close'),
                  tooltip: l.alertDismiss,
                  onPressed: onClose,
                  icon: Icon(Icons.close, size: 20, color: pp.muted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WeeklyCard extends StatelessWidget {
  const _WeeklyCard({required this.state});

  final BudgetState state;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = Theme.of(context).textTheme;
    final spent = AlertEngine.spentThisWeek(state.transactions, state.now);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Text('📅', style: TextStyle(fontSize: 26)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.weeklySummaryTitle, style: t.titleSmall),
                  Text(l.weeklySummaryBody(formatRupees(spent))),
                  const SizedBox(height: 4),
                  Text(
                    l.homeTotalSaved(formatRupees(state.totalSaved)),
                    style: t.labelMedium?.copyWith(color: context.pp.savings),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "This week's limits": every everyday glass's weekly budget and how much
/// of it has been spent this week.
class _WeeklyLimitsCard extends StatelessWidget {
  const _WeeklyLimitsCard({required this.state});

  final BudgetState state;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = Theme.of(context).textTheme;
    final pp = context.pp;
    final range = state.range;
    if (range == null) return const SizedBox.shrink();
    final limits = AlertEngine.weeklyLimits(
      jars: state.jars,
      cycleTransactions: state.cycleTransactions,
      range: range,
      now: state.now,
    );
    if (limits.isEmpty) return const SizedBox.shrink();
    final family = state.profile?.livesWithFamily ?? false;
    final rows = <Widget>[];
    for (final w in limits) {
      final jar = state.jarById(w.jarId);
      if (jar == null) continue;
      final name = jarName(l, jar.type, jar.name, family: family);
      rows.add(
        InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => context.push(Routes.jar(jar.id)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${jar.emoji} $name',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t.labelLarge,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l.weeklyLimitPerWeek(formatRupees(w.limit)),
                      style: t.labelLarge?.copyWith(
                        color: jarColor(
                          context,
                          jar.type,
                          colorHex: jar.colorHex,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                LinearProgressIndicator(
                  value: w.usedRatio,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                  color: w.isOver ? pp.warning : pp.success,
                ),
                const SizedBox(height: 3),
                Text(
                  w.isOver
                      ? l.weeklyLimitOver(
                          formatRupees(w.spent),
                          formatRupees(-w.left),
                        )
                      : l.weeklyLimitLeft(
                          formatRupees(w.spent),
                          formatRupees(w.left),
                        ),
                  style: t.bodySmall?.copyWith(
                    color: w.isOver ? pp.warning : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Card(
        key: const Key('weekly_limits'),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('📅 ${l.weeklyLimitsTitle}', style: t.titleSmall),
              const SizedBox(height: 2),
              Text(l.weeklyLimitsHint, style: t.bodySmall),
              const SizedBox(height: 8),
              ...rows,
            ],
          ),
        ),
      ),
    );
  }
}
