import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ids.dart';
import '../../features/badges/data/badge.dart';
import '../../features/badges/domain/badge_engine.dart';
import '../../features/badges/domain/celebration.dart';
import '../../features/badges/presentation/celebration_queue.dart';
import '../../features/goals/data/goal.dart';
import '../../features/goals/domain/goal_logic.dart';
import '../../features/jars/data/jar.dart';
import '../../features/jars/domain/jar_factory.dart';
import '../../features/onboarding/data/user_profile.dart';
import '../../features/salary/domain/cycle_range.dart';
import '../../features/salary/domain/month_rollover.dart';
import '../../features/settings/presentation/settings_controller.dart';
import '../../features/transactions/data/transaction.dart';
import '../../features/transactions/domain/overflow_planner.dart';
import 'budget_state.dart';
import 'repositories.dart';

/// The single entry point for every change to budget data.
///
/// Each action runs the pure domain rules, persists the result through the
/// repositories, and then re-reads state so the UI always reflects storage.
///
/// Note: both store implementations update their in-memory cache
/// synchronously when `put` is *called*, so issuing several writes together
/// (via [Future.wait]) and reading right after is safe.
class BudgetController extends Notifier<BudgetState> {
  Repositories get _repos => ref.read(repositoriesProvider);
  DateTime _now() => ref.read(clockProvider)();

  @override
  BudgetState build() {
    final rolled = _rolloverIfNeeded(_read());
    // Badges can't be pushed to another provider while building.
    Future.microtask(() => _checkBadges(silent: true));
    return rolled;
  }

  BudgetState _read() {
    final r = _repos;
    return BudgetState(
      profile: r.profile.read(),
      jars: r.jars.getAll(),
      cycles: r.cycles.getAll(),
      transactions: r.transactions.getAll(),
      goals: r.goals.getAll(),
      badges: r.badges.unlocked(),
      now: _now(),
    );
  }

  BudgetState _rolloverIfNeeded(BudgetState s) {
    final p = s.profile;
    if (p == null || !p.onboardingDone) return s;
    final res = MonthRollover.check(
      active: s.activeCycle,
      jars: s.jars,
      now: s.now,
      salaryDay: p.salaryDay,
    );
    if (res == null) return s;
    unawaited(
      Future.wait([
        if (res.closed != null) _repos.cycles.save(res.closed!),
        _repos.cycles.save(res.opened),
        _repos.jars.saveAll(res.jars),
      ]),
    );
    return _read();
  }

  /// Re-reads storage and starts a new month if the salary day has passed.
  /// Called when the app returns to the foreground.
  Future<void> refreshDay() async {
    state = _rolloverIfNeeded(_read());
    await _checkBadges();
  }

  void _celebrate(Celebration c) =>
      ref.read(celebrationQueueProvider.notifier).push(c);

  // ---------------------------------------------------------------------------
  // Onboarding & profile
  // ---------------------------------------------------------------------------

  Future<void> completeOnboarding({
    required String name,
    required int monthlyIncome,
    required int salaryDay,
    required IncomeType incomeType,
    required bool livesWithFamily,
    required Map<JarType, int> plan,
    required String language,
  }) async {
    final now = _now();
    final profile = UserProfile(
      name: name.trim(),
      monthlyIncome: monthlyIncome,
      salaryDay: salaryDay,
      livesWithFamily: livesWithFamily,
      incomeType: incomeType,
      language: language,
      createdAt: now,
      onboardingDone: true,
    );
    final cycle = MonthRollover.newCycle(CycleRange.forDate(now, salaryDay));
    await Future.wait([
      _repos.profile.write(profile),
      _repos.jars.saveAll(JarFactory.defaultJars(plan)),
      _repos.cycles.save(cycle),
    ]);
    state = _read();
    await _checkBadges();
  }

  Future<void> updateProfile(UserProfile profile) async {
    await _repos.profile.write(profile);
    state = _read();
  }

  // ---------------------------------------------------------------------------
  // Salary day / income
  // ---------------------------------------------------------------------------

  /// Pours [amount] into the glasses, Savings first. Returns the split so
  /// the salary screen can animate each glass.
  Future<FundingResult> fund(int amount) async {
    final s = state;
    final cycle = s.activeCycle!;
    final streakBefore = s.streak.current;
    final res = Funding.fund(
      cycle: cycle,
      jars: s.jars,
      amount: amount,
      now: _now(),
      transactionId: newId(),
      spentBeforeFilling:
          !cycle.funded && s.cycleTransactions.any((t) => t.isExpense),
    );
    await Future.wait([
      _repos.cycles.save(res.cycle),
      _repos.jars.saveAll(res.jars),
      _repos.transactions.save(res.incomeTransaction),
    ]);
    state = _read();
    final after = state.streak.current;
    if (res.firstFill && after > streakBefore && after >= 2) {
      _celebrate(Celebration.streak(after));
    }
    await _checkBadges();
    return res;
  }

