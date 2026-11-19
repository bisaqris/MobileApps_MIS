import 'package:equatable/equatable.dart';

/// Enum untuk status autentikasi.
enum AuthStatus { unknown, authenticated, unauthenticated }

/// State object untuk autentikasi.
class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.errorMessage,
    this.isLoading = false,
  });

  final AuthStatus status;
  final String? errorMessage;
  final bool isLoading;

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    bool? isLoading,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, isLoading];
}
