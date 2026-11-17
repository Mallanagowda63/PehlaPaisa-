import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:pehla_paisa/core/storage/hive_store.dart';
import 'package:pehla_paisa/core/storage/key_value_store.dart';
import 'package:pehla_paisa/features/badges/data/badge.dart';
import 'package:pehla_paisa/features/badges/data/badge_repository.dart';
import 'package:pehla_paisa/features/goals/data/goal.dart';
import 'package:pehla_paisa/features/goals/data/goal_repository.dart';
import 'package:pehla_paisa/features/jars/data/jar.dart';
import 'package:pehla_paisa/features/jars/data/jar_repository.dart';
import 'package:pehla_paisa/features/onboarding/data/profile_repository.dart';
import 'package:pehla_paisa/features/onboarding/data/user_profile.dart';
import 'package:pehla_paisa/features/salary/data/cycle_repository.dart';
import 'package:pehla_paisa/features/salary/data/month_cycle.dart';
import 'package:pehla_paisa/features/settings/data/app_settings.dart';
import 'package:pehla_paisa/features/settings/data/settings_repository.dart';
import 'package:pehla_paisa/features/transactions/data/transaction.dart';
import 'package:pehla_paisa/features/transactions/data/transaction_repository.dart';

import '../helpers/fixtures.dart';

/// Runs the same CRUD contract against both store implementations.
void main() {
  late Directory dir;
  var boxCounter = 0;

  setUpAll(() {
    dir = Directory.systemTemp.createTempSync('pp_hive_test');
    Hive.init(dir.path);
  });

  tearDownAll(() async {
    await Hive.close();
    dir.deleteSync(recursive: true);
  });

  final factories = <String, Future<KeyValueStore> Function()>{
    'memory': () async => MemoryStore(),
    'hive': () => HiveStore.open('box${boxCounter++}'),
  };

  for (final entry in factories.entries) {
    group('${entry.key} store', () {
      test('ProfileRepository read/write/clear', () async {
        final repo = ProfileRepository(await entry.value());
        expect(repo.read(), isNull);
        final p = UserProfile(
          name: 'Asha',
          monthlyIncome: 12000,
          salaryDay: 7,
          livesWithFamily: true,
          incomeType: IncomeType.irregular,
          language: 'hi',
          createdAt: DateTime(2026, 1, 2),
          onboardingDone: true,
        );
        await repo.write(p);
        final r = repo.read()!;
        expect(r.name, 'Asha');
        expect(r.salaryDay, 7);
        expect(r.incomeType, IncomeType.irregular);
        expect(r.createdAt, DateTime(2026, 1, 2));
        await repo.write(p.copyWith(name: 'Asha K'));
        expect(repo.read()!.name, 'Asha K');
        await repo.clear();
        expect(repo.read(), isNull);
      });

      test('SettingsRepository defaults and update', () async {
        final repo = SettingsRepository(await entry.value());
        expect(repo.readOrDefault().themeMode, AppThemeMode.dark);
        await repo.write(
          const AppSettings(
            language: 'hi',
            reminderMinutes: 600,
            alertedKeys: ['a'],
          ),
        );
        final s = repo.readOrDefault();
        expect(s.language, 'hi');
        expect(s.reminderHour, 10);
        expect(s.alertedKeys, ['a']);
      });

      test('JarRepository CRUD keeps shelf order', () async {
        final repo = JarRepository(await entry.value());
        final jars = jarsWith().reversed.toList();
        await repo.saveAll(jars);
        expect(repo.getAll().first.type, JarType.savings);
        expect(repo.byType(JarType.fun)!.allocatedAmount, 1000);
        final food = repo.byType(JarType.food)!;
        await repo.save(food.copyWith(spentAmount: 300));
        expect(repo.getById(food.id)!.remaining, 2200);
        await repo.delete(food.id);
        expect(repo.getAll().length, 4);
        await repo.clear();
        expect(repo.getAll(), isEmpty);
      });

      test('TransactionRepository queries', () async {
        final repo = TransactionRepository(await entry.value());
        Transaction t(
          String id,
          String jar,
          int day,
          String cyc, {
          String? to,
        }) => Transaction(
          id: id,
          jarId: jar,
          toJarId: to,
          amount: 100,
          note: 'n',
          dateTime: DateTime(2026, 1, day),
          type: to == null ? TransactionType.expense : TransactionType.transfer,
          cycleId: cyc,
        );
        await repo.saveAll([
          t('1', 'food', 1, '2026-01'),
          t('2', 'food', 3, '2026-01'),
          t('3', 'fun', 2, '2026-02', to: 'food'),
        ]);
        expect(repo.getAll().first.id, '2'); // newest first
        expect(repo.forCycle('2026-01').length, 2);
        expect(repo.forJar('food').length, 3); // includes transfer into food
        expect(repo.forJar('food', cycleId: '2026-02').length, 1);
        await repo.delete('1');
        expect(repo.getAll().length, 2);
      });

      test('CycleRepository with snapshots', () async {
        final repo = CycleRepository(await entry.value());
        await repo.save(
          cycle(
            2026,
            2,
            snapshot: const [
              JarSnapshot(
                jarId: 'jar_food',
                type: JarType.food,
                name: 'Food',
                emoji: '🍛',
                allocated: 2500,
                spent: 2000,
              ),
            ],
          ),
        );
        await repo.save(cycle(2026, 3, closed: false));
        expect(repo.getAll().first.id, '2026-02');
        expect(repo.active()!.id, '2026-03');
        final feb = repo.getById('2026-02')!;
        expect(feb.jarsSnapshot.single.remaining, 500);
        expect(feb.savingsFilledAt, DateTime(2026, 2, 1));
      });

      test('GoalRepository CRUD', () async {
        final repo = GoalRepository(await entry.value());
        final g = Goal(
          id: 'g1',
          name: 'Phone',
          emoji: '📱',
          targetAmount: 15000,
          savedAmount: 0,
          createdAt: DateTime(2026),
          targetDate: DateTime(2026, 12),
        );
        await repo.save(g);
        await repo.save(g.copyWith(savedAmount: 5000));
        expect(repo.getById('g1')!.savedAmount, 5000);
        expect(repo.getById('g1')!.targetDate, DateTime(2026, 12));
        await repo.delete('g1');
        expect(repo.getAll(), isEmpty);
      });

      test('BadgeRepository unlock is idempotent', () async {
        final repo = BadgeRepository(await entry.value());
        await repo.unlock(BadgeKey.logger, DateTime(2026, 1, 1));
        await repo.unlock(BadgeKey.logger, DateTime(2026, 5, 1));
        expect(repo.unlocked()[BadgeKey.logger], DateTime(2026, 1, 1));
        expect(repo.isUnlocked(BadgeKey.streak3), isFalse);
      });
    });
  }
}
