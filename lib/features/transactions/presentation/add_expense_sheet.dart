import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/l10n.dart';
import '../../../app/router.dart';
import '../../../app/state/budget_controller.dart';
import '../../../app/theme.dart';
import '../../../core/dates.dart';
import '../../../core/money.dart';
import '../../../core/widgets/amount_keypad.dart';
import '../../../core/widgets/dialogs.dart';
import '../../alerts/presentation/notification_sync.dart';
import '../../jars/data/jar.dart';
import '../../jars/presentation/jar_labels.dart';
import '../../jars/presentation/widgets/jar_tile.dart';
import '../domain/overflow_planner.dart';
import '../../../core/widgets/insets.dart';

/// Opens the Add Expense sheet. If the month isn't funded yet, asks the user
/// to fill their glasses first instead.
Future<void> showAddExpenseSheet(
  BuildContext context,
  WidgetRef ref, {
  String? jarId,
}) async {
  final state = ref.read(budgetProvider);
  if (state.needsFunding) {
    final l = context.l10n;
    final go = await confirmDialog(
      context,
      emoji: '🟡',
      title: l.fillFirstTitle,
      body: l.fillFirstBody,
      confirmLabel: l.homeFillButton,
    );
    if (go && context.mounted) context.push(Routes.salary);
    return;
  }
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    useSafeArea: true,
    builder: (_) => AddExpenseSheet(initialJarId: jarId),
  );
}

/// Amount keypad + glass selector + optional note/date. Save in ≤ 3 taps.
class AddExpenseSheet extends ConsumerStatefulWidget {
  const AddExpenseSheet({super.key, this.initialJarId});

  final String? initialJarId;

  @override
  ConsumerState<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

/// What the user picked in the overflow dialog.
class _OverflowChoice {
  const _OverflowChoice.borrow(this.jarId) : kind = 0;
  const _OverflowChoice.savings() : jarId = null, kind = 1;
  const _OverflowChoice.overspend() : jarId = null, kind = 2;

  final String? jarId;
  final int kind;
}

class _AddExpenseSheetState extends ConsumerState<AddExpenseSheet> {
  int _amount = 0;
  late String _jarId;
  DateTime? _date;
  final _note = TextEditingController();
  bool _showNote = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final jars = ref.read(budgetProvider).jars;
    final food = jars.where((j) => j.type == JarType.food).firstOrNull;
    _jarId =
        widget.initialJarId ??
        food?.id ??
        jars.firstWhere((j) => !j.isSavings, orElse: () => jars.first).id;
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final s = ref.read(budgetProvider);
    final range = s.range;
    if (range == null) return;
    final today = dateOnly(s.now);
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? today,
      firstDate: range.start,
      lastDate: today.isBefore(range.start) ? range.start : today,
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<bool> _confirmBreak(int amount) {
    final l = context.l10n;
    return confirmDialog(
      context,
      emoji: '⚠️',
      title: l.breakTitle,
      body: l.breakBody(formatRupees(amount)),
      confirmLabel: l.breakConfirm,
      cancelLabel: l.breakCancel,
      destructive: true,
    );
  }

