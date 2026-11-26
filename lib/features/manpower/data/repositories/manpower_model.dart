import '../../domain/entities/manpower.dart';

class ManpowerModel extends Manpower {
  const ManpowerModel({
    required super.id,
    required super.name,
    required super.role,
    super.positionId,
    super.email,
    required super.phone,
    super.skills = const [],
    super.skillIds = const [],
    super.employmentStatus = EmploymentStatus.freelance,
    super.availability = ManpowerAvailability.available,
    super.standardRate,
    super.createdAt,
  });

  factory ManpowerModel.fromEntity(Manpower m) {
    return ManpowerModel(
      id: m.id,
      name: m.name,
      role: m.role,
      positionId: m.positionId,
      email: m.email,
      phone: m.phone,
      skills: m.skills,
      skillIds: m.skillIds,
      employmentStatus: m.employmentStatus,
      availability: m.availability,
      standardRate: m.standardRate,
      createdAt: m.createdAt,
    );
  }

  factory ManpowerModel.fromJson(Map<String, dynamic> json) {
    String role = '-';
    if (json['positionRef'] is Map && json['positionRef']['name'] != null) {
      role = json['positionRef']['name'].toString();
    } else if (json['position'] != null &&
        json['position'].toString().trim().isNotEmpty) {
      role = json['position'].toString();
    } else if (json['role'] != null &&
        json['role'].toString().trim().isNotEmpty) {
      role = json['role'].toString();
    }

    final parsedSkills = <String>[];
    final parsedSkillIds = <String>[];
    if (json['skills'] is List) {
      for (final entry in (json['skills'] as List)) {
        if (entry is Map) {
          if (entry['skill'] is Map) {
            final skillMap = entry['skill'] as Map;
            final sName = skillMap['name']?.toString().trim() ?? '';
            final sId = skillMap['id']?.toString().trim() ?? '';
            if (sName.isNotEmpty) parsedSkills.add(sName);
            if (sId.isNotEmpty) parsedSkillIds.add(sId);
          } else if (entry['name'] != null) {
            final sName = entry['name'].toString().trim();
            final sId = entry['id']?.toString().trim() ?? '';
            if (sName.isNotEmpty) parsedSkills.add(sName);
            if (sId.isNotEmpty) parsedSkillIds.add(sId);
          }
        } else if (entry is String && entry.trim().isNotEmpty) {
          parsedSkills.add(entry.trim());
        }
      }
    }

    if (parsedSkills.isEmpty && json['skill'] is String) {
      final rawSkill = (json['skill'] as String).trim();
      if (rawSkill.isNotEmpty) {
        parsedSkills.addAll(
          rawSkill
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty),
        );
      }
    }

    final rawEmployment =
        (json['employmentStatus'] ?? json['employment_status'] ?? '')
            .toString()
            .toUpperCase();
    final employmentStatus = switch (rawEmployment) {
      'FULLTIME' || 'FULL_TIME' => EmploymentStatus.fulltime,
      'PART_TIME' || 'PARTTIME' => EmploymentStatus.partTime,
      'INTERNSHIP' || 'INTERN' => EmploymentStatus.internship,
      _ => EmploymentStatus.freelance,
    };

    final availability = _parseAvailability(json);

    final rawRate = json['standardRate'] ?? json['standard_rate'];
    final standardRate =
        rawRate != null ? num.tryParse(rawRate.toString())?.toInt() : null;

    final rawCreatedAt = json['createdAt'] ?? json['created_at'];
    final createdAt =
        rawCreatedAt != null ? DateTime.tryParse(rawCreatedAt.toString()) : null;

    return ManpowerModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      role: role,
      positionId: (json['positionId'] ?? json['position_id'])?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString() ?? '-',
      skills: parsedSkills,
      skillIds: parsedSkillIds,
      employmentStatus: employmentStatus,
      availability: availability,
      standardRate: standardRate,
      createdAt: createdAt,
    );
  }

  static ManpowerAvailability _parseAvailability(Map<String, dynamic> json) {
    final rawAvail =
        (json['availability'] ?? json['availabilityStatus'] ?? '')
            .toString()
            .toUpperCase();
    if (rawAvail == 'ON_PROJECT' || rawAvail == 'BUSY' || rawAvail == 'ASSIGNED') {
      return ManpowerAvailability.onProject;
    }
    if (rawAvail == 'AVAILABLE') {
      return ManpowerAvailability.available;
    }
    if (json['isAvailable'] is bool) {
      return (json['isAvailable'] as bool)
          ? ManpowerAvailability.available
          : ManpowerAvailability.onProject;
    }
    final activeCount = int.tryParse(
          (json['activeProjectCount'] ?? json['active_project_count'] ?? '0')
              .toString(),
        ) ??
        0;
    if (activeCount > 0) {
      return ManpowerAvailability.onProject;
    }
    return ManpowerAvailability.available;
  }

  /// Sesuai `UpsertManpowerDto` di Backend_Makromedia-Integrated-System.
  Map<String, dynamic> toUpsertJson() {
    return {
      'name': name.trim(),
      if (role.trim().isNotEmpty) 'position': role.trim(),
      if (positionId != null && positionId!.isNotEmpty)
        'positionId': positionId,
      if (email != null && email!.trim().isNotEmpty) 'email': email!.trim(),
      if (phone.trim().isNotEmpty) 'phone': phone.trim(),
      if (skills.isNotEmpty) 'skill': skills.join(', '),
      'employmentStatus': employmentStatus.apiValue,
      if (standardRate != null && standardRate! >= 0)
        'standardRate': standardRate,
    };
  }
}

