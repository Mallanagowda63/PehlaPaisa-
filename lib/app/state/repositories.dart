import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/hive_store.dart';
import '../../core/storage/key_value_store.dart';
import '../../features/alerts/data/notification_gateway.dart';
import '../../features/badges/data/badge_repository.dart';
import '../../features/goals/data/goal_repository.dart';
import '../../features/jars/data/jar_repository.dart';
import '../../features/onboarding/data/profile_repository.dart';
import '../../features/salary/data/cycle_repository.dart';
import '../../features/settings/data/settings_repository.dart';
import '../../features/transactions/data/transaction_repository.dart';

/// All repositories, created once at startup.
class Repositories {
  Repositories({
    required this.profile,
    required this.settings,
    required this.jars,
    required this.transactions,
    required this.cycles,
    required this.goals,
    required this.badges,
  });

  final ProfileRepository profile;
  final SettingsRepository settings;
  final JarRepository jars;
  final TransactionRepository transactions;
  final CycleRepository cycles;
  final GoalRepository goals;
  final BadgeRepository badges;

  /// Production: one Hive box per collection.
  static Future<Repositories> openHive() async {
    // Open every box in parallel: noticeably faster app start.
    final opened = await Future.wait(BoxNames.all.map(HiveStore.open));
    return Repositories.fromStores({
      for (var i = 0; i < BoxNames.all.length; i++) BoxNames.all[i]: opened[i],
    });
  }

  /// Tests: everything in memory.
  factory Repositories.inMemory() => Repositories.fromStores({
    for (final name in BoxNames.all) name: MemoryStore(),
  });

  factory Repositories.fromStores(Map<String, KeyValueStore> s) => Repositories(
    profile: ProfileRepository(s[BoxNames.profile]!),
    settings: SettingsRepository(s[BoxNames.settings]!),
    jars: JarRepository(s[BoxNames.jars]!),
    transactions: TransactionRepository(s[BoxNames.transactions]!),
    cycles: CycleRepository(s[BoxNames.cycles]!),
    goals: GoalRepository(s[BoxNames.goals]!),
    badges: BadgeRepository(s[BoxNames.badges]!),
  );

  /// Deletes every record except settings.
  Future<void> clearBudgetData() async {
    await profile.clear();
    await jars.clear();
    await transactions.clear();
    await cycles.clear();
    await goals.clear();
    await badges.clear();
  }
}

/// Overridden in `main()` and in tests.
final repositoriesProvider = Provider<Repositories>(
  (ref) => throw UnimplementedError('repositoriesProvider must be overridden'),
);

/// Injectable clock so tests can control "today".
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// Local notifications (a no-op implementation in tests).
final notificationGatewayProvider = Provider<NotificationGateway>(
  (ref) => NoopNotificationGateway(),
);
