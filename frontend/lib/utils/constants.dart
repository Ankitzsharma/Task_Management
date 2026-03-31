import 'package:flutter/foundation.dart';

class AppConstants {
  static String get baseUrl {
    if (kIsWeb) {
      return "http://localhost:8000";
    }
    // For Android emulator, use 10.0.2.2.
    // For iOS simulator or physical devices, you might need your machine's local IP.
    return "http://10.0.2.2:8000";
  }
}
