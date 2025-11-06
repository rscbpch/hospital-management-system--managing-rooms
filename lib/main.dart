import 'package:hospital_management_system__managing_rooms/data/bed_allocation_repository.dart';
import 'package:hospital_management_system__managing_rooms/data/reservation_repository.dart';
import 'package:hospital_management_system__managing_rooms/data/ward_repository.dart';
import 'package:hospital_management_system__managing_rooms/data/hospital_repository.dart';
import 'package:hospital_management_system__managing_rooms/ui/managers/patient_manager.dart';
import 'package:hospital_management_system__managing_rooms/ui/managers/ward_manager.dart';
import 'package:hospital_management_system__managing_rooms/ui/managers/bed_allocation_manager.dart';
import 'package:hospital_management_system__managing_rooms/ui/managers/reservation_manager.dart';

import 'ui/console.dart';
import 'data/room_repository.dart';
import 'data/bed_repository.dart';
import 'data/patient_repository.dart';
import 'ui/managers/room_manager.dart';

void main() {
  final roomRepo = RoomRepository('data/json/rooms.json');
  final bedRepo = BedRepository('data/json/beds.json');
  final patientRepo = PatientRepository('data/json/patients.json');
  final wardRepo = WardRepository('data/json/wards.json');
  final allocationRepo = BedAllocationRepository('data/json/bed_allocations.json');
  final reservationRepo = ReservationRepository('data/json/reservations.json');
  final hospitalRepo = HospitalRepository('data/json/hospitals.json');

  final roomManager = RoomManager(roomFilePath: 'data/json/rooms.json', roomRepo: roomRepo, bedRepo: bedRepo, patientRepo: patientRepo, allocationRepo: allocationRepo);
  final patientManager = PatientManager(patientFilePath: 'data/json/patients.json', patientRepo: patientRepo);
  final wardManager = WardManager(wardFilePath: 'data/json/wards.json', wardRepo: wardRepo, roomRepo: roomRepo, bedRepo: bedRepo, hospitalRepo: hospitalRepo);
  final bedAllocationManager = BedAllocationManager(allocationFilePath: 'data/json/bed_allocations.json', allocationRepo: allocationRepo, patientManager: patientManager, wardManager: wardManager);
  final reservationManager = ReservationManager(reservationFilePath: 'data/json/reservations.json', reservationRepo: reservationRepo, patientManager: patientManager, roomManager: roomManager);

  start(roomManager, patientManager, wardManager, bedAllocationManager, reservationManager);
}
