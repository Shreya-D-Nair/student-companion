import 'package:flutter/foundation.dart';

import '../models/student.dart';
import '../services/student_service.dart';

class StudentProvider extends ChangeNotifier {
  StudentProvider(this._service);

  final StudentService _service;

  final List<Student> _recommendedStudents = [];
  Student? _selectedStudent;
  bool _isLoading = false;
  bool _isSendingRequest = false;
  String? _errorMessage;
  String? _connectRequestMessage;

  List<Student> get recommendedStudents =>
      List.unmodifiable(_recommendedStudents);
  Student? get selectedStudent => _selectedStudent;
  bool get isLoading => _isLoading;
  bool get isSendingRequest => _isSendingRequest;
  String? get errorMessage => _errorMessage;
  String? get connectRequestMessage => _connectRequestMessage;

  Future<void> loadRecommendedStudents(String anonymousDeviceId) async {
    if (_isLoading) {
      return;
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final students = await _service.fetchRecommendedStudents(
        anonymousDeviceId: anonymousDeviceId,
      );
      _recommendedStudents
        ..clear()
        ..addAll(students);
    } catch (_) {
      _errorMessage =
          'We could not connect to the server. Please check your internet connection and try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> loadStudentDetails({
    required String studentId,
    required String anonymousDeviceId,
  }) async {
    if (_isLoading) {
      return false;
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedStudent = await _service.fetchStudent(
        studentId: studentId,
        anonymousDeviceId: anonymousDeviceId,
      );
      return true;
    } catch (error) {
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendConnectRequest({
    required String anonymousDeviceId,
    required String studentId,
  }) async {
    if (_isSendingRequest) {
      return false;
    }
    _isSendingRequest = true;
    _errorMessage = null;
    _connectRequestMessage = null;
    notifyListeners();

    try {
      _connectRequestMessage = await _service.sendConnectRequest(
        anonymousDeviceId: anonymousDeviceId,
        studentId: studentId,
      );
      return true;
    } catch (error) {
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isSendingRequest = false;
      notifyListeners();
    }
  }
}
