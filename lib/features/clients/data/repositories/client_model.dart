import '../../domain/entities/client.dart';

class ClientModel extends Client {
  const ClientModel({
    required super.id,
    required super.companyClientId,
    super.companyName = '-',
    required super.name,
    super.email,
    required super.phone,
    super.address,
    super.city,
    super.createdAt,
  });

  factory ClientModel.fromEntity(Client c) {
    return ClientModel(
      id: c.id,
      companyClientId: c.companyClientId,
      companyName: c.companyName,
      name: c.name,
      email: c.email,
      phone: c.phone,
      address: c.address,
      city: c.city,
      createdAt: c.createdAt,
    );
  }

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    String companyName = '-';
    if (json['company'] is Map && json['company']['name'] != null) {
      companyName = json['company']['name'].toString();
    } else if (json['companyName'] != null || json['company_name'] != null) {
      companyName = (json['companyName'] ?? json['company_name']).toString();
    }

    final rawCreatedAt = json['createdAt'] ?? json['created_at'];
    return ClientModel(
      id: json['id']?.toString() ?? '',
      companyClientId:
          (json['companyClientId'] ?? json['company_client_id'] ?? '')
              .toString(),
      companyName: companyName,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString(),
      phone: json['phone']?.toString() ?? '-',
      address: json['address']?.toString(),
      city: json['city']?.toString(),
      createdAt: rawCreatedAt != null
          ? DateTime.tryParse(rawCreatedAt.toString())
          : null,
    );
  }

  /// Sesuai `UpsertClientDto` di Backend_Makromedia-Integrated-System.
  Map<String, dynamic> toUpsertJson() {
    return {
      'companyClientId': companyClientId,
      'name': name.trim(),
      if (email != null && email!.trim().isNotEmpty) 'email': email!.trim(),
      if (phone.trim().isNotEmpty) 'phone': phone.trim(),
      if (address != null && address!.trim().isNotEmpty)
        'address': address!.trim(),
      if (city != null && city!.trim().isNotEmpty) 'city': city!.trim(),
    };
  }
}

