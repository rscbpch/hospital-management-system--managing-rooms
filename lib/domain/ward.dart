import 'package:hospital_management_system__managing_rooms/domain/room.dart';
import 'package:hospital_management_system__managing_rooms/domain/bed.dart';
import 'package:uuid/uuid.dart';

var uuid = Uuid();

enum WardType { general, surgery, icu, maternity }

extension WardTypeExtension on WardType {
  List<RoomType> get allowedRoomTypes {
    switch (this) {
      case WardType.general:
        return [RoomType.generalWard, RoomType.semiPrivate, RoomType.private];
      case WardType.surgery:
        return [RoomType.surgical, RoomType.semiPrivate, RoomType.private];
      case WardType.icu:
        return [RoomType.icu, RoomType.isolation, RoomType.private];
      case WardType.maternity:
        return [RoomType.maternity, RoomType.semiPrivate, RoomType.private];
    }
  }
}

class Ward {
  final String id;
  String name; // Changed from final to mutable
  WardType type; // Changed from final to mutable
  final List<Room> rooms;

  Ward({String? id, required this.name, required this.type, required this.rooms}) : id = id ?? uuid.v4();

  factory Ward.fromJson(Map<String, dynamic> json, Map<String, Room> roomById) {
    final wardTypeString = json['type'] as String? ?? 'general';
    final parsedType = WardType.values.firstWhere((e) => e.name == wardTypeString, orElse: () => WardType.general);

    final roomsJson = json['rooms'] as List<dynamic>? ?? [];
    final List<Room> rooms = [];

    for (var roomJson in roomsJson) {
      String? roomId;
      if (roomJson is String) {
        // Handle case where rooms are stored as simple strings (room IDs)
        roomId = roomJson;
      } else if (roomJson is Map<String, dynamic>) {
        // Handle case where rooms are stored as objects with 'id' field
        roomId = roomJson['id'] as String?;
      }

      if (roomId != null) {
        final room = roomById[roomId];
        if (room != null) {
          rooms.add(room);
        }
      }
    }

    return Ward(id: json['id'] as String?, name: json['name'] as String? ?? '', type: parsedType, rooms: rooms);
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'type': type.name, 'rooms': rooms.map((r) => r.toJson()).toList()};

  @override
  String toString() => 'Ward(id: $id, name: $name, type: ${type.name}, rooms: ${rooms.length})';

  // Checks if the ward is full
  bool isFull() {
    return !rooms.any((room) => room.hasAvailableBeds());
  }

  // Gets all available beds in the ward
  List<Bed> getAvailableBeds() {
    final List<Bed> availableBeds = [];
    for (var room in rooms) {
      availableBeds.addAll(room.getAvailableBeds());
    }
    return availableBeds;
  }

  // Gets all rooms that have available beds
  List<Room> getAvailableRooms() {
    return rooms.where((room) => room.hasAvailableBeds()).toList();
  }

  // Adds a room to the ward
  void addRoom(Room room) {
    if (!type.allowedRoomTypes.contains(room.type)) {
      throw ArgumentError('Room type ${room.type.name} is not allowed in ${type.name} ward. Allowed types: ${type.allowedRoomTypes.map((e) => e.name).join(", ")}');
    }

    if (rooms.any((r) => r.id == room.id)) {
      throw ArgumentError('Room with id ${room.id} already exists in this ward');
    }

    rooms.add(room);
  }

  // Removes a room from the ward by ID
  bool removeRoom(String roomId) {
    final roomIndex = rooms.indexWhere((room) => room.id == roomId);
    if (roomIndex == -1) {
      return false;
    }

    final room = rooms[roomIndex];
    final occupiedBeds = room.beds.where((bed) => bed.status == BedStatus.occupied).toList();
    if (occupiedBeds.isNotEmpty) {
      throw StateError('Cannot remove room that has ${occupiedBeds.length} occupied bed(s). Room must be empty.');
    }

    rooms.removeAt(roomIndex);
    return true;
  }

  /// Updates the ward's name and/or type
  void updateWard({String? name, WardType? type}) {
    if (name != null) {
      if (name.trim().isEmpty) {
        throw ArgumentError('Ward name cannot be empty');
      }
      this.name = name.trim();
    }

    if (type != null) {
      final newAllowedTypes = type.allowedRoomTypes;
      for (var room in rooms) {
        if (!newAllowedTypes.contains(room.type)) {
          throw StateError(
            'Cannot change ward type to ${type.name}. '
            'Room ${room.roomNumber} (${room.type.name}) is not compatible with ${type.name} ward. '
            'Allowed room types: ${newAllowedTypes.map((e) => e.name).join(", ")}',
          );
        }
      }
      this.type = type;
    }
  }
}
