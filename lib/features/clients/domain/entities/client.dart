import 'package:equatable/equatable.dart';

class Client extends Equatable {
  const Client({
    required this.id,
    required this.companyClientId,
    this.companyName = '-',
    required this.name,
    this.email,
    required this.phone,
    this.address,
    this.city,
    this.createdAt,
  });

  final String id;
  final String companyClientId;
  final String companyName;
  final String name;
  final String? email;
  final String phone;
  final String? address;
  final String? city;
  final DateTime? createdAt;

  Client copyWith({
    String? id,
    String? companyClientId,
    String? companyName,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? city,
    DateTime? createdAt,
  }) {
    return Client(
      id: id ?? this.id,
      companyClientId: companyClientId ?? this.companyClientId,
      companyName: companyName ?? this.companyName,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        companyClientId,
        companyName,
        name,
        email,
        phone,
        address,
        city,
        createdAt,
      ];
}

