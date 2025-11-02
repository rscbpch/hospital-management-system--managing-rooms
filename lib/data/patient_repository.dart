import 'dart:convert';
import 'dart:io';
import '../domain/patient.dart';

class PatientRepository {
  final String filePath;

  PatientRepository(this.filePath);

  List<Patient> readPatients() {
    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        throw Exception("File not found at: $filePath");
      }

      final content = file.readAsStringSync();
      final data = jsonDecode(content) as Map<String, dynamic>;

      final patientsJson = data['patients'] as List<dynamic>? ?? [];
      final List<Patient> patients = [];

      for (var p in patientsJson) {
        try {
          patients.add(Patient.fromJson(p as Map<String, dynamic>));
        } catch (e) {
          print("Warning: skipping invalid patient: $e");
        }
      }

      return patients;
    } catch (e) {
      print("Error: $e");
      rethrow;
    }
  }

  void writePatients(List<Patient> patients) {
    try {
      final outFile = File(filePath);

      final List<Map<String, dynamic>> patientsJson = patients.map((p) {
        final map = p.toJson();
        map['fullInfo'] = p.getFullInfo();
        return map;
      }).toList();

      final Map<String, dynamic> data = {'patients': patientsJson};

      final encoder = JsonEncoder.withIndent('  ');
      final jsonString = encoder.convert(data);

      outFile.writeAsStringSync(jsonString);
    } catch (e) {
      print("Error writing patients to $filePath: $e");
      rethrow;
    }
  }
}
