import 'dart:convert';
import 'dart:io';
import 'package:hospital_management_system__managing_rooms/data/bed_allocation_repository.dart';
import 'package:hospital_management_system__managing_rooms/domain/bed_allocation.dart';
import 'package:hospital_management_system__managing_rooms/domain/patient.dart';
import 'package:hospital_management_system__managing_rooms/domain/room.dart';
import 'package:hospital_management_system__managing_rooms/data/room_repository.dart';
import 'package:hospital_management_system__managing_rooms/data/bed_repository.dart';
import 'package:hospital_management_system__managing_rooms/domain/bed.dart';
import 'package:hospital_management_system__managing_rooms/data/patient_repository.dart';
import 'package:hospital_management_system__managing_rooms/domain/ward.dart';
import 'package:hospital_management_system__managing_rooms/managers/patient_manager.dart';

class RoomManager {
  final String roomFilePath;
  final RoomRepository roomRepo;
  final BedRepository bedRepo;
  final PatientRepository patientRepo;
  final BedAllocationRepository allocationRepo;

  List<Room> rooms = [];
  Map<String, Room> roomById = {};
  Map<String, Bed> bedById = {};
  Map<String, Patient> patientById = {};
  List<BedAllocation> allocations = [];
  List<Ward> wards = [];

  RoomManager({
    required this.roomFilePath,
    required this.roomRepo,
    required this.bedRepo,
    required this.patientRepo,
    required this.allocationRepo,
  }) {
    initialize();
  }

  void initialize() {
    ensureFileExists(roomFilePath);

    // load patietns
    final patients = patientRepo.readPatients();
    patientById = {for (var patient in patients) patient.id: patient};

    //load rooms
    rooms = roomRepo.readRooms(bedById);
    roomById = {for (var room in rooms) room.id: room};

    //load beds
    final beds = bedRepo.readBeds(roomById);
    bedById = {for (var bed in beds) bed.id: bed};

    for (var room in rooms) {
      room.beds.clear();
      final linkedBeds = beds.where((b) => b.room.id == room.id).toList();
      room.beds.addAll(linkedBeds);
      for (var bed in linkedBeds) {
        bed.room = room;
      }
    }

    // load allocations
    allocations = allocationRepo.readBedAllocations(patientById, bedById);

    for (var allocation in allocations) {
      allocation.bed.currentAllocation = allocation;
    }
    print('Rooms loaded: ${rooms.length}');
    print('Beds allocation linked successfully');
  }

  void ensureFileExists(String filePath) {
    final file = File(filePath);
    final dir = file.parent;
    if (!dir.existsSync()) dir.createSync(recursive: true);
    if (!file.existsSync()) file.writeAsString(jsonEncode({'rooms': []}));
  }

  List<Room> getAllRooms() {
    return rooms;
  }

  void addRoom(Room room) {
    rooms.add(room);
    roomById[room.id] = room;
    roomRepo.writeRooms(rooms);
  }

  Room? findRoomById(String id) => roomById[id];

  bool removeRoom(String roomId) {
    final initialLength = rooms.length;
    rooms.removeWhere((room) => room.id == roomId);
    final removed = rooms.length < initialLength;
    if (removed) roomRepo.writeRooms(rooms);
    return removed;
  }

  void addNewRoom(String roomNumber, String type, int bedCount) {
    print("\n === Add New Room ===");
    stdout.write("Enter room number: ");
    final roomNumber = stdin.readLineSync()?.trim() ?? '';

    if (roomNumber.isEmpty) {
      print("Invalid room number");
      return;
    }

    final existingRoom = rooms
        .where((r) => r.roomNumber == roomNumber)
        .isNotEmpty;
    if (existingRoom) {
      print("A room with number '$roomNumber' already exists!");
      return;
    }

    print('\nRoom types:');
    print('1. generalWard');
    print('2. semiPrivate');
    print('3. private');
    print('4. surgical');
    print('5. icu');
    print('6. isolation');
    print('7. maternity');
    stdout.write('Select room type (1-7): ');
    final typeChoice = stdin.readLineSync()?.trim() ?? '';

    final roomTypes = [
      RoomType.generalWard,
      RoomType.semiPrivate,
      RoomType.private,
      RoomType.surgical,
      RoomType.icu,
      RoomType.isolation,
      RoomType.maternity,
    ];

    RoomType? selectedType;
    final typeIndex = int.tryParse(typeChoice);
    if (typeIndex != null && typeIndex >= 1 && typeIndex <= 7) {
      selectedType = roomTypes[typeIndex - 1];
    } else {
      print('Invalid room type.');
      return;
    }

    stdout.write('How many beds in this room? ');
    final bedCountStr = stdin.readLineSync()?.trim() ?? '';
    final bedCount = int.tryParse(bedCountStr) ?? 0;
    if (bedCount <= 0) {
      print('Invalid bed count.');
      return;
    }

    final newRoom = Room(roomNumber: roomNumber, type: selectedType, beds: []);

    final bedLetters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
    for (int i = 0; i < bedCount && i < bedLetters.length; i++) {
      final newBed = Bed(
        room: newRoom,
        bedNumber: bedLetters[i],
        status: BedStatus.available,
      );
      newRoom.beds.add(newBed);
      bedById[newBed.id] = newBed;
    }

    rooms.add(newRoom);
    roomById[newRoom.id] = newRoom;

    roomRepo.writeRooms(rooms);
    bedRepo.writeBeds(bedById.values.toList());

    print('\nRoom created successfully!');
    print('Room: $roomNumber with $bedCount bed(s)');
  }

