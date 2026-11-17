import '../../../core/constants.dart';
import '../../../core/dates.dart';
import '../../../core/money.dart';
import '../../jars/data/jar.dart';
import '../../salary/data/month_cycle.dart';
import '../../salary/domain/cycle_range.dart';
import '../../transactions/data/transaction.dart';

enum AlertKind {
  /// It's a new month and the glasses haven't been filled.
  fillSalary,

  /// A glass is below 20% with more than a week left.
  lowJar,

  /// This week's food spending is over the weekly food budget.
  foodWeekly,
}

/// A glass's spending limit for the current week.
class WeeklyLimit {
  const WeeklyLimit({
    required this.jarId,
    required this.limit,
    required this.spent,
  });

  final String jarId;
  final int limit;
  final int spent;

  bool get isOver => spent > limit;
  int get left => limit - spent;

  /// 0..1 of the limit used (capped at 1 for the progress bar).
  double get usedRatio => limit <= 0 ? 0 : (spent / limit).clamp(0.0, 1.0);
}

class BudgetAlert {
  const BudgetAlert({
    required this.kind,
    this.jarId,
    this.percentEmpty = 0,
    this.daysLeft = 0,
    this.spent = 0,
    this.limit = 0,
    this.period = '',
  });

  final AlertKind kind;
  final String? jarId;
  final int percentEmpty;
  final int daysLeft;
  final int spent;
  final int limit;

  /// Extra scope for repeating alerts: the cycle-week start date for weekly
  /// alerts, empty for once-a-month ones.
  final String period;

  /// Unique per cycle (and per week for weekly alerts). Used so a
  /// notification is sent once, and a hidden warning stays hidden.
  String key(String cycleId) =>
      '$cycleId:${jarId ?? '-'}:${kind.name}'
      '${period.isEmpty ? '' : ':$period'}';
}

/// Alert rules (spec §4.7). Pure functions over the current cycle.
abstract final class AlertEngine {
  static List<BudgetAlert> compute({
    required CycleRange range,
    required MonthCycle cycle,
    required List<Jar> jars,
    required List<Transaction> cycleTransactions,
    required DateTime now,
  }) {
    if (!cycle.funded) {
      return const [BudgetAlert(kind: AlertKind.fillSalary)];
    }
    final alerts = <BudgetAlert>[];
    final daysLeft = range.daysLeft(now);
    for (final j in jars) {
      if (j.isSavings || j.allocatedAmount <= 0) continue;
      if (j.fillRatio < PPRules.lowJarRatio &&
          daysLeft > PPRules.lowJarMinDaysLeft) {
        alerts.add(
          BudgetAlert(
            kind: AlertKind.lowJar,
            jarId: j.id,
            percentEmpty: 100 - (j.fillRatio * 100).round(),
            daysLeft: daysLeft,
          ),
        );
      }
    }
    final food = jars.where((j) => j.type == JarType.food).toList();
    if (food.isNotEmpty && food.first.allocatedAmount > 0) {
      final limit = weeklyFoodLimit(food.first.allocatedAmount, range);
      final spent = spentInCycleWeek(
        cycleTransactions,
        food.first.id,
        range,
        now,
      );
      if (spent > limit) {
        final week = cycleWeekStart(range, now);
        alerts.add(
          BudgetAlert(
            kind: AlertKind.foodWeekly,
            jarId: food.first.id,
            spent: spent,
            limit: limit,
            period: '${week.year}-${week.month}-${week.day}',
          ),
        );
      }
    }
    return alerts;
  }

  /// Glasses that get a weekly limit: everyday spending glasses. Savings is
  /// never spent and Rent/Bills is paid once a month, so neither has one.
  static bool hasWeeklyLimit(Jar j) =>
      !j.isSavings && j.type != JarType.rent && j.allocatedAmount > 0;

  /// This cycle-week's limit and spending for every glass that has one.
  static List<WeeklyLimit> weeklyLimits({
    required List<Jar> jars,
    required List<Transaction> cycleTransactions,
    required CycleRange range,
    required DateTime now,
  }) => [
    for (final j in jars.where(hasWeeklyLimit))
      WeeklyLimit(
        jarId: j.id,
        limit: weeklyFoodLimit(j.allocatedAmount, range),
        spent: spentInCycleWeek(cycleTransactions, j.id, range, now),
      ),
  ];

  /// Weekly food budget = Food allocation ÷ number of weeks in the cycle.
  /// (The same rule gives every glass its weekly limit.)
  static int weeklyFoodLimit(int foodAllocation, CycleRange range) =>
      roundTo10(foodAllocation / range.weeks);

  /// Start of the 7-day block of the cycle that contains [now]. Weeks are
  /// counted from the salary day so every week of the budget is equal.
  static DateTime cycleWeekStart(CycleRange range, DateTime now) {
    final offset = daysBetween(range.start, dateOnly(now)).clamp(0, 400);
    final weekIndex = offset ~/ 7;
    return DateTime(
      range.start.year,
      range.start.month,
      range.start.day + weekIndex * 7,
    );
  }

  /// Spent from [jarId] in the current cycle-week.
  static int spentInCycleWeek(
    List<Transaction> txns,
    String jarId,
    CycleRange range,
    DateTime now,
  ) {
    final from = cycleWeekStart(range, now);
    final to = DateTime(from.year, from.month, from.day + 7);
    return txns
        .where(
          (t) =>
              t.isExpense &&
              t.jarId == jarId &&
              !t.dateTime.isBefore(from) &&
              t.dateTime.isBefore(to),
        )
        .fold(0, (a, t) => a + t.amount);
  }

  /// Total spent this calendar week (Monday → now), for the weekly check-in.
  static int spentThisWeek(List<Transaction> txns, DateTime now) {
    final from = startOfWeek(now);
    return txns
        .where(
          (t) =>
              t.isExpense &&
              !t.dateTime.isBefore(from) &&
              !t.dateTime.isAfter(now),
        )
        .fold(0, (a, t) => a + t.amount);
  }
}
