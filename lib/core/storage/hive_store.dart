import 'package:hive_ce/hive.dart';

import 'key_value_store.dart';

/// Names of every Hive box the app uses. Keeping them in one place makes
/// "reset all data" and export reliable.
abstract final class BoxNames {
  static const String profile = 'profile';
  static const String settings = 'settings';
  static const String jars = 'jars';
  static const String transactions = 'transactions';
  static const String cycles = 'cycles';
  static const String goals = 'goals';
  static const String badges = 'badges';

  static const List<String> all = [
    profile,
    settings,
    jars,
    transactions,
    cycles,
    goals,
    badges,
  ];
}

/// [KeyValueStore] backed by a Hive box of JSON-like maps.
///
/// Hive updates its in-memory cache synchronously on `put`, so reads right
/// after a write (even before the returned future completes) see new data.
class HiveStore implements KeyValueStore {
  HiveStore(this._box);

  final Box<dynamic> _box;

  /// Opens (or creates) the box called [name].
  static Future<HiveStore> open(String name) async =>
      HiveStore(await Hive.openBox<dynamic>(name));

  @override
  Map<String, dynamic>? get(String key) {
    final raw = _box.get(key);
    return raw is Map ? normalizeMap(raw) : null;
  }

  @override
  List<Map<String, dynamic>> values() =>
      _box.values.whereType<Map<dynamic, dynamic>>().map(normalizeMap).toList();

  @override
  List<String> keys() => _box.keys.map((k) => k.toString()).toList();

  @override
  Future<void> put(String key, Map<String, dynamic> value) =>
      _box.put(key, value);

  @override
  Future<void> putAll(Map<String, Map<String, dynamic>> entries) =>
      _box.putAll(entries);

  @override
  Future<void> delete(String key) => _box.delete(key);

  @override
  Future<void> clear() async {
    await _box.clear();
  }
}