  Future<void> _save() async {
    if (_amount <= 0 || _saving) return;
    final controller = ref.read(budgetProvider.notifier);
    var plan = controller.planExpense(_jarId, _amount);

    if (plan.targetIsSavings) {
      if (!await _confirmBreak(_amount)) return;
    } else if (plan.needsBorrowing) {
      if (!mounted) return;
      final choice = await _askOverflow(plan);
      if (choice == null) return;
      if (choice.kind == 0) {
        plan = controller.planExpense(
          _jarId,
          _amount,
          preferredSourceId: choice.jarId,
        );
      } else if (choice.kind == 1) {
        final savings = ref.read(budgetProvider).jarOfType(JarType.savings);
        plan = controller.planExpense(
          _jarId,
          _amount,
          preferredSourceId: savings?.id,
          allowSavings: true,
        );
        if (!await _confirmBreak(plan.fromSavings)) return;
      }
    }

    setState(() => _saving = true);
    await controller.addExpense(plan, note: _note.text, date: _date);
    HapticFeedback.lightImpact();
    // Low-glass alerts become local notifications (once per glass per month).
    await ref.read(notificationSyncProvider).dispatchAlerts();
    if (!mounted) return;
    final s = ref.read(budgetProvider);
    final jar = s.jarById(_jarId);
    final name = jar == null
        ? ''
        : jarName(
            context.l10n,
            jar.type,
            jar.name,
            family: s.profile?.livesWithFamily ?? false,
          );
    final message = context.l10n.expenseSaved(formatRupees(_amount), name);
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<_OverflowChoice?> _askOverflow(OverflowPlan plan) {
    final l = context.l10n;
    final s = ref.read(budgetProvider);
    final family = s.profile?.livesWithFamily ?? false;
    final target = s.jarById(plan.targetJarId)!;
    final lenders = OverflowPlanner.lenders(s.jars, plan.targetJarId);
    final savings = s.jarOfType(JarType.savings);
    String name(Jar j) => jarName(l, j.type, j.name, family: family);

    return showDialog<_OverflowChoice>(
      context: context,
      builder: (context) {
        String? selected = lenders.isEmpty ? null : lenders.first.id;
        return StatefulBuilder(
          builder: (context, setLocal) => AlertDialog(
            title: Text(l.overflowTitle(name(target))),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.overflowBody(
                      formatRupees(plan.amount),
                      name(target),
                      formatRupees(plan.fromTarget),
                      formatRupees(plan.shortfall),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (lenders.isEmpty)
                    Text(
                      l.overflowNothing,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  RadioGroup<String>(
                    groupValue: selected,
                    onChanged: (v) => setLocal(() => selected = v),
                    child: Column(
                      children: [
                        for (final j in lenders)
                          RadioListTile<String>(
                            value: j.id,
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              '${j.emoji} ${l.overflowOption(name(j), formatRupees(j.remaining))}',
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Divider(),
                  TextButton(
                    onPressed: () => Navigator.pop(
                      context,
                      const _OverflowChoice.overspend(),
                    ),
                    child: Text(l.overflowOverspend),
                  ),
                  if (savings != null && savings.remaining > 0)
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: context.pp.danger,
                      ),
                      onPressed: () => Navigator.pop(
                        context,
                        const _OverflowChoice.savings(),
                      ),
                      icon: const Icon(Icons.warning_amber_rounded),
                      label: Text(l.overflowBreakSavings),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.onSurface,
                ),
                child: Text(l.commonCancel),
              ),
              if (lenders.isNotEmpty)
                FilledButton(
                  onPressed: selected == null
                      ? null
                      : () => Navigator.pop(
                          context,
                          _OverflowChoice.borrow(selected),
                        ),
                  child: Text(l.overflowBorrow),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = Theme.of(context).textTheme;
    final s = ref.watch(budgetProvider);
    final family = s.profile?.livesWithFamily ?? false;
    final locale = Localizations.localeOf(context).toString();
    final dateLabel = _date == null || isSameDay(_date!, s.now)
        ? l.commonToday
        : DateFormat.MMMd(locale).format(_date!);

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: safeBottom(context) + 12,
      ),
      // Only the content scrolls; Save stays pinned and always visible.
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l.addExpenseTitle,
                    style: t.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Center(child: AmountDisplay(amount: _amount)),
                  const SizedBox(height: 8),
                  Text(l.addPickJar, style: t.labelMedium),
                  const SizedBox(height: 4),
                  SizedBox(
                    height: 112,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        for (final j in s.jars)
                          Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: JarTile(
                              key: Key('pick_${j.type.name}_${j.id}'),
                              jar: j,
                              family: family,
                              width: 44,
                              compact: true,
                              selected: j.id == _jarId,
                              onTap: () => setState(() => _jarId = j.id),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      ActionChip(
                        avatar: const Icon(Icons.event, size: 18),
                        label: Text(dateLabel),
                        onPressed: _pickDate,
                      ),
                      if (!_showNote)
                        ActionChip(
                          avatar: const Icon(Icons.edit_note, size: 18),
                          label: Text(l.addNoteHint),
                          onPressed: () => setState(() => _showNote = true),
                        ),
                    ],
                  ),
                  if (_showNote)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: TextField(
                        controller: _note,
                        autofocus: true,
                        maxLength: 60,
                        decoration: InputDecoration(
                          hintText: l.addNoteHint,
                          counterText: '',
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  AmountKeypad(
                    amount: _amount,
                    onChanged: (v) => setState(() => _amount = v),
                    compact: MediaQuery.sizeOf(context).height < 760,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          FilledButton(
            key: const Key('save_expense'),
            onPressed: _amount > 0 && !_saving ? _save : null,
            child: Text(_amount > 0 ? l.addSave : l.addEnterAmount),
          ),
        ],
      ),
    );
  }
}
