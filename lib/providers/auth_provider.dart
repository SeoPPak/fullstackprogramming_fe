// lib/providers/auth_provider.dart
import 'dart:developer';

import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

class AuthResult {
  final bool success;
  final String? error;

  AuthResult({
    required this.success,
    this.error,
  });
}

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();

  User? _user;
  String? _token;
  bool _isLoading = false;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;

  Future<void> checkAuthStatus() async {
    final storedToken = await _authService.getStoredToken();
    if (storedToken != null) {
      _token = storedToken;
      try {
        final userProfile = await _apiService.getUserProfile();
        _user = userProfile;
        notifyListeners();
      } catch (e) {
        await logout();
      }
    }
  }

  Future<AuthResult> login(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.login(email, password);
      _user = response.user;
      _token = response.token;
      await _authService.saveToken(response.token);
      notifyListeners();

      return AuthResult(success: true);
    } catch (e) {
      return AuthResult(
        success: false,
        error: e.toString(),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<AuthResult> googleLogin() async {
    try {
      debugPrint('google login start');
      _isLoading = true;
      notifyListeners();

      final result = await _authService.googleLogin();
      _user = result.user;
      _token = result.token;

      if (_token != null) {
        await _authService.saveToken(_token!);
      }

      notifyListeners();
      return AuthResult(success: true);
    } catch (e) {
      log('eorror: $e');
      return AuthResult(
        success: false,
        error: e.toString(),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.logout();
      _user = null;
      _token = null;

    } catch (e) {
      debugPrint('Logout failed: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String nickname,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.signUp(
        email: email,
        password: password,
        nickname: nickname,
      );

      _user = response.user;
      _token = response.token;
      await _authService.saveToken(response.token);

      notifyListeners();
      return AuthResult(success: true);
    } catch (e) {
      return AuthResult(success: false, error: e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}