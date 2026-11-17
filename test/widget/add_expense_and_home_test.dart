import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pehla_paisa/features/jars/data/jar.dart';
import 'package:pehla_paisa/features/transactions/data/transaction.dart';

import 'harness.dart';

Future<void> typeAmount(WidgetTester tester, String digits) async {
  for (final d in digits.split('')) {
    await tester.tap(find.text(d).last);
    await tester.pump();
  }
}

void main() {
  group('home shelf', () {
    testWidgets('renders every glass with accessible labels', (tester) async {
      final repos = await seededRepos();
      final handle = tester.ensureSemantics();
      await pumpApp(tester, repos: repos, location: '/home');

      // Total left to spend excludes Savings: 3500 + 2500 + 1000 + 1000.
      expect(find.text('₹8,000'), findsOneWidget);
      expect(find.text('🔥 1'), findsOneWidget);

      for (final label in [
        'Savings glass, ₹2,000 left of ₹2,000',
        'Rent & Bills glass, ₹3,500 left of ₹3,500',
        'Food glass, ₹2,500 left of ₹2,500',
        'Travel & Phone glass, ₹1,000 left of ₹1,000',
        'Fun glass, ₹1,000 left of ₹1,000',
      ]) {
        expect(find.bySemanticsLabel(label), findsOneWidget, reason: label);
      }
      handle.dispose();
    });

    testWidgets('family mode calls Rent "Home contribution"', (tester) async {
      final repos = await seededRepos(family: true);
      await pumpApp(tester, repos: repos, location: '/home');
      expect(find.textContaining('Home contribution'), findsOneWidget);
    });

    testWidgets('renders in Hindi', (tester) async {
      final repos = await seededRepos(language: 'hi');
      await pumpApp(tester, repos: repos, location: '/home');
      expect(find.textContaining('खाना'), findsOneWidget);
      expect(find.text('इस महीने खर्च के लिए बाक़ी'), findsOneWidget);
    });

    testWidgets('survives large system font scaling on a small phone', (
      tester,
    ) async {
      final repos = await seededRepos();
      tester.platformDispatcher.textScaleFactorTestValue = 1.4;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await pumpApp(tester, repos: repos, location: '/home');
      expect(tester.takeException(), isNull);
      await tester.tap(find.byKey(const Key('home_add_expense')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('works on a large screen too', (tester) async {
      final repos = await seededRepos();
      await pumpApp(
        tester,
        repos: repos,
        location: '/home',
        size: const Size(800, 1280),
      );
      expect(find.text('₹8,000'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('add expense', () {
    testWidgets(
      'logs an expense in ≤ 3 taps and drains the glass',
      (tester) async {
        final repos = await seededRepos();
        await pumpApp(tester, repos: repos, location: '/home');

        await tester.tap(find.byKey(const Key('home_add_expense')));
        await tester.pumpAndSettle();
        expect(find.text('Add expense'), findsWidgets);

        await typeAmount(tester, '500');
        expect(find.text('₹500'), findsOneWidget);
        // Food is preselected.
        await tester.tap(find.byKey(const Key('save_expense')));
        await tester.pumpAndSettle();

        final food = repos.jars.byType(JarType.food)!;
        expect(food.spentAmount, 500);
        expect(food.remaining, 2000);
        final expenses = repos.transactions
            .getAll()
            .where((t) => t.isExpense)
            .toList();
        expect(expenses.single.amount, 500);
        expect(find.text('₹500 spent from Food'), findsOneWidget);
        expect(find.text('₹7,500'), findsOneWidget);
      },
      variant: const TargetPlatformVariant({
        TargetPlatform.android,
        TargetPlatform.iOS,
      }),
    );

    testWidgets(
      'overspending borrows from Fun first, never from Savings',
      (tester) async {
        final repos = await seededRepos();
        await pumpApp(tester, repos: repos, location: '/home');

        await tester.tap(find.byKey(const Key('home_add_expense')));
        await tester.pumpAndSettle();
        await typeAmount(tester, '3000');
        await tester.tap(find.byKey(const Key('save_expense')));
        await tester.pumpAndSettle();

        // Overflow dialog with Fun selected by default.
        expect(find.text('Not enough in Food'), findsOneWidget);
        await tester.tap(find.text('Borrow'));
        await tester.pumpAndSettle();

        expect(repos.jars.byType(JarType.fun)!.allocatedAmount, 500);
        expect(repos.jars.byType(JarType.food)!.remaining, 0);
        expect(repos.jars.byType(JarType.savings)!.allocatedAmount, 2000);
        expect(repos.cycles.active()!.savingsBroken, isFalse);
        final transfer = repos.transactions
            .getAll()
            .where((t) => t.type == TransactionType.transfer)
            .single;
        expect(transfer.jarId, 'jar_fun');
        expect(transfer.toJarId, 'jar_food');
      },
      variant: const TargetPlatformVariant({
        TargetPlatform.android,
        TargetPlatform.iOS,
      }),
    );

    testWidgets('breaking savings needs explicit confirmation', (tester) async {
      final repos = await seededRepos();
      await pumpApp(tester, repos: repos, location: '/home');

      // Long-press the Savings glass → quick add on Savings.
      await tester.longPress(find.byKey(const Key('glass_savings')));
      await tester.pumpAndSettle();
      await typeAmount(tester, '300');
      await tester.tap(find.byKey(const Key('save_expense')));
      await tester.pumpAndSettle();

      expect(find.text('Break your savings?'), findsOneWidget);
      await tester.tap(find.text('Keep it safe'));
      await tester.pumpAndSettle();
      expect(repos.jars.byType(JarType.savings)!.spentAmount, 0);

      await tester.tap(find.byKey(const Key('save_expense')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Break my savings'));
      await tester.pumpAndSettle();
      expect(repos.jars.byType(JarType.savings)!.spentAmount, 300);
      expect(repos.cycles.active()!.savingsBroken, isTrue);
    });
  });
}
