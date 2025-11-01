import 'package:hospital_management_system__managing_rooms/domain/value_objects/contact_info.dart';
import 'package:uuid/uuid.dart';

var uuid = Uuid();

class Patient {
  final String id;
  final String name;
  final int age;
  final String gender;
  final ContactInfo contactInfo;

  Patient({String? id, required this.name, required this.age, required this.gender, required this.contactInfo}) : id = id ?? uuid.v4();

  String getFullInfo() {
    return '''
    Patient ID: $id
    Name: $name
    Age: $age
    Gender: $gender
    Contact Information: ${contactInfo.toString()}''';
  }
}
