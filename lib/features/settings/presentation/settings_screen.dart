import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/l10n.dart';
import '../../../app/router.dart';
import '../../../app/state/budget_controller.dart';
import '../../../app/state/repositories.dart';
import '../../../app/theme.dart';
import '../../../core/money.dart';
import '../../../core/widgets/dialogs.dart';
import '../../alerts/data/notification_gateway.dart';
import '../../onboarding/data/user_profile.dart';
import '../data/app_settings.dart';
import 'settings_controller.dart';
import '../../../core/widgets/insets.dart';
import '../../salary/domain/cycle_range.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final t = Theme.of(context).textTheme;
    final pp = context.pp;
    final settings = ref.watch(settingsProvider);
    final s = ref.watch(budgetProvider);
    final p = s.profile;
    final sc = ref.read(settingsProvider.notifier);
    final locale = Localizations.localeOf(context).toString();

    Widget header(String text) => Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
      child: Text(text, style: t.titleSmall?.copyWith(color: pp.savings)),
    );

    Future<void> setLanguage(String lang) async {
      await sc.update((x) => x.copyWith(language: lang));
      if (p != null) {
        await ref
            .read(budgetProvider.notifier)
            .updateProfile(p.copyWith(language: lang));
      }
    }

    Future<void> toggleNotifications(bool v) async {
      if (v) {
        final granted = await ref
            .read(notificationGatewayProvider)
            .requestPermission();
        if (!granted && context.mounted) {
          showSnack(context, l.notifPermissionDenied);
        }
      }
      await sc.update((x) => x.copyWith(notificationsEnabled: v));
    }

    Future<void> pickTime() async {
      final picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(
          hour: settings.reminderHour,
          minute: settings.reminderMinute,
        ),
      );
      if (picked != null) {
        await sc.update(
          (x) => x.copyWith(
            reminderMinutes: picked.hour * 60 + picked.minute,
            dailyReminderEnabled: true,
          ),
        );
      }
    }

    final time = DateFormat.jm(locale).format(
      DateTime(2000, 1, 1, settings.reminderHour, settings.reminderMinute),
    );
    final notifOn = settings.notificationsEnabled;

    return Scaffold(
      appBar: AppBar(title: Text(l.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          // --- Profile -------------------------------------------------------
          header(l.settingsProfile),
          if (p != null)
            Card(
              child: Column(
                children: [
                  ListTile(
                    key: const Key('profile_tile'),
                    leading: const Icon(Icons.person_outline),
                    title: Text(p.name),
                    subtitle: Text(
                      [
                        '${l.settingsIncome}: '
                            '${formatRupees(p.monthlyIncome)}',
                        '${l.settingsSalaryDay}: '
                            '${l.dayOfMonth(p.salaryDay)}',
                        l.nextSalaryOn(
                          DateFormat.yMMMd(locale).format(
                            s.range?.nextStart ??
                                CycleRange.nextSalaryDate(s.now, p.salaryDay),
                          ),
                        ),
                      ].join('\n'),
                    ),
                    trailing: const Icon(Icons.edit_outlined),
                    onTap: () => _editProfile(context, ref, p),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.tune),
                    title: Text(l.settingsEditSplit),
                    subtitle: Text(l.settingsEditSplitDesc),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(Routes.split),
                  ),
                ],
              ),
            ),

          // --- Appearance ------------------------------------------------------
          header(l.settingsAppearance),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.settingsLanguage, style: t.labelLarge),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<String>(
                      key: const Key('lang_switch'),
                      segments: const [
                        ButtonSegment(value: 'en', label: Text('English')),
                        ButtonSegment(value: 'hi', label: Text('हिंदी')),
                      ],
                      selected: {settings.language},
                      showSelectedIcon: false,
                      onSelectionChanged: (v) => setLanguage(v.first),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(l.settingsTheme, style: t.labelLarge),
                  RadioGroup<AppThemeMode>(
                    groupValue: settings.themeMode,
                    onChanged: (v) =>
                        sc.update((x) => x.copyWith(themeMode: v)),
                    child: Column(
                      children: [
                        for (final m in AppThemeMode.values)
                          RadioListTile<AppThemeMode>(
                            contentPadding: EdgeInsets.zero,
                            value: m,
                            title: Text(switch (m) {
                              AppThemeMode.system => l.themeSystem,
                              AppThemeMode.dark => l.themeDark,
                              AppThemeMode.light => l.themeLight,
                            }),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- Reminders -------------------------------------------------------
          header(l.settingsNotifications),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(l.notifMaster),
                  value: notifOn,
                  onChanged: toggleNotifications,
                ),
                SwitchListTile(
                  title: Text(l.notifSalary),
                  value: settings.salaryReminderEnabled,
                  onChanged: notifOn
                      ? (v) => sc.update(
                          (x) => x.copyWith(salaryReminderEnabled: v),
                        )
                      : null,
                ),
                SwitchListTile(
                  title: Text(l.notifWeekly),
                  value: settings.weeklyCheckinEnabled,
                  onChanged: notifOn
                      ? (v) => sc.update(
                          (x) => x.copyWith(weeklyCheckinEnabled: v),
                        )
                      : null,
                ),
                SwitchListTile(
                  title: Text(l.notifLowBalance),
                  value: settings.lowBalanceAlertsEnabled,
                  onChanged: notifOn
                      ? (v) => sc.update(
                          (x) => x.copyWith(lowBalanceAlertsEnabled: v),
                        )
                      : null,
                ),
                SwitchListTile(
                  title: Text(l.notifDaily),
                  value: settings.dailyReminderEnabled,
                  onChanged: notifOn
                      ? (v) => sc.update(
                          (x) => x.copyWith(dailyReminderEnabled: v),
                        )
                      : null,
                ),
                ListTile(
                  key: const Key('notif_test'),
                  enabled: notifOn,
                  leading: const Icon(Icons.notifications_active_outlined),
                  title: Text(l.notifTestButton),
                  subtitle: Text(l.notifTestDesc),
                  onTap: () async {
                    final g = ref.read(notificationGatewayProvider);
                    if (!await g.requestPermission()) {
                      if (context.mounted) {
                        showSnack(context, l.notifPermissionDenied);
                      }
                      return;
                    }
                    await g.showNow(
                      id: NotificationIds.test,
                      title: l.notifSalaryTitle,
                      body: l.notifSalaryBody,
                      channelName: l.notifChannel,
                    );
                  },
                ),
                ListTile(
                  enabled: notifOn && settings.dailyReminderEnabled,
                  leading: const Icon(Icons.schedule),
                  title: Text(l.notifDailyTime),
                  trailing: Text(time, style: t.titleSmall),
                  onTap: pickTime,
                ),
              ],
            ),
          ),

          // --- Sharing ---------------------------------------------------------
          header(l.settingsSharing),
          Card(
            child: SwitchListTile(
              title: Text(l.shareShowAmounts),
              subtitle: Text(l.shareShowAmountsHint),
              value: settings.showAmountsOnShare,
              onChanged: (v) =>
                  sc.update((x) => x.copyWith(showAmountsOnShare: v)),
            ),
          ),

          // --- Data -------------------------------------------------------------
          header(l.settingsData),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.download_outlined),
                  title: Text(l.settingsExport),
                  subtitle: Text(l.settingsExportDesc),
                  onTap: () => _export(context, ref),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(
                    Icons.delete_forever_outlined,
                    color: pp.danger,
                  ),
                  title: Text(
                    l.settingsReset,
                    style: TextStyle(color: pp.danger),
                  ),
                  subtitle: Text(l.settingsResetDesc),
                  onTap: () => _reset(context, ref),
                ),
              ],
            ),
          ),

          header(''),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(l.settingsAbout),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(Routes.about),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    final data = ref.read(budgetProvider.notifier).exportData();
    final json = const JsonEncoder.withIndent('  ').convert(data);
    final dir = await getTemporaryDirectory();
    final stamp = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
    final file = File('${dir.path}/pehlapaisa_export_$stamp.json');
    await file.writeAsString(json);
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path, mimeType: 'application/json')]),
    );
  }

  Future<void> _reset(BuildContext context, WidgetRef ref) async {
    final l = context.l10n;
    final first = await confirmDialog(
      context,
      emoji: '🗑️',
      title: l.resetTitle1,
      body: l.resetBody1,
      confirmLabel: l.commonContinue,
      destructive: true,
    );
    if (!first || !context.mounted) return;
    final second = await confirmDialog(
      context,
      emoji: '⚠️',
      title: l.resetTitle2,
      body: l.resetBody2,
      confirmLabel: l.resetConfirm,
      destructive: true,
    );
    if (!second || !context.mounted) return;
    await ref.read(budgetProvider.notifier).resetAll();
    HapticFeedback.heavyImpact();
    if (context.mounted) {
      showSnack(context, l.resetDone);
      context.go(Routes.onboarding);
    }
  }

  Future<void> _editProfile(
    BuildContext context,
    WidgetRef ref,
    UserProfile p,
  ) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    useSafeArea: true,
    builder: (_) => _ProfileForm(profile: p),
  );
}

