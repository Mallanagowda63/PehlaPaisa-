import '../../../core/dates.dart';
import '../../jars/data/jar.dart';
import '../../transactions/data/transaction.dart';
import '../data/month_cycle.dart';
import 'cycle_range.dart';
import 'split_calculator.dart';

/// Result of moving into a new month.
class RolloverResult {
  const RolloverResult({
    required this.closed,
    required this.opened,
    required this.jars,
  });

  /// The previous cycle, now closed with a snapshot (null on first launch).
  final MonthCycle? closed;

  /// The new, unfunded cycle.
  final MonthCycle opened;

  /// Glasses emptied for the new month.
  final List<Jar> jars;
}

/// Month rollover: a new month starts on the user's salary day.
abstract final class MonthRollover {
  /// Creates an empty cycle for [range].
  static MonthCycle newCycle(CycleRange range) => MonthCycle(
    id: range.id,
    month: range.start.month,
    year: range.start.year,
    startDate: range.start,
    endDate: range.end,
    income: 0,
    savingsFilledFirst: false,
    savingsFilledAt: null,
    savingsBroken: false,
    funded: false,
    jarsSnapshot: const [],
    closed: false,
  );

  /// Returns what must change when the app opens on [now], or null when the
  /// active cycle is still current.
  ///
  /// The active cycle ends after its own [MonthCycle.endDate]; changing the
  /// salary day therefore only takes effect from the next cycle.
  static RolloverResult? check({
    required MonthCycle? active,
    required List<Jar> jars,
    required DateTime now,
    required int salaryDay,
  }) {
    final today = dateOnly(now);
    if (active != null && !today.isAfter(dateOnly(active.endDate))) {
      return null;
    }
    var range = CycleRange.forDate(today, salaryDay);
    if (active != null) {
      // Never overlap the cycle we are closing (possible if the salary day
      // was changed mid-cycle).
      final afterActive = DateTime(
        active.endDate.year,
        active.endDate.month,
        active.endDate.day + 1,
      );
      if (range.start.isBefore(afterActive)) {
        range = CycleRange(afterActive, range.end);
      }
    }
    final closed = active?.copyWith(
      closed: true,
      jarsSnapshot: jars.map(JarSnapshot.fromJar).toList(),
    );
    final reset = jars
        .map((j) => j.copyWith(allocatedAmount: 0, spentAmount: 0))
        .toList();
    return RolloverResult(closed: closed, opened: newCycle(range), jars: reset);
  }
}

/// Result of pouring an income entry into the glasses.
class FundingResult {
  const FundingResult({
    required this.cycle,
    required this.jars,
    required this.split,
    required this.incomeTransaction,
    required this.firstFill,
  });

  final MonthCycle cycle;
  final List<Jar> jars;

  /// jarId → amount poured.
  final Map<String, int> split;
  final Transaction incomeTransaction;

  /// True when this was the month's first income (the salary-day ritual).
  final bool firstFill;
}

/// Pay-yourself-first funding (spec §4.2 and §4.4).
abstract final class Funding {
  /// Pours [amount] into [jars] — Savings first — using the planned split.
  ///
  /// For irregular income this is called once per income entry; every entry
  /// is split with the same percentages.
  ///
  /// [savingsFilledFirst] becomes true on the month's first fill when the
  /// Savings glass actually receives money and nothing was spent before it.
  static FundingResult fund({
    required MonthCycle cycle,
    required List<Jar> jars,
    required int amount,
    required DateTime now,
    required String transactionId,
    bool spentBeforeFilling = false,
  }) {
    final split = SplitCalculator.splitAcrossJars(amount, jars);
    final newJars = jars
        .map(
          (j) => j.copyWith(
            allocatedAmount: j.allocatedAmount + (split[j.id] ?? 0),
          ),
        )
        .toList();
    final savingsJar = jars.where((j) => j.isSavings).toList();
    final savingsAmount = savingsJar.isEmpty
        ? 0
        : (split[savingsJar.first.id] ?? 0);
    final firstFill = !cycle.funded;
    final filledFirst = firstFill
        ? (savingsAmount > 0 && !spentBeforeFilling)
        : cycle.savingsFilledFirst;
    final newCycle = cycle.copyWith(
      income: cycle.income + amount,
      funded: true,
      savingsFilledFirst: filledFirst,
      savingsFilledAt:
          cycle.savingsFilledAt ?? (savingsAmount > 0 ? now : null),
    );
    return FundingResult(
      cycle: newCycle,
      jars: newJars,
      split: split,
      firstFill: firstFill,
      incomeTransaction: Transaction(
        id: transactionId,
        jarId: '',
        amount: amount,
        note: '',
        dateTime: now,
        type: TransactionType.income,
        cycleId: cycle.id,
      ),
    );
  }
}
