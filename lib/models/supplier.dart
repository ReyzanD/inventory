import 'package:uuid/uuid.dart';

class Supplier {
  final String id;
  final String name;
  final String contactName;
  final String email;
  final String phone;
  final String address;
  final String city;
  final String country;
  final String taxId; // Tax/VAT ID
  final bool isActive;
  final DateTime dateCreated;
  final DateTime? dateUpdated;

  Supplier({
    String? id,
    required this.name,
    required this.contactName,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    required this.country,
    required this.taxId,
    this.isActive = true,
    DateTime? dateCreated,
    this.dateUpdated,
  })  : id = id ?? Uuid().v4(),
        dateCreated = dateCreated ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'contactName': contactName,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'country': country,
      'taxId': taxId,
      'isActive': isActive ? 1 : 0, // Store as int for database
      'dateCreated': dateCreated.millisecondsSinceEpoch,
      'dateUpdated': dateUpdated?.millisecondsSinceEpoch,
    };
  }

  factory Supplier.fromMap(Map<String, dynamic> map) {
    return Supplier(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      contactName: map['contactName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      country: map['country'] ?? '',
      taxId: map['taxId'] ?? '',
      isActive: (map['isActive'] == 1) ?? true,
      dateCreated: DateTime.fromMillisecondsSinceEpoch(map['dateCreated'] ?? DateTime.now().millisecondsSinceEpoch),
      dateUpdated: map['dateUpdated'] != null ? DateTime.fromMillisecondsSinceEpoch(map['dateUpdated']) : null,
    );
  }

  Supplier copyWith({
    String? id,
    String? name,
    String? contactName,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? country,
    String? taxId,
    bool? isActive,
    DateTime? dateCreated,
    DateTime? dateUpdated,
  }) {
    return Supplier(
      id: id ?? this.id,
      name: name ?? this.name,
      contactName: contactName ?? this.contactName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      taxId: taxId ?? this.taxId,
      isActive: isActive ?? this.isActive,
      dateCreated: dateCreated ?? this.dateCreated,
      dateUpdated: dateUpdated ?? this.dateUpdated,
    );
  }
}