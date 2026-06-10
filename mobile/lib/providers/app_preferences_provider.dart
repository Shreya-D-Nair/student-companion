import 'package:flutter/foundation.dart';

import '../services/preferences_service.dart';

class AppPreferencesProvider extends ChangeNotifier {
  AppPreferencesProvider(this._preferencesService);

  final PreferencesService _preferencesService;

  bool _hasCompletedOnboarding = false;
  String? _anonymousDeviceId;

  bool get hasCompletedOnboarding => _hasCompletedOnboarding;
  String? get anonymousDeviceId => _anonymousDeviceId;

  Future<void> load() async {
    _hasCompletedOnboarding = _preferencesService.hasCompletedOnboarding;
    _anonymousDeviceId = await _preferencesService.getOrCreateDeviceId();
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    await _preferencesService.setOnboardingComplete(true);
    _hasCompletedOnboarding = true;
    notifyListeners();
  }

  Future<void> clearLocalPreferences() async {
    await _preferencesService.clearLocalPreferences();
    _hasCompletedOnboarding = false;
    _anonymousDeviceId = await _preferencesService.getOrCreateDeviceId();
    notifyListeners();
  }
}
