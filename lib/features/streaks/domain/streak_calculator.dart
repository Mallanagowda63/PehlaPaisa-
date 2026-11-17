import '../../../core/dates.dart';
import '../../salary/data/month_cycle.dart';

class StreakResult {
  const StreakResult({required this.current, required this.best});

  /// Consecutive "pay yourself first" months ending now.
  final int current;

  /// Longest run ever.
  final int best;
}

/// Streak rules (spec §4.5).
///
/// A streak month = Savings filled first AND Savings not broken that month.
/// Months must be consecutive; a month with no record (app not used) breaks
/// the streak. The open month that hasn't been funded yet is "pending": it
/// neither counts nor breaks the streak.
abstract final class StreakCalculator {
  static bool qualifies(MonthCycle c) =>
      c.funded && c.savingsFilledFirst && !c.savingsBroken;

  static StreakResult compute(
    List<MonthCycle> cycles, {
    String? currentCycleId,
  }) {
    final sorted = [...cycles]
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
    var run = 0;
    var best = 0;
    int? lastIndex;
    for (final c in sorted) {
      final pending = !c.closed && !c.funded;
      if (pending) continue;
      final idx = monthIndexFromId(c.id);
      if (qualifies(c)) {
        final adjacent = lastIndex != null && idx == lastIndex + 1;
        run = (adjacent && run > 0) ? run + 1 : 1;
      } else {
        run = 0;
      }
      lastIndex = idx;
      if (run > best) best = run;
    }

    // If the last counted month is older than last month, the run is over.
    if (currentCycleId != null && lastIndex != null) {
      final now = monthIndexFromId(currentCycleId);
      if (lastIndex < now - 1) run = 0;
    }
    return StreakResult(current: run, best: best);
  }
}
