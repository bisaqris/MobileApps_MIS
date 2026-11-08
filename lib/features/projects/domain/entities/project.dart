import 'package:equatable/equatable.dart';

enum ProjectStatus { draft, active, onHold, completed, cancelled }

extension ProjectStatusX on ProjectStatus {
  String get label {
    switch (this) {
      case ProjectStatus.draft:
        return 'NEW';
      case ProjectStatus.active:
        return 'ON PROGRESS';
      case ProjectStatus.onHold:
        return 'ON HOLD';
      case ProjectStatus.completed:
        return 'DONE';
      case ProjectStatus.cancelled:
        return 'CANCELLED';
    }
  }

  String get apiValue {
    switch (this) {
      case ProjectStatus.draft:
        return 'DRAFT';
      case ProjectStatus.active:
        return 'ACTIVE';
      case ProjectStatus.onHold:
        return 'ON HOLD';
      case ProjectStatus.completed:
        return 'COMPLETED';
      case ProjectStatus.cancelled:
        return 'CANCELLED';
    }
  }
}

enum ProjectCategory { event, corporateVideo, filmProduction, wedding, other }

extension ProjectCategoryX on ProjectCategory {
  String get label {
    switch (this) {
      case ProjectCategory.event:
        return 'Event';
      case ProjectCategory.corporateVideo:
        return 'Corporate Video';
      case ProjectCategory.filmProduction:
        return 'Film Production';
      case ProjectCategory.wedding:
        return 'Wedding';
      case ProjectCategory.other:
        return 'Content Video/Marketing';
    }
  }

  String get apiValue {
    switch (this) {
      case ProjectCategory.event:
        return 'EVENT';
      case ProjectCategory.corporateVideo:
        return 'CORPORATE_VIDEO';
      case ProjectCategory.filmProduction:
        return 'FILM_PRODUCTION';
      case ProjectCategory.wedding:
        return 'WEDING';
      case ProjectCategory.other:
        return 'OTHER';
    }
  }
}

class Project extends Equatable {
  const Project({
    required this.id,
    required this.name,
    required this.category,
    required this.clientId,
    this.clientName = '-',
    required this.manager,
    this.projectManagerId,
    required this.contractValue,
    required this.eventDate,
    this.startDate,
    this.endDate,
    this.venue,
    this.description,
    required this.status,
  });

  final String id;
  final String name;
  final ProjectCategory category;
  final String clientId;
  final String clientName;
  final String manager;
  final String? projectManagerId;
  final int contractValue;
  final DateTime eventDate;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? venue;
  final String? description;
  final ProjectStatus status;

  @override
  List<Object?> get props => [
        id,
        name,
        category,
        clientId,
        clientName,
        manager,
        projectManagerId,
        contractValue,
        eventDate,
        startDate,
        endDate,
        venue,
        description,
        status
      ];
}
