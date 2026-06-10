import 'package:flutter/foundation.dart';

import '../models/confession.dart';
import '../services/confession_service.dart';

class ConfessionProvider extends ChangeNotifier {
  ConfessionProvider(this._service);

  final ConfessionService _service;

  final List<Confession> _confessions = [];
  final Set<String> _reactedConfessionIds = {};
  bool _isLoading = false;
  bool _isSubmitting = false;
  bool _isUpdatingAction = false;
  String? _errorMessage;

  List<Confession> get confessions => List.unmodifiable(_confessions);
  Set<String> get reactedConfessionIds =>
      Set.unmodifiable(_reactedConfessionIds);
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  bool get isUpdatingAction => _isUpdatingAction;
  String? get errorMessage => _errorMessage;

  Future<void> loadConfessions({String? anonymousDeviceId}) async {
    if (_isLoading) {
      return;
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final items = await _service.fetchConfessions(
        anonymousDeviceId: anonymousDeviceId,
      );
      _confessions
        ..clear()
        ..addAll(items);
      _reactedConfessionIds
        ..clear()
        ..addAll(
          items
              .where((confession) => confession.hasReacted)
              .map((confession) => confession.id),
        );
    } catch (_) {
      _errorMessage =
          'We could not connect to the server. Please check your internet connection and try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createConfession({
    required String anonymousDeviceId,
    required String content,
  }) async {
    if (_isSubmitting) {
      return false;
    }
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final created = await _service.createConfession(
        anonymousDeviceId: anonymousDeviceId,
        content: content,
      );
      _confessions.insert(0, created);
      return true;
    } catch (error) {
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> toggleReaction({
    required String confessionId,
    required String anonymousDeviceId,
  }) async {
    if (_isUpdatingAction) {
      return false;
    }
    _isUpdatingAction = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final hasReacted = _reactedConfessionIds.contains(confessionId);
      final updated =
          hasReacted
              ? await _service.removeReaction(
                confessionId: confessionId,
                anonymousDeviceId: anonymousDeviceId,
              )
              : await _service.reactToConfession(
                confessionId: confessionId,
                anonymousDeviceId: anonymousDeviceId,
              );

      _replaceConfession(updated);
      if (hasReacted) {
        _reactedConfessionIds.remove(confessionId);
      } else {
        _reactedConfessionIds.add(confessionId);
      }
      return true;
    } catch (error) {
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isUpdatingAction = false;
      notifyListeners();
    }
  }

  Future<bool> reportConfession({
    required String confessionId,
    required String anonymousDeviceId,
    required String reason,
  }) async {
    if (_isUpdatingAction) {
      return false;
    }
    _isUpdatingAction = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.reportConfession(
        confessionId: confessionId,
        anonymousDeviceId: anonymousDeviceId,
        reason: reason,
      );
      return true;
    } catch (error) {
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isUpdatingAction = false;
      notifyListeners();
    }
  }

  Future<bool> deleteConfession({
    required String confessionId,
    required String anonymousDeviceId,
  }) async {
    if (_isUpdatingAction) {
      return false;
    }
    _isUpdatingAction = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.deleteConfession(
        confessionId: confessionId,
        anonymousDeviceId: anonymousDeviceId,
      );
      _confessions.removeWhere((confession) => confession.id == confessionId);
      _reactedConfessionIds.remove(confessionId);
      return true;
    } catch (error) {
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isUpdatingAction = false;
      notifyListeners();
    }
  }

  void _replaceConfession(Confession updated) {
    final index = _confessions.indexWhere(
      (confession) => confession.id == updated.id,
    );
    if (index >= 0) {
      _confessions[index] = updated;
    }
  }
}
