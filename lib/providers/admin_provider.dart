import 'dart:async';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/admin_service.dart';

class AdminProvider with ChangeNotifier {
  final AdminService _adminService = AdminService();
  StreamSubscription<List<User>>? _usersSub;

  List<User> _users = [];
  bool _isLoading = false;
  String? _error;

  List<User> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize and load users stream
  void loadUsers() {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _usersSub?.cancel();
    _usersSub = _adminService.getAllUsers().listen(
      (userList) {
        _users = userList;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> createUser({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _adminService.createUser(email, password, name, role);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      if (_isLoading) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> updateUser(User user) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _adminService.updateUser(user);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      if (_isLoading) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> deleteUser(String uid) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _adminService.deleteUser(uid);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      if (_isLoading) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _usersSub?.cancel();
    super.dispose();
  }
}
