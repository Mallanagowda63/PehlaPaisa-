import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/l10n.dart';
import '../../../app/state/budget_controller.dart';
import '../../../app/theme.dart';
import '../../../core/money.dart';
import '../../ads/ads.dart';
import '../../../core/widgets/shelf_background.dart';
import '../../jars/data/jar.dart';
import '../../jars/presentation/jar_labels.dart';
import '../../salary/data/month_cycle.dart';
import '../domain/report_calculator.dart';

/// Monthly report: savings %, where money went, 6-month savings, best and
/// worst glass, and a comparison with last month.
class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key});

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  String? _selectedId;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = Theme.of(context).textTheme;
    final s = ref.watch(budgetProvider);
    final locale = Localizations.localeOf(context).toString();
    final all = s.cycleData.where((c) => c.cycle.funded).toList();

    if (all.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(l.reportTitle)),
        body: ShelfBackground(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                s.needsFunding ? l.reportNotFunded : l.reportNoData,
                textAlign: TextAlign.center,
                style: t.bodyLarge,
              ),
            ),
          ),
        ),
      );
    }

    final idx = _selectedId == null
        ? all.length - 1
        : math.max(0, all.indexWhere((c) => c.cycle.id == _selectedId));
    final current = all[idx];
    final previous = idx > 0 ? all[idx - 1] : null;
    final report = ReportCalculator.build(current, previous);
    final family = s.profile?.livesWithFamily ?? false;
    final tip = [
      l.reportTip1,
      l.reportTip2,
      l.reportTip3,
      l.reportTip4,
    ][current.cycle.month % 4];

    return Scaffold(
      appBar: AppBar(title: Text(l.reportTitle)),
      body: ShelfBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          children: [
            SizedBox(
              height: 52,
              child: ListView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                children: [
                  for (final c in all.reversed)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: ChoiceChip(
                        label: Text(_monthLabel(c.cycle, locale)),
                        selected: c.cycle.id == current.cycle.id,
                        onSelected: (_) =>
                            setState(() => _selectedId = c.cycle.id),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _SavedCard(report: report),
            const SizedBox(height: 12),
            _Section(
              title: l.reportWhereMoneyWent,
              child: _SpendingPie(report: report, family: family),
            ),
            const SizedBox(height: 12),
            _Section(
              title: l.reportLast6,
              child: _SavingsBars(
                months: ReportCalculator.lastMonths(all.sublist(0, idx + 1)),
                locale: locale,
              ),
            ),
            const SizedBox(height: 12),
            if (report.best != null && report.worst != null)
              Row(
                children: [
                  Expanded(
                    child: _JarVerdict(
                      title: l.reportBestJar,
                      jar: report.best!,
                      family: family,
                      good: true,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _JarVerdict(
                      title: l.reportWorstJar,
                      jar: report.worst!,
                      family: family,
                      good: false,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 12),
            _Section(
              title: l.reportVsLastMonth,
              child: _Comparison(report: report),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('💡 ${l.reportTipTitle}', style: t.titleSmall),
                    const SizedBox(height: 6),
                    Text(tip),
                    const SizedBox(height: 8),
                    Text(l.reportDisclaimer, style: t.bodySmall),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            const AdSpot(AdSlot.reportNative),
          ],
        ),
      ),
    );
  }

  static String _monthLabel(MonthCycle c, String locale) =>
      DateFormat.yMMM(locale).format(DateTime(c.year, c.month));
}

/// Distinct chart colours per glass type (the shelf uses one blue for all
/// everyday glasses; charts need to tell them apart).
Color chartColor(BuildContext context, JarSnapshot j) {
  final pp = context.pp;
  switch (j.type) {
    case JarType.savings:
      return pp.savings;
    case JarType.rent:
      return pp.jar;
    case JarType.food:
      return const Color(0xFF5FC9B8);
    case JarType.travel:
      return const Color(0xFFB08FE5);
    case JarType.fun:
      return pp.fun;
    case JarType.custom:
      return const Color(0xFFF2A65A);
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _SavedCard extends StatelessWidget {
  const _SavedCard({required this.report});

  final MonthlyReport report;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = Theme.of(context).textTheme;
    final pp = context.pp;
    return Card(
      color: pp.savings.withValues(alpha: 0.15),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.reportSavedPercent(report.savedPercent),
              style: t.headlineSmall,
            ),
            const SizedBox(height: 6),
            Text(
              l.reportSavedAmount(formatRupees(report.saved)),
              style: t.bodyLarge?.copyWith(color: pp.savings),
            ),
            Text(
              l.reportTotalSpent(formatRupees(report.totalSpent)),
              style: t.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _SpendingPie extends StatelessWidget {
  const _SpendingPie({required this.report, required this.family});

  final MonthlyReport report;
  final bool family;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = Theme.of(context).textTheme;
    if (report.spending.isEmpty) {
      return Text(l.reportNoSpending, style: t.bodyMedium);
    }
    final total = report.totalSpent;
    final semantics = report.spending
        .map(
          (j) =>
              '${jarName(l, j.type, j.name, family: family)} ${formatRupees(j.spent)}',
        )
        .join(', ');
    return Column(
      children: [
        Semantics(
          label: semantics,
          excludeSemantics: true,
          child: SizedBox(
            height: 190,
            child: PieChart(
              PieChartData(
                centerSpaceRadius: 46,
                sectionsSpace: 2,
                sections: [
                  for (final j in report.spending)
                    PieChartSectionData(
                      value: j.spent.toDouble(),
                      color: chartColor(context, j),
                      radius: 46,
                      title: '${percentOf(j.spent, total)}%',
                      titleStyle: t.labelSmall?.copyWith(
                        color: Colors.black87,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        for (final j in report.spending)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: chartColor(context, j),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${j.emoji} ${jarName(l, j.type, j.name, family: family)}',
                  ),
                ),
                Text(formatRupees(j.spent), style: t.titleSmall),
              ],
            ),
          ),
      ],
    );
  }
}

class _SavingsBars extends StatelessWidget {
  const _SavingsBars({required this.months, required this.locale});

  final List<MonthSavings> months;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final pp = context.pp;
    final t = Theme.of(context).textTheme;
    final maxY = months.fold<int>(0, (a, m) => math.max(a, m.saved));
    final semantics = months
        .map(
          (m) =>
              '${DateFormat.MMM(locale).format(DateTime(m.year, m.month))} ${formatRupees(m.saved)}',
        )
        .join(', ');
    return Semantics(
      label: semantics,
      excludeSemantics: true,
      child: SizedBox(
        height: 180,
        child: BarChart(
          BarChartData(
            maxY: maxY <= 0 ? 100 : maxY * 1.2,
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) =>
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                getTooltipItem: (group, _, rod, _) =>
                    BarTooltipItem(formatRupees(rod.toY), t.labelMedium!),
              ),
            ),
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(),
              rightTitles: const AxisTitles(),
              topTitles: const AxisTitles(),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  getTitlesWidget: (value, meta) {
                    final i = value.toInt();
                    if (i < 0 || i >= months.length) return const SizedBox();
                    final m = months[i];
                    return SideTitleWidget(
                      meta: meta,
                      child: Text(
                        DateFormat.MMM(locale)
                            .format(DateTime(m.year, m.month)),
                        style: t.labelSmall,
                      ),
                    );
                  },
                ),
              ),
            ),
            barGroups: [
              for (var i = 0; i < months.length; i++)
                BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: months[i].saved.toDouble(),
                      width: 22,
                      color: i == months.length - 1
                          ? pp.savings
                          : pp.savings.withValues(alpha: 0.55),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(6),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _JarVerdict extends StatelessWidget {
  const _JarVerdict({
    required this.title,
    required this.jar,
    required this.family,
    required this.good,
  });

  final String title;
  final JarSnapshot jar;
  final bool family;
  final bool good;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = Theme.of(context).textTheme;
    final pp = context.pp;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: t.labelMedium?.copyWith(
                color: good ? pp.success : pp.warning,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${jar.emoji} ${jarName(l, jar.type, jar.name, family: family)}',
              style: t.titleSmall,
            ),
            Text(
              l.reportUsed(percentOf(jar.spent, jar.allocated)),
              style: t.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _Comparison extends StatelessWidget {
  const _Comparison({required this.report});

  final MonthlyReport report;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final pp = context.pp;
    if (report.previousSpent == null) return Text(l.reportNoPrevious);
    final change = report.spentChangePercent;
    final savedDiff = report.savedChange ?? 0;
    final spendText = change == null || change.abs() < 2
        ? l.reportSpentSame
        : change > 0
        ? l.reportSpentMore(change)
        : l.reportSpentLess(-change);
    final saveText = savedDiff == 0
        ? l.reportSavedSame
        : savedDiff > 0
        ? l.reportSavedMore(formatRupees(savedDiff))
        : l.reportSavedLess(formatRupees(-savedDiff));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              (change ?? 0) > 0 ? Icons.trending_up : Icons.trending_down,
              color: (change ?? 0) > 0 ? pp.warning : pp.success,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(spendText)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.savings_outlined,
              color: savedDiff >= 0 ? pp.success : pp.warning,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(saveText)),
          ],
        ),
      ],
    );
  }
}
