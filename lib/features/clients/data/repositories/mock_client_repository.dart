import '../../domain/entities/client.dart';
import '../../domain/repositories/client_repository.dart';

class MockClientRepository implements ClientRepository {
  static final List<Client> _data = <Client>[
    Client(
      id: 'cli-001',
      companyClientId: 'comp-001',
      companyName: 'PT Telkom Indonesia',
      name: 'Budi Santoso',
      email: 'budi.santoso@telkom.co.id',
      phone: '0812-8800-1122',
      address: 'Jl. Japati No. 1, Sadang Serang',
      city: 'Bandung',
      createdAt: DateTime(2026, 1, 9),
    ),
    Client(
      id: 'cli-002',
      companyClientId: 'comp-002',
      companyName: 'CV Berkah Abadi',
      name: 'Siti Rahmawati',
      email: 'siti.rahma@berkahabadi.co.id',
      phone: '0813-4455-6677',
      address: 'Jl. Ahmad Yani No. 88, Gayungan',
      city: 'Surabaya',
      createdAt: DateTime(2026, 1, 19),
    ),
    Client(
      id: 'cli-003',
      companyClientId: 'comp-003',
      companyName: 'PT Nusantara Film',
      name: 'Hendra Wijaya',
      email: 'hendra@nusantarafilm.id',
      phone: '0811-7788-9900',
      address: 'Jl. Kemang Raya No. 45, Mampang Prapatan',
      city: 'Jakarta Selatan',
      createdAt: DateTime(2026, 2, 5),
    ),
    Client(
      id: 'cli-004',
      companyClientId: 'comp-004',
      companyName: 'The Onsen Resort',
      name: 'Clara Tanuwijaya',
      email: 'clara@theonsenresort.com',
      phone: '0822-3311-5544',
      address: 'Jl. Raya Arumdalu No. 98, Songgokerto',
      city: 'Batu',
      createdAt: DateTime(2026, 2, 23),
    ),
    Client(
      id: 'cli-005',
      companyClientId: 'comp-005',
      companyName: 'Universitas Brawijaya',
      name: 'Dr. Arif Nugroho',
      email: 'arif.nugroho@ub.ac.id',
      phone: '0856-9900-4433',
      address: 'Jl. Veteran, Ketawanggede',
      city: 'Malang',
      createdAt: DateTime(2026, 3, 11),
    ),
  ];

  @override
  Future<List<Client>> fetchClients({String query = ''}) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final q = query.trim().toLowerCase();
    return _data.where((c) {
      return q.isEmpty ||
          c.name.toLowerCase().contains(q) ||
          (c.email?.toLowerCase().contains(q) ?? false) ||
          c.phone.toLowerCase().contains(q) ||
          c.companyName.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Future<void> createClient(Client client) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final created = client.copyWith(
      id: client.id.isNotEmpty
          ? client.id
          : 'cli-${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
    );
    _data.insert(0, created);
  }

  @override
  Future<void> updateClient(Client client) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final index = _data.indexWhere((c) => c.id == client.id);
    if (index != -1) {
      _data[index] = client;
    }
  }

  @override
  Future<void> deleteClient(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    _data.removeWhere((c) => c.id == id);
  }
}

