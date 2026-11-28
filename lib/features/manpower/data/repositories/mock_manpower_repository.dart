import '../../domain/entities/manpower.dart';
import '../../domain/repositories/manpower_repository.dart';

class MockManpowerRepository implements ManpowerRepository {
  static final List<Manpower> _data = <Manpower>[
    Manpower(
      id: 'mp-001',
      name: 'Raka Pratama',
      role: 'Director of Photography',
      email: 'raka.pratama@makromedia.id',
      phone: '0812-3456-7890',
      skills: const ['Videography', 'Lighting Design'],
      skillIds: const ['skl-001', 'skl-005'],
      employmentStatus: EmploymentStatus.fulltime,
      availability: ManpowerAvailability.available,
      standardRate: 1500000,
      createdAt: DateTime(2026, 1, 15),
    ),
    Manpower(
      id: 'mp-002',
      name: 'Dimas Saputra',
      role: 'Senior Video Editor',
      email: 'dimas.saputra@makromedia.id',
      phone: '0813-9876-5432',
      skills: const ['Video Editing', 'Motion Graphics'],
      skillIds: const ['skl-002', 'skl-007'],
      employmentStatus: EmploymentStatus.fulltime,
      availability: ManpowerAvailability.onProject,
      standardRate: 1200000,
      createdAt: DateTime(2026, 1, 20),
    ),
    Manpower(
      id: 'mp-003',
      name: 'Nadia Kusuma',
      role: 'Live Broadcast Engineer',
      email: 'nadia.kusuma@gmail.com',
      phone: '0857-2233-4455',
      skills: const ['Live Streaming', 'Audio Engineering'],
      skillIds: const ['skl-003', 'skl-004'],
      employmentStatus: EmploymentStatus.freelance,
      availability: ManpowerAvailability.available,
      standardRate: 1350000,
      createdAt: DateTime(2026, 2, 3),
    ),
    Manpower(
      id: 'mp-004',
      name: 'Fajar Hidayat',
      role: 'Aerial Cinematographer',
      email: 'fajar.drone@gmail.com',
      phone: '0821-8899-1122',
      skills: const ['Drone Pilot', 'Videography'],
      skillIds: const ['skl-006', 'skl-001'],
      employmentStatus: EmploymentStatus.freelance,
      availability: ManpowerAvailability.onProject,
      standardRate: 1750000,
      createdAt: DateTime(2026, 2, 18),
    ),
    Manpower(
      id: 'mp-005',
      name: 'Ayu Lestari',
      role: 'Show Director',
      email: 'ayu.lestari@makromedia.id',
      phone: '0811-5566-7788',
      skills: const ['Event Direction', 'Live Streaming'],
      skillIds: const ['skl-008', 'skl-003'],
      employmentStatus: EmploymentStatus.partTime,
      availability: ManpowerAvailability.available,
      standardRate: 2000000,
      createdAt: DateTime(2026, 3, 5),
    ),
    Manpower(
      id: 'mp-006',
      name: 'Bagas Wicaksono',
      role: 'Soundman',
      email: 'bagas.audio@gmail.com',
      phone: '0878-3344-5566',
      skills: const ['Audio Engineering'],
      skillIds: const ['skl-004'],
      employmentStatus: EmploymentStatus.freelance,
      availability: ManpowerAvailability.onProject,
      standardRate: 1000000,
      createdAt: DateTime(2026, 3, 12),
    ),
  ];

  @override
  Future<List<Manpower>> fetchManpower({
    String query = '',
    ManpowerAvailability? availability,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final q = query.trim().toLowerCase();
    return _data.where((m) {
      final matchesQuery = q.isEmpty ||
          m.name.toLowerCase().contains(q) ||
          m.role.toLowerCase().contains(q) ||
          m.phone.toLowerCase().contains(q) ||
          (m.email?.toLowerCase().contains(q) ?? false) ||
          m.skills.any((s) => s.toLowerCase().contains(q));
      final matchesAvailability =
          availability == null || m.availability == availability;
      return matchesQuery && matchesAvailability;
    }).toList();
  }

  @override
  Future<Manpower> getManpowerById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _data.firstWhere(
      (m) => m.id == id,
      orElse: () => throw Exception('Manpower dengan ID $id tidak ditemukan.'),
    );
  }

  @override
  Future<void> createManpower(Manpower manpower) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final created = manpower.copyWith(
      id: manpower.id.isNotEmpty
          ? manpower.id
          : 'mp-${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
    );
    _data.insert(0, created);
  }

  @override
  Future<void> updateManpower(Manpower manpower) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final index = _data.indexWhere((m) => m.id == manpower.id);
    if (index != -1) {
      _data[index] = manpower;
    }
  }

  @override
  Future<void> deleteManpower(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    _data.removeWhere((m) => m.id == id);
  }
}

