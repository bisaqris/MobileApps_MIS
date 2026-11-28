import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/repositories/http_company_repository.dart';
import '../../data/repositories/mock_company_repository.dart';
import '../../domain/entities/company.dart';
import '../../domain/repositories/company_repository.dart';

// Set ke 'false' jika URL backend sudah aktif kembali
const bool _useMockData = false;

final companyRepositoryProvider = Provider<CompanyRepository>((ref) {
  if (_useMockData) {
    return MockCompanyRepository();
  }
  final dio = ref.watch(dioProvider);
  return HttpCompanyRepository(dio: dio);
});

final companySearchProvider = StateProvider<String>((ref) => '');

final companiesProvider = FutureProvider.autoDispose<List<Company>>((ref) {
  final query = ref.watch(companySearchProvider);
  return ref.watch(companyRepositoryProvider).fetchCompanies(query: query);
});

final allCompaniesProvider = FutureProvider.autoDispose<List<Company>>((ref) {
  return ref.watch(companyRepositoryProvider).fetchCompanies();
});

final companyControllerProvider =
    StateNotifierProvider<CompanyController, AsyncValue<void>>((ref) {
  return CompanyController(ref);
});

class CompanyController extends StateNotifier<AsyncValue<void>> {
  CompanyController(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  Future<bool> createCompany(Company company) async {
    state = const AsyncValue.loading();
    try {
      await _ref.read(companyRepositoryProvider).createCompany(company);
      state = const AsyncValue.data(null);
      _ref.invalidate(companiesProvider);
      _ref.invalidate(allCompaniesProvider);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> updateCompany(Company company) async {
    state = const AsyncValue.loading();
    try {
      await _ref.read(companyRepositoryProvider).updateCompany(company);
      state = const AsyncValue.data(null);
      _ref.invalidate(companiesProvider);
      _ref.invalidate(allCompaniesProvider);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> deleteCompany(String id) async {
    state = const AsyncValue.loading();
    try {
      await _ref.read(companyRepositoryProvider).deleteCompany(id);
      state = const AsyncValue.data(null);
      _ref.invalidate(companiesProvider);
      _ref.invalidate(allCompaniesProvider);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

