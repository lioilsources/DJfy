import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

export 'app_localizations.dart';

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Strings for code without a [BuildContext] (cubits): resolved from the
/// device locales the same way MaterialApp does, English as the fallback.
AppLocalizations deviceStrings() {
  final locale = basicLocaleListResolution(PlatformDispatcher.instance.locales, AppLocalizations.supportedLocales);
  return lookupAppLocalizations(locale);
}
