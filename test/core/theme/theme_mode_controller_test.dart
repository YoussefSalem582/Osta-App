import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:osta/core/theme/theme_mode_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('defaults to system when nothing saved', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    expect(ThemeModeController(prefs).state, ThemeMode.system);
  });

  test('setMode persists across restart', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await ThemeModeController(prefs).setMode(ThemeMode.dark);

    // Fresh controller over the same storage = app restart.
    expect(ThemeModeController(prefs).state, ThemeMode.dark);
  });

  test('cycle walks light → dark → system', () async {
    SharedPreferences.setMockInitialValues({'theme_mode': 'light'});
    final prefs = await SharedPreferences.getInstance();
    final controller = ThemeModeController(prefs);

    await controller.cycle();
    expect(controller.state, ThemeMode.dark);
    await controller.cycle();
    expect(controller.state, ThemeMode.system);
    await controller.cycle();
    expect(controller.state, ThemeMode.light);
  });
}
