import 'package:firebase_core/firebase_core.dart';

class FirebaseConfig {
  static Future<void> initialize({String? env}) async {
    // Environment-based configuration
    final isProduction = env == 'production' || _isProductionEnv();

    if (isProduction) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: String.fromEnvironment('FIREBASE_API_KEY',
              defaultValue: 'AIzaSyDiVSLs3goLrzmndUyLa9Sjp0gs4ovHHhA'),
          authDomain: String.fromEnvironment('FIREBASE_AUTH_DOMAIN',
              defaultValue: 'utpanna-dev.firebaseapp.com'),
          projectId: String.fromEnvironment('FIREBASE_PROJECT_ID',
              defaultValue: 'utpanna-dev'),
          storageBucket: String.fromEnvironment('FIREBASE_STORAGE_BUCKET',
              defaultValue: 'utpanna-dev.appspot.com'),
          messagingSenderId: String.fromEnvironment(
              'FIREBASE_MESSAGING_SENDER_ID',
              defaultValue: '340480522275'),
          appId: String.fromEnvironment('FIREBASE_APP_ID',
              defaultValue: '1:340480522275:web:31b799d4bd82e6398ad996'),
        ),
      );
    } else {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: String.fromEnvironment('FIREBASE_API_KEY_DEV',
              defaultValue: 'AIzaSyDiVSLs3goLrzmndUyLa9Sjp0gs4ovHHhA'),
          authDomain: String.fromEnvironment('FIREBASE_AUTH_DOMAIN_DEV',
              defaultValue: 'utpanna-dev.firebaseapp.com'),
          projectId: String.fromEnvironment('FIREBASE_PROJECT_ID_DEV',
              defaultValue: 'utpanna-dev'),
          storageBucket: String.fromEnvironment('FIREBASE_STORAGE_BUCKET_DEV',
              defaultValue: 'utpanna-dev.appspot.com'),
          messagingSenderId: String.fromEnvironment(
              'FIREBASE_MESSAGING_SENDER_ID_DEV',
              defaultValue: '340480522275'),
          appId: String.fromEnvironment('FIREBASE_APP_ID_DEV',
              defaultValue: '1:340480522275:web:31b799d4bd82e6398ad996'),
        ),
      );
    }
  }

  static bool _isProductionEnv() {
    // You can determine production from environment variables or build flags
    return const bool.fromEnvironment('dart.vm.product');
  }
}
