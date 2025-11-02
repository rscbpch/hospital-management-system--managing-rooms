import 'package:hospital_management_system__managing_rooms/domain/bed_allocation.dart';
import 'package:hospital_management_system__managing_rooms/domain/room.dart';
import 'package:uuid/uuid.dart';

var uuid = Uuid();

enum BedStatus { available, occupied, reserved }

class Bed {
  final String id;
  Room room;
  final String bedNumber;
  BedStatus status;
  BedAllocation? currentAllocation;

  Bed({String? id, required this.room, required this.bedNumber, this.status = BedStatus.available, this.currentAllocation}) 
    : id = id ?? uuid.v4();

  factory Bed.fromJson(Map<String, dynamic> json, Map<String, Room> roomById) {
    final roomId = json['roomId'] as String?;
    if (roomId == null) {
      throw FormatException('Bed missing roomId: $json');
    }
    final room = roomById[roomId];
    if (room == null) {
      throw FormatException('Bed references unknown roomId: $roomId');
    }

    final statusString = json['status'] as String? ?? 'available';
    final parsedStatus = BedStatus.values.firstWhere((e) => e.name == statusString, orElse: () => BedStatus.available);

    return Bed(
      id: json['id'] as String?, 
      room: room, 
      bedNumber: json['bedNumber'] as String? ?? '', 
      status: parsedStatus
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id, 
    'roomId': room.id, 
    'bedNumber': bedNumber, 
    'status': status.name, 
    'currentAllocationId': currentAllocation?.id
  };

  @override
  String toString() => 'Bed(id: $id, bedNumber: $bedNumber, room: ${room.roomNumber}, status: ${status.name})';

  /// Checks if the bed is available
  bool isAvailable() {
    return status == BedStatus.available;
  }

  /// Assigns a bed allocation to this bed
  void assign(BedAllocation allocation) {
    if (!isAvailable()) {
      throw StateError('Cannot assign allocation to bed that is not available. Current status: ${status.name}');
    }
    status = BedStatus.occupied;
    currentAllocation = allocation;
  }

  void occupy(BedAllocation allocation) {
    status = BedStatus.occupied;
    currentAllocation = allocation;
  }

  void release() {
    status = BedStatus.available;
    currentAllocation = null;
  }

  void reserve() {
    status = BedStatus.reserved;
  }
}
