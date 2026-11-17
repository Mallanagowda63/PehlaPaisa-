/// A tiny persistence abstraction so repositories don't depend on Hive
/// directly. Production uses [HiveStore]; tests use [MemoryStore].
///
/// Values are JSON-like maps (`String`, `num`, `bool`, `List`, `Map`), which
/// keeps records portable and makes the "export as JSON" feature trivial.
abstract class KeyValueStore {
  /// Returns the record stored under [key], or null.
  Map<String, dynamic>? get(String key);

  /// All stored records (unordered).
  List<Map<String, dynamic>> values();

  /// All stored keys.
  List<String> keys();

  Future<void> put(String key, Map<String, dynamic> value);

  Future<void> putAll(Map<String, Map<String, dynamic>> entries);

  Future<void> delete(String key);

  Future<void> clear();
}

/// Deep-converts the loosely typed maps that come back from storage into
/// `Map<String, dynamic>` (nested maps and lists included).
Map<String, dynamic> normalizeMap(Map<dynamic, dynamic> raw) {
  return raw.map((k, v) => MapEntry(k.toString(), _normalizeValue(v)));
}

dynamic _normalizeValue(dynamic v) {
  if (v is Map) return normalizeMap(v);
  if (v is List) return v.map(_normalizeValue).toList();
  return v;
}

/// In-memory implementation, used by widget tests and as a fallback.
class MemoryStore implements KeyValueStore {
  final Map<String, Map<String, dynamic>> _data = {};

  @override
  Map<String, dynamic>? get(String key) {
    final v = _data[key];
    return v == null ? null : normalizeMap(v);
  }

  @override
  List<Map<String, dynamic>> values() =>
      _data.values.map((v) => normalizeMap(v)).toList();

  @override
  List<String> keys() => _data.keys.toList();

  @override
  Future<void> put(String key, Map<String, dynamic> value) async {
    _data[key] = normalizeMap(value);
  }

  @override
  Future<void> putAll(Map<String, Map<String, dynamic>> entries) async {
    entries.forEach((k, v) => _data[k] = normalizeMap(v));
  }

  @override
  Future<void> delete(String key) async {
    _data.remove(key);
  }

  @override
  Future<void> clear() async {
    _data.clear();
  }
}
