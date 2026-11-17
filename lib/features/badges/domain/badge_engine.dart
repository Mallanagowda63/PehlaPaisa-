import '../../../core/constants.dart';
import '../../../core/dates.dart';
import '../../goals/data/goal.dart';
import '../../jars/data/jar.dart';
import '../../salary/domain/cycle_data.dart';
import '../../transactions/data/transaction.dart';
import '../data/badge.dart';

/// Everything the badge rules look at.
class BadgeInput {
  const BadgeInput({
    required this.onboardingDone,
    required this.cycles,
    required this.transactions,
    required this.goals,
    required this.bestStreak,
    required this.totalSaved,
  });

  final bool onboardingDone;

  /// All cycles, the open one included (with live jars).
  final List<CycleData> cycles;
  final List<Transaction> transactions;
  final List<Goal> goals;
  final int bestStreak;
  final int totalSaved;
}

/// Badge unlock rules (spec §6.1). Pure and deterministic.
abstract final class BadgeEngine {
  /// Every badge the user has earned given [input].
  static Set<BadgeKey> earned(BadgeInput input) {
    final s = <BadgeKey>{};
    if (input.onboardingDone) s.add(BadgeKey.pehlaKadam);
    if (input.cycles.any((c) => c.cycle.savingsFilledFirst)) {
      s.add(BadgeKey.pehlaPaisa);
    }
    if (input.bestStreak >= 3) s.add(BadgeKey.streak3);
    if (input.bestStreak >= 6) s.add(BadgeKey.streak6);
    if (input.bestStreak >= 12) s.add(BadgeKey.streak12);
    if (input.totalSaved >= PPRules.gullakMasterTotal) {
      s.add(BadgeKey.gullakMaster);
    }
    if (input.goals.any((g) => g.completedAt != null)) {
      s.add(BadgeKey.goalGetter);
    }
    if (input.cycles.any((c) => funUnderControl(c, input.transactions))) {
      s.add(BadgeKey.funUnderControl);
    }
    if (longestLoggingRun(input.transactions) >= PPRules.loggerStreakDays) {
      s.add(BadgeKey.logger);
    }
    if (input.cycles.any(
      (c) =>
          c.cycle.funded &&
          c.cycle.income > 0 &&
          c.savedShare >= PPRules.bachatChampionShare,
    )) {
      s.add(BadgeKey.bachatChampion);
    }
    return s;
  }

  /// Badges in [earnedNow] that weren't already unlocked.
  static List<BadgeKey> newlyUnlocked(
    Set<BadgeKey> earnedNow,
    Set<BadgeKey> alreadyUnlocked,
  ) => BadgeKey.values
      .where((k) => earnedNow.contains(k) && !alreadyUnlocked.contains(k))
      .toList();

  /// A finished month where Fun never went below zero and no money was
  /// borrowed into or out of the Fun glass.
  static bool funUnderControl(CycleData c, List<Transaction> txns) {
    if (!c.cycle.closed || !c.cycle.funded) return false;
    final fun = c.jarOfType(JarType.fun);
    if (fun == null || fun.allocated <= 0) return false;
    if (fun.spent > fun.allocated) return false;
    final borrowed = txns.any(
      (t) =>
          t.cycleId == c.cycle.id &&
          t.type == TransactionType.transfer &&
          t.goalId == null &&
          (t.jarId == fun.jarId || t.toJarId == fun.jarId),
    );
    return !borrowed;
  }

  /// Longest run of consecutive calendar days with at least one expense.
  static int longestLoggingRun(List<Transaction> txns) {
    final days =
        txns
            .where((t) => t.isExpense)
            .map((t) => dateOnly(t.dateTime))
            .toSet()
            .toList()
          ..sort();
    var best = 0;
    var run = 0;
    DateTime? prev;
    for (final d in days) {
      run = (prev != null && daysBetween(prev, d) == 1) ? run + 1 : 1;
      if (run > best) best = run;
      prev = d;
    }
    return best;
  }
}
