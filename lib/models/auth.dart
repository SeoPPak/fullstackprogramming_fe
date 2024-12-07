import 'user.dart';

class AuthResponse {
  final User user;
  final String token;
  final String message;

  AuthResponse({
    required this.user,
    required this.token,
    required this.message,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: User.fromJson(json['user'] ?? {}),
      token: json['token'] ?? '',
      message: json['message'] ?? '',
    );
  }
}

class AuthResult {
  final bool success;
  final String? error;
  final User? user;
  final String? token;

  AuthResult({
    required this.success,
    this.error,
    this.user,
    this.token,
  });
}