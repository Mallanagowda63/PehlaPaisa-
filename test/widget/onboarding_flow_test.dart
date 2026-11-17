import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pehla_paisa/app/state/repositories.dart';
import 'package:pehla_paisa/features/badges/data/badge.dart';
import 'package:pehla_paisa/features/jars/data/jar.dart';
import 'package:pehla_paisa/features/onboarding/data/user_profile.dart';

import 'harness.dart';

void main() {
  testWidgets(
    'onboarding → salary day ritual → shelf',
    (tester) async {
      final repos = Repositories.inMemory();
      await pumpApp(tester, repos: repos, location: '/onboarding');

      // Intro.
      expect(find.text('Save first, always'), findsOneWidget);
      await tester.tap(find.byKey(const Key('onb_next')));
      await tester.pumpAndSettle();

      // Step 1: name (empty name is rejected).
      expect(find.text('Step 1 of 4'), findsOneWidget);
      await tester.tap(find.byKey(const Key('onb_next')));
      await tester.pumpAndSettle();
      expect(find.text('Please enter your name'), findsOneWidget);
      await tester.enterText(find.byKey(const Key('onb_name')), 'Asha');
      await tester.tap(find.byKey(const Key('onb_next')));
      await tester.pumpAndSettle();

      // Step 2: income, salary day, income type.
      expect(find.text('Step 2 of 4'), findsOneWidget);
      await tester.enterText(find.byKey(const Key('onb_income')), '10000');
      await tester.tap(find.byKey(const Key('onb_next')));
      await tester.pumpAndSettle();

      // Step 3: family (Continue disabled until answered).
      expect(find.text('Do you live with family?'), findsOneWidget);
      await tester.tap(find.byKey(const Key('onb_family_no')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('onb_next')));
      await tester.pumpAndSettle();

      // Step 4: suggested split for ₹10,000 → 20/35/25/10/10.
      expect(find.text('Your suggested split'), findsOneWidget);
      expect(find.text('₹2,000'), findsOneWidget); // savings
      expect(find.text('₹3,500'), findsOneWidget); // rent
      expect(find.text('₹2,500'), findsOneWidget); // food
      await tester.tap(find.byKey(const Key('onb_finish')));
      await tester.pumpAndSettle();

      final profile = repos.profile.read()!;
      expect(profile.name, 'Asha');
      expect(profile.monthlyIncome, 10000);
      expect(profile.incomeType, IncomeType.fixed);
      expect(repos.jars.byType(JarType.savings)!.plannedAmount, 2000);

      // Salary day screen: Savings must be filled first.
      expect(find.text('Salary day!'), findsOneWidget);
      await tester.tap(find.byKey(const Key('fill_savings_first')));
      await tester.pumpAndSettle();
      expect(find.text('All glasses filled!'), findsOneWidget);

      final cycle = repos.cycles.active()!;
      expect(cycle.funded, isTrue);
      expect(cycle.savingsFilledFirst, isTrue);
      expect(repos.jars.byType(JarType.savings)!.allocatedAmount, 2000);
      expect(repos.jars.byType(JarType.fun)!.allocatedAmount, 1000);

      await tester.tap(find.byKey(const Key('salary_go_shelf')));
      await tester.pumpAndSettle();
      await dismissCelebrations(tester);

      // Badges for onboarding + first savings-first fill.
      expect(repos.badges.isUnlocked(BadgeKey.pehlaKadam), isTrue);
      expect(repos.badges.isUnlocked(BadgeKey.pehlaPaisa), isTrue);

      // Back on the shelf with ₹8,000 left to spend.
      expect(find.text('₹8,000'), findsOneWidget);
    },
    variant: const TargetPlatformVariant({
      TargetPlatform.android,
      TargetPlatform.iOS,
    }),
  );
}
