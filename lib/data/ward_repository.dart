import 'dart:convert';
import 'dart:io';
import '../domain/ward.dart';
import '../domain/room.dart';

class WardRepository {
  final String filePath;

  WardRepository(this.filePath);

  List<Ward> readWards(Map<String, Room> roomById) {
    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        throw Exception("File not found at: $filePath");
      }

      final content = file.readAsStringSync();
      final data = jsonDecode(content) as Map<String, dynamic>;

      final wardsJson = data['wards'] as List<dynamic>? ?? [];
      final List<Ward> wards = [];

      for (var w in wardsJson) {
        try {
          wards.add(Ward.fromJson(w as Map<String, dynamic>, roomById));
        } catch (e) {
          print("Warning: skipping invalid ward: $e");
        }
      }

      return wards;
    } catch (e) {
      print("Error: $e");
      rethrow;
    }
  }

  void writeWards(List<Ward> wards) {
    try {
      final outFile = File(filePath);

      final List<Map<String, dynamic>> wardsJson = wards.map((w) {
        final map = w.toJson();
        map['roomCount'] = w.rooms.length;
        map['totalBeds'] = w.rooms.fold<int>(0, (sum, room) => sum + room.beds.length);
        map['availableBedsCount'] = w.getAvailableBeds().length;
        map['isFull'] = w.isFull();
        map['availableRoomsCount'] = w.getAvailableRooms().length;
        return map;
      }).toList();

      final Map<String, dynamic> data = {'wards': wardsJson};

      final encoder = JsonEncoder.withIndent('  ');
      final jsonString = encoder.convert(data);

      outFile.writeAsStringSync(jsonString);
    } catch (e) {
      print("Error writing wards to $filePath: $e");
      rethrow;
    }
  }
}
