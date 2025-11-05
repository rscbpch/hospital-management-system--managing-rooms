import 'package:hospital_management_system__managing_rooms/data/bed_allocation_repository.dart';
import 'package:hospital_management_system__managing_rooms/data/ward_repository.dart';
import 'package:hospital_management_system__managing_rooms/managers/patient_manager.dart';
import 'package:hospital_management_system__managing_rooms/managers/ward_manager.dart';

import 'ui/console.dart';
import 'data/room_repository.dart';
import 'data/bed_repository.dart';
import 'data/patient_repository.dart';
import 'managers/room_manager.dart';

void main() {
  final roomRepo = RoomRepository('data/json/rooms.json');
  final bedRepo = BedRepository('data/json/beds.json');
  final patientRepo = PatientRepository('data/json/patients.json');
  final wardRepo = WardRepository('data/json/wards.json');
  final allocationRepo = BedAllocationRepository(
    'data/json/bed_allocations.json',
  );
  final roomManager = RoomManager(
    roomFilePath: 'data/json/rooms.json',
    roomRepo: roomRepo,
    bedRepo: bedRepo,
    patientRepo: patientRepo,
    allocationRepo: allocationRepo,
  );
  final patientManager = PatientManager(
    patientFilePath: 'data/json/patients.json',
    patientRepo: patientRepo,
  );
  final wardManager = WardManager(
    wardFilePath: 'data/json/wards.json',
    wardRepo: wardRepo,
    roomRepo: roomRepo,
    bedRepo: bedRepo,
  );

  start(roomManager, patientManager, wardManager);
}
