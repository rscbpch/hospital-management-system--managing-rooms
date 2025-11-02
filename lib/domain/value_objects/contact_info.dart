class ContactInfo {
  final String phone;
  final String email;
  final String address;

  const ContactInfo({required this.phone, required this.email, required this.address});

  Map<String, dynamic> toJson() => {
    'phone': phone, 
    'email': email, 
    'address': address
  };

  factory ContactInfo.fromJson(Map<String, dynamic> json) {
    return ContactInfo(
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      address: json['address'] as String? ?? ''
    );
  }

  @override
  String toString() {
    return '''
    Phone: $phone
    Email: $email
    Address: $address''';
  }

  ContactInfo copyWith({String? phone, String? email, String? address}) {
    return ContactInfo(phone: phone ?? this.phone, email: email ?? this.email, address: address ?? this.address);
  }
}
