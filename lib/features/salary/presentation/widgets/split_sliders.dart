import 'package:flutter/material.dart';

import '../../../../app/l10n.dart';
import '../../../../app/theme.dart';
import '../../../../core/money.dart';
import '../../../../core/widgets/dialogs.dart';
import '../../../jars/data/jar.dart';
import '../../../jars/presentation/jar_labels.dart';
import '../../domain/split_calculator.dart';

/// One editable line of the split.
class SplitRow {
  const SplitRow({
    required this.key,
    required this.type,
    required this.label,
    required this.emoji,
    this.colorHex,
  });

  final String key;
  final JarType type;
  final String label;
  final String emoji;
  final String? colorHex;
}

/// Sliders for dividing [income] between glasses. The [balancerKey] row
/// (Fun) has no slider: it shows whatever is left so the total always equals
/// income. Lowering Savings below 5% asks for confirmation.
class SplitSliders extends StatelessWidget {
  const SplitSliders({
    super.key,
    required this.income,
    required this.rows,
    required this.amounts,
    required this.balancerKey,
    required this.savingsKey,
    required this.onChanged,
  });

  final int income;
  final List<SplitRow> rows;
  final Map<String, int> amounts;
  final String balancerKey;
  final String savingsKey;
  final ValueChanged<Map<String, int>> onChanged;

  Future<void> _checkSavings(BuildContext context, int value) async {
    if (!SplitCalculator.isSavingsBelowMinimum(value, income)) return;
    final l = context.l10n;
    final ok = await confirmDialog(
      context,
      emoji: '🪙',
      title: l.lowSavingsTitle,
      body: l.lowSavingsBody,
      confirmLabel: l.lowSavingsConfirm,
      cancelLabel: l.lowSavingsKeep,
    );
    if (!ok) {
      onChanged(
        SplitCalculator.adjust(
          amounts: amounts,
          jarId: savingsKey,
          newAmount: SplitCalculator.minimumSavings(income),
          balancerId: balancerKey,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = Theme.of(context).textTheme;
    final balance = amounts[balancerKey] ?? 0;
    return Column(
      children: [
        for (final row in rows) ...[
          _buildRow(context, row, balance),
          const SizedBox(height: 4),
        ],
        const Divider(height: 24),
        Row(
          children: [
            Expanded(child: Text(l.splitTotalLabel, style: t.titleMedium)),
            Text(
              formatRupees(amounts.values.fold<int>(0, (a, b) => a + b)),
              style: t.titleMedium,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRow(BuildContext context, SplitRow row, int balance) {
    final l = context.l10n;
    final t = Theme.of(context).textTheme;
    final amount = amounts[row.key] ?? 0;
    final color = jarColor(context, row.type, colorHex: row.colorHex);
    final isBalancer = row.key == balancerKey;
    final max = amount + balance;
    final pct = percentOf(amount, income);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(row.emoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    row.label,
                    style: t.titleSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  formatRupees(amount),
                  style: t.titleMedium?.copyWith(color: color),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 44,
                  child: Text(
                    l.percentValue(pct),
                    textAlign: TextAlign.end,
                    style: t.bodySmall,
                  ),
                ),
              ],
            ),
            if (isBalancer)
              Padding(
                padding: const EdgeInsets.only(top: 6, bottom: 6),
                child: Text(l.splitFunLeft, style: t.bodySmall),
              )
            else
              Semantics(
                label: '${row.label} ${formatRupees(amount)}',
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: color,
                    thumbColor: color,
                    overlayColor: color.withValues(alpha: 0.15),
                  ),
                  child: Slider(
                    value: amount.toDouble().clamp(0, max.toDouble()),
                    min: 0,
                    max: max <= 0 ? 1 : max.toDouble(),
                    divisions: max >= 20 ? max ~/ 10 : null,
                    label: formatRupees(amount),
                    onChanged: max <= 0
                        ? null
                        : (v) => onChanged(
                            SplitCalculator.adjust(
                              amounts: amounts,
                              jarId: row.key,
                              newAmount: roundTo10(v),
                              balancerId: balancerKey,
                            ),
                          ),
                    onChangeEnd: row.key == savingsKey
                        ? (v) =>
                              _checkSavings(context, amounts[savingsKey] ?? 0)
                        : null,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Coloured bar showing the split proportions at a glance.
class SplitBar extends StatelessWidget {
  const SplitBar({super.key, required this.rows, required this.amounts});

  final List<SplitRow> rows;
  final Map<String, int> amounts;

  @override
  Widget build(BuildContext context) {
    final total = amounts.values.fold<int>(0, (a, b) => a + b);
    if (total <= 0) return const SizedBox(height: 14);
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 14,
        child: Row(
          children: [
            for (final r in rows)
              if ((amounts[r.key] ?? 0) > 0)
                Expanded(
                  flex: amounts[r.key]!,
                  child: Container(
                    color: r.type == JarType.savings || r.type == JarType.fun
                        ? jarColor(context, r.type)
                        : Color.lerp(
                            context.pp.jar,
                            Colors.white,
                            0.15 * rows.indexOf(r),
                          ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
