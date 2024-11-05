import 'package:flutter/material.dart';
import 'package:utpanna_admin/screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';

//dev
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyDiVSLs3goLrzmndUyLa9Sjp0gs4ovHHhA",
      authDomain: "utpanna-dev.firebaseapp.com",
      projectId: "utpanna-dev",
      storageBucket: "utpanna-dev.appspot.com",
      messagingSenderId: "340480522275",
      appId: "1:340480522275:web:31b799d4bd82e6398ad996"
    ),
  );
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
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(),
    );
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