import '../../features/alerts/domain/alert_engine.dart';
import '../../features/badges/data/badge.dart';
import '../../features/badges/domain/levels.dart';
import '../../features/goals/data/goal.dart';
import '../../features/jars/data/jar.dart';
import '../../features/onboarding/data/user_profile.dart';
import '../../features/salary/data/month_cycle.dart';
import '../../features/salary/domain/cycle_data.dart';
import '../../features/salary/domain/cycle_range.dart';
import '../../features/streaks/domain/streak_calculator.dart';
import '../../features/transactions/data/transaction.dart';

/// Immutable snapshot of everything the UI shows. Derived values are
/// computed on demand from the raw records (the data set is tiny).
class BudgetState {
  const BudgetState({
    required this.profile,
    required this.jars,
    required this.cycles,
    required this.transactions,
    required this.goals,
    required this.badges,
    required this.now,
  });

  factory BudgetState.empty(DateTime now) => BudgetState(
    profile: null,
    jars: const [],
    cycles: const [],
    transactions: const [],
    goals: const [],
    badges: const {},
    now: now,
  );

  final UserProfile? profile;

  /// Glasses in shelf order.
  final List<Jar> jars;

  /// All cycles, oldest first; the last open one is the active cycle.
  final List<MonthCycle> cycles;

  /// All transactions, newest first.
  final List<Transaction> transactions;
  final List<Goal> goals;
  final Map<BadgeKey, DateTime> badges;

  /// When this state was computed (from the injectable clock).
  final DateTime now;

  bool get isOnboarded => profile?.onboardingDone ?? false;

  MonthCycle? get activeCycle {
    for (final c in cycles.reversed) {
      if (!c.closed) return c;
    }
    return null;
  }

  CycleRange? get range {
    final c = activeCycle;
    return c == null ? null : CycleRange(c.startDate, c.endDate);
  }

  /// The month's glasses haven't been filled yet.
  bool get needsFunding => activeCycle != null && !activeCycle!.funded;

  Jar? jarById(String id) {
    for (final j in jars) {
      if (j.id == id) return j;
    }
    return null;
  }

  Jar? jarOfType(JarType t) {
    for (final j in jars) {
      if (j.type == t) return j;
    }
    return null;
  }

  Goal? goalById(String id) {
    for (final g in goals) {
      if (g.id == id) return g;
    }
    return null;
  }

  /// Money left to spend this month (all glasses except Savings).
  int get leftToSpend => jars
      .where((j) => !j.isSavings)
      .fold(0, (a, j) => a + (j.remaining > 0 ? j.remaining : 0));

  List<Transaction> get cycleTransactions {
    final c = activeCycle;
    if (c == null) return const [];
    return transactions.where((t) => t.cycleId == c.id).toList();
  }

  /// Closed cycles (snapshots) plus the live active cycle.
  List<CycleData> get cycleData => [
    for (final c in cycles)
      c.closed ? CycleData(c, c.jarsSnapshot) : CycleData.live(c, jars),
  ];

  StreakResult get streak =>
      StreakCalculator.compute(cycles, currentCycleId: activeCycle?.id);

  int get totalSaved => SavingsMath.totalSaved(cycleData);

  int get inGoals => goals.fold(0, (a, g) => a + g.savedAmount);

  int get availableForGoals =>
      SavingsMath.availableForGoals(totalSaved, inGoals);

  LevelProgress get level => Levels.forTotal(totalSaved);

  /// The planned monthly savings (used for goal estimates).
  int get monthlySavingsPlan => jarOfType(JarType.savings)?.plannedAmount ?? 0;

  int get plannedTotal => jars.fold(0, (a, j) => a + j.plannedAmount);

  List<BudgetAlert> get alerts {
    final c = activeCycle;
    final r = range;
    if (c == null || r == null || !isOnboarded) return const [];
    return AlertEngine.compute(
      range: r,
      cycle: c,
      jars: jars,
      cycleTransactions: cycleTransactions,
      now: now,
    );
  }

  BudgetState copyWith({
    UserProfile? profile,
    bool clearProfile = false,
    List<Jar>? jars,
    List<MonthCycle>? cycles,
    List<Transaction>? transactions,
    List<Goal>? goals,
    Map<BadgeKey, DateTime>? badges,
    DateTime? now,
  }) {
    return BudgetState(
      profile: clearProfile ? null : (profile ?? this.profile),
      jars: jars ?? this.jars,
      cycles: cycles ?? this.cycles,
      transactions: transactions ?? this.transactions,
      goals: goals ?? this.goals,
      badges: badges ?? this.badges,
      now: now ?? this.now,
    );
  }
}
