import '../entities/skill.dart';

abstract interface class SkillRepository {
  Future<List<Skill>> fetchSkills({String query = ''});
  Future<Skill> createSkill(String name);
  Future<Skill> updateSkill(String id, String name);
  Future<void> deleteSkill(String id);
}

