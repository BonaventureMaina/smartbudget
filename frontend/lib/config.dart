import 'package:flutter/foundation.dart';

String get baseUrl {
  if (kIsWeb) {
    return 'https://smartbudget-api-m4q6.onrender.com';
  } else {
    // Android emulator
    return 'http://10.0.2.2:8000';
  }
}
