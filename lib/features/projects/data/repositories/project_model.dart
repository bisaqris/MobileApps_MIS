import 'package:mis_app/features/projects/domain/entities/project.dart';

class ProjectModel extends Project {
  const ProjectModel({
    required super.id,
    required super.name,
    required super.category,
    required super.manager,
    required super.contractValue,
    required super.eventDate,
    required super.status,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    final statusStr = json['status']?.toString().toLowerCase() ?? '';
    final status = statusStr.contains('progress')
        ? ProjectStatus.onProgress
        : ProjectStatus.newProject;
    return ProjectModel(
        id: json['id']?.toString() ?? '',
        name: json['name'] ?? json['project_name'] ?? '',
        category: json['category'] ?? '-',
        manager: json['manager'] ?? json['project_manager'] ?? '-',
        contractValue: num.tryParse(
                    (json['contract_value'] ?? json['value'] ?? 0).toString())
                ?.toInt() ??
            0,
        eventDate: json['event_date'] != null
            ? DateTime.tryParse(json['event_date'].toString()) ?? DateTime.now()
            : DateTime.now(),
        status: status);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'manager': manager,
      'contract_value': contractValue,
      'event_date': eventDate.toIso8601String(),
      'status': status.name,
    };
  }
}
