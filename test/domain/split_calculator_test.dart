import 'package:flutter_test/flutter_test.dart';
import 'package:pehla_paisa/features/jars/data/jar.dart';
import 'package:pehla_paisa/features/salary/domain/split_calculator.dart';

import '../helpers/fixtures.dart';

int total(Map<dynamic, int> m) => m.values.fold(0, (a, b) => a + b);

void main() {
  group('SplitCalculator.suggest – income bands', () {
    test('≤ ₹7,000 uses 10/40/30/12/8', () {
      final s = SplitCalculator.suggest(6000, livesWithFamily: false);
      expect(s[JarType.savings], 600);
      expect(s[JarType.rent], 2400);
      expect(s[JarType.food], 1800);
      expect(s[JarType.travel], 720);
      expect(s[JarType.fun], 480);
      expect(total(s), 6000);
    });

    test('exactly ₹7,000 is still the low band', () {
      final s = SplitCalculator.suggest(7000, livesWithFamily: false);
      expect(s[JarType.savings], 700);
      expect(s[JarType.rent], 2800);
    });

    test('₹7,001–₹15,000 uses 20/35/25/10/10', () {
      final s = SplitCalculator.suggest(10000, livesWithFamily: false);
      expect(s[JarType.savings], 2000);
      expect(s[JarType.rent], 3500);
      expect(s[JarType.food], 2500);
      expect(s[JarType.travel], 1000);
      expect(s[JarType.fun], 1000);
    });

    test('exactly ₹15,000 is the middle band', () {
      final s = SplitCalculator.suggest(15000, livesWithFamily: false);
      expect(s[JarType.savings], 3000);
    });

    test('> ₹15,000 uses 25/30/20/10/15', () {
      final s = SplitCalculator.suggest(20000, livesWithFamily: false);
      expect(s[JarType.savings], 5000);
      expect(s[JarType.rent], 6000);
      expect(s[JarType.food], 4000);
      expect(s[JarType.travel], 2000);
      expect(s[JarType.fun], 3000);
    });
  });

  group('family mode', () {
    test('halves rent and moves the freed half to savings', () {
      final s = SplitCalculator.suggest(10000, livesWithFamily: true);
      // rent 35% → 17.5%, savings 20% → 37.5%
      expect(s[JarType.rent], 1750);
      expect(s[JarType.savings], 3750);
      expect(total(s), 10000);
    });

    test('low band family mode', () {
      final s = SplitCalculator.suggest(5000, livesWithFamily: true);
      expect(s[JarType.rent], 1000); // 20%
      expect(s[JarType.savings], 1500); // 30%
      expect(total(s), 5000);
    });
  });

  group('rounding', () {
    test('every non-fun glass is a multiple of ₹10', () {
      for (final income in [5000, 6789, 7001, 12345, 15001, 29999, 30000]) {
        for (final fam in [true, false]) {
          final s = SplitCalculator.suggest(income, livesWithFamily: fam);
          for (final e in s.entries) {
            if (e.key == JarType.fun) continue;
            expect(e.value % 10, 0, reason: '$income $fam ${e.key}');
          }
          expect(total(s), income, reason: 'total must equal income');
          expect(s[JarType.fun]! >= 0, isTrue);
        }
      }
    });

    test('fun absorbs the rounding difference', () {
      final s = SplitCalculator.suggest(12345, livesWithFamily: false);
      // 20% 2469 → 2470, 35% 4320.75 → 4320, 25% 3086.25 → 3090,
      // 10% 1234.5 → 1230 (round half: 123.45 → 123)
      expect(s[JarType.savings], 2470);
      expect(s[JarType.rent], 4320);
      expect(s[JarType.food], 3090);
      expect(s[JarType.travel], 1230);
      expect(s[JarType.fun], 12345 - 2470 - 4320 - 3090 - 1230);
    });

    test('zero income gives zeros', () {
      final s = SplitCalculator.suggest(0, livesWithFamily: false);
      expect(total(s), 0);
    });

    test('tiny incomes never make fun negative', () {
      for (var income = 1; income < 200; income++) {
        final s = SplitCalculator.suggest(income, livesWithFamily: false);
        expect(total(s), income);
        expect(s.values.every((v) => v >= 0), isTrue, reason: '$income');
      }
    });
  });

  group('minimum savings', () {
    test('below 5% needs confirmation', () {
      expect(SplitCalculator.isSavingsBelowMinimum(400, 10000), isTrue);
      expect(SplitCalculator.isSavingsBelowMinimum(500, 10000), isFalse);
      expect(SplitCalculator.isSavingsBelowMinimum(0, 0), isFalse);
    });

    test('minimumSavings rounds up to ₹10', () {
      expect(SplitCalculator.minimumSavings(10000), 500);
      expect(SplitCalculator.minimumSavings(6789), 340);
      expect(
        SplitCalculator.isSavingsBelowMinimum(
          SplitCalculator.minimumSavings(6789),
          6789,
        ),
        isFalse,
      );
    });
  });

  group('slider adjust', () {
    final base = {'s': 2000, 'r': 3500, 'f': 1000};

    test('moving a glass changes the balancer and keeps the total', () {
      final m = SplitCalculator.adjust(
        amounts: base,
        jarId: 's',
        newAmount: 2500,
        balancerId: 'f',
      );
      expect(m['s'], 2500);
      expect(m['f'], 500);
      expect(total(m), total(base));
    });

    test('cannot take more than the balancer has', () {
      final m = SplitCalculator.adjust(
        amounts: base,
        jarId: 'r',
        newAmount: 9000,
        balancerId: 'f',
      );
      expect(m['r'], 4500);
      expect(m['f'], 0);
    });

    test('cannot go below zero', () {
      final m = SplitCalculator.adjust(
        amounts: base,
        jarId: 's',
        newAmount: -50,
        balancerId: 'f',
      );
      expect(m['s'], 0);
      expect(m['f'], 3000);
    });
  });

  group('splitAcrossJars (irregular income)', () {
    test('returns the plan exactly when amount equals the plan total', () {
      final jars = jarsWith();
      final split = SplitCalculator.splitAcrossJars(10000, jars);
      expect(split[jarOf(jars, JarType.savings).id], 2000);
      expect(split[jarOf(jars, JarType.fun).id], 1000);
    });

    test('splits a partial entry with the same percentages', () {
      final jars = jarsWith();
      final split = SplitCalculator.splitAcrossJars(3000, jars);
      expect(split[jarOf(jars, JarType.savings).id], 600); // 20%
      expect(split[jarOf(jars, JarType.rent).id], 1050); // 35%
      expect(split[jarOf(jars, JarType.food).id], 750); // 25%
      expect(split[jarOf(jars, JarType.travel).id], 300);
      expect(split[jarOf(jars, JarType.fun).id], 300);
      expect(total(split), 3000);
    });

    test('odd amounts still sum exactly', () {
      final jars = jarsWith();
      for (final amt in [1, 7, 99, 1234, 4567, 9999]) {
        final split = SplitCalculator.splitAcrossJars(amt, jars);
        expect(total(split), amt);
        expect(split.values.every((v) => v >= 0), isTrue);
      }
    });
  });
}
