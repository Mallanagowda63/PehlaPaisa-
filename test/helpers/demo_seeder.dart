import 'dart:math' as math;

import 'package:pehla_paisa/core/money.dart';
import 'package:pehla_paisa/features/goals/data/goal.dart';
import 'package:pehla_paisa/features/jars/data/jar.dart';
import 'package:pehla_paisa/features/jars/domain/jar_factory.dart';
import 'package:pehla_paisa/features/onboarding/data/user_profile.dart';
import 'package:pehla_paisa/features/salary/data/month_cycle.dart';
import 'package:pehla_paisa/features/salary/domain/cycle_range.dart';
import 'package:pehla_paisa/features/salary/domain/month_rollover.dart';
import 'package:pehla_paisa/features/salary/domain/split_calculator.dart';
import 'package:pehla_paisa/features/transactions/data/transaction.dart';

/// A complete set of demo records.
class DemoData {
  const DemoData({
    required this.profile,
    required this.jars,
    required this.cycles,
    required this.transactions,
    required this.goals,
  });

  final UserProfile profile;
  final List<Jar> jars;
  final List<MonthCycle> cycles;
  final List<Transaction> transactions;
  final List<Goal> goals;
}

/// Test helper: generates 6 months of realistic, internally consistent data
/// so screenshot tests can show every screen, chart and most badges.
///
/// Deterministic for a given [income] and [now] (seeded random).
abstract final class DemoSeeder {
  static const Map<JarType, List<String>> _notes = {
    JarType.rent: ['Room rent', 'Electricity bill', 'Wi-Fi'],
    JarType.food: [
      'Sabzi',
      'Chai & snacks',
      'Groceries',
      'Tiffin',
      'Milk',
      'Dosa with friends',
    ],
    JarType.travel: ['Metro', 'Auto', 'Bus pass', 'Mobile recharge', 'Petrol'],
    JarType.fun: [
      'Movie',
      'Ice cream',
      'Cricket ball',
      'Gift',
      'Biryani treat',
    ],
  };

