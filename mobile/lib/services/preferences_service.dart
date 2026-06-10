import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class PreferencesService {
  PreferencesService._(this._preferences);

  static const _onboardingKey = 'onboarding_complete';
  static const _themeModeKey = 'theme_mode';
  static const _deviceIdKey = 'anonymous_device_id';
  static const _selectedInterestsKey = 'selected_interests';

  final SharedPreferences _preferences;

  static Future<PreferencesService> create() async {
    final preferences = await SharedPreferences.getInstance();
    return PreferencesService._(preferences);
  }

  bool get hasCompletedOnboarding =>
      _preferences.getBool(_onboardingKey) ?? false;

  Future<void> setOnboardingComplete(bool value) async {
    await _preferences.setBool(_onboardingKey, value);
  }

  ThemeMode get themeMode {
    final value = _preferences.getString(_themeModeKey);
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _preferences.setString(_themeModeKey, mode.name);
  }

  Future<String> getOrCreateDeviceId() async {
    final existingId = _preferences.getString(_deviceIdKey);
    if (existingId != null && existingId.isNotEmpty) {
      return existingId;
    }

    final newId = const Uuid().v4();
    await _preferences.setString(_deviceIdKey, newId);
    return newId;
  }

  List<String> get selectedInterests =>
      _preferences.getStringList(_selectedInterestsKey) ?? <String>[];

  Future<void> setSelectedInterests(List<String> interests) async {
    await _preferences.setStringList(_selectedInterestsKey, interests);
  }

  Future<void> clearLocalPreferences() async {
    await _preferences.remove(_onboardingKey);
    await _preferences.remove(_themeModeKey);
    await _preferences.remove(_selectedInterestsKey);
    await _preferences.remove(_deviceIdKey);
  }
}
