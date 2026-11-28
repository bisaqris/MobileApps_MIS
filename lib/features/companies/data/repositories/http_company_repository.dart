import 'package:dio/dio.dart';

import '../../domain/entities/company.dart';
import '../../domain/repositories/company_repository.dart';
import 'company_model.dart';

class HttpCompanyRepository implements CompanyRepository {
  HttpCompanyRepository({required this.dio});

  final Dio dio;

  @override
  Future<List<Company>> fetchCompanies({String query = ''}) async {
    try {
      final response = await dio.get<dynamic>('/company-clients');
      final data = response.data;
      List<dynamic> list = const [];

      if (data is List) {
        list = data;
      } else if (data is Map && data['data'] is List) {
        list = data['data'] as List;
      }

      final items = list
          .map((item) => CompanyModel.fromJson(item as Map<String, dynamic>))
          .toList();

      final q = query.trim().toLowerCase();
      if (q.isEmpty) return items;
      return items.where((c) {
        return c.name.toLowerCase().contains(q) ||
            c.phone.toLowerCase().contains(q) ||
            c.address.toLowerCase().contains(q) ||
            (c.city?.toLowerCase().contains(q) ?? false) ||
            (c.email?.toLowerCase().contains(q) ?? false);
      }).toList();
    } on DioException catch (e) {
      throw Exception(
        'Gagal mengambil data perusahaan: ${e.response?.statusMessage ?? e.message}',
      );
    } catch (e) {
      throw Exception('Terjadi kesalahan tidak terduga: $e');
    }
  }

  @override
  Future<void> createCompany(Company company) async {
    try {
      final model = CompanyModel.fromEntity(company);
      await dio.post<dynamic>('/company-clients', data: model.toUpsertJson());
    } on DioException catch (e) {
      throw Exception(
        'Gagal menambah perusahaan: ${e.response?.data ?? e.message}',
      );
    }
  }

  @override
  Future<void> updateCompany(Company company) async {
    try {
      final model = CompanyModel.fromEntity(company);
      await dio.patch<dynamic>(
        '/company-clients/${company.id}',
        data: model.toUpsertJson(),
      );
    } on DioException catch (e) {
      throw Exception(
        'Gagal memperbarui perusahaan: ${e.response?.data ?? e.message}',
      );
    }
  }

  @override
  Future<void> deleteCompany(String id) async {
    try {
      await dio.delete<dynamic>('/company-clients/$id');
    } on DioException catch (e) {
      throw Exception(
        'Gagal menghapus perusahaan: ${e.response?.data ?? e.message}',
      );
    }
  }
}

