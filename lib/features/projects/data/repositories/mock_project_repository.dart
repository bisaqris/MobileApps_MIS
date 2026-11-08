import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';

class MockProjectRepository implements ProjectRepository {
  @override
  Future<List<Project>> fetchProjects({String query = ''}) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final q = query.trim().toLowerCase();
    return _data
        .where((p) => q.isEmpty || p.name.toLowerCase().contains(q))
        .toList();
  }

  static final _data = <Project>[
    Project(
      id: '1',
      name: 'Annual Summit Livestream',
      category: ProjectCategory.event,
      clientId: 'cli-001',
      clientName: 'PT Telkom Indonesia',
      manager: 'Anton C.',
      contractValue: 22000000,
      eventDate: DateTime(2026, 5, 21),
      status: ProjectStatus.draft,
    ),
    Project(
      id: '2',
      name: 'Company Profile Video',
      category: ProjectCategory.corporateVideo,
      clientId: 'cli-002',
      clientName: 'CV Berkah Abadi',
      manager: 'Andi K.',
      contractValue: 45000000,
      eventDate: DateTime(2026, 8, 15),
      status: ProjectStatus.draft,
    ),
    Project(
      id: '3',
      name: 'Dokumenter Sejarah Budaya',
      category: ProjectCategory.filmProduction,
      clientId: 'cli-003',
      clientName: 'PT Nusantara Film',
      manager: 'Agus C.',
      contractValue: 95000000,
      eventDate: DateTime(2026, 8, 30),
      status: ProjectStatus.active,
    ),
    Project(
      id: '4',
      name: 'The Onsen Resort Wedding',
      category: ProjectCategory.wedding,
      clientId: 'cli-004',
      clientName: 'The Onsen Resort',
      manager: 'Budi S.',
      contractValue: 18000000,
      eventDate: DateTime(2026, 7, 10),
      status: ProjectStatus.completed,
    ),
  ];

  @override
  Future<void> createProject(Project project) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final newProject = Project(
      id: project.id.isNotEmpty
          ? project.id
          : DateTime.now().millisecondsSinceEpoch.toString(),
      name: project.name,
      category: project.category,
      clientId: project.clientId.isNotEmpty ? project.clientId : 'cli-mock',
      clientName: project.clientName.isNotEmpty ? project.clientName : 'Client Mock',
      manager: project.manager,
      contractValue: project.contractValue,
      eventDate: project.eventDate,
      status: project.status,
    );
    _data.insert(0, newProject);
  }

  @override
  Future<void> updateProject(Project project) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final index = _data.indexWhere((p) => p.id == project.id);
    if (index != -1) {
      _data[index] = project;
    }
  }

  @override
  Future<void> deleteProject(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _data.removeWhere((p) => p.id == id);
  }
}