  // ---------------------------------------------------------------------------
  // Spending
  // ---------------------------------------------------------------------------

  OverflowPlan planExpense(
    String jarId,
    int amount, {
    String? preferredSourceId,
    bool allowSavings = false,
  }) => OverflowPlanner.plan(
    jars: state.jars,
    targetJarId: jarId,
    amount: amount,
    preferredSourceId: preferredSourceId,
    allowSavings: allowSavings,
  );

  Future<ExpenseOutcome> addExpense(
    OverflowPlan plan, {
    String note = '',
    DateTime? date,
  }) async {
    final s = state;
    final cycle = s.activeCycle!;
    final now = _now();
    final when = date == null
        ? now
        : DateTime(date.year, date.month, date.day, now.hour, now.minute);
    final out = OverflowPlanner.apply(
      jars: s.jars,
      plan: plan,
      note: note.trim(),
      dateTime: when,
      cycleId: cycle.id,
      newId: newId,
    );
    await Future.wait([
      _repos.jars.saveAll(out.jars),
      _repos.transactions.saveAll([...out.transfers, out.expense]),
      if (out.brokeSavings)
        _repos.cycles.save(cycle.copyWith(savingsBroken: true)),
    ]);
    state = _read();
    await _checkBadges();
    return out;
  }

  /// Removes an expense from the current month and refills its glass.
  Future<void> deleteExpense(String transactionId) async {
    final s = state;
    final t = s.transactions.where((x) => x.id == transactionId).firstOrNull;
    if (t == null || !t.isExpense || t.cycleId != s.activeCycle?.id) return;
    final jar = s.jarById(t.jarId);
    await Future.wait([
      _repos.transactions.delete(t.id),
      if (jar != null)
        _repos.jars.save(jar.copyWith(spentAmount: jar.spentAmount - t.amount)),
    ]);
    state = _read();
  }

  /// Moves unspent money between two glasses this month. Taking from Savings
  /// breaks the streak (the UI confirms first).
  Future<void> moveBetweenJars(String fromId, String toId, int amount) async {
    final s = state;
    final from = s.jarById(fromId);
    final to = s.jarById(toId);
    final cycle = s.activeCycle;
    if (from == null || to == null || cycle == null || fromId == toId) return;
    final move = amount.clamp(0, from.remaining > 0 ? from.remaining : 0);
    if (move == 0) return;
    await Future.wait([
      _repos.jars.saveAll([
        from.copyWith(allocatedAmount: from.allocatedAmount - move),
        to.copyWith(allocatedAmount: to.allocatedAmount + move),
      ]),
      _repos.transactions.save(
        Transaction(
          id: newId(),
          jarId: fromId,
          toJarId: toId,
          amount: move,
          note: '',
          dateTime: _now(),
          type: TransactionType.transfer,
          cycleId: cycle.id,
        ),
      ),
      if (from.isSavings)
        _repos.cycles.save(cycle.copyWith(savingsBroken: true)),
    ]);
    state = _read();
  }

  // ---------------------------------------------------------------------------
  // Split plan & custom glasses
  // ---------------------------------------------------------------------------

  /// Saves the monthly plan (jarId → amount). Applies from the next fill.
  Future<void> updatePlan(Map<String, int> planned) async {
    await _repos.jars.saveAll(
      state.jars.map(
        (j) => j.copyWith(plannedAmount: planned[j.id] ?? j.plannedAmount),
      ),
    );
    state = _read();
  }

  /// Adds a custom glass just before Fun.
  Future<void> addCustomJar({
    required String name,
    required String emoji,
  }) async {
    final jars = state.jars;
    final fun = jars.where((j) => j.isFun).firstOrNull;
    final order = fun?.order ?? jars.length;
    final custom = JarFactory.custom(
      id: newId(),
      name: name.trim(),
      emoji: emoji,
      order: order,
    );
    await _repos.jars.saveAll([
      custom,
      if (fun != null) fun.copyWith(order: order + 1),
    ]);
    state = _read();
  }

  /// Removes a custom glass; its plan and leftover money go to Fun.
  Future<void> removeCustomJar(String id) async {
    final jar = state.jarById(id);
    if (jar == null || jar.type != JarType.custom) return;
    final fun = state.jarOfType(JarType.fun);
    final writes = <Future<void>>[_repos.jars.delete(id)];
    if (fun != null) {
      final leftover = jar.remaining > 0 ? jar.remaining : 0;
      writes.add(
        _repos.jars.save(
          fun.copyWith(
            plannedAmount: fun.plannedAmount + jar.plannedAmount,
            allocatedAmount: fun.allocatedAmount + leftover,
          ),
        ),
      );
    }
    await Future.wait(writes);
    state = _read();
  }

