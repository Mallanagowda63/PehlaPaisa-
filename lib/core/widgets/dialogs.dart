import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/l10n.dart';
import '../../app/theme.dart';

/// A simple yes/no dialog. Returns true only when confirmed.
Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String body,
  required String confirmLabel,
  String? cancelLabel,
  bool destructive = false,
  String? emoji,
}) async {
  final l = context.l10n;
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      icon: emoji == null
          ? null
          : Text(emoji, style: const TextStyle(fontSize: 40)),
      title: Text(title, textAlign: TextAlign.center),
      content: Text(body),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.onSurface,
          ),
          child: Text(cancelLabel ?? l.commonCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          style: destructive
              ? FilledButton.styleFrom(
                  backgroundColor: context.pp.danger,
                  foregroundColor: Colors.white,
                )
              : null,
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Disposes a dialog's text controller once the dialog's closing animation
/// has finished (disposing right away crashes the still-visible field).
void disposeAfterDialog(TextEditingController c) =>
    Future<void>.delayed(const Duration(milliseconds: 600), c.dispose);

/// Asks for a rupee amount up to [max]. Returns null if cancelled.
Future<int?> askAmount(
  BuildContext context, {
  required String title,
  required String helper,
  required int max,
  required String confirmLabel,
}) async {
  final l = context.l10n;
  final ctrl = TextEditingController();
  final result = await showDialog<int>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setLocal) {
        final v = int.tryParse(ctrl.text) ?? 0;
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: ctrl,
                autofocus: true,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(7),
                ],
                decoration: InputDecoration(
                  prefixText: '₹ ',
                  helperText: helper,
                ),
                onChanged: (_) => setLocal(() {}),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l.commonCancel),
            ),
            FilledButton(
              onPressed: v > 0 && v <= max
                  ? () => Navigator.pop(context, v)
                  : null,
              child: Text(confirmLabel),
            ),
          ],
        );
      },
    ),
  );
  disposeAfterDialog(ctrl);
  return result;
}

/// Shows a short message at the bottom of the screen.
void showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
