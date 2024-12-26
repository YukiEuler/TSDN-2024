// auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential?> signInWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> registerWithEmail(String email, String password, String name, DateTime birthDate) async {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    // Add user info to user profile
    await userCredential.user?.updateDisplayName(name);
    
    // You might want to store birth date in a separate database
    // as Firebase Auth doesn't have a built-in field for it
    
    return userCredential;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}