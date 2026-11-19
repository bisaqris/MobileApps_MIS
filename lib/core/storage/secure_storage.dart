import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Keys used to store auth tokens.
abstract final class StorageKeys {
  static const accessToken = 'access_token';
  static const refreshToken = 'refresh_token';
}

/// Singleton provider for [FlutterSecureStorage].
final secureStorageProvider = Provider<FlutterSecureStorage>(
  (_) => const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  ),
);
