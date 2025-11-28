import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:utpanna_admin/screens/login_screen.dart';
import 'package:utpanna_admin/screens/main_admin_panel.dart';
import 'package:utpanna_admin/utils/firebase_config.dart';
import 'package:utpanna_admin/utils/app_theme.dart';
import 'package:utpanna_admin/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with environment-based configuration
  await FirebaseConfig.initialize();

  runApp(MyApp());
}

// stag
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: FirebaseOptions(
//       apiKey: "AIzaSyC5bkN7NgLCif4beAhYAzsddvHzkLNqIy4",
//       authDomain: "utpanna-stag-197de.firebaseapp.com",
//       projectId: "utpanna-stag-197de",
//       storageBucket: "utpanna-stag-197de.appspot.com",
//       messagingSenderId: "466091422192",
//       appId: "1:466091422192:web:416fd2d7427a88ffbbad35",
//       measurementId: "G-PVN9PR1L27"
//     ),
//   );
//   runApp(MyApp());
// }

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Utpanna Admin Panel',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: FutureBuilder<Widget>(
        future: _getInitialScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          return snapshot.data ?? LoginScreen();
        },
      ),
    );
  }

  Future<Widget> _getInitialScreen() async {
    try {
      // Check if user is logged in and session is valid
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
      final lastLoginTime = prefs.getInt('last_login_time') ?? 0;
      final currentTime = DateTime.now().millisecondsSinceEpoch;

      // Session valid for 24 hours (86400000 milliseconds)
      const sessionDuration = 86400000; // 1 day in milliseconds

      final isSessionValid =
          isLoggedIn && (currentTime - lastLoginTime) < sessionDuration;

      if (isSessionValid) {
        // Verify Firebase user is still authenticated
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          return MainAdminPanel();
        }
      }

      // Clean up invalid session data
      await prefs.setBool('is_logged_in', false);
      await prefs.remove('last_login_time');

      return LoginScreen();
    } catch (e) {
      // On error, default to login screen
      return LoginScreen();
    }
  }
}

void showToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: Duration(seconds: 2),
    ),
  );
}
