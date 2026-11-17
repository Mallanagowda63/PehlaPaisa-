/// The built-in glass kinds plus user-created ones.
enum JarType { savings, rent, food, travel, fun, custom }

/// A glass on the shelf. Holds this cycle's allocation and spending.
class Jar {
  const Jar({
    required this.id,
    required this.name,
    required this.emoji,
    required this.colorHex,
    required this.type,
    required this.allocatedAmount,
    required this.spentAmount,
    required this.order,
    required this.isProtected,
    required this.plannedAmount,
  });

  final String id;

  /// Display name. Built-in jars are shown with a localized name instead;
  /// this field matters for [JarType.custom] glasses.
  final String name;
  final String emoji;

  /// ARGB hex like `FFFFC857`.
  final String colorHex;
  final JarType type;

  /// Money poured into the glass this cycle (can grow/shrink via transfers).
  final int allocatedAmount;

  /// Money spent from the glass this cycle.
  final int spentAmount;

  /// Position on the shelf (Savings first).
  final int order;

  /// True only for Savings: never drained automatically.
  final bool isProtected;

  /// The monthly plan for this glass (from the split). Also used as the
  /// weight when splitting irregular income entries.
  final int plannedAmount;

  int get remaining => allocatedAmount - spentAmount;

  /// Liquid level 0..1 (remaining / allocated).
  double get fillRatio {
    if (allocatedAmount <= 0) return 0;
    return (remaining / allocatedAmount).clamp(0.0, 1.0);
  }

  bool get isSavings => type == JarType.savings;
  bool get isFun => type == JarType.fun;

  Jar copyWith({
    String? name,
    String? emoji,
    String? colorHex,
    int? allocatedAmount,
    int? spentAmount,
    int? order,
    int? plannedAmount,
  }) {
    return Jar(
      id: id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      colorHex: colorHex ?? this.colorHex,
      type: type,
      allocatedAmount: allocatedAmount ?? this.allocatedAmount,
      spentAmount: spentAmount ?? this.spentAmount,
      order: order ?? this.order,
      isProtected: isProtected,
      plannedAmount: plannedAmount ?? this.plannedAmount,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'emoji': emoji,
    'colorHex': colorHex,
    'type': type.name,
    'allocatedAmount': allocatedAmount,
    'spentAmount': spentAmount,
    'order': order,
    'isProtected': isProtected,
    'plannedAmount': plannedAmount,
  };

  factory Jar.fromMap(Map<String, dynamic> m) => Jar(
    id: m['id'] as String,
    name: m['name'] as String? ?? '',
    emoji: m['emoji'] as String? ?? '🫙',
    colorHex: m['colorHex'] as String? ?? 'FF7FA7E0',
    type: JarType.values.firstWhere(
      (e) => e.name == m['type'],
      orElse: () => JarType.custom,
    ),
    allocatedAmount: (m['allocatedAmount'] as num?)?.toInt() ?? 0,
    spentAmount: (m['spentAmount'] as num?)?.toInt() ?? 0,
    order: (m['order'] as num?)?.toInt() ?? 0,
    isProtected: m['isProtected'] as bool? ?? false,
    plannedAmount: (m['plannedAmount'] as num?)?.toInt() ?? 0,
  );
}

/// Default look of each built-in glass.
class JarDefaults {
  static const Map<JarType, String> emoji = {
    JarType.savings: '🪙',
    JarType.rent: '🏠',
    JarType.food: '🍛',
    JarType.travel: '🛺',
    JarType.fun: '🎉',
    JarType.custom: '🫙',
  };

  static const Map<JarType, String> colorHex = {
    JarType.savings: 'FFFFC857',
    JarType.rent: 'FF7FA7E0',
    JarType.food: 'FF7FA7E0',
    JarType.travel: 'FF7FA7E0',
    JarType.fun: 'FFE58FB8',
    JarType.custom: 'FF8FD3C8',
  };

  /// Fill order on salary day (Savings first, always).
  static const List<JarType> fillOrder = [
    JarType.savings,
    JarType.rent,
    JarType.food,
    JarType.travel,
    JarType.fun,
  ];

  /// Stable ids for the built-in jars.
  static String idFor(JarType t) => 'jar_${t.name}';
}
