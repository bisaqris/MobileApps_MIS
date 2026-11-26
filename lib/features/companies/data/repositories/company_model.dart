import '../../domain/entities/company.dart';

class CompanyModel extends Company {
  const CompanyModel({
    required super.id,
    required super.name,
    super.email,
    required super.phone,
    super.website,
    required super.address,
    super.city,
    super.province,
    super.clientIds = const [],
    super.clientNames = const [],
    super.createdAt,
  });

  factory CompanyModel.fromEntity(Company c) {
    return CompanyModel(
      id: c.id,
      name: c.name,
      email: c.email,
      phone: c.phone,
      website: c.website,
      address: c.address,
      city: c.city,
      province: c.province,
      clientIds: c.clientIds,
      clientNames: c.clientNames,
      createdAt: c.createdAt,
    );
  }

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    final parsedClientIds = <String>[];
    final parsedClientNames = <String>[];
    if (json['clients'] is List) {
      for (final c in (json['clients'] as List)) {
        if (c is Map) {
          final cId = c['id']?.toString() ?? '';
          final cName = c['name']?.toString() ?? '';
          if (cId.isNotEmpty) parsedClientIds.add(cId);
          if (cName.isNotEmpty) parsedClientNames.add(cName);
        }
      }
    }

    final rawCreatedAt = json['createdAt'] ?? json['created_at'];
    return CompanyModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString(),
      phone: json['phone']?.toString() ?? '-',
      website: json['website']?.toString(),
      address: json['address']?.toString() ?? '',
      city: json['city']?.toString(),
      province: json['province']?.toString(),
      clientIds: parsedClientIds,
      clientNames: parsedClientNames,
      createdAt: rawCreatedAt != null
          ? DateTime.tryParse(rawCreatedAt.toString())
          : null,
    );
  }

  /// Sesuai `UpsertCompanyClientDto` di Backend_Makromedia-Integrated-System.
  Map<String, dynamic> toUpsertJson() {
    return {
      'name': name.trim(),
      if (email != null && email!.trim().isNotEmpty) 'email': email!.trim(),
      if (phone.trim().isNotEmpty) 'phone': phone.trim(),
      if (website != null && website!.trim().isNotEmpty)
        'website': website!.trim(),
      if (address.trim().isNotEmpty) 'address': address.trim(),
      if (city != null && city!.trim().isNotEmpty) 'city': city!.trim(),
      if (province != null && province!.trim().isNotEmpty)
        'province': province!.trim(),
    };
  }
}

