import 'package:flutter/foundation.dart';

import '../models/support_resource.dart';
import '../services/support_resource_service.dart';

class SupportResourceProvider extends ChangeNotifier {
  SupportResourceProvider(this._service);

  final SupportResourceService _service;

  final List<SupportResource> _resources = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<SupportResource> get resources => List.unmodifiable(_resources);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadResources() async {
    if (_isLoading) {
      return;
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final items = await _service.fetchSupportResources();
      _resources
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
}
