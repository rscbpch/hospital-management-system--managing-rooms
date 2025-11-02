import 'package:hospital_management_system__managing_rooms/domain/value_objects/contact_info.dart';
import 'package:uuid/uuid.dart';

var uuid = Uuid();

class Patient {
  final String id;
  final String name;
  final int age;
  final String gender;
  ContactInfo contactInfo;

  Patient({String? id, required this.name, required this.age, required this.gender, required this.contactInfo}) 
    : id = id ?? uuid.v4();

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] as String?,
      name: json['name'] as String? ?? '',
      age: (json['age'] is int) ? json['age'] as int : int.tryParse('${json['age']}') ?? 0,
      gender: json['gender'] as String? ?? '',
      contactInfo: ContactInfo.fromJson(json['contactInfo'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id, 
    'name': name, 
    'age': age, 
    'gender': gender, 
    'contactInfo': contactInfo.toJson()
  };

  String getFullInfo() {
    return '''
    Patient ID: $id
    Name: $name
    Age: $age
    Gender: $gender
    Contact Information: ${contactInfo.toString()}''';
  }

  @override
  String toString() => 'Patient(id: $id, name: $name, age: $age, gender: $gender)';

  void updateContactInfo(ContactInfo info) {
    contactInfo = info;
  }

  void updatePhone(String newPhone) {
    contactInfo = contactInfo.copyWith(phone: newPhone);
  }

  void updateEmail(String newEmail) {
    contactInfo = contactInfo.copyWith(email: newEmail);
  }

  void updateAddress(String newAddress) {
    contactInfo = contactInfo.copyWith(address: newAddress);
  }
}
