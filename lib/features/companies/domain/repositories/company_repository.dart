import '../entities/company.dart';

abstract interface class CompanyRepository {
  Future<List<Company>> fetchCompanies({String query = ''});
  Future<void> createCompany(Company company);
  Future<void> updateCompany(Company company);
  Future<void> deleteCompany(String id);
}