  static DemoData generate({required int income, required DateTime now}) {
    final rnd = math.Random(income);
    var idCounter = 0;
    String id() => 'demo_${idCounter++}';

    final plan = SplitCalculator.suggest(income, livesWithFamily: false);
    var jars = JarFactory.defaultJars(plan);
    final currentRange = CycleRange.forDate(now, 1);

    final cycles = <MonthCycle>[];
    final txns = <Transaction>[];

    // Five closed months, then the current one.
    for (var back = 5; back >= 0; back--) {
      final start = DateTime(
        currentRange.start.year,
        currentRange.start.month - back,
        1,
      );
      final range = CycleRange.forDate(start, 1);
      final isCurrent = back == 0;
      final lastDay = isCurrent ? now.day : range.totalDays;

      // One month saves extra (Bachat Champion): 30% to savings.
      final alloc = <JarType, int>{...plan};
      if (back == 2) {
        final extra = roundTo10(income * 0.30) - plan[JarType.savings]!;
        alloc[JarType.savings] = plan[JarType.savings]! + extra;
        alloc[JarType.fun] = plan[JarType.fun]! - extra;
        if (alloc[JarType.fun]! < 0) {
          alloc[JarType.rent] = alloc[JarType.rent]! + alloc[JarType.fun]!;
          alloc[JarType.fun] = 0;
        }
      }

      final spent = {for (final t in JarDefaults.fillOrder) t: 0};
      final fill = DateTime(range.start.year, range.start.month, 1, 9);
      txns.add(
        Transaction(
          id: id(),
          jarId: '',
          amount: income,
          note: '',
          dateTime: fill,
          type: TransactionType.income,
          cycleId: range.id,
        ),
      );

      void spend(JarType t, int day, int amount) {
        if (amount <= 0 || day > lastDay) return;
        final notes = _notes[t]!;
        spent[t] = spent[t]! + amount;
        txns.add(
          Transaction(
            id: id(),
            jarId: JarDefaults.idFor(t),
            amount: amount,
            note: notes[rnd.nextInt(notes.length)],
            dateTime: DateTime(
              range.start.year,
              range.start.month,
              day,
              8 + rnd.nextInt(13),
              rnd.nextInt(60),
            ),
            type: TransactionType.expense,
            cycleId: range.id,
          ),
        );
      }

      // Rent & bills early in the month.
      spend(JarType.rent, 2, roundTo10(alloc[JarType.rent]! * 0.85));
      spend(JarType.rent, 10, roundTo10(alloc[JarType.rent]! * 0.12));

      // Food almost every day (gives the Logger badge in the current month).
      final foodTarget = alloc[JarType.food]! * (0.75 + rnd.nextDouble() * 0.2);
      final perDay = foodTarget / range.totalDays;
      for (var d = 1; d <= range.totalDays; d++) {
        if (!isCurrent && rnd.nextInt(5) == 0) continue;
        spend(JarType.food, d, roundTo10(perDay * (0.6 + rnd.nextDouble())));
      }

      // Travel a few times a week.
      for (var d = 3; d <= range.totalDays; d += 3 + rnd.nextInt(3)) {
        spend(
          JarType.travel,
          d,
          roundTo10(alloc[JarType.travel]! * (0.08 + rnd.nextDouble() * 0.1)),
        );
      }

      // Fun at weekends-ish.
      for (var d = 6; d <= range.totalDays; d += 7) {
        spend(
          JarType.fun,
          d,
          roundTo10(alloc[JarType.fun]! * (0.12 + rnd.nextDouble() * 0.12)),
        );
      }

      // One month: a big food expense that borrows from Fun.
      if (back == 3) {
        final foodLeft = alloc[JarType.food]! - spent[JarType.food]!;
        final borrow = roundTo10(alloc[JarType.fun]! * 0.2);
        alloc[JarType.food] = alloc[JarType.food]! + borrow;
        alloc[JarType.fun] = alloc[JarType.fun]! - borrow;
        txns.add(
          Transaction(
            id: id(),
            jarId: JarDefaults.idFor(JarType.fun),
            toJarId: JarDefaults.idFor(JarType.food),
            amount: borrow,
            note: '',
            dateTime: DateTime(range.start.year, range.start.month, 20, 19),
            type: TransactionType.transfer,
            cycleId: range.id,
          ),
        );
        spend(JarType.food, 20, foodLeft + borrow);
      }

      // Never let a demo glass go negative.
      for (final t in JarDefaults.fillOrder) {
        if (spent[t]! > alloc[t]!) alloc[t] = spent[t]!;
      }

      var cycle = MonthRollover.newCycle(range).copyWith(
        income: alloc.values.fold<int>(0, (a, b) => a + b),
        funded: true,
        savingsFilledFirst: true,
        savingsFilledAt: fill,
        closed: !isCurrent,
      );

      final monthJars = jars
          .map(
            (j) => j.copyWith(
              allocatedAmount: alloc[j.type] ?? 0,
              spentAmount: spent[j.type] ?? 0,
            ),
          )
          .toList();
      if (!isCurrent) {
        cycle = cycle.copyWith(
          jarsSnapshot: monthJars.map(JarSnapshot.fromJar).toList(),
        );
      } else {
        jars = monthJars;
      }
      cycles.add(cycle);
    }

    final savings = plan[JarType.savings]!;
    final emergency = 3 * (income - savings);
    final phone = income >= 10000 ? 3000 : 1200;
    final goals = [
      Goal(
        id: id(),
        name: 'New Phone',
        emoji: '📱',
        targetAmount: phone,
        savedAmount: phone,
        createdAt: DateTime(now.year, now.month - 5, 3),
        completedAt: DateTime(now.year, now.month - 2, 2),
      ),
      Goal(
        id: id(),
        name: 'Emergency Fund',
        emoji: '🛟',
        targetAmount: emergency,
        savedAmount: roundTo10(savings * 2.5),
        createdAt: DateTime(now.year, now.month - 5, 1),
      ),
      Goal(
        id: id(),
        name: 'Goa Trip',
        emoji: '🏖️',
        targetAmount: income,
        savedAmount: roundTo10(savings * 0.5),
        targetDate: DateTime(now.year + 1, 5, 1),
        createdAt: DateTime(now.year, now.month - 1, 5),
      ),
    ];

    final profile = UserProfile(
      name: 'Demo',
      monthlyIncome: income,
      salaryDay: 1,
      livesWithFamily: false,
      incomeType: IncomeType.fixed,
      language: 'en',
      createdAt: DateTime(now.year, now.month - 5, 1),
      onboardingDone: true,
    );

    return DemoData(
      profile: profile,
      jars: jars,
      cycles: cycles,
      transactions: txns,
      goals: goals,
    );
  }
}
