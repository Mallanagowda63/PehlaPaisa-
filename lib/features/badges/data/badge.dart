/// Every badge the app can award.
enum BadgeKey {
  pehlaKadam,
  pehlaPaisa,
  streak3,
  streak6,
  streak12,
  gullakMaster,
  goalGetter,
  funUnderControl,
  logger,
  bachatChampion,
}

/// Emoji shown on each badge.
const Map<BadgeKey, String> badgeEmoji = {
  BadgeKey.pehlaKadam: '👣',
  BadgeKey.pehlaPaisa: '🪙',
  BadgeKey.streak3: '🔥',
  BadgeKey.streak6: '☄️',
  BadgeKey.streak12: '🏆',
  BadgeKey.gullakMaster: '🐷',
  BadgeKey.goalGetter: '🎯',
  BadgeKey.funUnderControl: '🎈',
  BadgeKey.logger: '📒',
  BadgeKey.bachatChampion: '👑',
};

/// The persisted "Badge" model (named BadgeRecord to avoid clashing with
/// Material's Badge widget). [unlockedAt] is null while locked.
class BadgeRecord {
  const BadgeRecord({required this.id, required this.key, this.unlockedAt});

  final String id;
  final BadgeKey key;
  final DateTime? unlockedAt;

  bool get isUnlocked => unlockedAt != null;

  Map<String, dynamic> toMap() => {
    'id': id,
    'key': key.name,
    'unlockedAt': unlockedAt?.millisecondsSinceEpoch,
  };

  factory BadgeRecord.fromMap(Map<String, dynamic> m) {
    final at = m['unlockedAt'] as num?;
    return BadgeRecord(
      id: m['id'] as String,
      key: BadgeKey.values.firstWhere(
        (e) => e.name == m['key'],
        orElse: () => BadgeKey.pehlaKadam,
      ),
      unlockedAt: at == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(at.toInt()),
    );
  }
}
