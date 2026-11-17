import '../../jars/data/jar.dart';
import '../data/transaction.dart';

/// Money borrowed from one glass to cover another.
class Draw {
  const Draw(this.jarId, this.amount);

  final String jarId;
  final int amount;

  @override
  bool operator ==(Object other) =>
      other is Draw && other.jarId == jarId && other.amount == amount;

  @override
  int get hashCode => Object.hash(jarId, amount);

  @override
  String toString() => 'Draw($jarId, $amount)';
}

/// How an expense will be paid for.
class OverflowPlan {
  const OverflowPlan({
    required this.targetJarId,
    required this.amount,
    required this.fromTarget,
    required this.draws,
    required this.fromSavings,
    required this.uncovered,
    required this.targetIsSavings,
  });

  final String targetJarId;
  final int amount;

  /// Paid from the glass the expense belongs to.
  final int fromTarget;

  /// Borrowed from other non-savings glasses, in order.
  final List<Draw> draws;

  /// Borrowed from Savings — only ever non-zero when the user explicitly
  /// chose "Break my savings". If Savings itself was picked as the source
  /// it is used first; otherwise only after every other glass.
  final int fromSavings;

  /// Not covered by anything: the glass goes below zero (overspent).
  final int uncovered;

  /// The expense is logged directly against the Savings glass.
  final bool targetIsSavings;

  int get shortfall => amount - fromTarget;
  bool get needsBorrowing => shortfall > 0;

  /// The user must confirm "Break my savings" before applying this plan.
  bool get breaksSavings => fromSavings > 0 || targetIsSavings;
}

/// Outcome of applying a plan.
class ExpenseOutcome {
  const ExpenseOutcome({
    required this.jars,
    required this.expense,
    required this.transfers,
    required this.brokeSavings,
  });

  final List<Jar> jars;
  final Transaction expense;
  final List<Transaction> transfers;
  final bool brokeSavings;
}

/// Spending & overflow rule (spec §4.3).
///
/// When an expense is bigger than what's left in its glass, the shortfall is
/// borrowed from Fun first, then from the other non-savings glasses. The
/// Savings glass is **never** used unless [allowSavings] is passed, which the
/// UI only does after an explicit "Break my savings" confirmation.
abstract final class OverflowPlanner {
  static OverflowPlan plan({
    required List<Jar> jars,
    required String targetJarId,
    required int amount,
    String? preferredSourceId,
    bool allowSavings = false,
  }) {
    final target = jars.firstWhere((j) => j.id == targetJarId);
    final available = target.remaining > 0 ? target.remaining : 0;
    final fromTarget = amount <= available ? amount : available;
    var rest = amount - fromTarget;

    // Spending straight from Savings: nothing is borrowed; it is a break.
    if (target.isSavings) {
      return OverflowPlan(
        targetJarId: targetJarId,
        amount: amount,
        fromTarget: fromTarget,
        draws: const [],
        fromSavings: 0,
        uncovered: rest,
        targetIsSavings: true,
      );
    }

    final draws = <Draw>[];
    var fromSavings = 0;
    final savingsJar = jars.where((j) => j.isSavings).firstOrNull;
    int takeFromSavings() {
      if (savingsJar == null || savingsJar.remaining <= 0 || rest <= 0) {
        return 0;
      }
      final take = savingsJar.remaining < rest ? savingsJar.remaining : rest;
      rest -= take;
      return take;
    }

    // The user explicitly chose "Break my savings" as the source.
    final savingsChosen =
        allowSavings &&
        savingsJar != null &&
        preferredSourceId == savingsJar.id;
    if (savingsChosen) fromSavings = takeFromSavings();

    for (final source in borrowOrder(jars, targetJarId, preferredSourceId)) {
      if (rest == 0) break;
      final take = source.remaining < rest ? source.remaining : rest;
      if (take <= 0) continue;
      draws.add(Draw(source.id, take));
      rest -= take;
    }

    if (allowSavings && !savingsChosen) fromSavings = takeFromSavings();

    return OverflowPlan(
      targetJarId: targetJarId,
      amount: amount,
      fromTarget: fromTarget,
      draws: draws,
      fromSavings: fromSavings,
      uncovered: rest,
      targetIsSavings: false,
    );
  }

  /// Non-savings glasses to borrow from: the user's choice first, then Fun,
  /// then the rest in shelf order. Savings is never included.
  static List<Jar> borrowOrder(
    List<Jar> jars,
    String targetJarId,
    String? preferredSourceId,
  ) {
    final candidates =
        jars.where((j) => !j.isSavings && j.id != targetJarId).toList()
          ..sort((a, b) => a.order.compareTo(b.order));
    int rank(Jar j) {
      if (j.id == preferredSourceId) return 0;
      if (j.isFun) return 1;
      return 2;
    }

    // Stable sort by rank keeps shelf order within the same rank.
    final indexed = candidates.asMap().entries.toList()
      ..sort((a, b) {
        final r = rank(a.value).compareTo(rank(b.value));
        return r != 0 ? r : a.key.compareTo(b.key);
      });
    return indexed.map((e) => e.value).toList();
  }

  /// Glasses that still have money to lend for [targetJarId].
  static List<Jar> lenders(List<Jar> jars, String targetJarId) => borrowOrder(
    jars,
    targetJarId,
    null,
  ).where((j) => j.remaining > 0).toList();

  /// Applies [plan]: borrowed money is moved into the target glass (as
  /// transfer records) and the full expense is spent from it.
  static ExpenseOutcome apply({
    required List<Jar> jars,
    required OverflowPlan plan,
    required String note,
    required DateTime dateTime,
    required String cycleId,
    required String Function() newId,
  }) {
    final byId = {for (final j in jars) j.id: j};
    final transfers = <Transaction>[];

    void move(String fromId, int amount) {
      final from = byId[fromId]!;
      final to = byId[plan.targetJarId]!;
      byId[fromId] = from.copyWith(
        allocatedAmount: from.allocatedAmount - amount,
      );
      byId[plan.targetJarId] = to.copyWith(
        allocatedAmount: to.allocatedAmount + amount,
      );
      transfers.add(
        Transaction(
          id: newId(),
          jarId: fromId,
          toJarId: plan.targetJarId,
          amount: amount,
          note: '',
          dateTime: dateTime,
          type: TransactionType.transfer,
          cycleId: cycleId,
        ),
      );
    }

    for (final d in plan.draws) {
      move(d.jarId, d.amount);
    }
    if (plan.fromSavings > 0) {
      final savings = jars.firstWhere((j) => j.isSavings);
      move(savings.id, plan.fromSavings);
    }

    final target = byId[plan.targetJarId]!;
    byId[plan.targetJarId] = target.copyWith(
      spentAmount: target.spentAmount + plan.amount,
    );

    final expense = Transaction(
      id: newId(),
      jarId: plan.targetJarId,
      amount: plan.amount,
      note: note,
      dateTime: dateTime,
      type: TransactionType.expense,
      cycleId: cycleId,
    );

    return ExpenseOutcome(
      jars: jars.map((j) => byId[j.id]!).toList(),
      expense: expense,
      transfers: transfers,
      brokeSavings: plan.breaksSavings,
    );
  }
}
