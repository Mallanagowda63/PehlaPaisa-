// Opens every screen on a matrix of real phone and tablet sizes, in English
// and Hindi, and fails on any layout overflow or exception.
//
// Run: flutter test test/devices
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pehla_paisa/app/state/repositories.dart';
import 'package:pehla_paisa/features/jars/data/jar.dart';
import 'package:pehla_paisa/features/jars/domain/jar_factory.dart';
import 'package:pehla_paisa/features/onboarding/data/user_profile.dart';
import 'package:pehla_paisa/features/salary/domain/cycle_range.dart';
import 'package:pehla_paisa/features/salary/domain/month_rollover.dart';
import 'package:pehla_paisa/features/settings/data/app_settings.dart';

import '../helpers/demo_repos.dart';
import '../helpers/pay_fakes.dart';
import '../widget/harness.dart';

/// Logical screen sizes (dp) of common devices.
const devices = <String, Size>{
  'Small phone 320x568 (iPhone SE 1st gen / old Android)': Size(320, 568),
  'Compact Android 360x640': Size(360, 640),
  'Realme / typical Android 360x800': Size(360, 800),
  'iPhone 15 393x852': Size(393, 852),
  'Pixel 7 412x915': Size(412, 915),
  'iPhone 15 Pro Max 430x932': Size(430, 932),
  'Tablet 7in 600x960': Size(600, 960),
  'iPad Mini 744x1133': Size(744, 1133),
  'iPad Air 820x1180': Size(820, 1180),
  'iPad Pro 12.9in 1024x1366': Size(1024, 1366),
};

const screens = <String, String>{
  'Shelf (home)': '/home',
  'Goals': '/goals',
  'Monthly report': '/report',
  'Badges': '/badges',
  'Settings': '/settings',
  'Jar detail – Food': '/jar/jar_food',
  'Jar detail – Savings': '/jar/jar_savings',
  'Split editor': '/settings/split',
  'About': '/settings/about',
  'Share card': '/share',
};

/// An onboarded user whose month is not filled yet (salary-day ritual).
Future<Repositories> unfundedRepos(String language) async {
  final repos = Repositories.inMemory();
  await repos.settings.write(AppSettings(language: language));
  await repos.profile.write(
    UserProfile(
      name: 'Asha',
      monthlyIncome: 12000,
      salaryDay: 1,
      livesWithFamily: true,
      incomeType: IncomeType.fixed,
      language: language,
      createdAt: DateTime(2026, 11, 1),
      onboardingDone: true,
    ),
  );
  await repos.jars.saveAll(
    JarFactory.defaultJars({
      JarType.savings: 4500,
      JarType.rent: 2100,
      JarType.food: 3000,
      JarType.travel: 1200,
      JarType.fun: 1200,
    }),
  );
  await repos.cycles.save(
    MonthRollover.newCycle(CycleRange.forDate(testNow, 1)),
  );
  return repos;
}