  // ---------------------------------------------------------------------------
  // Goals
  // ---------------------------------------------------------------------------

  Future<Goal> addGoal({
    required String name,
    required String emoji,
    required int targetAmount,
    DateTime? targetDate,
  }) async {
    final goal = Goal(
      id: newId(),
      name: name.trim(),
      emoji: emoji,
      targetAmount: targetAmount,
      savedAmount: 0,
      targetDate: targetDate,
      createdAt: _now(),
    );
    await _repos.goals.save(goal);
    state = _read();
    return goal;
  }

  Future<void> updateGoal(Goal goal) async {
    var g = goal;
    // Editing the target can complete or "un-complete" a goal.
    if (g.savedAmount >= g.targetAmount && g.completedAt == null) {
      g = g.copyWith(completedAt: _now());
    } else if (g.savedAmount < g.targetAmount && g.completedAt != null) {
      g = g.copyWith(clearCompletedAt: true);
    }
    await _repos.goals.save(g);
    state = _read();
    await _checkBadges();
  }

  Future<void> deleteGoal(String id) async {
    await _repos.goals.delete(id);
    state = _read();
  }

  /// Moves free savings into a goal glass.
  Future<int> depositToGoal(String goalId, int amount) async {
    final s = state;
    final goal = s.goalById(goalId);
    if (goal == null) return 0;
    final res = GoalLogic.deposit(
      goal: goal,
      amount: amount,
      available: s.availableForGoals,
      now: _now(),
    );
    if (res.moved == 0) return 0;
    final savings = s.jarOfType(JarType.savings);
    await Future.wait([
      _repos.goals.save(res.goal),
      _repos.transactions.save(
        Transaction(
          id: newId(),
          jarId: savings?.id ?? '',
          goalId: goalId,
          amount: res.moved,
          note: goal.name,
          dateTime: _now(),
          type: TransactionType.transfer,
          cycleId: s.activeCycle?.id ?? '',
        ),
      ),
    ]);
    state = _read();
    if (res.justCompleted) {
      _celebrate(
        Celebration.goal(
          name: res.goal.name,
          emoji: res.goal.emoji,
          amount: res.goal.targetAmount,
        ),
      );
    }
    await _checkBadges();
    return res.moved;
  }

  Future<void> withdrawFromGoal(String goalId, int amount) async {
    final goal = state.goalById(goalId);
    if (goal == null) return;
    await _repos.goals.save(GoalLogic.withdraw(goal, amount));
    state = _read();
  }

  // ---------------------------------------------------------------------------
  // Badges
  // ---------------------------------------------------------------------------

  Future<void> _checkBadges({bool silent = false}) async {
    final s = state;
    final earned = BadgeEngine.earned(
      BadgeInput(
        onboardingDone: s.isOnboarded,
        cycles: s.cycleData,
        transactions: s.transactions,
        goals: s.goals,
        bestStreak: s.streak.best,
        totalSaved: s.totalSaved,
      ),
    );
    final fresh = BadgeEngine.newlyUnlocked(earned, s.badges.keys.toSet());
    if (fresh.isEmpty) return;
    final now = _now();
    await Future.wait(fresh.map((k) => _repos.badges.unlock(k, now)));
    state = _read();
    if (!silent) {
      for (final k in fresh) {
        _celebrate(Celebration.badge(k));
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Data management
  // ---------------------------------------------------------------------------

  /// Everything as a JSON-ready map (for "Export data").
  Map<String, dynamic> exportData() {
    final s = state;
    return {
      'app': 'PehlaPaisa',
      'exportedAt': _now().toIso8601String(),
      'profile': s.profile?.toMap(),
      'settings': ref.read(settingsProvider).toMap(),
      'jars': s.jars.map((j) => j.toMap()).toList(),
      'cycles': s.cycles.map((c) => c.toMap()).toList(),
      'transactions': s.transactions.map((t) => t.toMap()).toList(),
      'goals': s.goals.map((g) => g.toMap()).toList(),
      'badges': [
        for (final e in s.badges.entries)
          BadgeRecord(id: e.key.name, key: e.key, unlockedAt: e.value).toMap(),
      ],
    };
  }

  /// Deletes all data, including settings.
  Future<void> resetAll() async {
    await _repos.clearBudgetData();
    await _repos.settings.clear();
    ref.invalidate(settingsProvider);
    ref.read(celebrationQueueProvider.notifier).clear();
    state = _read();
  }
}

final budgetProvider = NotifierProvider<BudgetController, BudgetState>(
  BudgetController.new,
);
