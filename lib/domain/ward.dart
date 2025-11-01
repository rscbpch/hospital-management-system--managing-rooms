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
}
