import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../../../core/widgets/dialogs.dart';
import '../../../core/widgets/shelf_background.dart';
import '../../jars/presentation/widgets/glass_jar.dart';
import '../../share/domain/share_card_data.dart';
import '../data/goal.dart';
import '../domain/goal_logic.dart';
import 'goal_form_sheet.dart';
import '../../../core/widgets/insets.dart';

/// Goals as glasses filling up, funded from free savings.
class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final t = Theme.of(context).textTheme;
    final pp = context.pp;
    final s = ref.watch(budgetProvider);
    final income = s.profile?.monthlyIncome ?? 0;
    final emergency = GoalLogic.suggestedEmergencyFund(
      monthlyIncome: income,
      monthlySavings: s.monthlySavingsPlan,
    );

    return Scaffold(
      appBar: AppBar(title: Text(l.goalsTitle)),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('goal_add'),
        onPressed: () => showGoalForm(context),
        icon: const Icon(Icons.add),
        label: Text(l.goalAdd),
      ),
      body: ShelfBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          children: [
            Card(
              color: pp.savings.withValues(alpha: 0.14),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Text('🪙', style: TextStyle(fontSize: 30)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l.goalsFree, style: t.titleSmall),
                          Text(l.goalsFreeHelp, style: t.bodySmall),
                        ],
                      ),
                    ),
                    Text(
                      formatRupees(s.availableForGoals),
                      style: t.headlineSmall?.copyWith(color: pp.savings),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (s.goals.isEmpty) ...[
              Text(l.goalsEmpty, style: t.bodyLarge),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('🛟 ${l.goalsSuggestTitle}', style: t.titleMedium),
                      const SizedBox(height: 6),
                      Text(l.goalsSuggestBody(formatRupees(emergency))),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => ref
                            .read(budgetProvider.notifier)
                            .addGoal(
                              name: l.goalEmergencyName,
                              emoji: '🛟',
                              targetAmount: emergency,
                            ),
                        child: Text(l.goalsSuggestButton),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            LayoutBuilder(
              builder: (context, c) {
                final cols = c.maxWidth > 520 ? 3 : 2;
                final w = (c.maxWidth - (cols - 1) * 10) / cols;
                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final g in s.goals)
                      SizedBox(
                        width: w,
                        child: _GoalTile(goal: g, state: s),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            const AdSpot(AdSlot.goalsNative),
          ],
        ),
      ),
    );
  }
}

String _estimate(AppLocalizations l, Goal g, BudgetState s, String locale) {
  if (g.isComplete) return l.goalReached;
  final rate = s.monthlySavingsPlan;
  final months = GoalLogic.monthsToReach(
    remaining: g.remaining,
    monthlyRate: rate,
  );
  final base = months == null
      ? l.goalEstimateNone
      : l.goalEstimate(formatRupees(rate), months);
  if (g.targetDate == null) return base;
  final need = GoalLogic.requiredMonthly(
    remaining: g.remaining,
    targetDate: g.targetDate!,
    now: s.now,
  );
  if (need == null) return base;
  return '$base\n${l.goalNeedPerMonth(formatRupees(need), DateFormat.yMMM(locale).format(g.targetDate!))}';
}

class _GoalTile extends StatelessWidget {
  const _GoalTile({required this.goal, required this.state});

