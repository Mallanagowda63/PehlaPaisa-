import '../../../core/storage/repository.dart';
import 'badge.dart';

class BadgeRepository extends CollectionRepository<BadgeRecord> {
  BadgeRepository(super.store);

  /// Unlocked badges keyed by [BadgeKey].
  Map<BadgeKey, DateTime> unlocked() => {
    for (final b in getAll())
      if (b.unlockedAt != null) b.key: b.unlockedAt!,
  };

  bool isUnlocked(BadgeKey key) => unlocked().containsKey(key);

  /// Marks [key] as unlocked at [at] (no-op if already unlocked).
  Future<void> unlock(BadgeKey key, DateTime at) async {
    if (isUnlocked(key)) return;
    await save(BadgeRecord(id: key.name, key: key, unlockedAt: at));
  }

  @override
  BadgeRecord fromMap(Map<String, dynamic> map) => BadgeRecord.fromMap(map);

  @override
  String idOf(BadgeRecord item) => item.id;

  @override
  Map<String, dynamic> toMap(BadgeRecord item) => item.toMap();
}
