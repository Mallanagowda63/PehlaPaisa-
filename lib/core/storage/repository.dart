import 'key_value_store.dart';

/// Generic CRUD repository for a collection of records keyed by id.
///
/// Feature repositories extend this and add their own queries.
abstract class CollectionRepository<T> {
  CollectionRepository(this.store);

  final KeyValueStore store;

  Map<String, dynamic> toMap(T item);
  T fromMap(Map<String, dynamic> map);
  String idOf(T item);

  /// Every record (unordered unless a subclass sorts).
  List<T> getAll() => store.values().map(fromMap).toList();

  T? getById(String id) {
    final m = store.get(id);
    return m == null ? null : fromMap(m);
  }

  /// Insert or replace.
  Future<void> save(T item) => store.put(idOf(item), toMap(item));

  Future<void> saveAll(Iterable<T> items) =>
      store.putAll({for (final i in items) idOf(i): toMap(i)});

  Future<void> delete(String id) => store.delete(id);

  Future<void> clear() => store.clear();
}

/// Repository for a single record (profile, settings).
abstract class SingletonRepository<T> {
  SingletonRepository(this.store);

  static const String _key = 'value';
  final KeyValueStore store;

  Map<String, dynamic> toMap(T item);
  T fromMap(Map<String, dynamic> map);

  T? read() {
    final m = store.get(_key);
    return m == null ? null : fromMap(m);
  }

  Future<void> write(T item) => store.put(_key, toMap(item));

  Future<void> clear() => store.clear();
}
