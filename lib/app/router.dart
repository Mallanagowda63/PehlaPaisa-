import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/badges/presentation/badges_screen.dart';
import '../features/goals/presentation/goals_screen.dart';
import '../features/jars/presentation/home_screen.dart';
import '../features/jars/presentation/jar_detail_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/onboarding/presentation/splash_screen.dart';
import '../features/payments/presentation/pay_screen.dart';
import '../features/reports/presentation/report_screen.dart';
import '../features/salary/presentation/salary_day_screen.dart';
import '../features/settings/presentation/about_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/settings/presentation/split_editor_screen.dart';
import '../features/share/domain/share_card_data.dart';
import '../features/share/presentation/share_screen.dart';
import 'l10n.dart';
import 'state/budget_controller.dart';

/// Route paths.
abstract final class Routes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const home = '/home';
  static const goals = '/goals';
  static const report = '/report';
  static const badges = '/badges';
  static const settings = '/settings';
  static const salary = '/salary';
  static const split = '/settings/split';
  static const about = '/settings/about';
  static const share = '/share';
  static String jar(String id) => '/jar/$id';
  static String pay(String jarId) => '/pay/$jarId';
}

final rootNavigatorKey = GlobalKey<NavigatorState>();

/// Initial location (tests start straight at a screen).
final initialLocationProvider = Provider<String>((ref) => Routes.splash);

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: ref.read(initialLocationProvider),
    redirect: (context, state) {
      final loc = state.matchedLocation;
      if (loc == Routes.splash || loc == Routes.onboarding) return null;
      final onboarded = ref.read(budgetProvider).isOnboarded;
      return onboarded ? null : Routes.onboarding;
    },
    routes: [
      GoRoute(
        path: Routes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: Routes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: Routes.salary,
        builder: (context, state) => const SalaryDayScreen(),
      ),
      GoRoute(
        path: '/jar/:id',
        builder: (context, state) =>
            JarDetailScreen(jarId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/pay/:jarId',
        builder: (context, state) =>
            PayScreen(jarId: state.pathParameters['jarId']!),
      ),
      GoRoute(
        path: Routes.split,
        builder: (context, state) => const SplitEditorScreen(),
      ),
      GoRoute(
        path: Routes.about,
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: Routes.share,
        builder: (context, state) =>
            ShareScreen(initial: state.extra as ShareCardData?),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => _TabShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.goals,
                builder: (context, state) => const GoalsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.report,
                builder: (context, state) => const ReportScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.badges,
                builder: (context, state) => const BadgesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.settings,
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

/// Bottom navigation for the five main tabs.
class _TabShell extends StatelessWidget {
  const _TabShell({required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        onDestinationSelected: (i) =>
            shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.local_drink_outlined),
            selectedIcon: const Icon(Icons.local_drink),
            label: l.navShelf,
          ),
          NavigationDestination(
            icon: const Icon(Icons.flag_outlined),
            selectedIcon: const Icon(Icons.flag),
            label: l.navGoals,
          ),
          NavigationDestination(
            icon: const Icon(Icons.pie_chart_outline),
            selectedIcon: const Icon(Icons.pie_chart),
            label: l.navReport,
          ),
          NavigationDestination(
            icon: const Icon(Icons.military_tech_outlined),
            selectedIcon: const Icon(Icons.military_tech),
            label: l.navBadges,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l.navSettings,
          ),
        ],
      ),
    );
  }
}
