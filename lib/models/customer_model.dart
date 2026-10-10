class Customer {
  final String id;
  final String customerId; // ADN-2025-001
  final String name;
  final String email;
  final String? phone;
  final String address;
  final String? latitude;
  final String? longitude;
  final InternetPackage package;
  final CustomerStatus status;
  final DateTime activationDate;
  final DateTime? suspensionDate;

  Customer({
    required this.id,
    required this.customerId,
    required this.name,
    required this.email,
    this.phone,
    required this.address,
    this.latitude,
    this.longitude,
    required this.package,
    required this.status,
    required this.activationDate,
    this.suspensionDate,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as String,
      customerId: json['customerId'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      address: json['address'] as String,
      latitude: json['latitude'] as String?,
      longitude: json['longitude'] as String?,
      package: InternetPackage.fromJson(
        json['package'] as Map<String, dynamic>,
      ),
      status: CustomerStatus.values.firstWhere(
        (e) => e.toString() == 'CustomerStatus.${json['status']}',
      ),
      activationDate: DateTime.parse(json['activationDate'] as String),
      suspensionDate: json['suspensionDate'] != null
          ? DateTime.parse(json['suspensionDate'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'package': package.toJson(),
      'status': status.toString().split('.').last,
      'activationDate': activationDate.toIso8601String(),
      'suspensionDate': suspensionDate?.toIso8601String(),
    };
  }
}

class InternetPackage {
  final String id;
  final String name;
  final int speedMbps;
  final int price;
  final bool isUnlimited;
  final int? quotaGB;

  InternetPackage({
    required this.id,
    required this.name,
    required this.speedMbps,
    required this.price,
    this.isUnlimited = true,
    this.quotaGB,
  });

  factory InternetPackage.fromJson(Map<String, dynamic> json) {
    return InternetPackage(
      id: json['id'] as String,
      name: json['name'] as String,
      speedMbps: json['speedMbps'] as int,
      price: json['price'] as int,
      isUnlimited: json['isUnlimited'] as bool? ?? true,
      quotaGB: json['quotaGB'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'speedMbps': speedMbps,
      'price': price,
      'isUnlimited': isUnlimited,
      'quotaGB': quotaGB,
    };
  }
}

enum CustomerStatus { active, suspended, pending, inactive }
