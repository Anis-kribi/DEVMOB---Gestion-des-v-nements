import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  firebase_auth.User? _firebaseUser;
  User? _user;
  bool _isLoading = true;
  String? _error;

  firebase_auth.User? get firebaseUser => _firebaseUser;
  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _firebaseUser != null;
  String? get error => _error;

  AuthProvider() {
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(firebase_auth.User? firebaseUser) async {
    _firebaseUser = firebaseUser;

    if (firebaseUser != null) {
      _error = null;
      // Attempt to load user data with retry (Firestore can be briefly slow)
      for (int attempt = 0; attempt < 3; attempt++) {
        try {
          _user = await _authService.getUserData(firebaseUser.uid);
          if (_user != null) {
            _error = null;
            break;
          }
        } catch (e) {
          _error = e.toString();
        }
        if (attempt < 2) await Future.delayed(const Duration(milliseconds: 600));
      }
      if (_user == null && _error == null) {
        _error = 'Document utilisateur introuvable. Réessayez.';
      }
    } else {
      _user = null;
      _error = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> signIn({required String email, required String password}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      // Firebase Auth triggers _onAuthStateChanged which loads the Firestore user
      await _authService.signInWithEmailAndPassword(email, password);
    } on firebase_auth.FirebaseAuthException catch (e) {
      _isLoading = false;
      _error = e.message;
      notifyListeners();
      rethrow;
    } catch (e) {
      _isLoading = false;
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      await _authService.signUpWithEmailAndPassword(email, password, name, role);
      // _onAuthStateChanged handles the rest
    } catch (e) {
      _isLoading = false;
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> retryLoadUserData() async {
    if (_firebaseUser == null) return;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await _authService.getUserData(_firebaseUser!.uid);
      if (_user == null) {
        _error = 'Profil introuvable. Contactez l\'administrateur.';
      }
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> signOut() async {
    _user = null;
    _error = null;
    await _authService.signOut();
  }

  Future<void> updateRole(UserRole role) async {
    if (_user != null) {
      await _authService.updateUserRole(_user!.id, role);
      _user = await _authService.getUserData(_user!.id);
      notifyListeners();
    }
  }

  /// Update display name in Firestore and Firebase Auth
  Future<void> updateName(String newName) async {
    if (_user == null) return;
    await _authService.updateName(_user!.id, newName);
    _user = await _authService.getUserData(_user!.id);
    notifyListeners();
  }

  /// Update email — requires current password for re-authentication
  Future<void> updateEmail(String newEmail, String currentPassword) async {
    if (_user == null) return;
    await _authService.updateEmail(_user!.id, newEmail, currentPassword);
    _user = await _authService.getUserData(_user!.id);
    notifyListeners();
  }

  /// Update password — requires current password for re-authentication
  Future<void> updatePassword(String currentPassword, String newPassword) async {
    await _authService.updatePassword(currentPassword, newPassword);
  }
}
