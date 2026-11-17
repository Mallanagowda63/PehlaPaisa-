import 'package:flutter_test/flutter_test.dart';
import 'package:pehla_paisa/features/goals/data/goal.dart';
import 'package:pehla_paisa/features/goals/domain/goal_logic.dart';
import 'package:pehla_paisa/features/streaks/domain/streak_calculator.dart';

import '../helpers/fixtures.dart';

void main() {
  group('StreakCalculator', () {
    test('counts consecutive qualifying months', () {
      final r = StreakCalculator.compute([
        cycle(2026, 1),
        cycle(2026, 2),
        cycle(2026, 3),
      ]);
      expect(r.current, 3);
      expect(r.best, 3);
    });

    test('a broken month resets the current streak but keeps the best', () {
      final r = StreakCalculator.compute([
        cycle(2026, 1),
        cycle(2026, 2),
        cycle(2026, 3, broken: true),
        cycle(2026, 4),
      ]);
      expect(r.current, 1);
      expect(r.best, 2);
    });

    test('not filling savings first breaks the streak', () {
      final r = StreakCalculator.compute([
        cycle(2026, 1),
        cycle(2026, 2, filledFirst: false),
      ]);
      expect(r.current, 0);
      expect(r.best, 1);
    });

    test('a missing month breaks the streak', () {
      final r = StreakCalculator.compute([
        cycle(2026, 1),
        cycle(2026, 2),
        cycle(2026, 4),
      ]);
      expect(r.current, 1);
      expect(r.best, 2);
    });

    test('an unfunded open month is pending, not a break', () {
      final r = StreakCalculator.compute([
        cycle(2026, 1),
        cycle(2026, 2),
        cycle(2026, 3, funded: false, filledFirst: false, closed: false),
      ], currentCycleId: '2026-03');
      expect(r.current, 2);
    });

    test('streak is over when the last counted month is too old', () {
      final r = StreakCalculator.compute([
        cycle(2026, 1),
        cycle(2026, 2),
      ], currentCycleId: '2026-05');
      expect(r.current, 0);
      expect(r.best, 2);
    });

    test('crosses year boundaries', () {
      final r = StreakCalculator.compute([
        cycle(2025, 11),
        cycle(2025, 12),
        cycle(2026, 1),
      ]);
      expect(r.current, 3);
    });

    test('empty history', () {
      final r = StreakCalculator.compute([]);
      expect(r.current, 0);
      expect(r.best, 0);
    });
  });

  group('GoalLogic', () {
    final goal = Goal(
      id: 'g',
      name: 'Phone',
      emoji: '📱',
      targetAmount: 12000,
      savedAmount: 2000,
      createdAt: DateTime(2026, 1, 1),
    );

    test('emergency fund = 3 × (income − savings)', () {
      expect(
        GoalLogic.suggestedEmergencyFund(
          monthlyIncome: 10000,
          monthlySavings: 2000,
        ),
        24000,
      );
    });

    test('months to reach rounds up', () {
      expect(GoalLogic.monthsToReach(remaining: 10000, monthlyRate: 2000), 5);
      expect(GoalLogic.monthsToReach(remaining: 10001, monthlyRate: 2000), 6);
      expect(GoalLogic.monthsToReach(remaining: 0, monthlyRate: 2000), 0);
      expect(GoalLogic.monthsToReach(remaining: 100, monthlyRate: 0), isNull);
    });

    test('required monthly to hit a date', () {
      final m = GoalLogic.requiredMonthly(
        remaining: 6000,
        targetDate: DateTime(2026, 7, 1),
        now: DateTime(2026, 1, 1),
      );
      expect(m, 1000);
    });

    test('deposit is limited by available savings and remaining need', () {
      var r = GoalLogic.deposit(
        goal: goal,
        amount: 5000,
        available: 3000,
        now: DateTime(2026),
      );
      expect(r.moved, 3000);
      expect(r.goal.savedAmount, 5000);
      expect(r.justCompleted, isFalse);

      r = GoalLogic.deposit(
        goal: goal,
        amount: 50000,
        available: 50000,
        now: DateTime(2026),
      );
      expect(r.moved, 10000);
      expect(r.goal.savedAmount, 12000);
      expect(r.justCompleted, isTrue);
      expect(r.goal.completedAt, isNotNull);
      expect(r.goal.isComplete, isTrue);
    });

    test('withdraw clears completion', () {
      final done = goal.copyWith(
        savedAmount: 12000,
        completedAt: DateTime(2026),
      );
      final w = GoalLogic.withdraw(done, 1000);
      expect(w.savedAmount, 11000);
      expect(w.completedAt, isNull);
    });
  });
}
