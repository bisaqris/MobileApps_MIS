import 'package:equatable/equatable.dart';

class Company extends Equatable {
  const Company({
    required this.id,
    required this.name,
    this.email,
    required this.phone,
    this.website,
    required this.address,
    this.city,
    this.province,
    this.clientIds = const [],
    this.clientNames = const [],
    this.createdAt,
  });

  final String id;
  final String name;
  final String? email;
  final String phone;
  final String? website;
  final String address;
  final String? city;
  final String? province;
  final List<String> clientIds;
  final List<String> clientNames;
  final DateTime? createdAt;

  String get fullAddress {
    final parts = <String>[
      if (address.trim().isNotEmpty) address.trim(),
      if (city != null && city!.trim().isNotEmpty) city!.trim(),
      if (province != null && province!.trim().isNotEmpty) province!.trim(),
    ];
    return parts.isEmpty ? '-' : parts.join(', ');
  }

  Company copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? website,
    String? address,
    String? city,
    String? province,
    List<String>? clientIds,
    List<String>? clientNames,
    DateTime? createdAt,
  }) {
    return Company(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      address: address ?? this.address,
      city: city ?? this.city,
      province: province ?? this.province,
      clientIds: clientIds ?? this.clientIds,
      clientNames: clientNames ?? this.clientNames,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        website,
        address,
        city,
        province,
        clientIds,
        clientNames,
        createdAt,
      ];
}

