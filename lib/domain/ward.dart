import 'package:hospital_management_system__managing_rooms/domain/room.dart';
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
  final String name;
  final WardType type;
  final List<Room> rooms;

  Ward({String? id, required this.name, required this.type, required this.rooms}) 
    : id = id ?? uuid.v4();

  Map<String, dynamic> toJson() => {
    'id': id, 
    'name': name, 
    'type': type.name, 
    'rooms': rooms.map((r) => r.toJson()).toList()
  };

  factory Ward.fromJson(Map<String, dynamic> json, List<Room> rooms) {
    return Ward(
      id: json['id'], 
      name: json['name'], 
      type: WardType.values.firstWhere((e) => e.name == json['type']), 
      rooms: rooms
    );
  }

  @override
  String toString() => 'Ward(id: $id, name: $name, type: ${type.name}, rooms: ${rooms.length})';
}
