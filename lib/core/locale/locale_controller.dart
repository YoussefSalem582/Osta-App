import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the user's locale choice (ar / en) and persists it locally.
class LocaleController extends Cubit<Locale> {
  LocaleController(this._prefs) : super(_load(_prefs));

  static const _prefsKey = 'app_locale';

  final SharedPreferences _prefs;

  static Locale _load(SharedPreferences prefs) {
    final saved = prefs.getString(_prefsKey);
    if (saved == 'en') return const Locale('en');
    return const Locale('ar');
  }

  Future<void> setLocale(Locale locale) async {
    emit(locale);
    await _prefs.setString(_prefsKey, locale.languageCode);
  }

  void toggle() {
    final next =
        state.languageCode == 'ar' ? const Locale('en') : const Locale('ar');
    setLocale(next);
  }

  bool get isArabic => state.languageCode == 'ar';
}
