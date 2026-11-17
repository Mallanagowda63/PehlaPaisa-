import '../../jars/data/jar.dart';
import '../../salary/data/month_cycle.dart';
import '../../salary/domain/cycle_data.dart';

/// Savings kept in one month, for the 6-month bar chart.
class MonthSavings {
  const MonthSavings({
    required this.cycleId,
    required this.month,
    required this.year,
    required this.saved,
    required this.income,
  });

  final String cycleId;
  final int month;
  final int year;
  final int saved;
  final int income;
}

class MonthlyReport {
  const MonthlyReport({
    required this.cycle,
    required this.income,
    required this.saved,
    required this.savedPercent,
    required this.totalSpent,
    required this.spending,
    required this.best,
    required this.worst,
    required this.previousSpent,
    required this.previousSaved,
  });

  final MonthCycle cycle;
  final int income;
  final int saved;
  final int savedPercent;

  /// Spent from all glasses this month.
  final int totalSpent;

  /// Glasses with spending, largest first (for the pie chart).
  final List<JarSnapshot> spending;

  /// Glass that kept the most of its budget (lowest spent share).
  final JarSnapshot? best;

  /// Glass that used the most of its budget (highest spent share).
  final JarSnapshot? worst;

  /// Last month's figures (null if there is no previous month).
  final int? previousSpent;
  final int? previousSaved;

  /// Spending change vs last month in percent (null if not comparable).
  int? get spentChangePercent {
    final p = previousSpent;
    if (p == null || p == 0) return null;
    return (((totalSpent - p) / p) * 100).round();
  }

  int? get savedChange => previousSaved == null ? null : saved - previousSaved!;
}

/// Monthly report maths (spec §5 "Monthly Report").
abstract final class ReportCalculator {
  static double _usage(JarSnapshot j) =>
      j.allocated <= 0 ? 0 : j.spent / j.allocated;

  static MonthlyReport build(CycleData current, CycleData? previous) {
    final spending = current.jars.where((j) => j.spent > 0).toList()
      ..sort((a, b) => b.spent.compareTo(a.spent));

    final budgeted = current.jars
        .where((j) => j.type != JarType.savings && j.allocated > 0)
        .toList();
    JarSnapshot? best;
    JarSnapshot? worst;
    if (budgeted.length >= 2) {
      final byUsage = [...budgeted]
        ..sort((a, b) => _usage(a).compareTo(_usage(b)));
      best = byUsage.first;
      worst = byUsage.last;
    }

    final income = current.cycle.income;
    final saved = current.netSaved;
    return MonthlyReport(
      cycle: current.cycle,
      income: income,
      saved: saved,
      savedPercent: income <= 0 ? 0 : ((saved / income) * 100).round(),
      totalSpent: current.totalSpent,
      spending: spending,
      best: best,
      worst: worst,
      previousSpent: previous?.totalSpent,
      previousSaved: previous?.netSaved,
    );
  }

  /// The last [n] months' savings, oldest first (for the bar chart).
  static List<MonthSavings> lastMonths(List<CycleData> all, {int n = 6}) {
    final sorted = [...all]
      ..sort((a, b) => a.cycle.startDate.compareTo(b.cycle.startDate));
    final tail = sorted.length > n ? sorted.sublist(sorted.length - n) : sorted;
    return tail
        .map(
          (c) => MonthSavings(
            cycleId: c.cycle.id,
            month: c.cycle.month,
            year: c.cycle.year,
            saved: c.netSaved,
            income: c.cycle.income,
          ),
        )
        .toList();
  }
}
