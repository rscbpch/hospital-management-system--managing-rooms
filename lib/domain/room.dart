import 'package:hospital_management_system__managing_rooms/domain/bed.dart';
import 'package:uuid/uuid.dart';

var uuid = Uuid();

enum RoomType { generalWard, semiPrivate, private, surgical, icu, isolation, maternity }

class Room {
  final String id;
  final String roomNumber;
  final RoomType type;
  final List<Bed> beds;

  Room({String? id, required this.roomNumber, required this.type, List<Bed>? beds})  
    : id = id ?? uuid.v4(),
      beds = beds ?? [];

  bool hasAvailableBeds() => beds.any((bed) => bed.status == BedStatus.available);

  Map<String, dynamic> toJson() => {
    'id': id,
    'roomNumber': roomNumber,
    'type': type.name,
    'beds': beds.map((b) => b.toJson()).toList(),
  };

  factory Room.fromJson(Map<String, dynamic> json, List<Bed> beds) {
    return Room(
      id: json['id'],
      roomNumber: json['roomNumber'],
      type: RoomType.values.firstWhere((e) => e.name == json['type']),
      beds: beds,
    );
  }

  @override
  String toString() => 'Room $roomNumber (${type.name}) - ${beds.length} beds';
}