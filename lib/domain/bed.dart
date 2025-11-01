import 'package:hospital_management_system__managing_rooms/domain/bed_allocation.dart';
import 'package:hospital_management_system__managing_rooms/domain/room.dart';
import 'package:uuid/uuid.dart';

var uuid = Uuid();

enum BedStatus { available, occupied, reserved }

class Bed {
  final String id;
  final Room room;
  final BedStatus status;
  final BedAllocation currentAllocation;

  Bed({String? id, required this.room, required this.status, required this.currentAllocation, required String bedNumber}) 
    : id = id ?? uuid.v4();
}
