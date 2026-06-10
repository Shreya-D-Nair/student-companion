import 'package:flutter/material.dart';

import '../services/preferences_service.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeProvider(this._preferencesService);

  final PreferencesService _preferencesService;

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> loadTheme() async {
    _themeMode = _preferencesService.themeMode;
    notifyListeners();
  }

  Future<void> setDarkMode(bool enabled) async {
    _themeMode = enabled ? ThemeMode.dark : ThemeMode.light;
    await _preferencesService.setThemeMode(_themeMode);
    notifyListeners();
  }
}
