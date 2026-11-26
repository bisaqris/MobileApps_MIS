import '../../domain/entities/skill.dart';
import '../../domain/repositories/skill_repository.dart';

class MockSkillRepository implements SkillRepository {
  static final List<Skill> _data = <Skill>[
    Skill(
      id: 'skl-001',
      name: 'Videography',
      createdAt: DateTime(2026, 1, 10),
    ),
    Skill(
      id: 'skl-002',
      name: 'Video Editing',
      createdAt: DateTime(2026, 1, 12),
    ),
    Skill(
      id: 'skl-003',
      name: 'Live Streaming',
      createdAt: DateTime(2026, 1, 15),
    ),
    Skill(
      id: 'skl-004',
      name: 'Audio Engineering',
      createdAt: DateTime(2026, 2, 1),
    ),
    Skill(
      id: 'skl-005',
      name: 'Lighting Design',
      createdAt: DateTime(2026, 2, 5),
    ),
    Skill(
      id: 'skl-006',
      name: 'Drone Pilot',
      createdAt: DateTime(2026, 2, 14),
    ),
    Skill(
      id: 'skl-007',
      name: 'Motion Graphics',
      createdAt: DateTime(2026, 3, 2),
    ),
    Skill(
      id: 'skl-008',
      name: 'Event Direction',
      createdAt: DateTime(2026, 3, 11),
    ),
  ];

  @override
  Future<List<Skill>> fetchSkills({String query = ''}) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final q = query.trim().toLowerCase();
    final filtered = _data
        .where((s) => q.isEmpty || s.name.toLowerCase().contains(q))
        .toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return filtered;
  }

  @override
  Future<Skill> createSkill(String name) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final trimmed = name.trim();
    final exists = _data.any(
      (s) => s.name.toLowerCase() == trimmed.toLowerCase(),
    );
    if (exists) {
      throw Exception('Skill "$trimmed" sudah ada.');
    }
    final now = DateTime.now();
    final created = Skill(
      id: 'skl-${now.millisecondsSinceEpoch}',
      name: trimmed,
      createdAt: now,
      updatedAt: now,
    );
    _data.add(created);
    return created;
  }

  @override
  Future<Skill> updateSkill(String id, String name) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final trimmed = name.trim();
    final index = _data.indexWhere((s) => s.id == id);
    if (index == -1) {
      throw Exception('Skill tidak ditemukan.');
    }
    final duplicate = _data.any(
      (s) => s.id != id && s.name.toLowerCase() == trimmed.toLowerCase(),
    );
    if (duplicate) {
      throw Exception('Skill "$trimmed" sudah ada.');
    }
    final updated = _data[index].copyWith(
      name: trimmed,
      updatedAt: DateTime.now(),
    );
    _data[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteSkill(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    _data.removeWhere((s) => s.id == id);
  }
}

