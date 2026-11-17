import '../../../core/storage/repository.dart';
import 'app_settings.dart';

class SettingsRepository extends SingletonRepository<AppSettings> {
  SettingsRepository(super.store);

  /// Stored settings, or defaults on first launch.
  AppSettings readOrDefault() => read() ?? const AppSettings();

  @override
  AppSettings fromMap(Map<String, dynamic> map) => AppSettings.fromMap(map);

  @override
  Map<String, dynamic> toMap(AppSettings item) => item.toMap();
}
