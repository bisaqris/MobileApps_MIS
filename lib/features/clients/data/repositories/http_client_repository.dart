import 'package:dio/dio.dart';

import '../../domain/entities/client.dart';
import '../../domain/repositories/client_repository.dart';
import 'client_model.dart';

class HttpClientRepository implements ClientRepository {
  HttpClientRepository({required this.dio});

  final Dio dio;

  @override
  Future<List<Client>> fetchClients({String query = ''}) async {
    try {
      final response = await dio.get<dynamic>('/clients');
      final data = response.data;
      List<dynamic> list = const [];

      if (data is List) {
        list = data;
      } else if (data is Map && data['data'] is List) {
        list = data['data'] as List;
      }

      final items = list
          .map((item) => ClientModel.fromJson(item as Map<String, dynamic>))
          .toList();

      final q = query.trim().toLowerCase();
      if (q.isEmpty) return items;
      return items.where((c) {
        return c.name.toLowerCase().contains(q) ||
            (c.email?.toLowerCase().contains(q) ?? false) ||
            c.phone.toLowerCase().contains(q) ||
            c.companyName.toLowerCase().contains(q);
      }).toList();
    } on DioException catch (e) {
      throw Exception(
        'Gagal mengambil data client: ${e.response?.statusMessage ?? e.message}',
      );
    } catch (e) {
      throw Exception('Terjadi kesalahan tidak terduga: $e');
    }
  }

  @override
  Future<void> createClient(Client client) async {
    try {
      final model = ClientModel.fromEntity(client);
      await dio.post<dynamic>('/clients', data: model.toUpsertJson());
    } on DioException catch (e) {
      throw Exception(
        'Gagal menambah client: ${e.response?.data ?? e.message}',
      );
    }
  }

  @override
  Future<void> updateClient(Client client) async {
    try {
      final model = ClientModel.fromEntity(client);
      await dio.patch<dynamic>(
        '/clients/${client.id}',
        data: model.toUpsertJson(),
      );
    } on DioException catch (e) {
      throw Exception(
        'Gagal memperbarui client: ${e.response?.data ?? e.message}',
      );
    }
  }

  @override
  Future<void> deleteClient(String id) async {
    try {
      await dio.delete<dynamic>('/clients/$id');
    } on DioException catch (e) {
      throw Exception(
        'Gagal menghapus client: ${e.response?.data ?? e.message}',
      );
    }
  }
}

