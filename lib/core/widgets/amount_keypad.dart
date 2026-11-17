import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/l10n.dart';
import '../../app/theme.dart';
import '../money.dart';

/// Big ₹ amount display.
class AmountDisplay extends StatelessWidget {
  const AmountDisplay({super.key, required this.amount, this.color});

  final int amount;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = color ?? (amount == 0 ? context.pp.muted : null);
    return Semantics(
      liveRegion: true,
      label: formatRupees(amount),
      excludeSemantics: true,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          formatRupees(amount),
          style: t.displayMedium?.copyWith(color: c),
        ),
      ),
    );
  }
}

/// A large numeric keypad for entering rupee amounts with one thumb.
class AmountKeypad extends StatelessWidget {
  const AmountKeypad({
    super.key,
    required this.amount,
    required this.onChanged,
    this.maxDigits = 7,
    this.compact = false,
  });

  final int amount;
  final ValueChanged<int> onChanged;
  final int maxDigits;

  /// Shorter keys for small screens (still ≥ 48dp tap targets).
  final bool compact;

  void _type(String digits) {
    final current = amount == 0 ? '' : amount.toString();
    final next = current + digits;
    if (next.length > maxDigits) return;
    HapticFeedback.selectionClick();
    onChanged(int.parse(next));
  }

  void _back() {
    HapticFeedback.selectionClick();
    final s = amount.toString();
    onChanged(s.length <= 1 ? 0 : int.parse(s.substring(0, s.length - 1)));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    Widget key(String label, VoidCallback onTap, {String? semantics}) {
      return Expanded(
        child: Padding(
          padding: EdgeInsets.all(compact ? 3 : 4),
          child: Semantics(
            button: true,
            label: semantics ?? label,
            excludeSemantics: true,
            child: Material(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: onTap,
                onLongPress: label == '⌫' ? () => onChanged(0) : null,
                child: SizedBox(
                  height: compact ? 48 : 56,
                  child: Center(
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    Widget row(List<String> keys) =>
        Row(children: [for (final k in keys) key(k, () => _type(k))]);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        row(['1', '2', '3']),
        row(['4', '5', '6']),
        row(['7', '8', '9']),
        Row(
          children: [
            key('00', () => _type('00')),
            key('0', () => _type('0')),
            key('⌫', _back, semantics: l.keypadDelete),
          ],
        ),
      ],
    );
  }
}