class _ProfileForm extends ConsumerStatefulWidget {
  const _ProfileForm({required this.profile});

  final UserProfile profile;

  @override
  ConsumerState<_ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends ConsumerState<_ProfileForm> {
  late final _name = TextEditingController(text: widget.profile.name);
  late final _income = TextEditingController(
    text: widget.profile.monthlyIncome.toString(),
  );
  late int _day = widget.profile.salaryDay;
  late IncomeType _type = widget.profile.incomeType;
  late bool _family = widget.profile.livesWithFamily;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _income.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l = context.l10n;
    final income = int.tryParse(_income.text) ?? 0;
    if (_name.text.trim().isEmpty) {
      setState(() => _error = l.onbNameError);
      return;
    }
    if (income < 500 || income > 1000000) {
      setState(() => _error = l.onbIncomeError);
      return;
    }
    await ref
        .read(budgetProvider.notifier)
        .updateProfile(
          widget.profile.copyWith(
            name: _name.text.trim(),
            monthlyIncome: income,
            salaryDay: _day,
            incomeType: _type,
            livesWithFamily: _family,
          ),
        );
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    messenger.showSnackBar(SnackBar(content: Text(l.profileSaved)));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, safeBottom(context) + 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.settingsEditProfile, style: t.titleLarge),
            const SizedBox(height: 16),
            TextField(
              controller: _name,
              maxLength: 30,
              decoration: InputDecoration(
                labelText: l.settingsName,
                counterText: '',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _income,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(7),
              ],
              decoration: InputDecoration(
                labelText: l.settingsIncome,
                prefixText: '₹ ',
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              isExpanded: true,
              initialValue: _day,
              menuMaxHeight: 320,
              decoration: InputDecoration(
                labelText: l.settingsSalaryDay,
                helperText: l.settingsSalaryDayNote,
              ),
              items: [
                for (var d = 1; d <= 31; d++)
                  DropdownMenuItem(
                    value: d,
                    child: Text(
                      l.dayOfMonth(d),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: (v) => setState(() => _day = v ?? _day),
            ),
            const SizedBox(height: 12),
            Text(l.settingsIncomeType, style: t.labelLarge),
            const SizedBox(height: 6),
            SegmentedButton<IncomeType>(
              segments: [
                ButtonSegment(
                  value: IncomeType.fixed,
                  label: Text(l.incomeFixed),
                ),
                ButtonSegment(
                  value: IncomeType.irregular,
                  label: Text(l.incomeIrregular),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (v) => setState(() => _type = v.first),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l.settingsFamily),
              value: _family,
              onChanged: (v) => setState(() => _family = v),
            ),
            if (_error != null)
              Text(_error!, style: TextStyle(color: context.pp.danger)),
            const SizedBox(height: 12),
            FilledButton(
              key: const Key('profile_save'),
              onPressed: _save,
              child: Text(l.commonSave),
            ),
          ],
        ),
      ),
    );
  }
}
