import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// A row of emoji choices (for goals and custom glasses).
class EmojiPicker extends StatelessWidget {
  const EmojiPicker({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  static const goalEmojis = [
    '🛟',
    '📱',
    '🏍️',
    '🏖️',
    '🎓',
    '💍',
    '🏠',
    '💻',
    '🎁',
    '🩺',
    '🚲',
    '🎯',
  ];

  static const jarEmojis = [
    '🫙',
    '📚',
    '💊',
    '👕',
    '🎁',
    '🐶',
    '🧒',
    '🙏',
    '💡',
    '🧴',
  ];

  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final e in options)
          Semantics(
            selected: e == selected,
            button: true,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => onSelected(e),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: e == selected
                      ? context.pp.savings.withValues(alpha: 0.25)
                      : Theme.of(context).colorScheme.surfaceContainerHigh,
                  border: Border.all(
                    color: e == selected
                        ? context.pp.savings
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Text(e, style: const TextStyle(fontSize: 22)),
              ),
            ),
          ),
      ],
    );
  }
}
