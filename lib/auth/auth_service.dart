import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agromat_project/models/app_user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign up and create user profile
  Future<AppUser?> signUp(
      {required String email,
      required String password,
      Map<String, dynamic>? extraData}) async {
    UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    User? user = cred.user;
    if (user != null) {
      final userData = {
        'email': email,
        'name': extraData?['name'] ?? '',
        'role': 'customer', // Always set to customer
        'createdAt': FieldValue.serverTimestamp(),
      };
      await _firestore.collection('users').doc(user.uid).set(userData);
      // Fetch the user profile as AppUser
      return getUserProfile(user.uid);
    }
    return null;
  }

  // Create admin user (for development only)
  // Future<AppUser?> createAdmin({
  //   required String email,
  //   required String password,
  //   required String name,
  // }) async {
  //   UserCredential cred = await _auth.createUserWithEmailAndPassword(
  //       email: email, password: password);
  //   User? user = cred.user;
  //   if (user != null) {
  //     final userData = {
  //       'email': email,
  //       'name': name,
  //       'role': 'admin',
  //       'createdAt': FieldValue.serverTimestamp(),
  //     };
  //     await _firestore.collection('users').doc(user.uid).set(userData);
  //     return getUserProfile(user.uid);
  //   }
  //   return null;
  // }

  // Login
  Future<User?> signIn(
      {required String email, required String password}) async {
    UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    return cred.user;
  }

  // Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes
  Stream<User?> get userChanges => _auth.authStateChanges();

  // Fetch user profile from Firestore
  Future<AppUser?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return AppUser.fromMap(uid, doc.data()!);
    }
    return null;
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
