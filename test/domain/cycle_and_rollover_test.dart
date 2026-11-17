import 'package:flutter_test/flutter_test.dart';
import 'package:pehla_paisa/features/jars/data/jar.dart';
import 'package:pehla_paisa/features/salary/domain/cycle_range.dart';
import 'package:pehla_paisa/features/salary/domain/month_rollover.dart';

import '../helpers/fixtures.dart';

void main() {
  group('CycleRange', () {
    test('salary day 1', () {
      final r = CycleRange.forDate(DateTime(2026, 3, 15), 1);
      expect(r.start, DateTime(2026, 3, 1));
      expect(r.end, DateTime(2026, 3, 31));
      expect(r.id, '2026-03');
      expect(r.totalDays, 31);
    });

    test('before the salary day belongs to the previous cycle', () {
      final r = CycleRange.forDate(DateTime(2026, 3, 4), 7);
      expect(r.start, DateTime(2026, 2, 7));
      expect(r.end, DateTime(2026, 3, 6));
      expect(r.id, '2026-02');
    });

    test('on the salary day starts a new cycle', () {
      final r = CycleRange.forDate(DateTime(2026, 3, 7, 23), 7);
      expect(r.start, DateTime(2026, 3, 7));
    });

    test('salary day 31 falls on the last day of short months', () {
      final r = CycleRange.forDate(DateTime(2026, 2, 28), 31);
      expect(r.start, DateTime(2026, 2, 28));
      expect(r.end, DateTime(2026, 3, 30));
      final jan = CycleRange.forDate(DateTime(2026, 2, 10), 31);
      expect(jan.start, DateTime(2026, 1, 31));
      expect(jan.end, DateTime(2026, 2, 27));
    });

    test('year boundary', () {
      final r = CycleRange.forDate(DateTime(2027, 1, 3), 25);
      expect(r.start, DateTime(2026, 12, 25));
      expect(r.end, DateTime(2027, 1, 24));
      expect(r.id, '2026-12');
    });

    test('next salary date', () {
      // Before the salary day → this month.
      expect(
        CycleRange.nextSalaryDate(DateTime(2026, 11, 5), 10),
        DateTime(2026, 11, 10),
      );
      // On the salary day → today.
      expect(
        CycleRange.nextSalaryDate(DateTime(2026, 11, 10, 18), 10),
        DateTime(2026, 11, 10),
      );
      // After it → next month.
      expect(
        CycleRange.nextSalaryDate(DateTime(2026, 11, 11), 10),
        DateTime(2026, 12, 10),
      );
      // Year change.
      expect(
        CycleRange.nextSalaryDate(DateTime(2026, 12, 20), 10),
        DateTime(2027, 1, 10),
      );
      // Day 31 in a 30-day month and in February.
      expect(
        CycleRange.nextSalaryDate(DateTime(2026, 11, 2), 31),
        DateTime(2026, 11, 30),
      );
      expect(
        CycleRange.nextSalaryDate(DateTime(2027, 2, 1), 31),
        DateTime(2027, 2, 28),
      );
    });

    test('days left includes today', () {
      final r = CycleRange.forDate(DateTime(2026, 3, 1), 1);
      expect(r.daysLeft(DateTime(2026, 3, 31)), 1);
      expect(r.daysLeft(DateTime(2026, 3, 22)), 10);
      expect(r.daysLeft(DateTime(2026, 4, 5)), 0);
    });
  });

  group('MonthRollover', () {
    test('first launch opens a cycle', () {
      final r = MonthRollover.check(
        active: null,
        jars: jarsWith(),
        now: DateTime(2026, 3, 10),
        salaryDay: 1,
      )!;
      expect(r.closed, isNull);
      expect(r.opened.id, '2026-03');
      expect(r.opened.funded, isFalse);
    });

    test('same cycle → no rollover', () {
      final active = MonthRollover.newCycle(
        CycleRange.forDate(DateTime(2026, 3, 1), 1),
      );
      expect(
        MonthRollover.check(
          active: active,
          jars: jarsWith(),
          now: DateTime(2026, 3, 31, 23, 59),
          salaryDay: 1,
        ),
        isNull,
      );
    });

    test(
      'new month closes the old cycle with a snapshot and empties glasses',
      () {
        final active = MonthRollover.newCycle(
          CycleRange.forDate(DateTime(2026, 3, 1), 1),
        ).copyWith(funded: true, income: 10000);
        final jars = jarsWith()
            .map((j) => j.copyWith(spentAmount: 100))
            .toList();
        final r = MonthRollover.check(
          active: active,
          jars: jars,
          now: DateTime(2026, 4, 1),
          salaryDay: 1,
        )!;
        expect(r.closed!.closed, isTrue);
        expect(r.closed!.jarsSnapshot.length, 5);
        expect(r.closed!.jarsSnapshot.first.spent, 100);
        expect(r.opened.id, '2026-04');
        expect(r.jars.every((j) => j.allocatedAmount == 0), isTrue);
        expect(r.jars.every((j) => j.spentAmount == 0), isTrue);
        // the plan survives the rollover
        expect(jarOf(r.jars, JarType.savings).plannedAmount, 2000);
      },
    );

    test('changing the salary day never overlaps the closed cycle', () {
      final active = MonthRollover.newCycle(
        CycleRange.forDate(DateTime(2026, 11, 1), 1),
      );
      final r = MonthRollover.check(
        active: active,
        jars: jarsWith(),
        now: DateTime(2026, 12, 1),
        salaryDay: 25,
      )!;
      expect(r.opened.startDate, DateTime(2026, 12, 1));
      expect(r.opened.endDate, DateTime(2026, 12, 24));
      expect(r.opened.id, '2026-12');
    });
  });

  group('Funding (salary day + irregular income)', () {
    final base = MonthRollover.newCycle(
      CycleRange.forDate(DateTime(2026, 3, 1), 1),
    );
    final empty = jarsWith()
        .map((j) => j.copyWith(allocatedAmount: 0))
        .toList();

    test('salary fill pours savings and marks savingsFilledFirst', () {
      final r = Funding.fund(
        cycle: base,
        jars: empty,
        amount: 10000,
        now: DateTime(2026, 3, 1, 10),
        transactionId: 'inc1',
      );
      expect(r.firstFill, isTrue);
      expect(r.cycle.savingsFilledFirst, isTrue);
      expect(r.cycle.savingsFilledAt, DateTime(2026, 3, 1, 10));
      expect(r.cycle.funded, isTrue);
      expect(r.cycle.income, 10000);
      expect(jarOf(r.jars, JarType.savings).allocatedAmount, 2000);
      expect(r.incomeTransaction.amount, 10000);
    });

    test('irregular: each entry is split with the same percentages', () {
      final first = Funding.fund(
        cycle: base,
        jars: empty,
        amount: 3000,
        now: DateTime(2026, 3, 2),
        transactionId: 'a',
      );
      final second = Funding.fund(
        cycle: first.cycle,
        jars: first.jars,
        amount: 2000,
        now: DateTime(2026, 3, 12),
        transactionId: 'b',
      );
      expect(second.firstFill, isFalse);
      expect(second.cycle.income, 5000);
      expect(jarOf(second.jars, JarType.savings).allocatedAmount, 600 + 400);
      expect(jarOf(second.jars, JarType.rent).allocatedAmount, 1050 + 700);
      final total = second.jars.fold<int>(0, (a, j) => a + j.allocatedAmount);
      expect(total, 5000);
      expect(second.cycle.savingsFilledFirst, isTrue);
    });

    test('spending before filling means savings was not first', () {
      final r = Funding.fund(
        cycle: base,
        jars: empty,
        amount: 10000,
        now: DateTime(2026, 3, 5),
        transactionId: 'x',
        spentBeforeFilling: true,
      );
      expect(r.cycle.savingsFilledFirst, isFalse);
    });

    test('a zero savings plan does not count as paying yourself first', () {
      final noSavings = empty
          .map((j) => j.isSavings ? j.copyWith(plannedAmount: 0) : j)
          .toList();
      final r = Funding.fund(
        cycle: base,
        jars: noSavings,
        amount: 8000,
        now: DateTime(2026, 3, 5),
        transactionId: 'x',
      );
      expect(r.cycle.savingsFilledFirst, isFalse);
    });
  });
}
