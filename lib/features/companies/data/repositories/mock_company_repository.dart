import '../../domain/entities/company.dart';
import '../../domain/repositories/company_repository.dart';

class MockCompanyRepository implements CompanyRepository {
  static final List<Company> _data = <Company>[
    Company(
      id: 'comp-001',
      name: 'PT Telkom Indonesia',
      email: 'corporate@telkom.co.id',
      phone: '(021) 5215-100',
      website: 'https://www.telkom.co.id',
      address: 'Jl. Japati No. 1, Sadang Serang',
      city: 'Bandung',
      province: 'Jawa Barat',
      clientIds: const ['cli-001'],
      clientNames: const ['Budi Santoso'],
      createdAt: DateTime(2026, 1, 8),
    ),
    Company(
      id: 'comp-002',
      name: 'CV Berkah Abadi',
      email: 'info@berkahabadi.co.id',
      phone: '(031) 5678-910',
      website: 'https://berkahabadi.co.id',
      address: 'Jl. Ahmad Yani No. 88, Gayungan',
      city: 'Surabaya',
      province: 'Jawa Timur',
      clientIds: const ['cli-002'],
      clientNames: const ['Siti Rahmawati'],
      createdAt: DateTime(2026, 1, 18),
    ),
    Company(
      id: 'comp-003',
      name: 'PT Nusantara Film',
      email: 'production@nusantarafilm.id',
      phone: '(021) 7890-234',
      website: 'https://nusantarafilm.id',
      address: 'Jl. Kemang Raya No. 45, Mampang Prapatan',
      city: 'Jakarta Selatan',
      province: 'DKI Jakarta',
      clientIds: const ['cli-003'],
      clientNames: const ['Hendra Wijaya'],
      createdAt: DateTime(2026, 2, 4),
    ),
    Company(
      id: 'comp-004',
      name: 'The Onsen Resort',
      email: 'events@theonsenresort.com',
      phone: '(0341) 510-1888',
      website: 'https://theonsenresort.com',
      address: 'Jl. Raya Arumdalu No. 98, Songgokerto',
      city: 'Batu',
      province: 'Jawa Timur',
      clientIds: const ['cli-004'],
      clientNames: const ['Clara Tanuwijaya'],
      createdAt: DateTime(2026, 2, 22),
    ),
    Company(
      id: 'comp-005',
      name: 'Universitas Brawijaya',
      email: 'humas@ub.ac.id',
      phone: '(0341) 551-611',
      website: 'https://ub.ac.id',
      address: 'Jl. Veteran, Ketawanggede, Lowokwaru',
      city: 'Malang',
      province: 'Jawa Timur',
      clientIds: const ['cli-005'],
      clientNames: const ['Dr. Arif Nugroho'],
      createdAt: DateTime(2026, 3, 10),
    ),
  ];

  @override
  Future<List<Company>> fetchCompanies({String query = ''}) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final q = query.trim().toLowerCase();
    return _data.where((c) {
      return q.isEmpty ||
          c.name.toLowerCase().contains(q) ||
          c.phone.toLowerCase().contains(q) ||
          c.address.toLowerCase().contains(q) ||
          (c.city?.toLowerCase().contains(q) ?? false) ||
          (c.email?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  @override
  Future<void> createCompany(Company company) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final created = company.copyWith(
      id: company.id.isNotEmpty
          ? company.id
          : 'comp-${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
    );
    _data.insert(0, created);
  }

  @override
  Future<void> updateCompany(Company company) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final index = _data.indexWhere((c) => c.id == company.id);
    if (index != -1) {
      _data[index] = company;
    }
  }

  @override
  Future<void> deleteCompany(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    _data.removeWhere((c) => c.id == id);
  }
}

