import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/l10n.dart';
import '../../../app/state/budget_controller.dart';
import '../../../core/widgets/emoji_picker.dart';
import '../data/goal.dart';
import '../../../core/widgets/insets.dart';

/// Create a new goal, or edit [existing].
Future<void> showGoalForm(
  BuildContext context, {
  Goal? existing,
  String? presetName,
  int? presetTarget,
  String? presetEmoji,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useRootNavigator: true,
  useSafeArea: true,
  builder: (_) => _GoalForm(
    existing: existing,
    presetName: presetName,
    presetTarget: presetTarget,
    presetEmoji: presetEmoji,
  ),
);

class _GoalForm extends ConsumerStatefulWidget {
  const _GoalForm({
    this.existing,
    this.presetName,
    this.presetTarget,
    this.presetEmoji,
  });

  final Goal? existing;
  final String? presetName;
  final int? presetTarget;
  final String? presetEmoji;

  @override
  ConsumerState<_GoalForm> createState() => _GoalFormState();
}

class _GoalFormState extends ConsumerState<_GoalForm> {
  late final TextEditingController _name = TextEditingController(
    text: widget.existing?.name ?? widget.presetName ?? '',
  );
  late final TextEditingController _target = TextEditingController(
    text:
        (widget.existing?.targetAmount ?? widget.presetTarget)?.toString() ??
        '',
  );
  late String _emoji =
      widget.existing?.emoji ?? widget.presetEmoji ?? EmojiPicker.goalEmojis[1];
  late DateTime? _date = widget.existing?.targetDate;
  String? _nameError;
  String? _targetError;

  @override
  void dispose() {
    _name.dispose();
    _target.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = ref.read(budgetProvider).now;
    final d = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime(now.year, now.month + 6, now.day),
      firstDate: now,
      lastDate: DateTime(now.year + 20),
    );
    if (d != null) setState(() => _date = d);
  }

  Future<void> _save() async {
    final l = context.l10n;
    final target = int.tryParse(_target.text) ?? 0;
    setState(() {
      _nameError = _name.text.trim().isEmpty ? l.goalNameError : null;
      _targetError = target <= 0 ? l.goalTargetError : null;
    });
    if (_nameError != null || _targetError != null) return;
    final c = ref.read(budgetProvider.notifier);
    final e = widget.existing;
    if (e == null) {
      await c.addGoal(
        name: _name.text,
        emoji: _emoji,
        targetAmount: target,
        targetDate: _date,
      );
    } else {
      await c.updateGoal(
        e.copyWith(
          name: _name.text.trim(),
          emoji: _emoji,
          targetAmount: target,
          targetDate: _date,
          clearTargetDate: _date == null,
        ),
      );
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = Theme.of(context).textTheme;
    final locale = Localizations.localeOf(context).toString();
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, safeBottom(context) + 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.existing == null ? l.goalAdd : l.goalEdit,
              style: t.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('goal_name'),
              controller: _name,
              maxLength: 30,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l.goalName,
                hintText: l.goalNameHint,
                errorText: _nameError,
                counterText: '',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('goal_target'),
              controller: _target,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(8),
              ],
              decoration: InputDecoration(
                labelText: l.goalTarget,
                prefixText: '₹ ',
                errorText: _targetError,
              ),
            ),
            const SizedBox(height: 12),
            Text(l.goalPickIcon, style: t.labelMedium),
            const SizedBox(height: 8),
            EmojiPicker(
              options: EmojiPicker.goalEmojis,
              selected: _emoji,
              onSelected: (e) => setState(() => _emoji = e),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.event),
                    label: Text(
                      _date == null
                          ? l.goalTargetDate
                          : DateFormat.yMMMd(locale).format(_date!),
                    ),
                  ),
                ),
                if (_date != null)
                  IconButton(
                    tooltip: l.goalNoDate,
                    onPressed: () => setState(() => _date = null),
                    icon: const Icon(Icons.close),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            FilledButton(
              key: const Key('goal_save'),
              onPressed: _save,
              child: Text(l.commonSave),
            ),
          ],
        ),
      ),
    );
  }
}
