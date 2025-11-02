import 'dart:convert';
import 'dart:io';
import '../domain/bed.dart';
import '../domain/room.dart';

class BedRepository {
  final String filePath;

  BedRepository(this.filePath);

  List<Bed> readBeds(Map<String, Room> roomById) {
    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        throw Exception("File not found at: $filePath");
      }

      final content = file.readAsStringSync();
      final data = jsonDecode(content) as Map<String, dynamic>;

      final bedsJson = data['beds'] as List<dynamic>? ?? [];
      final List<Bed> beds = [];

      for (var b in bedsJson) {
        try {
          beds.add(Bed.fromJson(b as Map<String, dynamic>, roomById));
        } catch (e) {
          print("Warning: skipping invalid bed: $e");
        }
      }

      return beds;
    } catch (e) {
      print("Error: $e");
      rethrow;
    }
  }

  void writeBeds(List<Bed> beds) {
    try {
      final outFile = File(filePath);

      final List<Map<String, dynamic>> bedsJson = beds.map((b) {
        final map = b.toJson();
        map['roomNumber'] = b.room.roomNumber;
        map['roomType'] = b.room.type.name;
        map['isAvailable'] = b.isAvailable();
        return map;
      }).toList();

      final Map<String, dynamic> data = {'beds': bedsJson};

      final encoder = JsonEncoder.withIndent('  ');
      final jsonString = encoder.convert(data);

      outFile.writeAsStringSync(jsonString);
    } catch (e) {
      print("Error writing beds to $filePath: $e");
      rethrow;
    }
  }
}