void main() {
  for (final lang in ['en', 'hi']) {
    for (final d in devices.entries) {
      group('[$lang] ${d.key}', () {
        for (final s in screens.entries) {
          testWidgets(s.key, (tester) async {
            await pumpApp(
              tester,
              repos: await demoRepos(language: lang),
              location: s.value,
              size: d.value,
            );
            expect(tester.takeException(), isNull);
            // Scroll to the end to lay out everything below the fold.
            final list = find.byType(Scrollable);
            if (list.evaluate().isNotEmpty) {
              await tester.fling(list.first, const Offset(0, -3000), 3000);
              await tester.pumpAndSettle();
            }
            expect(tester.takeException(), isNull);
          });
        }

        testWidgets('Add expense sheet', (tester) async {
          await pumpApp(
            tester,
            repos: await demoRepos(language: lang),
            location: '/home',
            size: d.value,
          );
          await tester.tap(find.byKey(const Key('home_add_expense')));
          await tester.pumpAndSettle();
          expect(find.byKey(const Key('save_expense')), findsOneWidget);
          expect(tester.takeException(), isNull);
        });

        testWidgets('Goal detail sheet', (tester) async {
          await pumpApp(
            tester,
            repos: await demoRepos(language: lang),
            location: '/goals',
            size: d.value,
          );
          await tester.tap(find.textContaining('Emergency Fund'));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        });

        testWidgets('Salary-day ritual', (tester) async {
          await pumpApp(
            tester,
            repos: await unfundedRepos(lang),
            location: '/salary',
            size: d.value,
          );
          await tester.tap(find.byKey(const Key('fill_savings_first')));
          await tester.pumpAndSettle();
          expect(find.byKey(const Key('salary_go_shelf')), findsOneWidget);
          expect(tester.takeException(), isNull);
        });

        testWidgets('Onboarding – all steps', (tester) async {
          final repos = Repositories.inMemory();
          await repos.settings.write(AppSettings(language: lang));
          await pumpApp(
            tester,
            repos: repos,
            location: '/onboarding',
            size: d.value,
          );
          Future<void> next() async {
            await tester.tap(find.byKey(const Key('onb_next')));
            await tester.pumpAndSettle();
          }

          await next();
          await tester.enterText(find.byKey(const Key('onb_name')), 'Asha');
          await next();
          await tester.enterText(find.byKey(const Key('onb_income')), '12000');
          await next();
          await tester.ensureVisible(find.byKey(const Key('onb_family_yes')));
          await tester.tap(find.byKey(const Key('onb_family_yes')));
          await tester.pump();
          await next();
          expect(find.byKey(const Key('onb_finish')), findsOneWidget);
          expect(tester.takeException(), isNull);
        });
      });
    }
  }

  // Every primary bottom button must be fully visible above the system
  // navigation bar (the bug seen on Android 16 edge-to-edge).
  for (final lang in ['en', 'hi']) {
    for (final d in devices.entries) {
      group('[$lang] bottom buttons clear the nav bar – ${d.key}', () {
        Future<void> open(
          WidgetTester tester,
          String location, {
          Repositories? repos,
        }) async {
          await pumpApp(
            tester,
            repos: repos ?? await demoRepos(language: lang),
            location: location,
            size: d.value,
          );
        }

        /// Scrolls (like a user would) until [f] is on screen.
        Future<void> reveal(WidgetTester tester, Finder f) async {
          if (f.evaluate().isEmpty) {
            // Lazily built lists only create items once scrolled to.
            await tester.scrollUntilVisible(
              f,
              250,
              scrollable: find.byType(Scrollable).last,
            );
          }
          await tester.ensureVisible(f);
          await tester.pumpAndSettle();
        }

        testWidgets('Shelf: + button', (tester) async {
          await open(tester, '/home');
          expectAboveNavBar(
            tester,
            find.byKey(const Key('home_add_expense')),
            d.value,
          );
        });

        testWidgets('Add expense sheet: Save expense', (tester) async {
          await open(tester, '/home');
          await tester.tap(find.byKey(const Key('home_add_expense')));
          await tester.pumpAndSettle();
          // The core 3-tap flow: Save must be visible WITHOUT scrolling.
          final save = find.byKey(const Key('save_expense'));
          expectAboveNavBar(tester, save, d.value);
          // …and still visible with the note field open.
          await tester.tap(find.byIcon(Icons.edit_note));
          await tester.pumpAndSettle();
          expectAboveNavBar(tester, save, d.value);
        });

        testWidgets('Jar detail: Move money sheet button', (tester) async {
          await open(tester, '/jar/jar_food');
          await reveal(tester, find.byKey(const Key('jar_move')));
          await tester.tap(find.byKey(const Key('jar_move')));
          await tester.pumpAndSettle();
          final move = find.byKey(const Key('move_button'));
          await reveal(tester, move);
          expectAboveNavBar(tester, move, d.value);
        });

        testWidgets('Goals: New goal form Save', (tester) async {
          await open(tester, '/goals');
          await tester.tap(find.byKey(const Key('goal_add')));
          await tester.pumpAndSettle();
          final save = find.byKey(const Key('goal_save'));
          await reveal(tester, save);
          expectAboveNavBar(tester, save, d.value);
        });

        testWidgets('Goals: goal detail Add from savings', (tester) async {
          await open(tester, '/goals');
          await reveal(tester, find.textContaining('Emergency Fund'));
          await tester.tap(find.textContaining('Emergency Fund'));
          await tester.pumpAndSettle();
          final add = find.byKey(const Key('goal_add_money'));
          await reveal(tester, add);
          expectAboveNavBar(tester, add, d.value);
        });

        testWidgets('Settings: Edit profile Save', (tester) async {
          await open(tester, '/settings');
          await tester.tap(find.byKey(const Key('profile_tile')));
          await tester.pumpAndSettle();
          final save = find.byKey(const Key('profile_save'));
          await reveal(tester, save);
          expectAboveNavBar(tester, save, d.value);
        });

        testWidgets('Split editor: Save (scrolled to end)', (tester) async {
          await open(tester, '/settings/split');
          final save = find.byKey(const Key('split_save'));
          await reveal(tester, save);
          expectAboveNavBar(tester, save, d.value);
        });

        testWidgets('Share: Share image (scrolled to end)', (tester) async {
          await open(tester, '/share');
          final share = find.byKey(const Key('share_button'));
          await reveal(tester, share);
          expectAboveNavBar(tester, share, d.value);
        });

        testWidgets('Salary day: Fill Savings First + Go to shelf', (
          tester,
        ) async {
          await open(tester, '/salary', repos: await unfundedRepos(lang));
          final fill = find.byKey(const Key('fill_savings_first'));
          expectAboveNavBar(tester, fill, d.value);
          await tester.tap(fill);
          await tester.pumpAndSettle();
          expectAboveNavBar(
            tester,
            find.byKey(const Key('salary_go_shelf')),
            d.value,
          );
        });

        testWidgets('Pay with UPI: Pay button above the nav bar', (
          tester,
        ) async {
          await pumpApp(
            tester,
            repos: await demoRepos(language: lang),
            location: '/pay/jar_food',
            size: d.value,
            overrides: fakes(FakeUpiApp()),
          );
          for (final digit in ['4', '5']) {
            await tester.tap(find.text(digit).last);
            await tester.pump();
          }
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          expectAboveNavBar(
            tester,
            find.byKey(const Key('pay_button')),
            d.value,
          );
          await tester.tap(find.byKey(const Key('pay_button')));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          expect(find.byKey(const Key('pay_with_sheet')), findsOneWidget);
        });

        testWidgets('Onboarding: Continue / Start saving', (tester) async {
          final repos = Repositories.inMemory();
          await repos.settings.write(AppSettings(language: lang));
          await open(tester, '/onboarding', repos: repos);
          final next = find.byKey(const Key('onb_next'));
          expectAboveNavBar(tester, next, d.value);
          await tester.tap(next);
          await tester.pumpAndSettle();
          await tester.enterText(find.byKey(const Key('onb_name')), 'Asha');
          await tester.tap(next);
          await tester.pumpAndSettle();
          await tester.enterText(find.byKey(const Key('onb_income')), '9000');
          await tester.tap(next);
          await tester.pumpAndSettle();
          await reveal(tester, find.byKey(const Key('onb_family_no')));
          await tester.tap(find.byKey(const Key('onb_family_no')));
          await tester.pump();
          await tester.tap(next);
          await tester.pumpAndSettle();
          expectAboveNavBar(
            tester,
            find.byKey(const Key('onb_finish')),
            d.value,
          );
        });
      });
    }
  }

  // Large system font on the smallest screens.
  for (final d in devices.entries.take(3)) {
    group('[en, font 1.3×] ${d.key}', () {
      for (final s in screens.entries) {
        testWidgets(s.key, (tester) async {
          tester.platformDispatcher.textScaleFactorTestValue = 1.3;
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          await pumpApp(
            tester,
            repos: await demoRepos(),
            location: s.value,
            size: d.value,
          );
          expect(tester.takeException(), isNull);
        });
      }
    });
  }
}
