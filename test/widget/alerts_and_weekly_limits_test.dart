import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pehla_paisa/app/state/repositories.dart';
import 'package:pehla_paisa/features/transactions/data/transaction.dart';

import 'harness.dart';

/// ₹10,000 user (Food ₹2,500/month) who spent ₹700 on food this week.
Future<Repositories> overspentFood() async {
  final repos = await seededRepos();
  await repos.jars.save(
    repos.jars.getById('jar_food')!.copyWith(spentAmount: 700),
  );
  await repos.transactions.save(
    Transaction(
      id: 't1',
      jarId: 'jar_food',
      amount: 700,
      note: 'Groceries',
      dateTime: DateTime(2026, 11, 9, 9),
      type: TransactionType.expense,
      cycleId: '2026-11',
    ),
  );
  return repos;
}

void main() {
  testWidgets('✕ hides a warning, and it stays hidden after reopening', (
    tester,
  ) async {
    final repos = await overspentFood();
    await pumpApp(tester, repos: repos, location: '/home');
    // Nov has 30 days = 4.29 weeks → ₹2,500 / 4.29 = ₹583 → ₹580 a week.
    expect(find.textContaining('Food this week: ₹700'), findsOneWidget);

    await tester.tap(find.byKey(const Key('alert_close')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Food this week'), findsNothing);
    expect(repos.settings.readOrDefault().dismissedAlerts, hasLength(1));

    // Reopen the app with the same storage: still hidden.
    await tester.pumpWidget(const SizedBox());
    await pumpApp(tester, repos: repos, location: '/home');
    expect(find.textContaining('Food this week'), findsNothing);
  });

  testWidgets('weekly limits card shows every everyday glass', (tester) async {
    final repos = await overspentFood();
    await pumpApp(tester, repos: repos, location: '/home');
    final card = find.byKey(const Key('weekly_limits'));
    // It sits below the glasses: scroll down like a user.
    await tester.scrollUntilVisible(
      card,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(card, findsOneWidget);
    // Food ₹2,500, Travel ₹1,000, Fun ₹1,000 ÷ 4.29 weeks (rounded to ₹10).
    expect(find.text('₹580/week'), findsOneWidget);
    expect(find.text('₹230/week'), findsNWidgets(2));
    expect(find.text('₹700 spent · ₹120 over this week'), findsOneWidget);
    // No weekly limit for Rent & Bills or Savings.
    expect(
      find.descendant(of: card, matching: find.textContaining('Rent')),
      findsNothing,
    );
    expect(
      find.descendant(of: card, matching: find.textContaining('Savings')),
      findsNothing,
    );
  });
}
