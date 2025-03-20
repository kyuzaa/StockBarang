import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Register
  Future<User?> register(String email, String password, String name, String notelp, String alamat, String role) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'email': email,
          'name': name,
          'no_telp': notelp,
          'alamat': alamat, 
          'role': role,
        });
      }
      return user;
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
        String role = userDoc['role'] ?? 'customer';
        return {'user': user, 'role': role};
      }
    } catch (e) {
      print("Error: $e");
    }
    return {'user': null, 'role': null};
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }
}