  final Goal goal;
  final BudgetState state;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = Theme.of(context).textTheme;
    final pp = context.pp;
    final color = goal.isComplete ? pp.success : pp.savings;
    final percent = (goal.progress * 100).round();
    return Semantics(
      button: true,
      label:
          '${goal.name}, ${l.goalProgress(formatRupees(goal.savedAmount), formatRupees(goal.targetAmount))}, ${l.goalPercent(percent)}',
      excludeSemantics: true,
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            useRootNavigator: true,
            useSafeArea: true,
            builder: (_) => _GoalSheet(goalId: goal.id),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                GlassJar(
                  level: goal.progress,
                  color: color,
                  width: 70,
                  height: 92,
                ),
                const SizedBox(height: 8),
                Text(
                  '${goal.emoji} ${goal.name}',
                  style: t.titleSmall,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  l.goalProgress(
                    formatRupees(goal.savedAmount),
                    formatRupees(goal.targetAmount),
                  ),
                  style: t.bodySmall,
                  textAlign: TextAlign.center,
                ),
                Text(
                  goal.isComplete ? l.goalReached : l.goalPercent(percent),
                  style: t.labelMedium?.copyWith(color: color),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Goal details: move money in/out, edit, delete, share when done.
class _GoalSheet extends ConsumerWidget {
  const _GoalSheet({required this.goalId});

  final String goalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final t = Theme.of(context).textTheme;
    final pp = context.pp;
    final s = ref.watch(budgetProvider);
    final goal = s.goalById(goalId);
    if (goal == null) return const SizedBox(height: 80);
    final locale = Localizations.localeOf(context).toString();
    final color = goal.isComplete ? pp.success : pp.savings;
    final c = ref.read(budgetProvider.notifier);

    Future<void> addMoney() async {
      if (s.availableForGoals <= 0) {
        showSnack(context, l.goalNoFreeSavings);
        return;
      }
      final max = s.availableForGoals < goal.remaining
          ? s.availableForGoals
          : goal.remaining;
      final v = await askAmount(
        context,
        title: l.goalMoveTitle(goal.name),
        helper: l.moveAvailable(formatRupees(max)),
        max: max,
        confirmLabel: l.moveButton,
      );
      if (v == null) return;
      final moved = await c.depositToGoal(goal.id, v);
      HapticFeedback.lightImpact();
      if (context.mounted && moved > 0) {
        showSnack(context, l.goalMoved(formatRupees(moved), goal.name));
      }
    }

    Future<void> takeBack() async {
      final v = await askAmount(
        context,
        title: l.goalTakeBackTitle(goal.name),
        helper: l.moveAvailable(formatRupees(goal.savedAmount)),
        max: goal.savedAmount,
        confirmLabel: l.goalTakeBack,
      );
      if (v != null) await c.withdrawFromGoal(goal.id, v);
    }

    Future<void> delete() async {
      final ok = await confirmDialog(
        context,
        title: l.goalDeleteTitle,
        body: l.goalDeleteBody,
        confirmLabel: l.commonDelete,
        destructive: true,
      );
      if (!ok) return;
      await c.deleteGoal(goal.id);
      if (context.mounted) Navigator.pop(context);
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, safeBottom(context) + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${goal.emoji} ${goal.name}', style: t.titleLarge),
            const SizedBox(height: 12),
            GlassJar(
              level: goal.progress,
              color: color,
              width: 120,
              height: 156,
            ),
            const SizedBox(height: 12),
            Text(
              l.goalProgress(
                formatRupees(goal.savedAmount),
                formatRupees(goal.targetAmount),
              ),
              style: t.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              _estimate(l, goal, s, locale),
              textAlign: TextAlign.center,
              style: t.bodyMedium?.copyWith(color: pp.muted),
            ),
            const SizedBox(height: 16),
            if (!goal.isComplete)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: const Key('goal_add_money'),
                  onPressed: addMoney,
                  icon: const Icon(Icons.add),
                  label: Text(l.goalAddMoney),
                ),
              ),
            if (goal.isComplete)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    context.push(
                      Routes.share,
                      extra: ShareCardData.goal(
                        name: goal.name,
                        emoji: goal.emoji,
                        amount: goal.targetAmount,
                      ),
                    );
                  },
                  icon: const Icon(Icons.ios_share),
                  label: Text(l.commonShare),
                ),
              ),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              children: [
                if (goal.savedAmount > 0)
                  TextButton(onPressed: takeBack, child: Text(l.goalTakeBack)),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    showGoalForm(context, existing: goal);
                  },
                  child: Text(l.commonEdit),
                ),
                TextButton(
                  style: TextButton.styleFrom(foregroundColor: pp.danger),
                  onPressed: delete,
                  child: Text(l.commonDelete),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
