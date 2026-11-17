import 'package:flutter_test/flutter_test.dart';
import 'package:pehla_paisa/features/alerts/domain/alert_engine.dart';
import 'package:pehla_paisa/features/badges/data/badge.dart';
import 'package:pehla_paisa/features/badges/domain/badge_engine.dart';
import 'package:pehla_paisa/features/badges/domain/levels.dart';
import 'package:pehla_paisa/features/goals/data/goal.dart';
import 'package:pehla_paisa/features/jars/data/jar.dart';
import 'package:pehla_paisa/features/reports/domain/report_calculator.dart';
import 'package:pehla_paisa/features/salary/data/month_cycle.dart';
import 'package:pehla_paisa/features/salary/domain/cycle_data.dart';
import 'package:pehla_paisa/features/salary/domain/cycle_range.dart';
import 'package:pehla_paisa/features/salary/domain/month_rollover.dart';
import 'package:pehla_paisa/features/transactions/data/transaction.dart';

import '../helpers/fixtures.dart';

List<JarSnapshot> snap({
  int savingsAlloc = 2000,
  int savingsSpent = 0,
  int funAlloc = 1000,
  int funSpent = 500,
  int foodSpent = 2000,
}) => [
  JarSnapshot(
    jarId: 'jar_savings',
    type: JarType.savings,
    name: 'Savings',
    emoji: '🪙',
    allocated: savingsAlloc,
    spent: savingsSpent,
  ),
  const JarSnapshot(
    jarId: 'jar_rent',
    type: JarType.rent,
    name: 'Rent',
    emoji: '🏠',
    allocated: 3500,
    spent: 3500,
  ),
  JarSnapshot(
    jarId: 'jar_food',
    type: JarType.food,
    name: 'Food',
    emoji: '🍛',
    allocated: 2500,
    spent: foodSpent,
  ),
  const JarSnapshot(
    jarId: 'jar_travel',
    type: JarType.travel,
    name: 'Travel',
    emoji: '🛺',
    allocated: 1000,
    spent: 200,
  ),
  JarSnapshot(
    jarId: 'jar_fun',
    type: JarType.fun,
    name: 'Fun',
    emoji: '🎉',
    allocated: funAlloc,
    spent: funSpent,
  ),
];

Transaction expense(DateTime d, {String jar = 'jar_food', int amt = 100}) =>
    Transaction(
      id: testId(),
      jarId: jar,
      amount: amt,
      note: '',
      dateTime: d,
      type: TransactionType.expense,
      cycleId: '${d.year}-${d.month.toString().padLeft(2, '0')}',
    );

BadgeInput input({
  bool onboarding = true,
  List<CycleData> cycles = const [],
  List<Transaction> txns = const [],
  List<Goal> goals = const [],
  int best = 0,
  int total = 0,
}) => BadgeInput(
  onboardingDone: onboarding,
  cycles: cycles,
  transactions: txns,
  goals: goals,
  bestStreak: best,
  totalSaved: total,
);

