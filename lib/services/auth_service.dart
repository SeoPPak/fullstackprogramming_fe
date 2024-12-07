import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/auth.dart';
import '../models/user.dart';
import 'api_service.dart';
import 'package:flutter/material.dart';

class AuthService {
  static const String baseUrl = 'http://10.0.2.2:5000';
  static const String tokenKey = 'jwt_token';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'https://www.googleapis.com/auth/userinfo.profile'],
    serverClientId: '974943437893-ohotc0roqcakgi26o33ubm45ng0fp08e.apps.googleusercontent.com',
  );

  // 토큰 관리 메서드
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  Future<String?> getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
  }

  // Google 로그인 구현
  Future<AuthResult> googleLogin() async {
    try {
      // 기존 로그인 상태를 초기화합니다.
      await _googleSignIn.signOut();

      // Google 로그인을 시도합니다.
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        debugPrint('사용자가 로그인을 취소했습니다.');
        return AuthResult(success: false, error: '로그인이 취소되었습니다.');
      }

      // 인증 정보를 가져옵니다.
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 디버깅을 위한 로그를 출력합니다.
      debugPrint('이메일: ${googleUser.email}');
      debugPrint('액세스 토큰: ${googleAuth.accessToken}');
      debugPrint('ID 토큰: ${googleAuth.idToken}');

      if (googleAuth.idToken == null) {
        debugPrint('ID 토큰을 가져오는데 실패했습니다.');
        return AuthResult(success: false, error: '인증 토큰 획득에 실패했습니다.');
      }

      // 서버 인증을 진행합니다.
      final response = await http.post(
        Uri.parse('$baseUrl/auth/google/verify'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'idToken': googleAuth.idToken}),
      );

      if (response.statusCode != 200) {
        debugPrint('서버 인증 실패: ${response.body}');
        return AuthResult(success: false, error: '서버 인증에 실패했습니다.');
      }

      final responseData = json.decode(response.body);
      return AuthResult(
        success: true,
        token: responseData['token'],
        user: User.fromJson(responseData['user']),
      );

    } catch (e, stackTrace) {
      debugPrint('Google 로그인 오류: $e');
      debugPrint('스택 트레이스: $stackTrace');
      return AuthResult(success: false, error: '인증 실패: $e');
    }
  }

  Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
      await removeToken();
    } catch (e) {
      debugPrint('Logout error: $e');
      throw Exception('Failed to logout');
    }
  }
}