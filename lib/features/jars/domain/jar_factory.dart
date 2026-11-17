import '../data/jar.dart';

/// Creates the default shelf of glasses from a planned split.
abstract final class JarFactory {
  /// English fallback names; the UI shows localized names for built-ins.
  static const Map<JarType, String> _names = {
    JarType.savings: 'Savings',
    JarType.rent: 'Rent',
    JarType.food: 'Food',
    JarType.travel: 'Travel',
    JarType.fun: 'Fun',
  };

  static List<Jar> defaultJars(Map<JarType, int> plan) {
    var order = 0;
    return [
      for (final t in JarDefaults.fillOrder)
        Jar(
          id: JarDefaults.idFor(t),
          name: _names[t]!,
          emoji: JarDefaults.emoji[t]!,
          colorHex: JarDefaults.colorHex[t]!,
          type: t,
          allocatedAmount: 0,
          spentAmount: 0,
          order: order++,
          isProtected: t == JarType.savings,
          plannedAmount: plan[t] ?? 0,
        ),
    ];
  }

  /// A user-made glass placed just before Fun on the shelf.
  static Jar custom({
    required String id,
    required String name,
    required String emoji,
    required int order,
    String colorHex = 'FF8FD3C8',
  }) => Jar(
    id: id,
    name: name,
    emoji: emoji,
    colorHex: colorHex,
    type: JarType.custom,
    allocatedAmount: 0,
    spentAmount: 0,
    order: order,
    isProtected: false,
    plannedAmount: 0,
  );
}
