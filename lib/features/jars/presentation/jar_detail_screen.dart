import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/l10n.dart';
import '../../../app/router.dart';
import '../../../app/state/budget_controller.dart';
import '../../../app/state/budget_state.dart';
import '../../../app/theme.dart';
import '../../../core/dates.dart';
import '../../../core/money.dart';
import '../../../core/widgets/dialogs.dart';
import '../../../core/widgets/shelf_background.dart';
import '../../alerts/domain/alert_engine.dart';
import '../../transactions/data/transaction.dart';
import '../../transactions/presentation/add_expense_sheet.dart';
import '../data/jar.dart';
import 'jar_labels.dart';
import 'move_money_sheet.dart';
import 'widgets/glass_jar.dart';
import '../../../core/widgets/insets.dart';

/// One glass up close: allocation, spending, weekly limit (Food) and this
/// month's history grouped by day.
class JarDetailScreen extends ConsumerWidget {
  const JarDetailScreen({super.key, required this.jarId});

  final String jarId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final t = Theme.of(context).textTheme;
    final pp = context.pp;
    final s = ref.watch(budgetProvider);
    final jar = s.jarById(jarId);
    if (jar == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l.jarGone)),
      );
    }
    final family = s.profile?.livesWithFamily ?? false;
    final name = jarName(l, jar.type, jar.name, family: family);
    final color = jarColor(context, jar.type, colorHex: jar.colorHex);
    final txns = s.cycleTransactions
        .where((x) => x.jarId == jar.id || x.toJarId == jar.id)
        .where((x) => x.type != TransactionType.income)
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text('${jar.emoji} $name')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAddExpenseSheet(context, ref, jarId: jar.id),
        icon: const Icon(Icons.add),
        label: Text(l.homeAddExpense),
      ),
      body: ShelfBackground(
        child: ListView(
          padding: EdgeInsets.fromLTRB(16, 8, 16, safeBottom(context) + 100),
          children: [
            Center(
              child: Semantics(
                label: glassSemantics(
                  l,
                  name,
                  jar.remaining,
                  jar.allocatedAmount,
                ),
                excludeSemantics: true,
                child: GlassJar(
                  level: jar.fillRatio,
                  color: color,
                  glow: jarGlow(context, jar.type, colorHex: jar.colorHex),
                  width: 150,
                  height: 195,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _Stat(label: l.jarAllocated, value: jar.allocatedAmount),
                _Stat(label: l.jarSpent, value: jar.spentAmount),
                _Stat(
                  label: l.jarRemaining,
                  value: jar.remaining,
                  color: jar.remaining < 0 ? pp.danger : color,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (!jar.isSavings && !s.needsFunding)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: FilledButton.icon(
                  key: const Key('jar_scan_pay'),
                  onPressed: () => context.push(Routes.pay(jar.id)),
                  icon: const Icon(Icons.currency_rupee),
                  label: Text(l.payScan),
                ),
              ),
            if (jar.isSavings) _InfoCard(icon: '🛡️', text: l.jarSavingsInfo),
            if (AlertEngine.hasWeeklyLimit(jar))
              _FoodWeekCard(state: s, jar: jar),
            if (jar.allocatedAmount > 0)
              OutlinedButton.icon(
                key: const Key('jar_move'),
                onPressed: () => showMoveMoneySheet(context, toId: jar.id),
                icon: const Icon(Icons.swap_horiz),
                label: Text(l.jarMoveMoney),
              ),
            const SizedBox(height: 16),
            Text(l.jarHistory, style: t.titleMedium),
            const SizedBox(height: 8),
            if (txns.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  l.jarNoTransactions,
                  textAlign: TextAlign.center,
                  style: t.bodyMedium?.copyWith(color: pp.muted),
                ),
              )
            else
              ..._grouped(context, ref, s, jar, txns),
          ],
        ),
      ),
    );
  }

  List<Widget> _grouped(
    BuildContext context,
    WidgetRef ref,
    BudgetState s,
    Jar jar,
    List<Transaction> txns,
  ) {
    final l = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final out = <Widget>[];
    DateTime? day;
    for (final x in txns) {
      final d = dateOnly(x.dateTime);
      if (day == null || d != day) {
        day = d;
        final label = isSameDay(d, s.now)
            ? l.commonToday
            : isSameDay(d, s.now.subtract(const Duration(days: 1)))
            ? l.commonYesterday
            : DateFormat.MMMEd(locale).format(d);
        out.add(
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Text(label, style: Theme.of(context).textTheme.labelMedium),
          ),
        );
      }
      out.add(_TxnTile(txn: x, jar: jar, state: s));
    }
    return out;
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, this.color});

  final String label;
  final int value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Expanded(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            children: [
              Text(label, style: t.bodySmall, textAlign: TextAlign.center),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  formatRupees(value),
                  style: t.titleMedium?.copyWith(color: color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.icon, required this.text});

  final String icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        color: context.pp.savings.withValues(alpha: 0.12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(child: Text(text)),
            ],
          ),
        ),
      ),
    );
  }
}

