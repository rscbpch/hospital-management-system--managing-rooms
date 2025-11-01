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

  Map<String, dynamic> toJson() => {
    'id': id, 
    'roomId': room.id, 
    'bedNumber': bedNumber, 
    'status': status.name, 
    'currentAllocationId': currentAllocation?.id
  };

  factory Bed.fromJson(Map<String, dynamic> json, Room room) {
    return Bed(
      id: json['id'], 
      room: room, 
      bedNumber: json['bedNumber'], 
      status: BedStatus.values.firstWhere((e) => e.name == json['status'])
    );
  }

  @override
  String toString() => 'Bed(id: $id, bedNumber: $bedNumber, room: ${room.roomNumber}, status: ${status.name})';

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
