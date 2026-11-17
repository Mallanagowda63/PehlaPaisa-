import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/l10n.dart';
import '../../../app/theme.dart';
import '../../../core/money.dart';
import '../../../core/widgets/dialogs.dart';
import '../../../core/widgets/emoji_picker.dart';
import '../../../app/state/budget_controller.dart';
import '../../jars/data/jar.dart';
import '../../jars/presentation/jar_labels.dart';
import '../../salary/domain/split_calculator.dart';
import '../../salary/presentation/widgets/split_sliders.dart';
import '../../../core/widgets/insets.dart';

/// Edit the monthly plan for every glass, and add/remove custom glasses.
class SplitEditorScreen extends ConsumerStatefulWidget {
  const SplitEditorScreen({super.key});

  @override
  ConsumerState<SplitEditorScreen> createState() => _SplitEditorScreenState();
}

class _SplitEditorScreenState extends ConsumerState<SplitEditorScreen> {
  Map<String, int> _amounts = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// Loads the saved plan; if income changed since, rescales it to income.
  void _load() {
    final s = ref.read(budgetProvider);
    final income = s.profile?.monthlyIncome ?? 0;
    _amounts = s.plannedTotal == income
        ? {for (final j in s.jars) j.id: j.plannedAmount}
        : SplitCalculator.splitAcrossJars(income, s.jars);
  }

  void _useSuggested() {
    final s = ref.read(budgetProvider);
    final suggested = SplitCalculator.suggest(
      s.profile?.monthlyIncome ?? 0,
      livesWithFamily: s.profile?.livesWithFamily ?? false,
    );
    setState(() {
      _amounts = {for (final j in s.jars) j.id: suggested[j.type] ?? 0};
    });
  }

  Future<void> _save({bool quiet = false}) async {
    await ref.read(budgetProvider.notifier).updatePlan(_amounts);
    if (!mounted || quiet) return;
    showSnack(context, context.l10n.splitSaved);
    Navigator.pop(context);
  }

  Future<void> _addCustom() async {
    final l = context.l10n;
    final name = TextEditingController();
    var emoji = EmojiPicker.jarEmojis.first;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          title: Text(l.customJarAdd),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: name,
                  autofocus: true,
                  maxLength: 20,
                  decoration: InputDecoration(
                    labelText: l.customJarName,
                    hintText: l.customJarNameHint,
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 12),
                EmojiPicker(
                  options: EmojiPicker.jarEmojis,
                  selected: emoji,
                  onSelected: (e) => setLocal(() => emoji = e),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l.commonCancel),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.pop(context, name.text.trim().isNotEmpty),
              child: Text(l.commonSave),
            ),
          ],
        ),
      ),
    );
    final text = name.text;
    disposeAfterDialog(name);
    if (ok != true) return;
    await _save(quiet: true);
    await ref
        .read(budgetProvider.notifier)
        .addCustomJar(name: text, emoji: emoji);
    if (mounted) setState(_load);
  }

  Future<void> _removeCustom(Jar jar) async {
    final l = context.l10n;
    final ok = await confirmDialog(
      context,
      title: l.customJarRemove,
      body: l.customJarRemoveBody,
      confirmLabel: l.commonDelete,
      destructive: true,
    );
    if (!ok) return;
    await _save(quiet: true);
    await ref.read(budgetProvider.notifier).removeCustomJar(jar.id);
    if (mounted) setState(_load);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = Theme.of(context).textTheme;
    final s = ref.watch(budgetProvider);
    final income = s.profile?.monthlyIncome ?? 0;
    final family = s.profile?.livesWithFamily ?? false;
    final jars = s.jars;
    if (jars.isEmpty) return Scaffold(appBar: AppBar());
    final balancer = SplitCalculator.balancerJar(jars);
    final savings = jars.firstWhere(
      (j) => j.isSavings,
      orElse: () => jars.first,
    );
    final rows = [
      for (final j in jars)
        SplitRow(
          key: j.id,
          type: j.type,
          label: jarName(l, j.type, j.name, family: family),
          emoji: j.emoji,
          colorHex: j.colorHex,
        ),
    ];
    final customs = jars.where((j) => j.type == JarType.custom).toList();

    return Scaffold(
      appBar: AppBar(title: Text(l.splitEditorTitle)),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 0, 16, safeBottom(context) + 32),
        children: [
          Text(l.splitEditorIncome(formatRupees(income)), style: t.titleSmall),
          const SizedBox(height: 4),
          Text(l.splitEditorHint, style: t.bodySmall),
          const SizedBox(height: 12),
          SplitBar(rows: rows, amounts: _amounts),
          const SizedBox(height: 12),
          SplitSliders(
            income: income,
            rows: rows,
            amounts: _amounts,
            balancerKey: balancer.id,
            savingsKey: savings.id,
            onChanged: (m) => setState(() => _amounts = m),
          ),
          const SizedBox(height: 12),
          for (final c in customs)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Text(c.emoji, style: const TextStyle(fontSize: 24)),
              title: Text(c.name),
              trailing: IconButton(
                tooltip: l.customJarRemove,
                icon: Icon(Icons.delete_outline, color: context.pp.danger),
                onPressed: () => _removeCustom(c),
              ),
            ),
          OutlinedButton.icon(
            onPressed: _addCustom,
            icon: const Icon(Icons.add),
            label: Text(l.customJarAdd),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _useSuggested,
            child: Text(l.splitUseSuggested),
          ),
          const SizedBox(height: 8),
          FilledButton(
            key: const Key('split_save'),
            onPressed: _save,
            child: Text(l.commonSave),
          ),
        ],
      ),
    );
  }
}
