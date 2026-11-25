import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/storage/secure_storage.dart';
import '../../domain/entities/user.dart';
import '../datasources/dummy_accounts.dart';

class AuthRepository {
  AuthRepository({required this.storage});

  final FlutterSecureStorage storage;

  Future<User> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final user = DummyAccounts.authenticate(email, password);
    if (user == null) {
      throw Exception('Email atau password salah.');
    }

    await Future.wait([
      storage.write(
        key: StorageKeys.accessToken,
        value: 'dummy_token_${user.id}_${DateTime.now().millisecondsSinceEpoch}',
      ),
      storage.write(
        key: StorageKeys.refreshToken,
        value: 'dummy_refresh_${user.id}',
      ),
      storage.write(
        key: StorageKeys.userData,
        value: jsonEncode(user.toJson()),
      ),
    ]);

    return user;
  }

  /// Ambil access token yang tersimpan.
  Future<String?> getAccessToken() =>
      storage.read(key: StorageKeys.accessToken);

  /// Ambil data user yang tersimpan.
  Future<User?> getStoredUser() async {
    final data = await storage.read(key: StorageKeys.userData);
    if (data == null) return null;
    try {
      return User.fromJson(jsonDecode(data) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// Hapus semua token dan data user (logout).
  Future<void> clearTokens() async {
    await Future.wait([
      storage.delete(key: StorageKeys.accessToken),
      storage.delete(key: StorageKeys.refreshToken),
      storage.delete(key: StorageKeys.userData),
    ]);
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    storage: ref.watch(secureStorageProvider),
  );
});
