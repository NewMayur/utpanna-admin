class Constants {
  // Base URL for your API
  // static const String apiUrl = 'http://127.0.0.1:8000';

  
  //dev
  // static const String apiUrl = 'http://16.16.209.148:8000';
  static const String apiUrl = 'https://utpanna-dev.serveftp.com';

  // stag
  // static const String apiUrl = 'https://utpanna-backend-stag-466091422192.asia-south1.run.app';
  
  // JWT token for authentication
  static String jwtToken = '';

  // Method to update the JWT token
  static void updateJwtToken(String newToken) {
    jwtToken = newToken;
  }

  // Other constants can be added here
  static const int timeoutDuration = 30; // in seconds
  static const String appName = 'Utpanna Admin Panel';
}
