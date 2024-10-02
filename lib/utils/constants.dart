class Constants {
  // Base URL for your API
  static const String apiUrl = 'http://127.0.0.1:8080';
  // static const String apiUrl = 'https://utpanna-backend-340480522275.us-central1.run.app';

  // JWT token for authentication
  // Note: In a real app, this should be stored securely and updated dynamically
  static String jwtToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJmcmVzaCI6ZmFsc2UsImlhdCI6MTcyNDUzODEzNiwianRpIjoiNGVlMjM0NTEtNzEwNy00MjAwLWIyNDItNGQ4MWMxNGMyMWU3IiwidHlwZSI6ImFjY2VzcyIsInN1YiI6MSwibmJmIjoxNzI0NTM4MTM2LCJjc3JmIjoiNjE3MmVmNDgtYjhkZC00YTcwLTk0MjUtNDkzYzc0ZjE1OTQ3IiwiZXhwIjoxNzI0NTM5MDM2fQ.54LArtY-Nka_4kgyoNcKNuQGT0thtrzuuL03ZsYsNWc';

  // Method to update the JWT token
  static void updateJwtToken(String newToken) {
    jwtToken = newToken;
  }

  // Other constants can be added here
  static const int timeoutDuration = 30; // in seconds
  static const String appName = 'utpanna';
}
