import 'dart:convert';
import 'dart:io';
import '../domain/bed_allocation.dart';
import '../domain/patient.dart';
import '../domain/bed.dart';

class BedAllocationRepository {
  final String filePath;

  BedAllocationRepository(this.filePath);

  List<BedAllocation> readBedAllocations(Map<String, Patient> patientById, Map<String, Bed> bedById) {
    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        throw Exception("File not found at: $filePath");
      }

      final content = file.readAsStringSync();
      final data = jsonDecode(content) as Map<String, dynamic>;

      final allocationsJson = data['bedAllocations'] as List<dynamic>? ?? [];
      final List<BedAllocation> allocations = [];

      for (var a in allocationsJson) {
        try {
          allocations.add(BedAllocation.fromJson(a as Map<String, dynamic>, patientById, bedById));
        } catch (e) {
          print("Warning: skipping invalid bed allocation: $e");
        }
      }

      return allocations;
    } catch (e) {
      print("Error: $e");
      rethrow;
    }
  }

  void writeBedAllocations(List<BedAllocation> allocations) {
    try {
      final outFile = File(filePath);

      final List<Map<String, dynamic>> allocationsJson = allocations.map((a) {
        final map = a.toJson();
        map['isActive'] = a.isActive();
        map['durationDays'] = a.getDuration().inDays;
        map['patientName'] = a.patient.name;
        map['bedNumber'] = a.bed.bedNumber;
        map['roomNumber'] = a.bed.room.roomNumber;
        return map;
      }).toList();

      final Map<String, dynamic> data = {'bedAllocations': allocationsJson};

      final encoder = JsonEncoder.withIndent('  ');
      final jsonString = encoder.convert(data);

      outFile.writeAsStringSync(jsonString);
    } catch (e) {
      print("Error writing bed allocations to $filePath: $e");
      rethrow;
    }
  }
}
