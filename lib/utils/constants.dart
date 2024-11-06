class Constants {
  // Base URL for your API
  // static const String apiUrl = 'http://127.0.0.1:8080';
  // static const String apiUrl = 'http://192.168.131.147:8080';  //win-dev-local
  // static const String apiUrl = 'http://192.168.131.92:8080';
  static const String apiUrl = 'https://utpanna-dev-backend-340480522275.asia-south1.run.app';
  // stag
  // static const String apiUrl = 'https://utpanna-backend-stag-466091422192.asia-south1.run.app';
  // JWT token for authentication
  // Note: In a real app, this should be stored securely and updated dynamically
  static String jwtToken = '';

  // Method to update the JWT token
  static void updateJwtToken(String newToken) {
    jwtToken = newToken;
  }

  // Other constants can be added here
  static const int timeoutDuration = 30; // in seconds
  static const String appName = 'Utpanna Admin Panel';
}
