import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pehla_paisa/app/state/repositories.dart';
import 'package:pehla_paisa/features/jars/data/jar.dart';

import '../helpers/pay_fakes.dart';
import 'harness.dart';

const phonePe = Key('pay_app_com.phonepe.app');
const googlePay = Key('pay_app_com.google.android.apps.nbu.paisa.user');

/// Simulates leaving PehlaPaisa for the UPI app and coming back.
Future<void> returnFromUpiApp(WidgetTester tester) async {
  for (final s in [
    AppLifecycleState.inactive,
    AppLifecycleState.hidden,
    AppLifecycleState.paused,
    AppLifecycleState.hidden,
    AppLifecycleState.inactive,
    AppLifecycleState.resumed,
  ]) {
    tester.binding.handleAppLifecycleStateChanged(s);
  }
  await tester.pumpAndSettle();
}

Future<void> typeAmount(WidgetTester tester, String digits) async {
  for (final d in digits.split('')) {
    await tester.tap(find.text(d).last);
    await tester.pump();
  }
}

/// Amount → Open UPI app → pick [app].
Future<void> payWith(WidgetTester tester, String amount, Key app) async {
  await typeAmount(tester, amount);
  await tester.tap(find.byKey(const Key('pay_button')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(app));
  await tester.pumpAndSettle();
}

void main() {
  late Repositories repos;
  setUp(() async => repos = await seededRepos());

  testWidgets(
    'glass → Pay with UPI → amount → UPI app opens on its home screen '
    '(pay there) → Yes, paid → recorded with the name',
    (tester) async {
      final upi = FakeUpiApp();
      await pumpApp(
        tester,
        repos: repos,
        location: '/jar/jar_food',
        overrides: fakes(upi),
      );
      await tester.tap(find.byKey(const Key('jar_scan_pay')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('pay_steps')), findsOneWidget);

      // No amount yet: the button is disabled.
      final button = find.byKey(const Key('pay_button'));
      expect(tester.widget<ButtonStyleButton>(button).onPressed, isNull);

      await tester.enterText(find.byKey(const Key('pay_to')), 'Chai Point');
      await typeAmount(tester, '30');
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(find.text('Pay ₹30 with'), findsOneWidget);
      expect(
        find.text(
          'The app opens. Scan the QR there and pay ₹30, then come back.',
        ),
        findsOneWidget,
      );
      await tester.tap(find.byKey(googlePay));
      await tester.pumpAndSettle();
      expect(upi.homes, ['Google Pay']);

      // Nothing is recorded until the user comes back and confirms.
      expect(repos.jars.byType(JarType.food)!.spentAmount, 0);
      await returnFromUpiApp(tester);
      expect(find.text('Did you pay ₹30 to Chai Point?'), findsOneWidget);
      await tester.tap(find.byKey(const Key('pay_result_yes')));
      await tester.pumpAndSettle();

      expect(repos.jars.byType(JarType.food)!.spentAmount, 30);
      expect(
        repos.transactions.getAll().any((t) => t.note == 'UPI · Chai Point'),
        isTrue,
      );
      expect(find.text('₹30 added to Food'), findsOneWidget);
    },
    variant: const TargetPlatformVariant({
      TargetPlatform.android,
      TargetPlatform.iOS,
    }),
  );

  testWidgets('no name: plain question and "UPI payment" note', (tester) async {
    await pumpApp(
      tester,
      repos: repos,
      location: '/pay/jar_food',
      overrides: fakes(FakeUpiApp()),
    );
    await payWith(tester, '45', phonePe);
    await returnFromUpiApp(tester);
    expect(find.text('Did you pay ₹45?'), findsOneWidget);
    await tester.tap(find.byKey(const Key('pay_result_yes')));
    await tester.pumpAndSettle();
    expect(
      repos.transactions.getAll().any((t) => t.note == 'UPI payment'),
      isTrue,
    );
  });

  testWidgets('"Open another app" reopens the list; last app listed first', (
    tester,
  ) async {
    final upi = FakeUpiApp();
    await pumpApp(
      tester,
      repos: repos,
      location: '/pay/jar_food',
      overrides: fakes(upi),
    );
    await payWith(tester, '20', phonePe);
    await returnFromUpiApp(tester);
    await tester.tap(find.byKey(const Key('pay_result_retry')));
    await tester.pumpAndSettle();
    // PhonePe (used last) is now above Google Pay.
    expect(
      tester.getTopLeft(find.byKey(phonePe)).dy,
      lessThan(tester.getTopLeft(find.byKey(googlePay)).dy),
    );
    await tester.tap(find.byKey(googlePay));
    await tester.pumpAndSettle();
    expect(upi.homes, ['PhonePe', 'Google Pay']);
    await returnFromUpiApp(tester);
    await tester.tap(find.byKey(const Key('pay_result_yes')));
    await tester.pumpAndSettle();
    expect(repos.jars.byType(JarType.food)!.spentAmount, 20);
  });

  testWidgets('"No / failed" records nothing', (tester) async {
    await pumpApp(
      tester,
      repos: repos,
      location: '/pay/jar_food',
      overrides: fakes(FakeUpiApp()),
    );
    await payWith(tester, '50', phonePe);
    await returnFromUpiApp(tester);
    await tester.tap(find.byKey(const Key('pay_result_no')));
    await tester.pumpAndSettle();
    expect(repos.jars.byType(JarType.food)!.spentAmount, 0);
    expect(find.text('Nothing was recorded'), findsOneWidget);
  });

  testWidgets('over the glass: warns, then borrows from Fun — never Savings', (
    tester,
  ) async {
    await pumpApp(
      tester,
      repos: repos,
      location: '/pay/jar_travel',
      overrides: fakes(FakeUpiApp()),
    );
    await typeAmount(tester, '1300'); // Travel has ₹1,000
    expect(
      find.text(
        '₹300 more than this glass has. It will be borrowed from Fun '
        'first — never from Savings.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('pay_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(phonePe));
    await tester.pumpAndSettle();
    await returnFromUpiApp(tester);
    await tester.tap(find.byKey(const Key('pay_result_yes')));
    await tester.pumpAndSettle();
    expect(repos.jars.byType(JarType.fun)!.allocatedAmount, 700);
    expect(repos.jars.byType(JarType.savings)!.allocatedAmount, 2000);
    expect(repos.cycles.active()!.savingsBroken, isFalse);
  });

  testWidgets('closing the app list opens nothing and asks nothing', (
    tester,
  ) async {
    final upi = FakeUpiApp();
    await pumpApp(
      tester,
      repos: repos,
      location: '/pay/jar_food',
      overrides: fakes(upi),
    );
    await typeAmount(tester, '10');
    await tester.tap(find.byKey(const Key('pay_button')));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(20, 20)); // outside the sheet
    await tester.pumpAndSettle();
    expect(upi.homes, isEmpty);
    await returnFromUpiApp(tester);
    expect(find.byKey(const Key('pay_result_yes')), findsNothing);
  });

  testWidgets('no UPI app installed', (tester) async {
    await pumpApp(
      tester,
      repos: repos,
      location: '/pay/jar_food',
      overrides: fakes(FakeUpiApp(installed: false)),
    );
    await typeAmount(tester, '10');
    await tester.tap(find.byKey(const Key('pay_button')));
    await tester.pumpAndSettle();
    expect(find.text('No UPI app found on this phone'), findsOneWidget);
  });

  testWidgets('Savings glass has no Pay button', (tester) async {
    await pumpApp(tester, repos: repos, location: '/jar/jar_savings');
    expect(find.byKey(const Key('jar_scan_pay')), findsNothing);
  });
}
