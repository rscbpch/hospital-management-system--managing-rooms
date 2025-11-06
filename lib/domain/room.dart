import 'package:hospital_management_system__managing_rooms/domain/bed.dart';
import 'package:uuid/uuid.dart';

var uuid = Uuid();

enum RoomType { generalWard, semiPrivate, private, surgical, icu, isolation, maternity }

class Room {
  final String id;
  final String roomNumber;
  RoomType type;
  final List<Bed> beds;

  Room({String? id, required this.roomNumber, required this.type, List<Bed>? beds}) 
    : id = id ?? uuid.v4(), beds = beds ?? [];

  factory Room.fromJson(Map<String, dynamic> json, List<Bed> beds) {
    final roomTypeString = json['type'] as String? ?? 'generalWard';
    final parsedType = RoomType.values.firstWhere((e) => e.name == roomTypeString, orElse: () => RoomType.generalWard);

    return Room(
      id: json['id'] as String?, 
      roomNumber: json['roomNumber'] as String? ?? '', 
      type: parsedType, beds: beds
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id, 
    'roomNumber': roomNumber, 
    'type': type.name, 
    'beds': beds.map((b) => b.toJson()).toList()
  };

  @override
  String toString() => 'Room $roomNumber (${type.name}) - ${beds.length} beds';

  bool isFull() {
    return !beds.any((bed) => bed.status == BedStatus.available);
  }

  List<Bed> getAvailableBeds() {
    return beds.where((bed) => bed.status == BedStatus.available).toList();
  }

  void addBed(Bed bed) {
    if (bed.room.id != id) {
      throw ArgumentError('Bed belongs to a different room. Bed room: ${bed.room.id}, This room: $id');
    }
    if (beds.any((b) => b.id == bed.id)) {
      throw ArgumentError('Bed with id ${bed.id} already exists in this room');
    }
    beds.add(bed);
  }

  bool removeBed(String bedId) {
    final bedIndex = beds.indexWhere((bed) => bed.id == bedId);
    if (bedIndex == -1) {
      return false; 
    }

    final bed = beds[bedIndex];
    if (bed.status != BedStatus.available) {
      throw StateError('Cannot remove bed that is ${bed.status.name}. Bed must be available.');
    }

    beds.removeAt(bedIndex);
    return true; 
  }

  bool hasAvailableBeds() => beds.any((bed) => bed.status == BedStatus.available);
}