  void checkRoomAvailability() {
    print("\n=== Check Room Availability ===");
    for (var room in rooms) {
      final freeBeds = room.beds.where((b) => b.isAvailable()).toList();
      if (freeBeds.isNotEmpty) {
        print(
          "Room ${room.roomNumber} (${room.type.name}) : ${freeBeds.length} free bed(s)",
        );
        for (var bed in freeBeds) {
          print(" - Bed ${bed.bedNumber}");
        }
      }
    }
  }

  void allocateBedToPatient(PatientManager patientManager) {
    print("\n === Allocate Bed To Patient");
    for (var p in patientManager.getAllPatients()) {
      print("- Name: ${p.name} - ID: ${p.id}");
    }
    stdout.write("Enter Patient ID: ");
    final patientId = stdin.readLineSync()?.trim();
    final patient = patientManager.findPatientById(patientId ?? '');
    if (patient == null) {
      print("Invalid ID");
      return;
    }

    final hasActiveBed = bedById.values.any(
      (b) =>
          b.currentAllocation?.patient.id == patient.id &&
          b.currentAllocation?.status == AllocationStatus.active,
    );
    if (hasActiveBed) {
      print("Patient ${patient.name} already has an allocated bed.");
      return;
    }
    final availableBed = bedById.values.where((b) => b.isAvailable()).toList();
    if (availableBed.isEmpty) {
      print("No available bed");
      return;
    }
    print("\nAvailable Beds: ");
    for (var bed in availableBed) {
      print("-Room ${bed.room.roomNumber}, Bed ${bed.bedNumber}");
    }
    stdout.write("Enter room number: ");
    final roomNumber = stdin.readLineSync()?.trim();
    final selectedRoom =
        rooms.where((r) => r.roomNumber == roomNumber).isNotEmpty
        ? rooms.firstWhere((r) => r.roomNumber == roomNumber)
        : null;
    if (selectedRoom == null) {
      print("Room not found.");
      return;
    }

    final freeBeds = selectedRoom.beds.where((b) => b.isAvailable()).toList();
    if (freeBeds.isEmpty) {
      print("No free beds in this room.");
      return;
    }

    print("\nAvailable Beds in Room $roomNumber: ");
    for (var b in freeBeds) {
      print("- ${b.bedNumber}");
    }

    stdout.write("Enter bed number: ");
    final bedNumber = stdin.readLineSync()?.trim();
    final chosenBed = freeBeds.where((b) => b.bedNumber == bedNumber).isNotEmpty
        ? freeBeds.firstWhere((b) => b.bedNumber == bedNumber)
        : null;

    if (chosenBed == null) {
      print("Invalid bed number.");
      return;
    }

    final allocation = BedAllocation(
      patient: patient,
      bed: chosenBed,
      startDate: DateTime.now(),
      status: AllocationStatus.active,
    );
    chosenBed.occupy(allocation);
    bedById[chosenBed.id] = chosenBed;
    roomRepo.writeRooms(rooms);
    bedRepo.writeBeds(bedById.values.toList());
    print(
      "\nSuccessfully allocated Bed ${chosenBed.bedNumber} in Room ${selectedRoom.roomNumber} to ${patient.name}!",
    );
  }

  void releaseBed() {
    print("\n=== Release Bed From Patient");
    final occupiedBed = bedById.values
        .where((b) => b.status == BedStatus.occupied)
        .toList();
    if (occupiedBed.isEmpty) {
      print("No occupied beds found");
      return;
    }

    for (var bed in occupiedBed) {
      final patienName = bed.currentAllocation?.patient.name ?? 'Unknown';
      print(
        "Room ${bed.room.roomNumber}, Bed ${bed.bedNumber} - Occupied by $patienName",
      );
    }
    stdout.write("\nEnter Room Number: ");
    final roomNumber = stdin.readLineSync()?.trim();
    stdout.write("Enter Bed Number: ");
    final bedNumber = stdin.readLineSync()?.trim();

    final matchingBeds = occupiedBed
        .where(
          (b) => b.room.roomNumber == roomNumber && b.bedNumber == bedNumber,
        )
        .toList();

    if (matchingBeds.isEmpty) {
      print("No matching bed found.");
      return;
    }
    final bedToRelease = matchingBeds.first;
    bedToRelease.release();
    bedRepo.writeBeds(bedById.values.toList());
    roomRepo.writeRooms(rooms);
    print("Bed released successfully!");
  }
}
