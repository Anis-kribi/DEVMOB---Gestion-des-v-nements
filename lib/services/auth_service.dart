import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<firebase_auth.User?> get authStateChanges => _auth.authStateChanges();

  firebase_auth.User? get currentUser => _auth.currentUser;

  Future<firebase_auth.UserCredential> signUpWithEmailAndPassword(
    String email,
    String password,
    String name,
    UserRole role,
  ) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _createUserDocument(result.user!.uid, email, name, role);
      return result;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw Exception('Une erreur inattendue s\'est produite: $e');
    }
  }

  Future<firebase_auth.UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw Exception('Une erreur inattendue s\'est produite: $e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<User?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        // Inject the document ID if missing from the stored data
        if (data['id'] == null || (data['id'] as String).isEmpty) {
          data['id'] = doc.id;
        }
        return User.fromJson(data);
      }
      return null;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      // Log but don't crash — permission-denied is recoverable
      print('AuthService.getUserData error for $uid: $e');
      return null;
    }
  }

  Future<void> _createUserDocument(
    String uid,
    String email,
    String name,
    UserRole role,
  ) async {
    final user = User(
      id: uid,
      email: email,
      name: name,
      role: role,
      createdAt: DateTime.now(),
    );
    await _firestore.collection('users').doc(uid).set(user.toJson());
  }

  Future<void> updateUserProfile(User user) async {
    await _firestore.collection('users').doc(user.id).update(user.toJson());
  }

  Future<void> updateUserRole(String uid, UserRole role) async {
    await _firestore.collection('users').doc(uid).update({
      'role': User.roleToString(role),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  /// Update just the display name in Firestore
  Future<void> updateName(String uid, String newName) async {
    await _firestore.collection('users').doc(uid).update({
      'name': newName,
      'updatedAt': DateTime.now().toIso8601String(),
    });
    await _auth.currentUser?.updateDisplayName(newName);
  }

  /// Update email: requires re-auth then updates Firebase Auth + Firestore
  Future<void> updateEmail(String uid, String newEmail, String currentPassword) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('Non authentifié');
    try {
      // Re-authenticate
      final credential = firebase_auth.EmailAuthProvider.credential(
        email: currentUser.email!,
        password: currentPassword,
      );
      await currentUser.reauthenticateWithCredential(credential);
      // Update email in Firebase Auth
      await currentUser.verifyBeforeUpdateEmail(newEmail);
      // Update email in Firestore immediately
      await _firestore.collection('users').doc(uid).update({
        'email': newEmail,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Update password: requires re-auth with current password
  Future<void> updatePassword(String currentPassword, String newPassword) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('Non authentifié');
    try {
      final credential = firebase_auth.EmailAuthProvider.credential(
        email: currentUser.email!,
        password: currentPassword,
      );
      await currentUser.reauthenticateWithCredential(credential);
      await currentUser.updatePassword(newPassword);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  Exception _handleAuthError(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return Exception('Le mot de passe est trop faible (min. 6 caractères).');
      case 'email-already-in-use':
        return Exception('Un compte existe déjà avec cette adresse email.');
      case 'invalid-email':
        return Exception('L\'adresse email n\'est pas valide.');
      case 'user-disabled':
        return Exception('Ce compte a été désactivé.');
      case 'user-not-found':
        return Exception('Aucun compte trouvé avec cet email.');
      case 'wrong-password':
        return Exception('Mot de passe incorrect.');
      case 'invalid-credential':
        return Exception('Email ou mot de passe incorrect.');
      case 'too-many-requests':
        return Exception('Trop de tentatives. Réessayez plus tard.');
      case 'network-request-failed':
        return Exception('Erreur réseau. Vérifiez votre connexion internet.');
      default:
        return Exception('Erreur: ${e.message ?? e.code}');
    }
  }
}
