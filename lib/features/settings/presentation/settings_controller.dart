import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/state/repositories.dart';
import '../data/app_settings.dart';

/// App preferences, persisted on every change.
class SettingsController extends Notifier<AppSettings> {
  @override
  AppSettings build() =>
      ref.read(repositoriesProvider).settings.readOrDefault();

  Future<void> update(AppSettings Function(AppSettings s) change) async {
    final next = change(state);
    state = next;
    await ref.read(repositoriesProvider).settings.write(next);
  }
}

final settingsProvider = NotifierProvider<SettingsController, AppSettings>(
  SettingsController.new,
);

/// Material theme mode from the stored preference.
final themeModeProvider = Provider<ThemeMode>((ref) {
  switch (ref.watch(settingsProvider).themeMode) {
    case AppThemeMode.system:
      return ThemeMode.system;
    case AppThemeMode.light:
      return ThemeMode.light;
    case AppThemeMode.dark:
      return ThemeMode.dark;
  }
});

/// Current UI locale; changing it rebuilds the app instantly.
final localeProvider = Provider<Locale>(
  (ref) => Locale(ref.watch(settingsProvider).language),
);
