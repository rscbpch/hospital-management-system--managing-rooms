import 'package:uuid/uuid.dart';
import 'dart:io';
import 'package:hospital_management_system__managing_rooms/data/patient_repository.dart';
import 'package:hospital_management_system__managing_rooms/domain/patient.dart';
import 'package:hospital_management_system__managing_rooms/domain/value_objects/contact_info.dart';

class PatientManager {
  final String patientFilePath;
  final PatientRepository patientRepo;
  final uuid = Uuid();

  List<Patient> patients = [];
  Map<String, Patient> patientById = {};

  PatientManager({required this.patientFilePath, required this.patientRepo}) {
    initialize();
  }

  void initialize() {
    ensureFileExist(patientFilePath);

    patients = patientRepo.readPatients();
    patientById = {for (var patient in patients) patient.id: patient};
    print("Patient loaded: ${patients.length}");
  }

  void ensureFileExist(String filePath) {
    final file = File(filePath);
    final dir = file.parent;

    if (!dir.existsSync()) dir.createSync(recursive: true);
    if (!file.existsSync()) file.writeAsStringSync('{"patients": []}');
  }

  List<Patient> getAllPatients() => patients;
  Patient? findPatientById(String id) => patientById[id];

  void addPatient(Patient patient) {
    patients.add(patient);
    patientById[patient.id] = patient;
    patientRepo.writePatients(patients);
  }

  void printAllPatientIds() {
    if (patients.isEmpty) {
      print("No patients found");
      return;
    }
    for (var patient in patients) {
      print("- Name: ${patient.name} - ID: ${patient.id}");
    }
  }

  bool removePatient(String patientId) {
    final initialLength = patients.length;
    patients.removeWhere((p) => p.id == patientId);
    final removed = patients.length < initialLength;
    if (removed) patientRepo.writePatients(patients);
    return removed;
  }

  void createPatient() {
    print("\n === Register Patient ===");
    stdout.write("Enter Patient name: ");
    final name = stdin.readLineSync()?.trim() ?? '';
    if (name.isEmpty) {
      print("Invalid name");
      return;
    }

    stdout.write("Age: ");
    final ageStr = stdin.readLineSync()?.trim() ?? '';
    final age = int.tryParse(ageStr) ?? 0;
    if (age <= 0) {
      print("Invalid age");
      return;
    }

    stdout.write("Gender: ");
    final gender = stdin.readLineSync()?.trim() ?? '';
    if (gender.isEmpty) {
      print('Invalid gender.');
      return;
    }

    stdout.write('Phone: ');
    final phone = stdin.readLineSync()?.trim() ?? '';
    stdout.write('Email: ');
    final email = stdin.readLineSync()?.trim() ?? '';
    stdout.write('Address: ');
    final address = stdin.readLineSync()?.trim() ?? '';

    final contactInfo = ContactInfo(
      phone: phone,
      email: email,
      address: address,
    );

    final newPatient = Patient(
      name: name,
      age: age,
      gender: gender,
      contactInfo: contactInfo,
    );

    patients.add(newPatient);
    patientById[newPatient.id] = newPatient;
    patientRepo.writePatients(patients);
    print("\nPatient created successfully!");
  }
}