class _FoodWeekCard extends StatelessWidget {
  const _FoodWeekCard({required this.state, required this.jar});

  final BudgetState state;
  final Jar jar;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = Theme.of(context).textTheme;
    final pp = context.pp;
    final range = state.range;
    if (range == null || jar.allocatedAmount <= 0) return const SizedBox();
    final limit = AlertEngine.weeklyFoodLimit(jar.allocatedAmount, range);
    final spent = AlertEngine.spentInCycleWeek(
      state.cycleTransactions,
      jar.id,
      range,
      state.now,
    );
    final ratio = limit <= 0 ? 0.0 : (spent / limit).clamp(0.0, 1.0);
    final over = spent > limit;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      jar.type == JarType.food
                          ? l.jarWeeklyLimit
                          : l.weeklyLimitTitleFor(
                              jarName(
                                l,
                                jar.type,
                                jar.name,
                                family: state.profile?.livesWithFamily ?? false,
                              ),
                            ),
                      style: t.titleSmall,
                    ),
                  ),
                  Text(formatRupees(limit), style: t.titleSmall),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: ratio,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
                color: over ? pp.warning : pp.success,
              ),
              const SizedBox(height: 6),
              Text(
                l.jarWeeklyProgress(formatRupees(spent), formatRupees(limit)),
                style: t.bodySmall?.copyWith(color: over ? pp.warning : null),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TxnTile extends ConsumerWidget {
  const _TxnTile({required this.txn, required this.jar, required this.state});

  final Transaction txn;
  final Jar jar;
  final BudgetState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final pp = context.pp;
    final family = state.profile?.livesWithFamily ?? false;
    String nameOf(String id) {
      final j = state.jarById(id);
      return j == null ? '' : jarName(l, j.type, j.name, family: family);
    }

    late final String title;
    late final String amountText;
    Color? amountColor;
    if (txn.type == TransactionType.expense) {
      title = txn.note.isEmpty ? l.txnExpense : txn.note;
      amountText = '−${formatRupees(txn.amount)}';
    } else if (txn.goalId != null) {
      title = l.txnToGoal(state.goalById(txn.goalId!)?.name ?? txn.note);
      amountText = formatRupees(txn.amount);
      amountColor = pp.savings;
    } else if (txn.toJarId == jar.id) {
      title = l.txnBorrowedFrom(nameOf(txn.jarId));
      amountText = '+${formatRupees(txn.amount)}';
      amountColor = pp.success;
    } else {
      title = l.txnLentTo(nameOf(txn.toJarId ?? ''));
      amountText = '−${formatRupees(txn.amount)}';
      amountColor = pp.warning;
    }
    final time = DateFormat.jm(Localizations.localeOf(context).toString())
        .format(txn.dateTime);

    final tile = Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        title: Text(title),
        subtitle: Text(time),
        trailing: Text(
          amountText,
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(color: amountColor),
        ),
      ),
    );
    if (txn.type != TransactionType.expense) return tile;

    return Dismissible(
      key: ValueKey(txn.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: pp.danger.withValues(alpha: 0.25),
        child: Icon(Icons.delete_outline, color: pp.danger),
      ),
      confirmDismiss: (_) => confirmDialog(
        context,
        title: l.deleteExpenseTitle,
        body: l.deleteExpenseBody(
          formatRupees(txn.amount),
          jarName(l, jar.type, jar.name, family: family),
        ),
        confirmLabel: l.commonDelete,
        destructive: true,
      ),
      onDismissed: (_) =>
          ref.read(budgetProvider.notifier).deleteExpense(txn.id),
      child: tile,
    );
  }
}
