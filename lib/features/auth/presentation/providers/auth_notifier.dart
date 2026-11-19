import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/auth_repository.dart';
import 'auth_state.dart';

/// Notifier yang mengelola state autentikasi.
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier({required this.repository}) : super(const AuthState());

  final AuthRepository repository;

  /// Cek apakah user sudah punya token tersimpan.
  Future<void> checkAuthStatus() async {
    final token = await repository.getAccessToken();
    if (token != null && token.isNotEmpty) {
      state = state.copyWith(status: AuthStatus.authenticated, clearError: true);
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated, clearError: true);
    }
  }

  /// Login dengan email dan password.
  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await repository.login(email: email, password: password);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        isLoading: false,
        clearError: true,
      );
    } on DioException catch (e) {
      final message = _extractErrorMessage(e);
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        isLoading: false,
        errorMessage: message,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        isLoading: false,
        errorMessage: 'Terjadi kesalahan. Silakan coba lagi.',
      );
    }
  }

  /// Logout – hapus token dan set status unauthenticated.
  Future<void> logout() async {
    await repository.clearTokens();
    state = state.copyWith(
      status: AuthStatus.unauthenticated,
      clearError: true,
    );
  }

  /// Dipanggil oleh interceptor jika mendapat 401.
  void forceLogout() {
    repository.clearTokens();
    state = state.copyWith(
      status: AuthStatus.unauthenticated,
      errorMessage: 'Sesi Anda telah berakhir. Silakan login kembali.',
    );
  }

  /// Extract pesan error dari DioException.
  String _extractErrorMessage(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map<String, dynamic>) {
        return data['message'] as String? ?? 'Email atau password salah.';
      }
      if (e.response!.statusCode == 401) {
        return 'Email atau password salah.';
      }
      if (e.response!.statusCode == 422) {
        return 'Data yang dikirim tidak valid.';
      }
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Koneksi timeout. Periksa jaringan Anda.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Tidak dapat terhubung ke server.';
    }
    return 'Terjadi kesalahan. Silakan coba lagi.';
  }
}

/// Provider untuk [AuthNotifier].
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final notifier = AuthNotifier(repository: ref.watch(authRepositoryProvider));
  // Check stored token on startup.
  notifier.checkAuthStatus();
  return notifier;
});
