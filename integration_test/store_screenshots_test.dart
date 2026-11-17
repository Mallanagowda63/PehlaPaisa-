// Takes Google Play screenshots on a real phone, with sample data.
//
//   flutter drive --driver=test_driver/screenshot_driver.dart \
//     --target=integration_test/store_screenshots_test.dart -d <device-id>
//
// Runs as the separate debug app (com.pehlapaisa.app.debug) with in-memory
// storage, so the real app and its data are never touched. Images are saved
// to build/store/screenshots/. Ads are hidden for clean store images.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pehla_paisa/app/app.dart';
import 'package:pehla_paisa/app/router.dart';
import 'package:pehla_paisa/app/state/repositories.dart';
import 'package:pehla_paisa/features/ads/ads.dart';
import 'package:pehla_paisa/features/alerts/data/notification_gateway.dart';

import '../test/helpers/demo_repos.dart';
import '../test/widget/harness.dart' show testNow;

Future<void> wait(WidgetTester tester, [int ms = 1500]) async {
  await Future<void>.delayed(Duration(milliseconds: ms));
  await tester.pump();
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  const shots = <(String, String, String)>[
    ('1_shelf', Routes.home, 'en'),
    ('2_glass_food', '/jar/jar_food', 'en'),
    ('3_pay_upi', '/pay/jar_food', 'en'),
    ('4_goals', Routes.goals, 'en'),
    ('5_report', Routes.report, 'en'),
    ('6_badges', Routes.badges, 'en'),
    ('7_shelf_hindi', Routes.home, 'hi'),
  ];

  testWidgets('store screenshots', (tester) async {
    await binding.convertFlutterSurfaceToImage();
    for (final (name, location, lang) in shots) {
      final repos = await demoRepos(language: lang);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(
        ProviderScope(
          key: UniqueKey(),
          overrides: [
            repositoriesProvider.overrideWithValue(repos),
            clockProvider.overrideWithValue(() => testNow),
            initialLocationProvider.overrideWithValue(location),
            notificationGatewayProvider.overrideWithValue(
              NoopNotificationGateway(),
            ),
            adSlotBuilderProvider.overrideWithValue(
              (context, slot) => const SizedBox.shrink(),
            ),
          ],
          child: const PehlaPaisaApp(),
        ),
      );
      await wait(tester, 2500);
      if (name == '3_pay_upi') {
        for (final d in ['1', '2', '0']) {
          await tester.tap(find.text(d).last);
          await wait(tester, 250);
        }
        await tester.enterText(find.byKey(const Key('pay_to')), 'Chai Point');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        FocusManager.instance.primaryFocus?.unfocus();
        await wait(tester);
      }
      await binding.takeScreenshot(name);
    }
  });
}
