import 'package:flutter/widgets.dart';

import '../l10n/app_localizations.dart';

export '../l10n/app_localizations.dart';

/// Short access to localized strings: `context.l10n.appName`.
extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Strings outside a widget tree (notifications), for a language code.
AppLocalizations l10nFor(String languageCode) =>
    lookupAppLocalizations(Locale(languageCode == 'hi' ? 'hi' : 'en'));
