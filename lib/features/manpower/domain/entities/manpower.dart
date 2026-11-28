import 'package:equatable/equatable.dart';

enum ManpowerAvailability { available, onProject }

extension ManpowerAvailabilityX on ManpowerAvailability {
  String get label {
    switch (this) {
      case ManpowerAvailability.available:
        return 'Available';
      case ManpowerAvailability.onProject:
        return 'On Project';
    }
  }

  String get apiValue {
    switch (this) {
      case ManpowerAvailability.available:
        return 'AVAILABLE';
      case ManpowerAvailability.onProject:
        return 'ON_PROJECT';
    }
  }
}

enum EmploymentStatus { fulltime, partTime, freelance, internship }

extension EmploymentStatusX on EmploymentStatus {
  String get label {
    switch (this) {
      case EmploymentStatus.fulltime:
        return 'Fulltime';
      case EmploymentStatus.partTime:
        return 'Part Time';
      case EmploymentStatus.freelance:
        return 'Freelance';
      case EmploymentStatus.internship:
        return 'Internship';
    }
  }

  String get apiValue {
    switch (this) {
      case EmploymentStatus.fulltime:
        return 'FULLTIME';
      case EmploymentStatus.partTime:
        return 'PART_TIME';
      case EmploymentStatus.freelance:
        return 'FREELANCE';
      case EmploymentStatus.internship:
        return 'INTERNSHIP';
    }
  }
}

class Manpower extends Equatable {
  const Manpower({
    required this.id,
    required this.name,
    required this.role,
    this.positionId,
    this.email,
    required this.phone,
    this.skills = const [],
    this.skillIds = const [],
    this.employmentStatus = EmploymentStatus.freelance,
    this.availability = ManpowerAvailability.available,
    this.standardRate,
    this.createdAt,
  });

  final String id;
  final String name;
  final String role;
  final String? positionId;
  final String? email;
  final String phone;
  final List<String> skills;
  final List<String> skillIds;
  final EmploymentStatus employmentStatus;
  final ManpowerAvailability availability;
  final int? standardRate;
  final DateTime? createdAt;

  String get skillsSummary => skills.isEmpty ? '-' : skills.join(', ');

  Manpower copyWith({
    String? id,
    String? name,
    String? role,
    String? positionId,
    String? email,
    String? phone,
    List<String>? skills,
    List<String>? skillIds,
    EmploymentStatus? employmentStatus,
    ManpowerAvailability? availability,
    int? standardRate,
    DateTime? createdAt,
  }) {
    return Manpower(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      positionId: positionId ?? this.positionId,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      skills: skills ?? this.skills,
      skillIds: skillIds ?? this.skillIds,
      employmentStatus: employmentStatus ?? this.employmentStatus,
      availability: availability ?? this.availability,
      standardRate: standardRate ?? this.standardRate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        role,
        positionId,
        email,
        phone,
        skills,
        skillIds,
        employmentStatus,
        availability,
        standardRate,
        createdAt,
      ];
}

