import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/l10n.dart';
import '../../../app/router.dart';
import '../../../app/state/budget_controller.dart';
import '../../../app/state/repositories.dart';
import '../../../app/theme.dart';
import '../../../core/money.dart';
import '../../../core/widgets/shelf_background.dart';
import '../../badges/presentation/celebration_queue.dart';
import '../../jars/data/jar.dart';
import '../../jars/presentation/jar_labels.dart';
import '../../salary/domain/split_calculator.dart';
import '../../salary/presentation/widgets/split_sliders.dart';
import '../../settings/presentation/settings_controller.dart';
import '../../alerts/data/notification_gateway.dart';
import '../data/user_profile.dart';
import 'widgets/intro_hero.dart';

import 'package:intl/intl.dart';

import '../../salary/domain/cycle_range.dart';

/// Intro + 4 steps: name → income/salary day/type → family → split.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const int _steps = 4;
  static const int minIncome = 500;
  static const int maxIncome = 1000000;

  int _page = 0; // 0 = intro, 1..4 = steps
  final _name = TextEditingController();
  final _income = TextEditingController();
  int _salaryDay = 1;
  IncomeType _incomeType = IncomeType.fixed;
  bool? _family;
  Map<String, int> _split = {};
  bool _saving = false;
  String? _error;

  int get _incomeValue => int.tryParse(_income.text.replaceAll(',', '')) ?? 0;

  @override
  void dispose() {
    _name.dispose();
    _income.dispose();
    super.dispose();
  }

  void _buildSplit() {
    final s = SplitCalculator.suggest(
      _incomeValue,
      livesWithFamily: _family ?? false,
    );
    _split = {for (final e in s.entries) e.key.name: e.value};
  }

  void _next() {
    final l = context.l10n;
    setState(() => _error = null);
    switch (_page) {
      case 1:
        if (_name.text.trim().isEmpty) {
          setState(() => _error = l.onbNameError);
          return;
        }
      case 2:
        final v = _incomeValue;
        if (v < minIncome || v > maxIncome) {
          setState(() => _error = l.onbIncomeError);
          return;
        }
      case 3:
        if (_family == null) return;
        _buildSplit();
    }
    FocusScope.of(context).unfocus();
    setState(() => _page++);
  }

  void _back() {
    if (_page == 0) return;
    setState(() {
      _error = null;
      _page--;
    });
  }

  Future<void> _finish() async {
    setState(() => _saving = true);
    HapticFeedback.mediumImpact();
    // Pehla Kadam pops up after the salary-day ritual, not on top of it.
    ref.read(celebrationQueueProvider.notifier).pause();
    await ref
        .read(budgetProvider.notifier)
        .completeOnboarding(
          name: _name.text,
          monthlyIncome: _incomeValue,
          salaryDay: _salaryDay,
          incomeType: _incomeType,
          livesWithFamily: _family ?? false,
          plan: {for (final t in JarDefaults.fillOrder) t: _split[t.name] ?? 0},
          language: ref.read(settingsProvider).language,
        );
    // Ask once for permission to send salary-day and low-glass reminders.
    if (ref.read(settingsProvider).notificationsEnabled) {
      final gateway = ref.read(notificationGatewayProvider);
      if (await gateway.requestPermission()) {
        final l = l10nFor(ref.read(settingsProvider).language);
        await gateway.showNow(
          id: NotificationIds.welcome,
          title: l.notifWelcomeTitle,
          body: l.notifWelcomeBody,
          channelName: l.notifChannel,
        );
      }
    }
    if (!mounted) return;
    context.go(Routes.home);
    context.push(Routes.salary);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = Theme.of(context).textTheme;
    return PopScope(
      canPop: _page == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        body: ShelfBackground(
          child: SafeArea(
            child: Column(
              children: [
                if (_page > 0)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 4, 16, 0),
                    child: Row(
                      children: [
                        IconButton(
                          tooltip: l.commonBack,
                          onPressed: _back,
                          icon: const Icon(Icons.arrow_back),
                        ),
                        Expanded(
                          child: Text(
                            l.stepOf(_page, _steps),
                            style: t.labelMedium,
                          ),
                        ),
                        SizedBox(
                          width: 120,
                          child: LinearProgressIndicator(
                            value: _page / _steps,
                            borderRadius: BorderRadius.circular(4),
                            color: context.pp.savings,
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: KeyedSubtree(
                      key: ValueKey(_page),
                      child: _buildPage(context),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: _page == _steps
                        ? FilledButton(
                            key: const Key('onb_finish'),
                            onPressed: _saving ? null : _finish,
                            child: Text(l.onbFinish),
                          )
                        : FilledButton(
                            key: const Key('onb_next'),
                            onPressed: _page == 3 && _family == null
                                ? null
                                : _next,
                            child: Text(
                              _page == 0 ? l.onbStart : l.commonContinue,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPage(BuildContext context) {
    switch (_page) {
      case 0:
        return _intro(context);
      case 1:
        return _nameStep(context);
      case 2:
        return _incomeStep(context);
      case 3:
        return _familyStep(context);
      default:
        return _splitStep(context);
    }
  }

  Widget _scroll(List<Widget> children) => ListView(
    padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
    children: children,
  );

  Widget _intro(BuildContext context) {
    final l = context.l10n;
    final t = Theme.of(context).textTheme;
    final pp = context.pp;
    final lang = ref.watch(settingsProvider).language;
    return LayoutBuilder(
      builder: (context, c) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: c.maxHeight - 16),
          child: IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: pp.savings.withValues(alpha: 0.16),
                      ),
                      child: Text(
                        '₹',
                        style: t.titleMedium?.copyWith(color: pp.savings),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: SegmentedButton<String>(
                            style: const ButtonStyle(
                              visualDensity: VisualDensity.compact,
                            ),
                            segments: const [
                              ButtonSegment(
                                value: 'en',
                                label: Text('English'),
                              ),
                              ButtonSegment(value: 'hi', label: Text('हिंदी')),
                            ],
                            selected: {lang},
                            showSelectedIcon: false,
                            onSelectionChanged: (v) => ref
                                .read(settingsProvider.notifier)
                                .update((s) => s.copyWith(language: v.first)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                IntroHero(height: (c.maxHeight * 0.32).clamp(180.0, 280.0)),
                const SizedBox(height: 12),
                const Spacer(),
                Text(
                  l.appName,
                  style: t.displaySmall?.copyWith(letterSpacing: -0.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: pp.savings.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      l.tagline,
                      style: t.titleSmall?.copyWith(color: pp.savings),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  l.onbIntroSub,
                  style: t.bodyMedium?.copyWith(color: pp.muted),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                IntroFeature(
                  icon: Icons.savings_rounded,
                  color: pp.savings,
                  title: l.onbFeat1Title,
                  body: l.onbFeat1Body,
                ),
                const SizedBox(height: 8),
                IntroFeature(
                  icon: Icons.local_drink_rounded,
                  color: pp.jar,
                  title: l.onbFeat2Title,
                  body: l.onbFeat2Body,
                ),
                const SizedBox(height: 8),
                IntroFeature(
                  icon: Icons.local_fire_department_rounded,
                  color: pp.fun,
                  title: l.onbFeat3Title,
                  body: l.onbFeat3Body,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _nameStep(BuildContext context) {
    final l = context.l10n;
    final t = Theme.of(context).textTheme;
    return _scroll([
      const SizedBox(height: 24),
      Text('👋', style: t.displayMedium),
      const SizedBox(height: 12),
      Text(l.onbNameTitle, style: t.headlineMedium),
      const SizedBox(height: 24),
      TextField(
        key: const Key('onb_name'),
        controller: _name,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        maxLength: 30,
        decoration: InputDecoration(
          hintText: l.onbNameHint,
          errorText: _error,
          counterText: '',
        ),
        onSubmitted: (_) => _next(),
      ),
    ]);
  }

  Widget _incomeStep(BuildContext context) {
    final l = context.l10n;
    final t = Theme.of(context).textTheme;
    return _scroll([
      Text(l.onbIncomeTitle(_name.text.trim()), style: t.headlineMedium),
      const SizedBox(height: 20),
      Text(l.onbIncomeLabel, style: t.titleSmall),
      const SizedBox(height: 8),
      TextField(
        key: const Key('onb_income'),
        controller: _income,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(7),
        ],
        style: t.headlineSmall,
        decoration: InputDecoration(
          prefixText: '₹ ',
          hintText: l.onbIncomeHint,
          errorText: _error,
        ),
      ),
      const SizedBox(height: 20),
      Text(l.onbSalaryDayLabel, style: t.titleSmall),
      const SizedBox(height: 4),
      Text(l.onbSalaryDayHelp, style: t.bodySmall),
      const SizedBox(height: 8),
      DropdownButtonFormField<int>(
        isExpanded: true,
        key: const Key('onb_day'),
        initialValue: _salaryDay,
        menuMaxHeight: 320,
        items: [
          for (var d = 1; d <= 31; d++)
            DropdownMenuItem(
              value: d,
              child: Text(l.dayOfMonth(d), overflow: TextOverflow.ellipsis),
            ),
        ],
        onChanged: (v) => setState(() => _salaryDay = v ?? 1),
      ),
      const SizedBox(height: 6),
      Row(
        children: [
          Icon(Icons.event_available, size: 18, color: context.pp.savings),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              l.nextSalaryOn(
                DateFormat.yMMMd(Localizations.localeOf(context).toString())
                    .format(
                      CycleRange.nextSalaryDate(
                        ref.read(clockProvider)(),
                        _salaryDay,
                      ),
                    ),
              ),
              key: const Key('onb_next_salary'),
              style: t.labelMedium?.copyWith(color: context.pp.savings),
            ),
          ),
        ],
      ),
      const SizedBox(height: 20),
      Text(l.onbIncomeTypeLabel, style: t.titleSmall),
      const SizedBox(height: 8),
      _ChoiceCard(
        emoji: '🗓️',
        title: l.incomeFixed,
        subtitle: l.incomeFixedDesc,
        selected: _incomeType == IncomeType.fixed,
        onTap: () => setState(() => _incomeType = IncomeType.fixed),
      ),
      const SizedBox(height: 8),
      _ChoiceCard(
        emoji: '🛵',
        title: l.incomeIrregular,
        subtitle: l.incomeIrregularDesc,
        selected: _incomeType == IncomeType.irregular,
        onTap: () => setState(() => _incomeType = IncomeType.irregular),
      ),
    ]);
  }

  Widget _familyStep(BuildContext context) {
    final l = context.l10n;
    final t = Theme.of(context).textTheme;
    // On short screens drop the decoration so both answers stay in view.
    final short = MediaQuery.sizeOf(context).height < 700;
    return _scroll([
      if (!short) ...[
        const SizedBox(height: 16),
        Text('🏡', style: t.displayMedium),
        const SizedBox(height: 12),
      ],
      Text(l.onbFamilyTitle, style: short ? t.headlineSmall : t.headlineMedium),
      const SizedBox(height: 8),
      Text(l.onbFamilyBody, style: short ? t.bodyMedium : t.bodyLarge),
      SizedBox(height: short ? 16 : 24),
      _ChoiceCard(
        key: const Key('onb_family_yes'),
        emoji: '👨‍👩‍👧',
        title: l.onbFamilyYes,
        selected: _family == true,
        onTap: () => setState(() => _family = true),
      ),
      const SizedBox(height: 8),
      _ChoiceCard(
        key: const Key('onb_family_no'),
        emoji: '🧳',
        title: l.onbFamilyNo,
        selected: _family == false,
        onTap: () => setState(() => _family = false),
      ),
    ]);
  }

  Widget _splitStep(BuildContext context) {
    final l = context.l10n;
    final t = Theme.of(context).textTheme;
    final family = _family ?? false;
    final rows = [
      for (final type in JarDefaults.fillOrder)
        SplitRow(
          key: type.name,
          type: type,
          label: jarName(l, type, '', family: family),
          emoji: JarDefaults.emoji[type]!,
        ),
    ];
    return _scroll([
      Text(l.onbSplitTitle, style: t.headlineMedium),
      const SizedBox(height: 6),
      Text(l.onbSplitBody(formatRupees(_incomeValue)), style: t.bodyMedium),
      const SizedBox(height: 16),
      SplitBar(rows: rows, amounts: _split),
      const SizedBox(height: 16),
      SplitSliders(
        income: _incomeValue,
        rows: rows,
        amounts: _split,
        balancerKey: JarType.fun.name,
        savingsKey: JarType.savings.name,
        onChanged: (m) => setState(() => _split = m),
      ),
    ]);
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    super.key,
    required this.emoji,
    required this.title,
    this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String emoji;
  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final pp = context.pp;
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected
            ? pp.savings.withValues(alpha: 0.14)
            : Theme.of(context).colorScheme.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: selected ? pp.savings : Colors.transparent,
            width: 2,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: t.titleMedium),
                      if (subtitle != null) Text(subtitle!, style: t.bodySmall),
                    ],
                  ),
                ),
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: selected ? pp.savings : pp.muted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
