/// A savings goal, shown as its own glass filling up.
class Goal {
  const Goal({
    required this.id,
    required this.name,
    required this.emoji,
    required this.targetAmount,
    required this.savedAmount,
    required this.createdAt,
    this.targetDate,
    this.completedAt,
  });

  final String id;
  final String name;
  final String emoji;
  final int targetAmount;
  final int savedAmount;
  final DateTime? targetDate;
  final DateTime createdAt;
  final DateTime? completedAt;

  bool get isComplete => completedAt != null || savedAmount >= targetAmount;
  int get remaining => (targetAmount - savedAmount).clamp(0, targetAmount);

  double get progress {
    if (targetAmount <= 0) return 0;
    return (savedAmount / targetAmount).clamp(0.0, 1.0);
  }

  Goal copyWith({
    String? name,
    String? emoji,
    int? targetAmount,
    int? savedAmount,
    DateTime? targetDate,
    bool clearTargetDate = false,
    DateTime? completedAt,
    bool clearCompletedAt = false,
  }) {
    return Goal(
      id: id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      targetAmount: targetAmount ?? this.targetAmount,
      savedAmount: savedAmount ?? this.savedAmount,
      createdAt: createdAt,
      targetDate: clearTargetDate ? null : (targetDate ?? this.targetDate),
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'emoji': emoji,
    'targetAmount': targetAmount,
    'savedAmount': savedAmount,
    'targetDate': targetDate?.millisecondsSinceEpoch,
    'createdAt': createdAt.millisecondsSinceEpoch,
    'completedAt': completedAt?.millisecondsSinceEpoch,
  };

  factory Goal.fromMap(Map<String, dynamic> m) {
    DateTime? opt(String k) {
      final v = m[k] as num?;
      return v == null ? null : DateTime.fromMillisecondsSinceEpoch(v.toInt());
    }

    return Goal(
      id: m['id'] as String,
      name: m['name'] as String? ?? '',
      emoji: m['emoji'] as String? ?? '🎯',
      targetAmount: (m['targetAmount'] as num?)?.toInt() ?? 0,
      savedAmount: (m['savedAmount'] as num?)?.toInt() ?? 0,
      targetDate: opt('targetDate'),
      createdAt: opt('createdAt') ?? DateTime.fromMillisecondsSinceEpoch(0),
      completedAt: opt('completedAt'),
    );
  }
}
