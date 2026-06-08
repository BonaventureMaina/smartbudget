import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _loading = false;

  User? get user => _user;
  bool get loading => _loading;
  bool get isAuthenticated => _user != null;

  Future<void> tryAutoLogin() async {
    final token = await _authService.getToken();
    if (token != null) {
      try {
        _user = await _authService.fetchMe();
        notifyListeners();
      } catch (_) {
        await _authService.logout();
      }
    }
  }

  Future<void> login(String username, String password) async {
    _loading = true;
    notifyListeners();
    try {
      await _authService.login(username, password);
      _user = await _authService.fetchMe();
      notifyListeners();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> register(String username, String email, String password) async {
    _loading = true;
    notifyListeners();
    try {
      // Create the account but do NOT set _user yet
      await _authService.register(username, email, password);
      // Now log in — this sets the token and _user atomically
      await login(username, password);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }
}
