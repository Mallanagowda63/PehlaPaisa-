import 'dart:math' as math;

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/l10n.dart';
import '../../../app/router.dart';
import '../../../app/state/budget_controller.dart';
import '../../../app/theme.dart';
import '../../../core/constants.dart';
import '../../../core/money.dart';
import '../../../core/widgets/amount_keypad.dart';
import '../../../core/widgets/dialogs.dart';
import '../../../core/widgets/shelf_background.dart';
import '../../badges/presentation/celebration_queue.dart';
import '../../jars/data/jar.dart';
import '../../jars/presentation/widgets/jar_tile.dart';

import 'package:intl/intl.dart';

enum _Phase { ready, pouringSavings, pouringOthers, done }

/// The salary-day ritual: tap "Fill Savings First", watch money pour into the
/// Savings glass, then into Rent → Food → Travel → Fun, then celebrate.
///
/// Irregular earners use the same screen for every "income received" entry.
class SalaryDayScreen extends ConsumerStatefulWidget {
  const SalaryDayScreen({super.key});

  @override
  ConsumerState<SalaryDayScreen> createState() => _SalaryDayScreenState();
}

class _SalaryDayScreenState extends ConsumerState<SalaryDayScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pour = AnimationController(vsync: this);
  final ConfettiController _confetti = ConfettiController(
    duration: const Duration(milliseconds: 1600),
  );

  late final CelebrationQueue _queue;
  _Phase _phase = _Phase.ready;
  late int _amount;
  late final bool _irregular;

  /// Jar levels before the pour (remaining money), keyed by id.
  Map<String, int> _before = {};
  Map<String, int> _split = {};
  List<Jar> _after = [];
  String? _activeJarId;
  final Set<String> _filled = {};

  @override
  void initState() {
    super.initState();
    final s = ref.read(budgetProvider);
    _irregular = s.profile?.isIrregular ?? false;
    _amount = _irregular ? 0 : (s.profile?.monthlyIncome ?? 0);
    if (!_irregular && !s.needsFunding) _phase = _Phase.done;
    _pour.addListener(() => setState(() {}));
    // Hold badge/streak pop-ups until the ritual is over.
    _queue = ref.read(celebrationQueueProvider.notifier);
    Future.microtask(_queue.pause);
  }

  bool get _reduceMotion =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  void _burst() {
    if (!_reduceMotion) _confetti.play();
  }

  @override
  void dispose() {
    _pour.dispose();
    _confetti.dispose();
    // Badge/streak celebrations show once the user leaves the ritual.
    final queue = _queue;
    Future.microtask(queue.resume);
    super.dispose();
  }

  Future<void> _start() async {
    if (_amount <= 0) return;
    final controller = ref.read(budgetProvider.notifier);
    final beforeJars = ref.read(budgetProvider).jars;
    _before = {for (final j in beforeJars) j.id: j.remaining};

    final res = await controller.fund(_amount);
    if (!mounted) return;
    _split = res.split;
    _after = res.jars;

    // 1) Savings first.
    final savings = _after.firstWhere((j) => j.isSavings);
    setState(() {
      _phase = _Phase.pouringSavings;
      _activeJarId = savings.id;
    });
    HapticFeedback.mediumImpact();
    _pour.duration = PPMotion.pour;
    await _pour.forward(from: 0).orCancel.catchError((_) {});
    if (!mounted) return;
    _filled.add(savings.id);
    HapticFeedback.heavyImpact();
    _burst();

    // 2) Then the rest, in shelf order (Rent → Food → Travel → Fun).
    setState(() => _phase = _Phase.pouringOthers);
    for (final j in _after.where((j) => !j.isSavings)) {
      if (!mounted) return;
      setState(() => _activeJarId = j.id);
      _pour.duration = PPMotion.pourSmall;
      await _pour.forward(from: 0).orCancel.catchError((_) {});
      _filled.add(j.id);
      HapticFeedback.selectionClick();
    }
    if (!mounted) return;
    setState(() {
      _activeJarId = null;
      _phase = _Phase.done;
    });
    HapticFeedback.heavyImpact();
    _burst();
  }

  /// Visual level of [jar] during the ritual.
  double _levelFor(Jar jar) {
    if (_after.isEmpty) return jar.fillRatio;
    final after = _after.firstWhere((j) => j.id == jar.id, orElse: () => jar);
    if (after.allocatedAmount <= 0) return 0;
    final start = (_before[jar.id] ?? 0).clamp(0, after.allocatedAmount);
    final add = _split[jar.id] ?? 0;
    double progress;
    if (_filled.contains(jar.id)) {
      progress = 1;
    } else if (_activeJarId == jar.id) {
      progress = Curves.easeOutCubic.transform(_pour.value);
    } else {
      progress = 0;
    }
    return ((start + add * progress) / after.allocatedAmount).clamp(0.0, 1.0);
  }

  Future<void> _editAmount() async {
    final l = context.l10n;
    final ctrl = TextEditingController(text: _amount.toString());
    final v = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.salaryChangeAmount),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(7),
          ],
          decoration: const InputDecoration(prefixText: '₹ '),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, int.tryParse(ctrl.text)),
            child: Text(l.commonSave),
          ),
        ],
      ),
    );
    disposeAfterDialog(ctrl);
    if (v != null && v > 0) setState(() => _amount = v);
  }

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(Routes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = Theme.of(context).textTheme;
    final pp = context.pp;
    final state = ref.watch(budgetProvider);
    final family = state.profile?.livesWithFamily ?? false;
    final jars = _after.isNotEmpty ? _after : state.jars;
    final savings = jars.where((j) => j.isSavings).firstOrNull;
    final others = jars.where((j) => !j.isSavings).toList();
    final busy =
        _phase == _Phase.pouringSavings || _phase == _Phase.pouringOthers;
    final width = MediaQuery.sizeOf(context).width;
    // Each compact tile is its glass width + 28; the list has 20px padding.
    final smallW = math.min(
      64.0,
      (width - 40) / math.max(others.length, 1) - 34,
    );
    final showKeypad = _irregular && _phase == _Phase.ready;

    String status() {
      switch (_phase) {
        case _Phase.ready:
          return _irregular ? l.salaryIncomeHint : l.salaryIntro;
        case _Phase.pouringSavings:
          return l.salaryPouring;
        case _Phase.pouringOthers:
          return l.salaryFillingOthers;
        case _Phase.done:
          final saved = savings?.allocatedAmount ?? 0;
          return l.salaryDoneBody(formatRupees(saved));
      }
    }

    return PopScope(
      canPop: !busy,
      child: Scaffold(
        body: ShelfBackground(
          child: Stack(
            children: [
              SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _phase == _Phase.done
                                      ? l.salaryDone
                                      : _irregular
                                      ? l.salaryIncomeTitle
                                      : l.salaryTitle,
                                  style: t.headlineMedium,
                                ),
                              ),
                              if (!busy)
                                IconButton(
                                  tooltip: l.commonClose,
                                  onPressed: _close,
                                  icon: const Icon(Icons.close),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          if (state.range != null && !_irregular)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(
                                l.salaryForDate(
                                  DateFormat.yMMMd(
                                    Localizations.localeOf(context).toString(),
                                  ).format(state.range!.start),
                                ),
                                style: t.titleSmall?.copyWith(
                                  color: pp.savings,
                                ),
                              ),
                            ),
                          Text(status(), style: t.bodyLarge),
                          const SizedBox(height: 16),
                          if (_irregular && state.activeCycle != null)
                            Text(
                              l.salaryReceivedSoFar(
                                formatRupees(state.activeCycle!.income),
                              ),
                              style: t.bodySmall,
                            ),
                          if (!_irregular && _phase == _Phase.ready) ...[
                            Text(l.salaryAmountLabel, style: t.labelMedium),
                            AmountDisplay(amount: _amount, color: pp.savings),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton(
                                onPressed: _editAmount,
                                child: Text(l.salaryChangeAmount),
                              ),
                            ),
                          ],
                          if (showKeypad) ...[
                            const SizedBox(height: 8),
                            Center(child: AmountDisplay(amount: _amount)),
                          ],
                          const SizedBox(height: 12),
                          if (savings != null)
                            Center(
                              child: JarTile(
                                jar: savings,
                                family: family,
                                width: showKeypad ? 90 : 130,
                                levelOverride: _levelFor(savings),
                                pour: _activeJarId == savings.id
                                    ? _pour.value
                                    : 0,
                              ),
                            ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              for (final j in others)
                                JarTile(
                                  jar: j,
                                  family: family,
                                  width: smallW,
                                  compact: true,
                                  levelOverride: _levelFor(j),
                                  pour: _activeJarId == j.id ? _pour.value : 0,
                                ),
                            ],
                          ),
                          const ShelfPlank(),
                          const SizedBox(height: 20),
                          if (showKeypad)
                            AmountKeypad(
                              amount: _amount,
                              onChanged: (v) => setState(() => _amount = v),
                            ),
                        ],
                      ),
                    ),
                    // The main action is always visible, even on small phones.
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: _phase == _Phase.done
                            ? FilledButton(
                                key: const Key('salary_go_shelf'),
                                onPressed: _close,
                                child: Text(l.salaryGoShelf),
                              )
                            : FilledButton.icon(
                                key: const Key('fill_savings_first'),
                                onPressed: _amount > 0 && !busy ? _start : null,
                                icon: const Text(
                                  '🪙',
                                  style: TextStyle(fontSize: 20),
                                ),
                                label: Text(
                                  busy
                                      ? (_phase == _Phase.pouringSavings
                                            ? l.salaryPouring
                                            : l.salaryFillingOthers)
                                      : l.salaryFillSavings,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confetti,
                  blastDirectionality: BlastDirectionality.explosive,
                  numberOfParticles: 24,
                  gravity: 0.25,
                  colors: [pp.savings, pp.jar, pp.fun, pp.success],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
