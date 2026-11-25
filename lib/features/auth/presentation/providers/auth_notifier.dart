import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/auth_repository.dart';
import '../../domain/entities/user.dart';
import 'auth_state.dart';

/// Notifier yang mengelola state autentikasi.
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier({required this.repository}) : super(const AuthState());

  final AuthRepository repository;

  /// Cek apakah user sudah punya token & data tersimpan.
  Future<void> checkAuthStatus() async {
    final token = await repository.getAccessToken();
    if (token != null && token.isNotEmpty) {
      final user = await repository.getStoredUser();
      if (user != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          clearError: true,
        );
        return;
      }
    }
    state = state.copyWith(
      status: AuthStatus.unauthenticated,
      clearError: true,
      clearUser: true,
    );
  }

  /// Login dengan email dan password.
  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final user = await repository.login(email: email, password: password);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        isLoading: false,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
        clearUser: true,
      );
    }
  }

  /// Logout – hapus token dan set status unauthenticated.
  Future<void> logout() async {
    await repository.clearTokens();
    state = state.copyWith(
      status: AuthStatus.unauthenticated,
      clearError: true,
      clearUser: true,
    );
  }

  /// Dipanggil oleh interceptor jika mendapat 401.
  void forceLogout() {
    repository.clearTokens();
    state = state.copyWith(
      status: AuthStatus.unauthenticated,
      errorMessage: 'Sesi Anda telah berakhir. Silakan login kembali.',
      clearUser: true,
    );
  }
}

/// Provider untuk [AuthNotifier].
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final notifier = AuthNotifier(repository: ref.watch(authRepositoryProvider));
  // Check stored token on startup.
  notifier.checkAuthStatus();
  return notifier;
});

/// Convenience provider: current logged-in user (nullable).
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).user;
});
