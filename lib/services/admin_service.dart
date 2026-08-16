import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream all users
  Stream<List<User>> getAllUsers() {
    return _firestore
        .collection('users')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => User.fromJson(doc.data())).toList();
    });
  }

  // Create user bypassing auto-login by using a secondary Firebase App instance
  Future<void> createUser(String email, String password, String name, UserRole role) async {
    FirebaseApp? tempApp;
    try {
      // 1. Initialize secondary app to isolate auth state
      tempApp = await Firebase.initializeApp(
        name: 'TemporarySignupApp',
        options: Firebase.app().options,
      );

      // 2. Create the user in Auth
      final auth = firebase_auth.FirebaseAuth.instanceFor(app: tempApp);
      final result = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = result.user?.uid;
      if (uid == null) throw Exception('Échec de la création de l\'utilisateur auth');

      // 3. Save to Firestore (using main firestore instance)
      User newUser = User(
        id: uid,
        email: email,
        name: name,
        role: role,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(uid).set(newUser.toJson());

    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw Exception('Erreur lors de la création : $e');
    } finally {
      // 4. Cleanup
      if (tempApp != null) {
        await tempApp.delete();
      }
    }
  }

  // Update a user entirely
  Future<void> updateUser(User user) async {
    try {
      await _firestore.collection('users').doc(user.id).update(user.toJson());
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour: $e');
    }
  }

  // Delete a user from Firestore (Logical deletion from auth is complex client-side)
  Future<void> deleteUser(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).delete();
      // Note: We only delete from Firestore here. 
      // Deleting from Firebase Auth requires Cloud Functions or Admin SDK.
    } catch (e) {
      throw Exception('Erreur lors de la suppression: $e');
    }
  }

  Exception _handleAuthError(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return Exception('Le mot de passe est trop faible.');
      case 'email-already-in-use':
        return Exception('Un compte existe déjà avec cette adresse email.');
      case 'invalid-email':
        return Exception('L\'adresse email n\'est pas valide.');
      default:
        return Exception('Erreur d\'authentification: \${e.message ?? e.code}');
    }
  }
}