void main() {
  group('BadgeEngine', () {
    test('Pehla Kadam after onboarding', () {
      expect(BadgeEngine.earned(input()), {BadgeKey.pehlaKadam});
      expect(BadgeEngine.earned(input(onboarding: false)), isEmpty);
    });

    test('Pehla Paisa when savings filled first', () {
      final e = BadgeEngine.earned(
        input(
          cycles: [
            CycleData(cycle(2026, 1, closed: false, income: 20000), snap()),
          ],
        ),
      );
      expect(e, contains(BadgeKey.pehlaPaisa));
    });

    test('streak badges at 3, 6, 12', () {
      expect(
        BadgeEngine.earned(input(best: 2)),
        isNot(contains(BadgeKey.streak3)),
      );
      expect(BadgeEngine.earned(input(best: 3)), contains(BadgeKey.streak3));
      final six = BadgeEngine.earned(input(best: 6));
      expect(six, containsAll([BadgeKey.streak3, BadgeKey.streak6]));
      expect(six, isNot(contains(BadgeKey.streak12)));
      expect(BadgeEngine.earned(input(best: 12)), contains(BadgeKey.streak12));
    });

    test('Gullak Master at ₹10,000 total saved', () {
      expect(
        BadgeEngine.earned(input(total: 9999)),
        isNot(contains(BadgeKey.gullakMaster)),
      );
      expect(
        BadgeEngine.earned(input(total: 10000)),
        contains(BadgeKey.gullakMaster),
      );
    });

    test('Goal Getter after the first completed goal', () {
      final g = Goal(
        id: 'g',
        name: 'x',
        emoji: '🎯',
        targetAmount: 100,
        savedAmount: 100,
        createdAt: DateTime(2026),
        completedAt: DateTime(2026, 2),
      );
      expect(
        BadgeEngine.earned(input(goals: [g])),
        contains(BadgeKey.goalGetter),
      );
    });

    test(
      'Fun Under Control: closed month, fun within budget, no borrowing',
      () {
        final ok = CycleData(cycle(2026, 1), snap());
        expect(BadgeEngine.funUnderControl(ok, const []), isTrue);

        final over = CycleData(cycle(2026, 1), snap(funSpent: 1200));
        expect(BadgeEngine.funUnderControl(over, const []), isFalse);

        final borrow = Transaction(
          id: 't',
          jarId: 'jar_fun',
          toJarId: 'jar_food',
          amount: 100,
          note: '',
          dateTime: DateTime(2026, 1, 10),
          type: TransactionType.transfer,
          cycleId: '2026-01',
        );
        expect(BadgeEngine.funUnderControl(ok, [borrow]), isFalse);

        final open = CycleData(cycle(2026, 1, closed: false), snap());
        expect(BadgeEngine.funUnderControl(open, const []), isFalse);
      },
    );

    test('Logger needs 7 consecutive days', () {
      final six = [
        for (var d = 1; d <= 6; d++) expense(DateTime(2026, 1, d, 12)),
      ];
      expect(BadgeEngine.longestLoggingRun(six), 6);
      final seven = [...six, expense(DateTime(2026, 1, 7, 9))];
      expect(BadgeEngine.longestLoggingRun(seven), 7);
      expect(BadgeEngine.earned(input(txns: seven)), contains(BadgeKey.logger));
      final gap = [...six, expense(DateTime(2026, 1, 8))];
      expect(BadgeEngine.longestLoggingRun(gap), 6);
      // two expenses on one day count once
      expect(
        BadgeEngine.longestLoggingRun([
          ...six,
          expense(DateTime(2026, 1, 6, 20)),
        ]),
        6,
      );
    });

    test('Bachat Champion at ≥ 25% saved', () {
      final c20 = CycleData(cycle(2026, 1, income: 10000), snap());
      expect(
        BadgeEngine.earned(input(cycles: [c20])),
        isNot(contains(BadgeKey.bachatChampion)),
      );
      final c25 = CycleData(
        cycle(2026, 1, income: 10000),
        snap(savingsAlloc: 2500),
      );
      expect(
        BadgeEngine.earned(input(cycles: [c25])),
        contains(BadgeKey.bachatChampion),
      );
      // broken savings lowers the share
      final broken = CycleData(
        cycle(2026, 1, income: 10000),
        snap(savingsAlloc: 2500, savingsSpent: 1000),
      );
      expect(
        BadgeEngine.earned(input(cycles: [broken])),
        isNot(contains(BadgeKey.bachatChampion)),
      );
    });

    test('newlyUnlocked only returns new keys', () {
      expect(
        BadgeEngine.newlyUnlocked(
          {BadgeKey.pehlaKadam, BadgeKey.logger},
          {BadgeKey.pehlaKadam},
        ),
        [BadgeKey.logger],
      );
    });
  });

  group('Levels', () {
    test('thresholds and progress', () {
      expect(Levels.forTotal(0).level, UserLevel.beginner);
      final half = Levels.forTotal(500);
      expect(half.progress, closeTo(0.5, 0.001));
      expect(half.toNext, 500);
      expect(Levels.forTotal(1000).level, UserLevel.saver);
      expect(Levels.forTotal(7000).level, UserLevel.smartSaver);
      expect(Levels.forTotal(10000).level, UserLevel.gullakMaster);
      final top = Levels.forTotal(80000);
      expect(top.level, UserLevel.legend);
      expect(top.next, isNull);
      expect(top.progress, 1);
    });
  });

  group('SavingsMath', () {
    test('total saved sums net savings of funded cycles', () {
      final a = CycleData(cycle(2026, 1), snap());
      final b = CycleData(
        cycle(2026, 2),
        snap(savingsAlloc: 3000, savingsSpent: 500),
      );
      final unfunded = CycleData(
        cycle(2026, 3, funded: false, closed: false),
        snap(),
      );
      expect(SavingsMath.totalSaved([a, b, unfunded]), 2000 + 2500);
      expect(SavingsMath.availableForGoals(4500, 5000), 0);
      expect(SavingsMath.availableForGoals(4500, 1000), 3500);
    });
  });

  group('AlertEngine', () {
    final range = CycleRange.forDate(DateTime(2026, 3, 1), 1);
    final funded = MonthRollover.newCycle(range).copyWith(funded: true);

    test('unfunded cycle asks to fill salary', () {
      final a = AlertEngine.compute(
        range: range,
        cycle: MonthRollover.newCycle(range),
        jars: jarsWith(),
        cycleTransactions: const [],
        now: DateTime(2026, 3, 2),
      );
      expect(a.single.kind, AlertKind.fillSalary);
    });

    test('low jar alert below 20% with > 7 days left', () {
      final jars = jarsWith()
          .map(
            (j) => j.type == JarType.food ? j.copyWith(spentAmount: 2100) : j,
          )
          .toList();
      final a = AlertEngine.compute(
        range: range,
        cycle: funded,
        jars: jars,
        cycleTransactions: const [],
        now: DateTime(2026, 3, 22), // 10 days left
      );
      final low = a.where((x) => x.kind == AlertKind.lowJar).single;
      expect(low.jarId, 'jar_food');
      expect(low.percentEmpty, 84);
      expect(low.daysLeft, 10);
    });

    test('no low jar alert with 7 or fewer days left', () {
      final jars = jarsWith()
          .map(
            (j) => j.type == JarType.food ? j.copyWith(spentAmount: 2100) : j,
          )
          .toList();
      final a = AlertEngine.compute(
        range: range,
        cycle: funded,
        jars: jars,
        cycleTransactions: const [],
        now: DateTime(2026, 3, 25), // 7 days left
      );
      expect(a.where((x) => x.kind == AlertKind.lowJar), isEmpty);
    });

    test('savings never triggers a low alert', () {
      final jars = jarsWith()
          .map((j) => j.isSavings ? j.copyWith(spentAmount: 1900) : j)
          .toList();
      final a = AlertEngine.compute(
        range: range,
        cycle: funded,
        jars: jars,
        cycleTransactions: const [],
        now: DateTime(2026, 3, 5),
      );
      expect(a, isEmpty);
    });

    test('weekly food limit = allocation ÷ weeks', () {
      // 31 days = 4.43 weeks; 2500 / 4.43 = 564.5 → 560
      expect(AlertEngine.weeklyFoodLimit(2500, range), 560);
    });

    test('warns when this cycle-week food spending is over the limit', () {
      final txns = [
        expense(DateTime(2026, 3, 8, 10), amt: 300),
        expense(DateTime(2026, 3, 10, 10), amt: 300),
        expense(DateTime(2026, 3, 7, 10), amt: 999), // previous week
      ];
      final a = AlertEngine.compute(
        range: range,
        cycle: funded,
        jars: jarsWith(),
        cycleTransactions: txns,
        now: DateTime(2026, 3, 11),
      );
      final w = a.where((x) => x.kind == AlertKind.foodWeekly).single;
      expect(w.spent, 600);
      expect(w.limit, 560);
    });

    test('weekly limits: every everyday glass, not Savings or Rent', () {
      final txns = [
        expense(DateTime(2026, 3, 9, 10), amt: 200), // food, this week
        expense(DateTime(2026, 3, 10, 10), jar: 'jar_fun', amt: 300),
        expense(DateTime(2026, 3, 2, 10), jar: 'jar_fun', amt: 999), // old
      ];
      final limits = AlertEngine.weeklyLimits(
        jars: jarsWith(),
        cycleTransactions: txns,
        range: range,
        now: DateTime(2026, 3, 11),
      );
      expect(limits.map((l) => l.jarId), ['jar_food', 'jar_travel', 'jar_fun']);
      final fun = limits.firstWhere((l) => l.jarId == 'jar_fun');
      // 1000 / (31/7 weeks) = 225.8 → ₹230
      expect(fun.limit, 230);
      expect(fun.spent, 300);
      expect(fun.isOver, isTrue);
      expect(fun.usedRatio, 1);
      final food = limits.firstWhere((l) => l.jarId == 'jar_food');
      expect(food.left, 560 - 200);
    });

    test('weekly food alert key changes every week', () {
      List<BudgetAlert> at(DateTime now, List<Transaction> t) =>
          AlertEngine.compute(
            range: range,
            cycle: funded,
            jars: jarsWith(),
            cycleTransactions: t,
            now: now,
          ).where((a) => a.kind == AlertKind.foodWeekly).toList();
      final w2 = at(DateTime(2026, 3, 9), [
        expense(DateTime(2026, 3, 9), amt: 900),
      ]).single;
      final w3 = at(DateTime(2026, 3, 16), [
        expense(DateTime(2026, 3, 16), amt: 900),
      ]).single;
      expect(w2.key('2026-03'), isNot(w3.key('2026-03')));
      // Low-glass alerts stay once per month.
      expect(
        const BudgetAlert(kind: AlertKind.lowJar, jarId: 'x').key('2026-03'),
        '2026-03:x:lowJar',
      );
    });

    test('weekly summary counts Monday → now', () {
      final txns = [
        expense(DateTime(2026, 3, 9, 10), amt: 100), // Monday
        expense(DateTime(2026, 3, 15, 10), amt: 50), // Sunday
        expense(DateTime(2026, 3, 8, 10), amt: 999), // previous Sunday
      ];
      expect(AlertEngine.spentThisWeek(txns, DateTime(2026, 3, 15, 19)), 150);
    });
  });

  group('ReportCalculator', () {
    test('builds savings %, best/worst and comparison', () {
      final prev = CycleData(cycle(2026, 1), snap(foodSpent: 2500));
      final cur = CycleData(cycle(2026, 2), snap());
      final r = ReportCalculator.build(cur, prev);
      expect(r.saved, 2000);
      expect(r.savedPercent, 20);
      expect(r.totalSpent, 3500 + 2000 + 200 + 500);
      expect(r.best!.type, JarType.travel); // 20% used
      expect(r.worst!.type, JarType.rent); // 100% used
      expect(r.previousSpent, 3500 + 2500 + 200 + 500);
      expect(r.spentChangePercent, -7);
      expect(r.savedChange, 0);
      expect(r.spending.first.type, JarType.rent);
    });

    test('last 6 months, oldest first', () {
      final all = [
        for (var m = 1; m <= 8; m++)
          CycleData(cycle(2026, m), snap(savingsAlloc: m * 100)),
      ];
      final six = ReportCalculator.lastMonths(all);
      expect(six.length, 6);
      expect(six.first.month, 3);
      expect(six.last.saved, 800);
    });
  });
}
