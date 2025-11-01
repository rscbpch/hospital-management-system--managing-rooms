class ContactInfo {
  final String phone;
  final String email;
  final String address;

  const ContactInfo({
    required this.phone, 
    required this.email, 
    required this.address
  });

  @override
  String toString() {
    return '''
    Phone: $phone
    Email: $email
    Address: $address''';
  }

  ContactInfo copyWith({
    String? phone,
    String? email,
    String? address,
  }) {
    return ContactInfo(
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContactInfo &&
          phone == other.phone &&
          email == other.email &&
          address == other.address;

  @override
  int get hashCode => Object.hash(phone, email, address);
}
