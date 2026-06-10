import 'package:flutter/foundation.dart';

import '../models/interest.dart';
import '../services/interest_service.dart';
import '../services/preferences_service.dart';

class InterestProvider extends ChangeNotifier {
  InterestProvider(this._service, this._preferencesService);

  final InterestService _service;
  final PreferencesService _preferencesService;

  final List<Interest> _interests = [];
  final Set<String> _selectedInterestNames = {};
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  List<Interest> get interests => List.unmodifiable(_interests);
  Set<String> get selectedInterestNames =>
      Set.unmodifiable(_selectedInterestNames);
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  Future<void> loadInterests() async {
    if (_isLoading) {
      return;
    }
    _isLoading = true;
    _errorMessage = null;
    _selectedInterestNames
      ..clear()
      ..addAll(_preferencesService.selectedInterests);
    notifyListeners();

    try {
      final items = await _service.fetchInterests();
      _interests
        ..clear()
        ..addAll(items);
    } catch (_) {
      _errorMessage =
          'We could not connect to the server. Please check your internet connection and try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleInterest(String name) async {
    if (_selectedInterestNames.contains(name)) {
      _selectedInterestNames.remove(name);
    } else {
      _selectedInterestNames.add(name);
    }

    await _preferencesService.setSelectedInterests(
      _selectedInterestNames.toList()..sort(),
    );
    notifyListeners();
  }

  Future<bool> saveSelectedInterests(String anonymousDeviceId) async {
    if (_isSaving) {
      return false;
    }
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final selectedIds =
          _interests
              .where(
                (interest) => _selectedInterestNames.contains(interest.name),
              )
              .map((interest) => interest.id)
              .toList();
      await _service.saveUserInterests(
        anonymousDeviceId: anonymousDeviceId,
        interestIds: selectedIds,
      );
      return true;
    } catch (error) {
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
