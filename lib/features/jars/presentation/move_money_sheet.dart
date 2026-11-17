import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/l10n.dart';
import '../../../app/state/budget_controller.dart';
import '../../../core/money.dart';
import '../../../core/widgets/dialogs.dart';
import '../data/jar.dart';
import 'jar_labels.dart';
import '../../../core/widgets/insets.dart';

/// Moves unspent money between two glasses this month ("edit allocation").
Future<void> showMoveMoneySheet(
  BuildContext context, {
  String? fromId,
  String? toId,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useRootNavigator: true,
  useSafeArea: true,
  builder: (_) => _MoveMoneySheet(fromId: fromId, toId: toId),
);

class _MoveMoneySheet extends ConsumerStatefulWidget {
  const _MoveMoneySheet({this.fromId, this.toId});

  final String? fromId;
  final String? toId;

  @override
  ConsumerState<_MoveMoneySheet> createState() => _MoveMoneySheetState();
}

class _MoveMoneySheetState extends ConsumerState<_MoveMoneySheet> {
  late String _from;
  late String _to;
  final _amount = TextEditingController();

  @override
  void initState() {
    super.initState();
    final jars = ref.read(budgetProvider).jars;
    final fun = jars.firstWhere((j) => j.isFun, orElse: () => jars.last);
    _to = widget.toId ?? jars.firstWhere((j) => !j.isSavings).id;
    _from =
        widget.fromId ??
        (fun.id != _to
            ? fun.id
            : jars.firstWhere((j) => !j.isSavings && j.id != _to).id);
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _move() async {
    final l = context.l10n;
    final s = ref.read(budgetProvider);
    final from = s.jarById(_from)!;
    final amount = int.tryParse(_amount.text) ?? 0;
    if (amount <= 0 || _from == _to) return;
    if (from.isSavings) {
      final ok = await confirmDialog(
        context,
        emoji: '⚠️',
        title: l.breakTitle,
        body: l.breakBody(formatRupees(amount)),
        confirmLabel: l.breakConfirm,
        cancelLabel: l.breakCancel,
        destructive: true,
      );
      if (!ok) return;
    }
    await ref.read(budgetProvider.notifier).moveBetweenJars(_from, _to, amount);
    HapticFeedback.lightImpact();
    if (!mounted) return;
    final to = ref.read(budgetProvider).jarById(_to)!;
    final name = jarName(
      l,
      to.type,
      to.name,
      family: s.profile?.livesWithFamily ?? false,
    );
    final messenger = ScaffoldMessenger.of(context);
    final moved = amount.clamp(0, from.remaining);
    Navigator.pop(context);
    messenger.showSnackBar(
      SnackBar(content: Text(l.moveDone(formatRupees(moved), name))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = Theme.of(context).textTheme;
    final s = ref.watch(budgetProvider);
    final family = s.profile?.livesWithFamily ?? false;
    final from = s.jarById(_from);
    final available = from == null || from.remaining < 0 ? 0 : from.remaining;
    final amount = int.tryParse(_amount.text) ?? 0;

    DropdownMenuItem<String> item(Jar j) => DropdownMenuItem(
      value: j.id,
      child: Text(
        '${j.emoji} ${jarName(l, j.type, j.name, family: family)}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, safeBottom(context) + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.moveTitle, style: t.titleLarge),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            isExpanded: true,
            initialValue: _from,
            decoration: InputDecoration(labelText: l.moveFrom),
            items: [for (final j in s.jars) item(j)],
            onChanged: (v) => setState(() => _from = v ?? _from),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              l.moveAvailable(formatRupees(available)),
              style: t.bodySmall,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            isExpanded: true,
            initialValue: _to,
            decoration: InputDecoration(labelText: l.moveTo),
            items: [for (final j in s.jars) item(j)],
            onChanged: (v) => setState(() => _to = v ?? _to),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amount,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(7),
            ],
            decoration: const InputDecoration(prefixText: '₹ '),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          FilledButton(
            key: const Key('move_button'),
            onPressed: amount > 0 && available > 0 && _from != _to
                ? _move
                : null,
            child: Text(l.moveButton),
          ),
        ],
      ),
    );
  }
}
