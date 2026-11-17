import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:pehla_paisa/app/app.dart';
import 'package:pehla_paisa/app/router.dart';
import 'package:pehla_paisa/app/state/repositories.dart';
import 'package:pehla_paisa/features/ads/ads.dart';
import 'package:pehla_paisa/features/jars/data/jar.dart';
import 'package:pehla_paisa/features/jars/domain/jar_factory.dart';
import 'package:pehla_paisa/features/onboarding/data/user_profile.dart';
import 'package:pehla_paisa/features/salary/domain/cycle_range.dart';
import 'package:pehla_paisa/features/salary/domain/month_rollover.dart';
import 'package:pehla_paisa/features/settings/data/app_settings.dart';

import '../helpers/sample_ad.dart';

/// Height of the simulated system navigation bar (3-button mode), in dp.
const double navBarDp = 48;

/// Fails unless [finder]'s widget is entirely on screen and not hidden
/// under the system navigation bar.
void expectAboveNavBar(WidgetTester tester, Finder finder, Size screen) {
  expect(finder, findsOneWidget);
  final r = tester.getRect(finder);
  final limit = screen.height - navBarDp;
  expect(
    r.top >= 0 && r.bottom <= limit + 0.5,
    isTrue,
    reason:
        'Button spans ${r.top.toStringAsFixed(1)}–'
        '${r.bottom.toStringAsFixed(1)} but the navigation bar starts at '
        '${limit.toStringAsFixed(1)} (screen ${screen.width}×${screen.height})',
  );
}

/// "Today" for every widget test.
final testNow = DateTime(2026, 11, 9, 10);

/// Pumps the real app with in-memory storage on a 360×740 phone.
Future<void> pumpApp(
  WidgetTester tester, {
  required Repositories repos,
  required String location,
  Size size = const Size(360, 740),
  List<Override> overrides = const [],
}) async {
  tester.view.devicePixelRatio = 3;
  tester.view.physicalSize = size * 3;
  // Like a real Android phone drawn edge-to-edge (Android 15+): a 24dp
  // status bar and a 48dp 3-button navigation bar overlap the app.
  const insets = FakeViewPadding(top: 24 * 3, bottom: navBarDp * 3);
  tester.view.padding = insets;
  tester.view.viewPadding = insets;
  addTearDown(tester.view.reset);
  // Reduce motion: stops the endless wave so pumpAndSettle can settle.
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  // Haptics are platform calls; ignore them in tests.
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (_) async => null,
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        repositoriesProvider.overrideWithValue(repos),
        clockProvider.overrideWithValue(() => testNow),
        initialLocationProvider.overrideWithValue(location),
        adSlotBuilderProvider.overrideWithValue(
          (context, slot) =>
              slot.native ? const SampleAd.native() : const SampleAd.banner(),
        ),
        ...overrides,
      ],
      child: const PehlaPaisaApp(),
    ),
  );
  await tester.pumpAndSettle();
}

/// Seeds an onboarded ₹10,000 user whose November glasses are filled.
Future<Repositories> seededRepos({
  String language = 'en',
  bool family = false,
}) async {
  final repos = Repositories.inMemory();
  await repos.settings.write(AppSettings(language: language));
  await repos.profile.write(
    UserProfile(
      name: 'Asha',
      monthlyIncome: 10000,
      salaryDay: 1,
      livesWithFamily: family,
      incomeType: IncomeType.fixed,
      language: language,
      createdAt: DateTime(2026, 11, 1),
      onboardingDone: true,
    ),
  );
  final plan = {
    JarType.savings: 2000,
    JarType.rent: 3500,
    JarType.food: 2500,
    JarType.travel: 1000,
    JarType.fun: 1000,
  };
  await repos.jars.saveAll(
    JarFactory.defaultJars(plan)
        .map((j) => j.copyWith(allocatedAmount: plan[j.type])),
  );
  await repos.cycles.save(
    MonthRollover.newCycle(CycleRange.forDate(testNow, 1)).copyWith(
      income: 10000,
      funded: true,
      savingsFilledFirst: true,
      savingsFilledAt: DateTime(2026, 11, 1, 9),
    ),
  );
  return repos;
}

/// Dismisses any celebration modals that are showing.
Future<void> dismissCelebrations(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    final btn = find.byKey(const Key('celebrate_continue'));
    if (btn.evaluate().isEmpty) return;
    await tester.tap(btn);
    await tester.pumpAndSettle();
  }
}
