import 'package:equatable/equatable.dart';

enum ProjectStatus { newProject, onProgress }

class Project extends Equatable {
  const Project({
    required this.id,
    required this.name,
    required this.category,
    required this.manager,
    required this.contractValue,
    required this.eventDate,
    required this.status,
  });

  final String id;
  final String name;
  final String category;
  final String manager;
  final int contractValue;
  final DateTime eventDate;
  final ProjectStatus status;

  @override
  List<Object?> get props => [id, name, category, manager, contractValue, eventDate, status];
}
