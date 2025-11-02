import 'dart:convert';
import 'dart:io';
import '../domain/reservation.dart';
import '../domain/patient.dart';
import '../domain/bed.dart';

class ReservationRepository {
  final String filePath;

  ReservationRepository(this.filePath);

  List<Reservation> readReservations(Map<String, Patient> patientById, Map<String, Bed> bedById) {
    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        throw Exception("File not found at: $filePath");
      }

      final content = file.readAsStringSync();
      final data = jsonDecode(content) as Map<String, dynamic>;

      final reservationsJson = data['reservations'] as List<dynamic>? ?? [];
      final List<Reservation> reservations = [];

      for (var r in reservationsJson) {
        try {
          reservations.add(Reservation.fromJson(r as Map<String, dynamic>, patientById, bedById));
        } catch (e) {
          print("Warning: skipping invalid reservation: $e");
        }
      }

      return reservations;
    } catch (e) {
      print("Error: $e");
      rethrow;
    }
  }

  // Writes reservations to JSON file
  void writeReservations(List<Reservation> reservations) {
    try {
      final outFile = File(filePath);

      final List<Map<String, dynamic>> reservationsJson = reservations.map((r) {
        final map = r.toJson();
        map['isActive'] = r.isActive();
        map['patientName'] = r.patient.name;
        map['bedNumber'] = r.bed.bedNumber;
        map['roomNumber'] = r.bed.room.roomNumber;
        return map;
      }).toList();

      final Map<String, dynamic> data = {'reservations': reservationsJson};

      final encoder = JsonEncoder.withIndent('  ');
      final jsonString = encoder.convert(data);

      outFile.writeAsStringSync(jsonString);
    } catch (e) {
      print("Error writing reservations to $filePath: $e");
      rethrow;
    }
  }
}
