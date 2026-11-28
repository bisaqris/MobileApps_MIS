import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/repositories/http_skill_repository.dart';
import '../../data/repositories/mock_skill_repository.dart';
import '../../domain/entities/skill.dart';
import '../../domain/repositories/skill_repository.dart';

// Set ke 'false' jika URL backend sudah aktif kembali
const bool _useMockData = false;

final skillRepositoryProvider = Provider<SkillRepository>((ref) {
  if (_useMockData) {
    return MockSkillRepository();
  }
  final dio = ref.watch(dioProvider);
  return HttpSkillRepository(dio: dio);
});

final skillSearchProvider = StateProvider<String>((ref) => '');

final skillsProvider = FutureProvider.autoDispose<List<Skill>>((ref) {
  final query = ref.watch(skillSearchProvider);
  return ref.watch(skillRepositoryProvider).fetchSkills(query: query);
});

final allSkillsProvider = FutureProvider.autoDispose<List<Skill>>((ref) {
  return ref.watch(skillRepositoryProvider).fetchSkills();
});

final skillControllerProvider =
    StateNotifierProvider<SkillController, AsyncValue<void>>((ref) {
  return SkillController(ref);
});

class SkillController extends StateNotifier<AsyncValue<void>> {
  SkillController(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  Future<bool> createSkill(String name) async {
    state = const AsyncValue.loading();
    try {
      await _ref.read(skillRepositoryProvider).createSkill(name);
      state = const AsyncValue.data(null);
      _ref.invalidate(skillsProvider);
      _ref.invalidate(allSkillsProvider);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> updateSkill(String id, String name) async {
    state = const AsyncValue.loading();
    try {
      await _ref.read(skillRepositoryProvider).updateSkill(id, name);
      state = const AsyncValue.data(null);
      _ref.invalidate(skillsProvider);
      _ref.invalidate(allSkillsProvider);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> deleteSkill(String id) async {
    state = const AsyncValue.loading();
    try {
      await _ref.read(skillRepositoryProvider).deleteSkill(id);
      state = const AsyncValue.data(null);
      _ref.invalidate(skillsProvider);
      _ref.invalidate(allSkillsProvider);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

