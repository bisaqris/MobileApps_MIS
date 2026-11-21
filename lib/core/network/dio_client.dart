import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _baseUrl = String.fromEnvironment('API_BASE_URL',
    defaultValue: 'http://localhost:4000/api/v1');

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {'Accept': 'application/json'},
  ));
  dio.interceptors
      .add(InterceptorsWrapper(onRequest: ((options, handler) async {
    const demoToken =
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI3NzdlOTA4Yy0wYjc1LTRmNzMtOTE1Yy04ZWQ1NmVkNDZiZGIiLCJlbWFpbCI6ImRpcmVrdHVyQG1ha3JvbWVkaWEuaWQiLCJyb2xlIjoiRElSRUtUVVIiLCJ0diI6MCwiaWF0IjoxNzk1MjU0OTM4LCJleHAiOjE3OTUzNDEzMzh9.qL1TOvb0TXsSf21YpfRYLH73px0G8MiYKSuMuDTGvKY';
    options.headers['Authorization'] = 'Bearer $demoToken';
    return handler.next(options);
  }), onError: (DioException e, handler) {
    debugPrint(
        '[Dio Error] ${e.requestOptions.path}: ${e.response?.statusCode} -> ${e.response?.data}');
    return handler.next(e);
  }));
  return dio;
});
