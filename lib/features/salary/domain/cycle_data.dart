import '../../jars/data/jar.dart';
import '../data/month_cycle.dart';

/// A cycle together with its glasses: the live jars for the open cycle, or
/// the frozen snapshot for a closed one. Reports, badges and savings totals
/// all work on this one shape.
class CycleData {
  const CycleData(this.cycle, this.jars);

  final MonthCycle cycle;
  final List<JarSnapshot> jars;

  /// Builds the live view of the open cycle.
  factory CycleData.live(MonthCycle cycle, List<Jar> jars) =>
      CycleData(cycle, jars.map(JarSnapshot.fromJar).toList());

  JarSnapshot? jarOfType(JarType t) {
    for (final j in jars) {
      if (j.type == t) return j;
    }
    return null;
  }

  /// Money kept in the Savings glass this month (poured in minus broken).
  int get netSaved {
    final s = jarOfType(JarType.savings);
    if (s == null || !cycle.funded) return 0;
    return (s.allocated - s.spent).clamp(0, s.allocated);
  }

  /// Total spent from all glasses.
  int get totalSpent => jars.fold(0, (a, j) => a + j.spent);

  /// Share of income kept in savings (0..1).
  double get savedShare => cycle.income <= 0 ? 0 : netSaved / cycle.income;
}

/// Lifetime totals derived from all cycles.
abstract final class SavingsMath {
  /// Everything ever kept in the Savings glass across all months.
  static int totalSaved(List<CycleData> cycles) =>
      cycles.fold(0, (a, c) => a + c.netSaved);

  /// Savings not yet assigned to any goal (never negative).
  static int availableForGoals(int totalSaved, int inGoals) =>
      (totalSaved - inGoals).clamp(0, totalSaved);
}
