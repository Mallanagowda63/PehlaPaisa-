import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/alerts/presentation/notification_sync.dart';
import '../features/badges/presentation/celebration_host.dart';
import '../features/settings/presentation/settings_controller.dart';
import 'l10n.dart';
import 'router.dart';
import 'state/budget_controller.dart';
import 'state/repositories.dart';
import 'theme.dart';

/// Root widget: theme, locale, router, celebrations and notification sync.
class PehlaPaisaApp extends ConsumerStatefulWidget {
  const PehlaPaisaApp({super.key});

  @override
  ConsumerState<PehlaPaisaApp> createState() => _PehlaPaisaAppState();
}

class _PehlaPaisaAppState extends ConsumerState<PehlaPaisaApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _ensureNotificationPermission(),
    );
  }

  /// On every app start, make sure we may show reminders (Android 13+ and
  /// iOS only show the system dialog if permission isn't granted yet).
  Future<void> _ensureNotificationPermission() async {
    final settings = ref.read(settingsProvider);
    if (!settings.notificationsEnabled) return;
    if (!ref.read(budgetProvider).isOnboarded) return;
    await ref.read(notificationGatewayProvider).requestPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // A new month may have started while the app was in the background.
    if (state == AppLifecycleState.resumed) {
      ref.read(budgetProvider.notifier).refreshDay();
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    // Keeps notifications in sync with data + settings.
    ref.watch(notificationSyncProvider);
    return MaterialApp.router(
      onGenerateTitle: (context) => context.l10n.appName,
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: ref.watch(themeModeProvider),
      locale: ref.watch(localeProvider),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
      builder: (context, child) => CelebrationHost(child: child!),
    );
  }
}
