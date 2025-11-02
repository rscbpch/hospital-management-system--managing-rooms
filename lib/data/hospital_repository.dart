import 'dart:convert';
import 'dart:io';
import '../domain/hospital.dart';
import '../domain/ward.dart';

class HospitalRepository {
  final String filePath;

  HospitalRepository(this.filePath);

  List<Hospital> readHospitals(Map<String, Ward> wardById) {
    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        throw Exception("File not found at: $filePath");
      }

      final content = file.readAsStringSync();
      final data = jsonDecode(content) as Map<String, dynamic>;

      final hospitalsJson = data['hospitals'] as List<dynamic>? ?? [];
      final List<Hospital> hospitals = [];

      for (var h in hospitalsJson) {
        try {
          hospitals.add(Hospital.fromJson(h as Map<String, dynamic>, wardById));
        } catch (e) {
          print("Warning: skipping invalid hospital: $e");
        }
      }

      return hospitals;
    } catch (e) {
      print("Error: $e");
      rethrow;
    }
  }

  void writeHospitals(List<Hospital> hospitals) {
    try {
      final outFile = File(filePath);

      final List<Map<String, dynamic>> hospitalsJson = hospitals.map((h) {
        final map = h.toJson();
        map['wardCount'] = h.wards.length;
        map['totalRooms'] = h.wards.fold<int>(0, (sum, ward) => sum + ward.rooms.length);
        map['totalBeds'] = h.wards.fold<int>(0, (sum, ward) => sum + ward.rooms.fold<int>(0, (roomSum, room) => roomSum + room.beds.length));
        return map;
      }).toList();

      final Map<String, dynamic> data = {'hospitals': hospitalsJson};

      final encoder = JsonEncoder.withIndent('  ');
      final jsonString = encoder.convert(data);

      outFile.writeAsStringSync(jsonString);
    } catch (e) {
      print("Error writing hospitals to $filePath: $e");
      rethrow;
    }
  }
}
