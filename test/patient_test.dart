import 'package:test/test.dart';
import 'package:hospital_management_system__managing_rooms/domain/patient.dart';
import 'package:hospital_management_system__managing_rooms/domain/value_objects/contact_info.dart';

void main() {
  group('Patient:', () {
    late Patient patient1;
    late ContactInfo contactInfo1;

    setUp(() {
      contactInfo1 = ContactInfo(phone: '123-456-7890', email: 'poy@email.com', address: '123 Main St, City');

      patient1 = Patient(id: 'a1b2c3d4-e5f6-4789-a012-345678901234', name: 'Poy', age: 45, gender: 'Male', contactInfo: contactInfo1);
    });

    test('Create patient from json', () {
      final jsonData = {
        'id': 'test-patient-id',
        'name': 'Test Patient',
        'age': 30,
        'gender': 'Male',
        'contactInfo': {'phone': '123-456-7890', 'email': 'test@example.com', 'address': '123 Test St'},
      };

      final patient = Patient.fromJson(jsonData);

      expect(patient.id, equals('test-patient-id'));
      expect(patient.name, equals('Test Patient'));
      expect(patient.age, equals(30));
      expect(patient.gender, equals('Male'));
      expect(patient.contactInfo.phone, equals('123-456-7890'));
      expect(patient.contactInfo.email, equals('test@example.com'));
      expect(patient.contactInfo.address, equals('123 Test St'));
    });

    test('Convert patient to json', () {
      final json = patient1.toJson();

      expect(json['id'], equals(patient1.id));
      expect(json['name'], equals(patient1.name));
      expect(json['age'], equals(patient1.age));
      expect(json['gender'], equals(patient1.gender));
      expect(json['contactInfo'], isA<Map<String, dynamic>>());
      expect(json['contactInfo']['phone'], equals(contactInfo1.phone));
      expect(json['contactInfo']['email'], equals(contactInfo1.email));
      expect(json['contactInfo']['address'], equals(contactInfo1.address));
    });

    test('Update whole contact info', () {
      final patient = Patient(name: 'Test Patient', age: 30, gender: 'Male', contactInfo: contactInfo1);
      final originalPhone = patient.contactInfo.phone;

      final newContactInfo = ContactInfo(phone: '999-888-7777', email: 'newemail@example.com', address: '456 New St');

      patient.updateContactInfo(newContactInfo);

      expect(patient.contactInfo.phone, equals('999-888-7777'));
      expect(patient.contactInfo.email, equals('newemail@example.com'));
      expect(patient.contactInfo.address, equals('456 New St'));
      expect(patient.contactInfo.phone, isNot(equals(originalPhone)));
    });

    test('Update phone number only', () {
      final patient = Patient(name: 'Test Patient', age: 30, gender: 'Male', contactInfo: contactInfo1);
      final originalEmail = patient.contactInfo.email;
      final originalAddress = patient.contactInfo.address;

      patient.updatePhone('999-888-7777');

      expect(patient.contactInfo.phone, equals('999-888-7777'));
      expect(patient.contactInfo.email, equals(originalEmail));
      expect(patient.contactInfo.address, equals(originalAddress));
    });

    test('Update email only', () {
      final patient = Patient(name: 'Test Patient', age: 30, gender: 'Male', contactInfo: contactInfo1);
      final originalPhone = patient.contactInfo.phone;
      final originalAddress = patient.contactInfo.address;

      patient.updateEmail('newemail@example.com');

      expect(patient.contactInfo.email, equals('newemail@example.com'));
      expect(patient.contactInfo.phone, equals(originalPhone));
      expect(patient.contactInfo.address, equals(originalAddress));
    });

    test('Update address only', () {
      final patient = Patient(name: 'Test Patient', age: 30, gender: 'Male', contactInfo: contactInfo1);
      final originalPhone = patient.contactInfo.phone;
      final originalEmail = patient.contactInfo.email;

      patient.updateAddress('456 New St');

      expect(patient.contactInfo.address, equals('456 New St'));
      expect(patient.contactInfo.phone, equals(originalPhone));
      expect(patient.contactInfo.email, equals(originalEmail));
    });
  });
}
