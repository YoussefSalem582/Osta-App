import 'package:flutter/widgets.dart';
import 'package:osta/core/l10n/app_localizations.dart';

/// Convenience accessors on [BuildContext].
extension BuildContextX on BuildContext {
  /// Localized strings for the current locale.
  AppLocalizations get l10n => AppLocalizations.of(this);
}
