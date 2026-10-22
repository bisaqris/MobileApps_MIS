import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'https://api.example.com');

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {'Accept': 'application/json'},
  ));
  // TODO: tambahkan interceptor token (Authorization) & error mapping.
  return dio;
});
