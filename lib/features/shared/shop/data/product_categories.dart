import 'package:osta/core/l10n/app_localizations.dart';

/// Canonical category keys stored on the backend; labels are localized via
/// [categoryLabel].
const productCategoryKeys = <String>[
  'oils',
  'filters',
  'brakes',
  'batteries',
  'tires',
  'engine',
  'electrical',
  'body',
  'accessories',
  'tools',
  'other',
];

/// Localized label for a category key. Unknown keys (legacy free-form data)
/// fall back to the key itself so they still render.
String categoryLabel(AppLocalizations l10n, String key) => switch (key) {
  'oils' => l10n.shopCatOils,
  'filters' => l10n.shopCatFilters,
  'brakes' => l10n.shopCatBrakes,
  'batteries' => l10n.shopCatBatteries,
  'tires' => l10n.shopCatTires,
  'engine' => l10n.shopCatEngine,
  'electrical' => l10n.shopCatElectrical,
  'body' => l10n.shopCatBody,
  'accessories' => l10n.shopCatAccessories,
  'tools' => l10n.shopCatTools,
  'other' => l10n.shopCatOther,
  _ => key,
};
