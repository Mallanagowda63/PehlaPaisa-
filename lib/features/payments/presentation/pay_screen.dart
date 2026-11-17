import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/l10n.dart';
import '../../../app/router.dart';
import '../../../app/state/budget_controller.dart';
import '../../../app/theme.dart';
import '../../../core/money.dart';
import '../../../core/widgets/amount_keypad.dart';
import '../../../core/widgets/dialogs.dart';
import '../../../core/widgets/insets.dart';
import '../../alerts/presentation/notification_sync.dart';
import '../../jars/presentation/jar_labels.dart';
import '../data/upi_launcher.dart';

/// Pay from a glass: choose the amount here, pay inside the phone's own UPI
/// app (scan the QR there), then confirm so it's logged in this glass.
///
/// The payment itself is started by the UPI app, so it goes through like any
/// normal payment. (UPI apps decline payments handed to them by apps that
/// aren't registered payment partners.) PehlaPaisa never sees the UPI PIN
/// or bank details.
class PayScreen extends ConsumerStatefulWidget {
  const PayScreen({super.key, required this.jarId});

  final String jarId;

  @override
  ConsumerState<PayScreen> createState() => _PayScreenState();
}

class _PayScreenState extends ConsumerState<PayScreen>
    with WidgetsBindingObserver {
  int _amount = 0;
  final _to = TextEditingController();

  /// The UPI app was opened and we're waiting for the user to come back.
  bool _awaitingReturn = false;
  bool _asking = false;

  /// Package of the UPI app used last, listed first next time.
  String? _lastApp;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _to.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Back from Google Pay / PhonePe / Paytm…: ask whether it went through.
    if (state == AppLifecycleState.resumed && _awaitingReturn) {
      _awaitingReturn = false;
      WidgetsBinding.instance.addPostFrameCallback((_) => _confirmPaid());
    }
  }

  String get _payeeName => _to.text.trim();

  /// Lists the installed UPI apps and opens the chosen one on its home
  /// screen, where the user scans the QR and pays.
  Future<void> _openUpiApp() async {
    final l = context.l10n;
    FocusScope.of(context).unfocus();
    final launcher = ref.read(upiLauncherProvider);
    final apps = await launcher.installedApps();
    if (!mounted) return;
    if (apps.isEmpty) {
      showSnack(context, l.payNoUpiApp);
      return;
    }
    final app = await showModalBottomSheet<UpiApp>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _PayWithSheet(
        apps: apps,
        title: l.payWithTitle(formatRupees(_amount)),
        hint: l.payWithHint(formatRupees(_amount)),
        last: _lastApp,
      ),
    );
    if (app == null || !mounted) return;
    _lastApp = app.package;
    final ok = await launcher.openHome(app);
    if (!mounted) return;
    if (!ok) {
      showSnack(context, l.payNoUpiApp);
      return;
    }
    _awaitingReturn = true;
  }

  Future<void> _confirmPaid() async {
    if (!mounted || _asking) return;
    _asking = true;
    final l = context.l10n;
    final amount = formatRupees(_amount);
    final answer = await showDialog<_PayResult>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Text('💸', style: TextStyle(fontSize: 40)),
        title: Text(l.payConfirmTitle, textAlign: TextAlign.center),
        content: Text(
          _payeeName.isEmpty
              ? l.payConfirmBody(amount)
              : l.payConfirmBodyTo(amount, _payeeName),
        ),
        actionsOverflowDirection: VerticalDirection.up,
        actions: [
          TextButton(
            key: const Key('pay_result_no'),
            onPressed: () => Navigator.pop(context, _PayResult.no),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onSurface,
            ),
            child: Text(l.payConfirmNo),
          ),
          OutlinedButton(
            key: const Key('pay_result_retry'),
            onPressed: () => Navigator.pop(context, _PayResult.retry),
            child: Text(l.payTryAnother),
          ),
          FilledButton(
            key: const Key('pay_result_yes'),
            onPressed: () => Navigator.pop(context, _PayResult.paid),
            child: Text(l.payConfirmYes),
          ),
        ],
      ),
    );
    _asking = false;
    if (!mounted) return;
    switch (answer) {
      case _PayResult.paid:
        await _record();
      case _PayResult.retry:
        await _openUpiApp();
      case _PayResult.no || null:
        showSnack(context, l.payNotRecorded);
    }
  }

  /// Adds the payment to this glass and goes back to it.
  Future<void> _record() async {
    final l = context.l10n;
    final c = ref.read(budgetProvider.notifier);
    // Default borrowing: Fun first, then other glasses — never Savings.
    final plan = c.planExpense(widget.jarId, _amount);
    await c.addExpense(
      plan,
      note: _payeeName.isEmpty
          ? l.payExpenseNotePlain
          : l.payExpenseNote(_payeeName),
    );
    HapticFeedback.lightImpact();
    await ref.read(notificationSyncProvider).dispatchAlerts();
    if (!mounted) return;
    final s = ref.read(budgetProvider);
    final jar = s.jarById(widget.jarId)!;
    final message = l.payRecorded(
      formatRupees(_amount),
      jarName(
        l,
        jar.type,
        jar.name,
        family: s.profile?.livesWithFamily ?? false,
      ),
    );
    final messenger = ScaffoldMessenger.of(context);
    // Opened directly (nothing to go back to)? Show the glass instead.
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(Routes.jar(widget.jarId));
    }
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = Theme.of(context).textTheme;
    final pp = context.pp;
    final s = ref.watch(budgetProvider);
    final jar = s.jarById(widget.jarId);
    if (jar == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l.jarGone)),
      );
    }
    final family = s.profile?.livesWithFamily ?? false;
    final name = jarName(l, jar.type, jar.name, family: family);
    final left = jar.remaining > 0 ? jar.remaining : 0;

    // Preview the overflow rule before paying.
    String? warning;
    if (_amount > left) {
      final plan = ref
          .read(budgetProvider.notifier)
          .planExpense(jar.id, _amount);
      warning = plan.uncovered > 0
          ? l.payOverspendWarning(formatRupees(plan.uncovered))
          : l.payBorrowWarning(formatRupees(plan.shortfall));
    }

    return Scaffold(
      appBar: AppBar(title: Text(l.payTitle)),
      body: Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, safeBottom(context) + 12),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Chip(
                      avatar: Text(jar.emoji),
                      label: Text(l.payFrom(name, formatRupees(left))),
                    ),
                    const SizedBox(height: 4),
                    AmountDisplay(amount: _amount),
                    if (warning != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Card(
                          color: pp.warning.withValues(alpha: 0.14),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, color: pp.warning),
                                const SizedBox(width: 8),
                                Expanded(child: Text(warning)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    AmountKeypad(
                      amount: _amount,
                      onChanged: (v) => setState(() => _amount = v),
                      compact: MediaQuery.sizeOf(context).height < 760,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      key: const Key('pay_to'),
                      controller: _to,
                      textCapitalization: TextCapitalization.words,
                      maxLength: 40,
                      decoration: InputDecoration(
                        labelText: l.payToLabel,
                        hintText: l.payToHint,
                        prefixIcon: const Icon(Icons.storefront_outlined),
                        counterText: '',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      key: const Key('pay_steps'),
                      color: pp.savings.withValues(alpha: 0.10),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l.payHowTitle, style: t.titleSmall),
                            const SizedBox(height: 6),
                            Text(l.paySteps, style: t.bodyMedium),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.lock_outline, size: 16, color: pp.muted),
                        const SizedBox(width: 6),
                        Expanded(child: Text(l.payHandOff, style: t.bodySmall)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                key: const Key('pay_button'),
                onPressed: _amount > 0 ? _openUpiApp : null,
                icon: const Icon(Icons.qr_code_scanner),
                label: Text(
                  _amount > 0
                      ? l.payButton(formatRupees(_amount))
                      : l.addEnterAmount,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _PayResult { paid, retry, no }

/// "Pay ₹X with": the installed UPI apps, as big tappable rows.
class _PayWithSheet extends StatelessWidget {
  const _PayWithSheet({
    required this.apps,
    required this.title,
    required this.hint,
    this.last,
  });

  final List<UpiApp> apps;
  final String title;
  final String hint;
  final String? last;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final ordered = [
      ...apps.where((a) => a.package == last),
      ...apps.where((a) => a.package != last),
    ];
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, safeBottom(context) + 12),
      child: Column(
        key: const Key('pay_with_sheet'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
            child: Text(title, style: t.titleLarge),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
            child: Text(hint, style: t.bodyMedium),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final app in ordered)
                  Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      key: Key('pay_app_${app.package}'),
                      minVerticalPadding: 14,
                      leading: CircleAvatar(
                        backgroundColor: app.color,
                        foregroundColor: Colors.white,
                        child: Text(
                          app.name.characters.first,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      title: Text(app.name, style: t.titleMedium),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.pop(context, app),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
