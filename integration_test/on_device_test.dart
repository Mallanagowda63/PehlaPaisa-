// Runs the real app on a connected phone/tablet with that device's actual
// screen size, status bar and navigation bar.
//
//   flutter test integration_test -d <device-id>
//
// Uses in-memory storage, so it never touches the user's real data.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pehla_paisa/app/app.dart';
import 'package:pehla_paisa/app/router.dart';
import 'package:pehla_paisa/app/state/repositories.dart';
import 'package:pehla_paisa/features/alerts/data/notification_gateway.dart';
import 'package:pehla_paisa/features/jars/data/jar.dart';

/// Fails unless the widget is fully on screen and above the system
/// navigation bar of *this* device.
void expectAboveSystemBars(WidgetTester tester, Finder f, String what) {
  final view = tester.view;
  final screenH = view.physicalSize.height / view.devicePixelRatio;
  final navBar = view.viewPadding.bottom / view.devicePixelRatio;
  final r = tester.getRect(f);
  expect(
    r.top >= 0 && r.bottom <= screenH - navBar + 0.5,
    isTrue,
    reason: '$what spans ${r.top.toStringAsFixed(1)}–'
        '${r.bottom.toStringAsFixed(1)}dp; screen ${screenH.toStringAsFixed(1)}dp, '
        'navigation bar ${navBar.toStringAsFixed(1)}dp',
  );
}

/// Waits real time (like a person between taps) and redraws. On a device
/// `pump(duration)` doesn't actually wait, and the glass waves animate
/// forever, so pumpAndSettle can't be used.
Future<void> settle(WidgetTester tester, [int ms = 900]) async {
  await Future<void>.delayed(Duration(milliseconds: ms));
  await tester.pump();
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  // Draw frames continuously, exactly like normal use, so animations run
  // in real time between test steps.
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('real device: onboarding → salary day → add expense',
      (tester) async {
    final repos = Repositories.inMemory();
    final view = tester.view;
    debugPrint('Device screen: '
        '${(view.physicalSize.width / view.devicePixelRatio).toStringAsFixed(0)}×'
        '${(view.physicalSize.height / view.devicePixelRatio).toStringAsFixed(0)}dp, '
        'nav bar ${(view.viewPadding.bottom / view.devicePixelRatio).toStringAsFixed(0)}dp');

    await tester.pumpWidget(ProviderScope(
      overrides: [
        repositoriesProvider.overrideWithValue(repos),
        initialLocationProvider.overrideWithValue(Routes.onboarding),
        // No system permission dialog popping over the test.
        notificationGatewayProvider.overrideWithValue(NoopNotificationGateway()),
      ],
      child: const PehlaPaisaApp(),
    ));
    await settle(tester);

    // Onboarding.
    final next = find.byKey(const Key('onb_next'));
    expectAboveSystemBars(tester, next, "Let's start");
    await tester.tap(next);
    await settle(tester);
    await tester.enterText(find.byKey(const Key('onb_name')), 'Test');
    await tester.tap(next);
    await settle(tester);
    await tester.enterText(find.byKey(const Key('onb_income')), '10000');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.tap(next);
    await settle(tester);
    await tester.ensureVisible(find.byKey(const Key('onb_family_no')));
    await tester.tap(find.byKey(const Key('onb_family_no')));
    await settle(tester);
    await tester.tap(next);
    await settle(tester);
    final finish = find.byKey(const Key('onb_finish'));
    expectAboveSystemBars(tester, finish, 'Start saving');
    await tester.tap(finish);
    await settle(tester);
    await settle(tester);

    // Salary-day ritual.
    final fill = find.byKey(const Key('fill_savings_first'));
    expectAboveSystemBars(tester, fill, 'Fill Savings First');
    await tester.tap(fill);
    // Pour animation: ~1.4s for Savings + ~0.65s for each other glass.
    await settle(tester, 5000);
    final goShelf = find.byKey(const Key('salary_go_shelf'));
    expectAboveSystemBars(tester, goShelf, 'Go to my shelf');
    expect(repos.jars.byType(JarType.savings)!.allocatedAmount, 2000);
    await tester.tap(goShelf);
    await settle(tester);
    // Dismiss badge celebrations.
    for (var i = 0; i < 5; i++) {
      final c = find.byKey(const Key('celebrate_continue'));
      if (c.evaluate().isEmpty) break;
      await tester.tap(c);
      await settle(tester);
    }

    // Add expense: the bug from the screenshot.
    await tester.tap(find.byKey(const Key('home_add_expense')));
    await settle(tester);
    final save = find.byKey(const Key('save_expense'));
    expectAboveSystemBars(tester, save, 'Save expense');
    for (final d in ['8', '5']) {
      await tester.tap(find.text(d).last);
      await settle(tester, 250);
    }
    expectAboveSystemBars(tester, save, 'Save expense (with amount)');
    await tester.tap(save);
    await settle(tester);
    expect(repos.jars.byType(JarType.food)!.spentAmount, 85);
  });
}
