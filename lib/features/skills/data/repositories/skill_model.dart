import '../../domain/entities/skill.dart';

class SkillModel extends Skill {
  const SkillModel({
    required super.id,
    required super.name,
    super.createdAt,
    super.updatedAt,
  });

  factory SkillModel.fromJson(Map<String, dynamic> json) {
    return SkillModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      createdAt: _parseDate(json['createdAt'] ?? json['created_at']),
      updatedAt: _parseDate(json['updatedAt'] ?? json['updated_at']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  Map<String, dynamic> toCreateJson() => {'name': name};

  Map<String, dynamic> toUpdateJson() => {'name': name};

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      };
}

