import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/providers/auth_notifier.dart';
import '../storage/secure_storage.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.ref});

  final Ref ref;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final skipPaths = ['/login', '/register', '/forgot-password'];
    if (skipPaths.any((p) => options.path.contains(p))) {
      return handler.next(options);
    }

    final storage = ref.read(secureStorageProvider);
    final token = await storage.read(key: StorageKeys.accessToken);

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      ref.read(authProvider.notifier).forceLogout();
    }
    handler.next(err);
  }
}
