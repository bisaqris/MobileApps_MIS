import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';

/// Data contoh diambil dari Figma. Ganti dengan implementasi Dio saat API siap.
class MockProjectRepository implements ProjectRepository {
  @override
  Future<List<Project>> fetchProjects({String query = ''}) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final q = query.trim().toLowerCase();
    return _data.where((p) => q.isEmpty || p.name.toLowerCase().contains(q)).toList();
  }

  static final _data = <Project>[
    Project(id: '1', name: 'Annual Summit Livestream', category: 'Event', manager: 'Anton C.', contractValue: 22000000, eventDate: DateTime(2026, 5, 21), status: ProjectStatus.newProject),
    Project(id: '2', name: 'CV Berkah Abadi', category: 'Corporate Video', manager: 'Andi K.', contractValue: 45000000, eventDate: DateTime(2026, 8, 15), status: ProjectStatus.newProject),
    Project(id: '3', name: 'PT Nusantara Film', category: 'Film Production', manager: 'Agus C.', contractValue: 95000000, eventDate: DateTime(2026, 8, 30), status: ProjectStatus.onProgress),
    Project(id: '4', name: 'The Onsen Resort', category: 'Wedding', manager: 'Budi S.', contractValue: 18000000, eventDate: DateTime(2026, 7, 10), status: ProjectStatus.onProgress),
  ];
}
