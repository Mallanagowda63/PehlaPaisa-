import 'package:flutter_test/flutter_test.dart';
import 'package:pehla_paisa/features/jars/data/jar.dart';
import 'package:pehla_paisa/features/transactions/data/transaction.dart';
import 'package:pehla_paisa/features/transactions/domain/overflow_planner.dart';

import '../helpers/fixtures.dart';

void main() {
  final jars =
      jarsWith(); // savings 2000, rent 3500, food 2500, travel 1000, fun 1000
  final food = jarOf(jars, JarType.food).id;
  final fun = jarOf(jars, JarType.fun).id;
  final travel = jarOf(jars, JarType.travel).id;
  final rent = jarOf(jars, JarType.rent).id;
  final savings = jarOf(jars, JarType.savings).id;

  group('plan', () {
    test('expense within balance needs no borrowing', () {
      final p = OverflowPlanner.plan(
        jars: jars,
        targetJarId: food,
        amount: 500,
      );
      expect(p.fromTarget, 500);
      expect(p.draws, isEmpty);
      expect(p.needsBorrowing, isFalse);
      expect(p.breaksSavings, isFalse);
    });

    test('shortfall is taken from Fun first', () {
      final p = OverflowPlanner.plan(
        jars: jars,
        targetJarId: food,
        amount: 3000,
      );
      expect(p.fromTarget, 2500);
      expect(p.draws, [Draw(fun, 500)]);
      expect(p.uncovered, 0);
    });

    test('then from other non-savings glasses in shelf order', () {
      final p = OverflowPlanner.plan(
        jars: jars,
        targetJarId: food,
        amount: 5000,
      );
      // 2500 food + 1000 fun + 1000 rent (order 1) + 500 travel? rent first
      expect(p.draws.first, Draw(fun, 1000));
      expect(p.draws[1], Draw(rent, 1500));
      expect(p.fromSavings, 0);
    });

    test('NEVER takes from savings automatically', () {
      final p = OverflowPlanner.plan(
        jars: jars,
        targetJarId: food,
        amount: 20000,
      );
      expect(p.draws.any((d) => d.jarId == savings), isFalse);
      expect(p.fromSavings, 0);
      expect(p.uncovered, 20000 - 2500 - 1000 - 3500 - 1000);
      expect(p.breaksSavings, isFalse);
    });

    test('a preferred source is used before Fun', () {
      final p = OverflowPlanner.plan(
        jars: jars,
        targetJarId: food,
        amount: 3000,
        preferredSourceId: travel,
      );
      expect(p.draws, [Draw(travel, 500)]);
    });

    test('preferring savings as a source is ignored', () {
      final p = OverflowPlanner.plan(
        jars: jars,
        targetJarId: food,
        amount: 3000,
        preferredSourceId: savings,
      );
      expect(p.draws, [Draw(fun, 500)]);
      expect(p.fromSavings, 0);
    });

    test('savings is only used with explicit allowSavings', () {
      final p = OverflowPlanner.plan(
        jars: jars,
        targetJarId: food,
        amount: 9000,
        allowSavings: true,
      );
      expect(p.fromSavings, 1000);
      expect(p.uncovered, 0);
      expect(p.breaksSavings, isTrue);
    });

    test(
      'choosing Savings explicitly takes the shortfall from Savings first',
      () {
        final p = OverflowPlanner.plan(
          jars: jars,
          targetJarId: food,
          amount: 3000,
          preferredSourceId: savings,
          allowSavings: true,
        );
        expect(p.fromSavings, 500);
        expect(p.draws, isEmpty);
        expect(p.breaksSavings, isTrue);
      },
    );

    test('expense straight from Savings is a break', () {
      final p = OverflowPlanner.plan(
        jars: jars,
        targetJarId: savings,
        amount: 300,
      );
      expect(p.targetIsSavings, isTrue);
      expect(p.breaksSavings, isTrue);
      expect(p.draws, isEmpty);
    });

    test('lenders lists non-savings glasses with money, Fun first', () {
      final l = OverflowPlanner.lenders(jars, food);
      expect(l.first.id, fun);
      expect(l.any((j) => j.isSavings), isFalse);
      expect(l.any((j) => j.id == food), isFalse);
    });
  });

  group('apply', () {
    test('moves borrowed money and records transfers', () {
      final plan = OverflowPlanner.plan(
        jars: jars,
        targetJarId: food,
        amount: 3000,
      );
      final out = OverflowPlanner.apply(
        jars: jars,
        plan: plan,
        note: 'groceries',
        dateTime: DateTime(2026, 3, 5),
        cycleId: '2026-03',
        newId: testId,
      );
      final f = jarOf(out.jars, JarType.food);
      final u = jarOf(out.jars, JarType.fun);
      expect(f.allocatedAmount, 3000);
      expect(f.spentAmount, 3000);
      expect(f.remaining, 0);
      expect(u.allocatedAmount, 500);
      expect(jarOf(out.jars, JarType.savings).allocatedAmount, 2000);
      expect(out.transfers.single.type, TransactionType.transfer);
      expect(out.transfers.single.jarId, fun);
      expect(out.transfers.single.toJarId, food);
      expect(out.expense.amount, 3000);
      expect(out.brokeSavings, isFalse);
    });

    test('breaking savings reduces the savings glass', () {
      final plan = OverflowPlanner.plan(
        jars: jars,
        targetJarId: food,
        amount: 9000,
        allowSavings: true,
      );
      final out = OverflowPlanner.apply(
        jars: jars,
        plan: plan,
        note: '',
        dateTime: DateTime(2026, 3, 5),
        cycleId: '2026-03',
        newId: testId,
      );
      expect(jarOf(out.jars, JarType.savings).allocatedAmount, 1000);
      expect(out.brokeSavings, isTrue);
    });

    test('uncovered expense leaves the glass overspent', () {
      final plan = OverflowPlanner.plan(
        jars: jars,
        targetJarId: food,
        amount: 20000,
      );
      final out = OverflowPlanner.apply(
        jars: jars,
        plan: plan,
        note: '',
        dateTime: DateTime(2026, 3, 5),
        cycleId: '2026-03',
        newId: testId,
      );
      expect(jarOf(out.jars, JarType.food).remaining, lessThan(0));
      expect(jarOf(out.jars, JarType.savings).remaining, 2000);
    });
  });
}
