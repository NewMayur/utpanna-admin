import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String _userKey = 'auth_user';

  /// Sign in with email and password using Firebase Auth
  Future<UserCredential> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save user info to SharedPreferences
      await _saveUserData(userCredential);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Wrong password provided.');
      } else {
        throw Exception(e.message ?? 'Authentication failed.');
      }
    }
  }

  /// Sign out from Firebase Auth
  Future<void> logout() async {
    await _auth.signOut();
    await _clearUserData();
  }

  /// Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// Check if user is authenticated
  bool isUserLoggedIn() {
    return _auth.currentUser != null;
  }

  /// Auto login - attempt to restore session
  Future<bool> autoLogin() async {
    if (_auth.currentUser != null) {
      return true;
    }

    // Try to get saved user data
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_userKey);

    if (userId == null) {
      return false;
    }

    // Firebase automatically restores sessions, so we just check if current user exists
    return _auth.currentUser != null;
  }

  /// Save user credentials to SharedPreferences
  Future<void> _saveUserData(UserCredential userCredential) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, userCredential.user!.uid);
  }

  /// Clear user data from SharedPreferences
  Future<void> _clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  // ============= BACKWARD COMPATIBILITY (FOR EXISTING ADMIN PANEL) =============

  /// Legacy method for backward compatibility
  Future<String> login(String email, String password) async {
    final userCredential = await signIn(email, password);
    final idToken = await userCredential.user!.getIdToken();
    return idToken ?? '';
  }

  /// Legacy token method for backward compatibility
  Future<String?> getToken() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      return await user.getIdToken();
    } catch (e) {
      return null;
    }
  }

  // ============================================================================
}
