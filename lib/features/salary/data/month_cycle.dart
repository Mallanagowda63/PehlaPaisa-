import '../../jars/data/jar.dart';

/// A frozen copy of a glass at the end of (or during) a month.
class JarSnapshot {
  const JarSnapshot({
    required this.jarId,
    required this.type,
    required this.name,
    required this.emoji,
    required this.allocated,
    required this.spent,
  });

  final String jarId;
  final JarType type;
  final String name;
  final String emoji;
  final int allocated;
  final int spent;

  int get remaining => allocated - spent;

  factory JarSnapshot.fromJar(Jar j) => JarSnapshot(
    jarId: j.id,
    type: j.type,
    name: j.name,
    emoji: j.emoji,
    allocated: j.allocatedAmount,
    spent: j.spentAmount,
  );

  Map<String, dynamic> toMap() => {
    'jarId': jarId,
    'type': type.name,
    'name': name,
    'emoji': emoji,
    'allocated': allocated,
    'spent': spent,
  };

  factory JarSnapshot.fromMap(Map<String, dynamic> m) => JarSnapshot(
    jarId: m['jarId'] as String? ?? '',
    type: JarType.values.firstWhere(
      (e) => e.name == m['type'],
      orElse: () => JarType.custom,
    ),
    name: m['name'] as String? ?? '',
    emoji: m['emoji'] as String? ?? '🫙',
    allocated: (m['allocated'] as num?)?.toInt() ?? 0,
    spent: (m['spent'] as num?)?.toInt() ?? 0,
  );
}

/// One budget month, starting on the user's salary day.
class MonthCycle {
  const MonthCycle({
    required this.id,
    required this.month,
    required this.year,
    required this.startDate,
    required this.endDate,
    required this.income,
    required this.savingsFilledFirst,
    required this.savingsFilledAt,
    required this.savingsBroken,
    required this.funded,
    required this.jarsSnapshot,
    required this.closed,
  });

  /// `YYYY-MM` of [startDate].
  final String id;
  final int month;
  final int year;
  final DateTime startDate;

  /// Last day of the cycle (inclusive).
  final DateTime endDate;

  /// Total income poured in this cycle (sum of entries for irregular users).
  final int income;

  /// The pay-yourself-first ritual happened: Savings was filled before
  /// anything else this month.
  final bool savingsFilledFirst;
  final DateTime? savingsFilledAt;

  /// The user broke their savings this month (ends the streak).
  final bool savingsBroken;

  /// At least one income entry has been poured into the glasses.
  final bool funded;

  /// Allocations + spending per glass, filled in when the cycle closes.
  final List<JarSnapshot> jarsSnapshot;
  final bool closed;

  MonthCycle copyWith({
    int? income,
    bool? savingsFilledFirst,
    DateTime? savingsFilledAt,
    bool? savingsBroken,
    bool? funded,
    List<JarSnapshot>? jarsSnapshot,
    bool? closed,
  }) {
    return MonthCycle(
      id: id,
      month: month,
      year: year,
      startDate: startDate,
      endDate: endDate,
      income: income ?? this.income,
      savingsFilledFirst: savingsFilledFirst ?? this.savingsFilledFirst,
      savingsFilledAt: savingsFilledAt ?? this.savingsFilledAt,
      savingsBroken: savingsBroken ?? this.savingsBroken,
      funded: funded ?? this.funded,
      jarsSnapshot: jarsSnapshot ?? this.jarsSnapshot,
      closed: closed ?? this.closed,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'month': month,
    'year': year,
    'startDate': startDate.millisecondsSinceEpoch,
    'endDate': endDate.millisecondsSinceEpoch,
    'income': income,
    'savingsFilledFirst': savingsFilledFirst,
    'savingsFilledAt': savingsFilledAt?.millisecondsSinceEpoch,
    'savingsBroken': savingsBroken,
    'funded': funded,
    'jarsSnapshot': jarsSnapshot.map((s) => s.toMap()).toList(),
    'closed': closed,
  };

  factory MonthCycle.fromMap(Map<String, dynamic> m) {
    DateTime d(String k) =>
        DateTime.fromMillisecondsSinceEpoch((m[k] as num?)?.toInt() ?? 0);
    final filledAt = m['savingsFilledAt'] as num?;
    return MonthCycle(
      id: m['id'] as String,
      month: (m['month'] as num).toInt(),
      year: (m['year'] as num).toInt(),
      startDate: d('startDate'),
      endDate: d('endDate'),
      income: (m['income'] as num?)?.toInt() ?? 0,
      savingsFilledFirst: m['savingsFilledFirst'] as bool? ?? false,
      savingsFilledAt: filledAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(filledAt.toInt()),
      savingsBroken: m['savingsBroken'] as bool? ?? false,
      funded: m['funded'] as bool? ?? false,
      jarsSnapshot: (m['jarsSnapshot'] as List<dynamic>? ?? const [])
          .map((e) => JarSnapshot.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      closed: m['closed'] as bool? ?? false,
    );
  }
}
