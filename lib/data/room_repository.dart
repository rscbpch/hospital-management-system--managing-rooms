import 'dart:convert';
import 'dart:io';
import '../domain/room.dart';
import '../domain/bed.dart';

class RoomRepository {
  final String filePath;

  RoomRepository(this.filePath);

  List<Room> readRooms(Map<String, Bed> bedById) {
    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        throw Exception("File not found at: $filePath");
      }

      final content = file.readAsStringSync();
      final data = jsonDecode(content) as Map<String, dynamic>;

      final roomsJson = data['rooms'] as List<dynamic>? ?? [];
      final List<Room> rooms = [];

      for (var r in roomsJson) {
        try {
          final roomJson = r as Map<String, dynamic>;
          final bedsJson = roomJson['beds'] as List<dynamic>? ?? [];
          final List<Bed> roomBeds = [];

          for (var bedData in bedsJson) {
            if (bedData is String) {
              // If it's just an ID string, look it up
              final bed = bedById[bedData];
              if (bed != null) {
                roomBeds.add(bed);
              }
            } else if (bedData is Map<String, dynamic>) {
              // If it's a bed object, extract ID and look it up
              final bedId = bedData['id'] as String?;
              if (bedId != null) {
                final bed = bedById[bedId];
                if (bed != null) {
                  roomBeds.add(bed);
                }
              }
            }
          }

          rooms.add(Room.fromJson(roomJson, roomBeds));
        } catch (e) {
          print("Warning: skipping invalid room: $e");
        }
      }

      return rooms;
    } catch (e) {
      print("Error: $e");
      rethrow;
    }
  }

  void writeRooms(List<Room> rooms) {
    try {
      final outFile = File(filePath);

      final List<Map<String, dynamic>> roomsJson = rooms.map((r) {
        final map = r.toJson();
        map['hasAvailableBeds'] = r.hasAvailableBeds();
        map['bedCount'] = r.beds.length;
        map['availableBedCount'] = r.beds.where((b) => b.status == BedStatus.available).length;
        map['isFull'] = r.isFull();
        return map;
      }).toList();

      final Map<String, dynamic> data = {'rooms': roomsJson};

      final encoder = JsonEncoder.withIndent('  ');
      final jsonString = encoder.convert(data);

      outFile.writeAsStringSync(jsonString);
    } catch (e) {
      print("Error writing rooms to $filePath: $e");
      rethrow;
    }
  }
}
