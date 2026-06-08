import 'package:flutter/foundation.dart';

String get baseUrl {
  if (kIsWeb) {
    return 'http://localhost:8000';
  } else {
    // Android emulator
    return 'http://10.0.2.2:8000';
  }
}
