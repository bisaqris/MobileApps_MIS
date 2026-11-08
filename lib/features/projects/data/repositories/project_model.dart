import 'package:mis_app/features/projects/domain/entities/project.dart';

class ProjectModel extends Project {
  const ProjectModel({
    required super.id,
    required super.name,
    required super.category,
    required super.clientId,
    super.clientName = '-',
    required super.manager,
    super.projectManagerId,
    required super.contractValue,
    required super.eventDate,
    super.startDate,
    super.endDate,
    super.venue,
    super.description,
    required super.status,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    final rawStatus = (json['status'] ?? '').toString().toUpperCase();
    ProjectStatus status;

    switch (rawStatus) {
      case 'ACTIVE':
      case 'IN_PROGRESS':
      case 'ONPROGRESS':
        status = ProjectStatus.active;
        break;
      case 'COMPLETED':
      case 'DONE':
        status = ProjectStatus.completed;
        break;
      case 'ON_HOLD':
        status = ProjectStatus.onHold;
        break;
      case 'CANCELLED':
        status = ProjectStatus.cancelled;
        break;
      case 'DRAFT':
      case 'NEWPROJECT':
      default:
        status = ProjectStatus.draft;
        break;
    }

    final rawCat = (json['category'] ?? '').toString().toUpperCase();
    ProjectCategory category;
    if (rawCat.contains('CORPORATE')) {
      category = ProjectCategory.corporateVideo;
    } else if (rawCat.contains('FILM')) {
      category = ProjectCategory.filmProduction;
    } else if (rawCat.contains('WEDDING')) {
      category = ProjectCategory.wedding;
    } else if (rawCat.contains('OTHER') ||
        rawCat.contains('CONTENT') ||
        rawCat.contains('MARKETING')) {
      category = ProjectCategory.other;
    } else {
      category = ProjectCategory.event;
    }

    String clientId = (json['clientId'] ?? json['client_id'] ?? '').toString();
    String clientName = '-';

    if (json['client'] is Map) {
      final clientMap = json['client'] as Map<String, dynamic>;
      if (clientMap['company'] is Map && clientMap['company']['name'] != null) {
        clientName = clientMap['company']['name'].toString();
      } else if (clientMap['name'] != null) {
        clientName = clientMap['name'].toString();
      }
    } else if (json['client_name'] != null || json['clientName'] != null) {
      clientName = (json['client_name'] ?? json['clientName']).toString();
    }

    String manager = '-';
    String? pmId = json['projectManagerId'] ?? json['project_manager_id'];
    if (json['projectManager'] is Map &&
        json['projectManager']['name'] != null) {
      manager = json['projectManager']['name'].toString();
    } else if (json['manager'] != null || json['project_manager'] != null) {
      manager = (json['manager'] ?? json['project_manager']).toString();
    }

    final numVal = num.tryParse((json['contractValue'] ??
                json['contract_value'] ??
                json['value'] ??
                0)
            .toString()) ??
        0;

    final eventDate = json['eventDate'] != null || json['event_date'] != null
        ? DateTime.tryParse(
                (json['eventDate'] ?? json['event_date']).toString()) ??
            DateTime.now()
        : DateTime.now();

    final startDate = json['startDate'] != null || json['start_date'] != null
        ? DateTime.tryParse(
            (json['startDate'] ?? json['start_date']).toString())
        : null;

    final endDate = json['endDate'] != null || json['end_date'] != null
        ? DateTime.tryParse((json['endDate'] ?? json['end_date']).toString())
        : null;

    return ProjectModel(
        id: json['id']?.toString() ?? '',
        name: json['name'] ?? json['project_name'] ?? '',
        category: category,
        clientId: clientId,
        clientName: clientName,
        manager: manager,
        projectManagerId: pmId,
        contractValue: numVal.toInt(),
        eventDate: eventDate,
        startDate: startDate,
        endDate: endDate,
        venue: json['venue']?.toString(),
        description: (json['description'] ?? json['generalBrief'])?.toString(),
        status: status);
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'name': name,
      'category': category.apiValue,
      'clientId': clientId.isNotEmpty
          ? clientId
          : 'd290f1ee-6c54-4b01-90e6-d701748f0851',
      if (projectManagerId != null && projectManagerId!.isNotEmpty)
        'projectManagerId': projectManagerId,
      'contractValue': contractValue,
      'eventDate': eventDate..toIso8601String().split('T').first,
      if (startDate != null)
        'startDate': startDate!.toIso8601String().split('T').first,
      if (endDate != null)
        'endDate': endDate!.toIso8601String().split('T').first,
      if (venue != null && venue!.isNotEmpty) 'venue': venue,
      if (description != null && description!.isNotEmpty)
        'description': description,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'name': name,
      'category': category.apiValue,
      'contractValue': contractValue,
      'eventDate': eventDate.toIso8601String().split('T').first,
      'status': status.apiValue,
      if (venue != null && venue!.isNotEmpty) 'venue': venue,
      if (description != null && description!.isNotEmpty)
        'description': description
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category.apiValue,
      'clientId': clientId,
      'clientName': clientName,
      'manager': manager,
      'projectManagerId': projectManagerId,
      'contractValue': contractValue,
      'eventDate': eventDate.toIso8601String(),
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'venue': venue,
      'description': description,
      'status': status.apiValue,
    };
  }
}
