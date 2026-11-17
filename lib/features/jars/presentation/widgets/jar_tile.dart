import 'package:flutter/material.dart';

import '../../../../app/l10n.dart';
import '../../../../app/theme.dart';
import '../../../../core/money.dart';
import '../../data/jar.dart';
import '../jar_labels.dart';
import 'glass_jar.dart';

/// A glass on the shelf with its emoji, name and amount left underneath.
///
/// Tap → details, long-press → quick add. Screen readers hear e.g.
/// "Food glass, ₹1,200 left of ₹2,500".
class JarTile extends StatelessWidget {
  const JarTile({
    super.key,
    required this.jar,
    required this.family,
    this.width = 96,
    this.onTap,
    this.onLongPress,
    this.selected = false,
    this.compact = false,
    this.levelOverride,
    this.pour = 0,
  });

  final Jar jar;
  final bool family;
  final double width;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool selected;

  /// Small variant for selectors (name only, no amount).
  final bool compact;

  /// Drives the level directly (salary-day pour) instead of from the jar.
  final double? levelOverride;
  final double pour;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = Theme.of(context).textTheme;
    final pp = context.pp;
    final name = jarName(l, jar.type, jar.name, family: family);
    final color = jarColor(context, jar.type, colorHex: jar.colorHex);
    final glow = jarGlow(context, jar.type, colorHex: jar.colorHex);
    final height = width * 1.3;
    final remaining = jar.remaining;

    final amountText = jar.allocatedAmount == 0 && jar.spentAmount == 0
        ? l.jarEmpty
        : remaining < 0
        ? l.jarOver(formatRupees(-remaining))
        : l.jarLeft(formatRupees(remaining));

    return Semantics(
      button: onTap != null,
      selected: selected,
      label: glassSemantics(l, name, remaining, jar.allocatedAmount),
      hint: onLongPress != null ? l.glassHint : null,
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        onLongPress: onLongPress,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: selected
                ? color.withValues(alpha: 0.16)
                : Colors.transparent,
            border: Border.all(
              color: selected ? color : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GlassJar(
                level: levelOverride ?? jar.fillRatio,
                color: color,
                glow: glow,
                width: width,
                height: height,
                pour: pour,
                animateLevel: levelOverride == null,
                glowStrength: compact ? 0.6 : 1,
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: width + 16,
                child: Text(
                  '${jar.emoji} $name',
                  textAlign: TextAlign.center,
                  maxLines: compact ? 1 : 2,
                  overflow: TextOverflow.ellipsis,
                  style: compact ? t.labelSmall : t.labelMedium,
                ),
              ),
              if (!compact)
                SizedBox(
                  width: width + 16,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      amountText,
                      textAlign: TextAlign.center,
                      style: t.titleSmall?.copyWith(
                        color: remaining < 0
                            ? pp.danger
                            : jar.isSavings
                            ? pp.savings
                            : null,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
