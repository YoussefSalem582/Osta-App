import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the user's theme choice (light / dark / system) and persists it
/// locally — not synced to the backend in M0.
///
/// The More screen (#40) surfaces the toggle.
class ThemeModeController extends Cubit<ThemeMode> {
  ThemeModeController(this._prefs) : super(_load(_prefs));

  static const _prefsKey = 'theme_mode';

  final SharedPreferences _prefs;

  static ThemeMode _load(SharedPreferences prefs) {
    final saved = prefs.getString(_prefsKey);
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == saved,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> setMode(ThemeMode mode) async {
    emit(mode);
    await _prefs.setString(_prefsKey, mode.name);
  }

  /// Cycles light → dark → system (debug convenience).
  Future<void> cycle() => setMode(
    ThemeMode.values[(state.index + 1) % ThemeMode.values.length],
  );
}
