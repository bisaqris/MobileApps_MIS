/// Model yang memetakan JSON response dari POST /login.
class AuthResponse {
  const AuthResponse({
    required this.accessToken,
    required this.refreshToken,
  });

  final String accessToken;
  final String refreshToken;

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access_token'] as String? ?? json['token'] as String,
      refreshToken: json['refresh_token'] as String? ?? '',
    );
  }
}
