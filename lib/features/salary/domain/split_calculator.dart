import '../../../core/constants.dart';
import '../../../core/money.dart';
import '../../jars/data/jar.dart';

/// Suggests and maintains how income is divided between glasses.
///
/// Rules (see product spec §4.1):
/// * Percentages depend on the income band.
/// * Living with family halves the Rent share ("Home contribution") and moves
///   the freed half to Savings.
/// * Every glass is rounded to the nearest ₹10, and Fun absorbs the rounding
///   difference so the total always equals income exactly.
abstract final class SplitCalculator {
  /// Upper bound (inclusive) of the lowest band.
  static const int lowBandMax = 7000;

  /// Upper bound (inclusive) of the middle band.
  static const int midBandMax = 15000;

  /// Base percentages for [income], before the family adjustment.
  static Map<JarType, double> basePercents(int income) {
    if (income <= lowBandMax) {
      return const {
        JarType.savings: 0.10,
        JarType.rent: 0.40,
        JarType.food: 0.30,
        JarType.travel: 0.12,
        JarType.fun: 0.08,
      };
    }
    if (income <= midBandMax) {
      return const {
        JarType.savings: 0.20,
        JarType.rent: 0.35,
        JarType.food: 0.25,
        JarType.travel: 0.10,
        JarType.fun: 0.10,
      };
    }
    return const {
      JarType.savings: 0.25,
      JarType.rent: 0.30,
      JarType.food: 0.20,
      JarType.travel: 0.10,
      JarType.fun: 0.15,
    };
  }

  /// Percentages after applying the living-with-family rule.
  static Map<JarType, double> percentsFor(
    int income, {
    required bool livesWithFamily,
  }) {
    final p = Map<JarType, double>.of(basePercents(income));
    if (livesWithFamily) {
      final freed = p[JarType.rent]! / 2;
      p[JarType.rent] = freed;
      p[JarType.savings] = p[JarType.savings]! + freed;
    }
    return p;
  }

  /// Suggested rupee amount for each built-in glass. Sums exactly to [income].
  static Map<JarType, int> suggest(
    int income, {
    required bool livesWithFamily,
  }) {
    if (income <= 0) {
      return {for (final t in JarDefaults.fillOrder) t: 0};
    }
    final p = percentsFor(income, livesWithFamily: livesWithFamily);
    final result = <JarType, int>{};
    for (final t in JarDefaults.fillOrder) {
      if (t == JarType.fun) continue;
      result[t] = roundTo10(income * p[t]!);
    }
    result[JarType.fun] = income - _sum(result.values);
    _fixNegativeBalancer(result, JarType.fun);
    return {for (final t in JarDefaults.fillOrder) t: result[t]!};
  }

  /// Splits an income [amount] across [jars] in proportion to each jar's
  /// [Jar.plannedAmount]. Used for salary day (when the salary differs from
  /// the plan) and for every irregular income entry.
  ///
  /// Returns jarId → amount. The total equals [amount] exactly; the Fun glass
  /// (or the last non-savings glass if there is no Fun) absorbs rounding.
  static Map<String, int> splitAcrossJars(int amount, List<Jar> jars) {
    if (jars.isEmpty) return {};
    final totalPlanned = _sum(jars.map((j) => j.plannedAmount));
    if (totalPlanned == amount) {
      return {for (final j in jars) j.id: j.plannedAmount};
    }
    final balancer = balancerJar(jars);
    final result = <String, int>{};
    for (final j in jars) {
      if (j.id == balancer.id) continue;
      final share = totalPlanned <= 0 ? 0.0 : j.plannedAmount / totalPlanned;
      result[j.id] = roundTo10(amount * share);
    }
    result[balancer.id] = amount - _sum(result.values);
    _fixNegativeBalancerById(result, balancer.id, jars);
    return result;
  }

  /// The glass that absorbs rounding and slider changes: Fun, else the last
  /// non-savings glass, else the first glass.
  static Jar balancerJar(List<Jar> jars) {
    for (final j in jars) {
      if (j.type == JarType.fun) return j;
    }
    final nonSavings = jars.where((j) => !j.isSavings).toList();
    return nonSavings.isNotEmpty ? nonSavings.last : jars.first;
  }

  /// True when [savings] is below the 5% minimum that needs confirmation.
  static bool isSavingsBelowMinimum(int savings, int income) =>
      income > 0 && savings < income * PPRules.minSavingsShare;

  /// The smallest savings amount that does not need confirmation.
  static int minimumSavings(int income) {
    final raw = (income * PPRules.minSavingsShare).ceil();
    // Round *up* to the next ₹10 so the result itself is never below 5%.
    return ((raw + 9) ~/ 10) * 10;
  }

  /// Slider editing: sets [jarId] to [newAmount] and lets the balancer glass
  /// ([balancerId]) absorb the difference, so the total never changes.
  /// [newAmount] is clamped so the balancer never goes negative.
  static Map<String, int> adjust({
    required Map<String, int> amounts,
    required String jarId,
    required int newAmount,
    required String balancerId,
  }) {
    if (jarId == balancerId) return Map.of(amounts);
    final current = amounts[jarId] ?? 0;
    final balance = amounts[balancerId] ?? 0;
    final clamped = newAmount.clamp(0, current + balance);
    return Map.of(amounts)
      ..[jarId] = clamped
      ..[balancerId] = balance - (clamped - current);
  }

  static int _sum(Iterable<int> xs) => xs.fold(0, (a, b) => a + b);

  /// Very small incomes can round the other glasses above the total; take
  /// ₹10 at a time from the largest non-savings glass until Fun is ≥ 0.
  static void _fixNegativeBalancer(Map<JarType, int> m, JarType balancer) {
    while (m[balancer]! < 0) {
      final largest = m.entries
          .where((e) => e.key != balancer && e.key != JarType.savings)
          .reduce((a, b) => a.value >= b.value ? a : b);
      final take = largest.value >= 10 ? 10 : largest.value;
      if (take == 0) break;
      m[largest.key] = largest.value - take;
      m[balancer] = m[balancer]! + take;
    }
  }

  static void _fixNegativeBalancerById(
    Map<String, int> m,
    String balancerId,
    List<Jar> jars,
  ) {
    final savingsIds = jars.where((j) => j.isSavings).map((j) => j.id).toSet();
    while (m[balancerId]! < 0) {
      final candidates = m.entries
          .where((e) => e.key != balancerId && !savingsIds.contains(e.key))
          .toList();
      if (candidates.isEmpty) break;
      final largest = candidates.reduce((a, b) => a.value >= b.value ? a : b);
      final take = largest.value >= 10 ? 10 : largest.value;
      if (take == 0) break;
      m[largest.key] = largest.value - take;
      m[balancerId] = m[balancerId]! + take;
    }
  }
}
