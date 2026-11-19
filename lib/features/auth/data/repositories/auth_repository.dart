import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/secure_storage.dart';
import '../models/auth_response.dart';

/// Repository yang menangani komunikasi dengan API auth.
class AuthRepository {
  AuthRepository({required this.dio, required this.storage});

  final Dio dio;
  final FlutterSecureStorage storage;

  /// Login via POST /login. Simpan token jika berhasil.
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await dio.post(
      '/login',
      data: {'email': email, 'password': password},
    );

    final authResponse = AuthResponse.fromJson(
      response.data as Map<String, dynamic>,
    );

    // Persist tokens ke secure storage.
    await Future.wait([
      storage.write(
        key: StorageKeys.accessToken,
        value: authResponse.accessToken,
      ),
      storage.write(
        key: StorageKeys.refreshToken,
        value: authResponse.refreshToken,
      ),
    ]);

    return authResponse;
  }

  /// Ambil access token yang tersimpan.
  Future<String?> getAccessToken() =>
      storage.read(key: StorageKeys.accessToken);

  /// Ambil refresh token yang tersimpan.
  Future<String?> getRefreshToken() =>
      storage.read(key: StorageKeys.refreshToken);

  /// Hapus semua token (logout).
  Future<void> clearTokens() async {
    await Future.wait([
      storage.delete(key: StorageKeys.accessToken),
      storage.delete(key: StorageKeys.refreshToken),
    ]);
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    dio: ref.watch(dioProvider),
    storage: ref.watch(secureStorageProvider),
  );
});
