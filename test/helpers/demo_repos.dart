import 'package:pehla_paisa/app/state/repositories.dart';
import 'package:pehla_paisa/features/badges/data/badge.dart';
import 'package:pehla_paisa/features/settings/data/app_settings.dart';

import '../widget/harness.dart';
import 'demo_seeder.dart';

/// In-memory storage filled with 6 months of realistic data, so every screen
/// has charts, goals, history and badges to lay out.
Future<Repositories> demoRepos({
  String language = 'en',
  AppThemeMode theme = AppThemeMode.dark,
  int income = 10000,
}) async {
  final repos = Repositories.inMemory();
  final demo = DemoSeeder.generate(income: income, now: testNow);
  await repos.settings.write(AppSettings(language: language, themeMode: theme));
  await repos.profile.write(demo.profile.copyWith(language: language));
  await repos.jars.saveAll(demo.jars);
  await repos.cycles.saveAll(demo.cycles);
  await repos.transactions.saveAll(demo.transactions);
  await repos.goals.saveAll(demo.goals);
  for (final k in [
    BadgeKey.pehlaKadam,
    BadgeKey.pehlaPaisa,
    BadgeKey.streak3,
    BadgeKey.streak6,
    BadgeKey.gullakMaster,
    BadgeKey.goalGetter,
  ]) {
    await repos.badges.unlock(k, DateTime(2026, 10, 1));
  }
  return repos;
}
