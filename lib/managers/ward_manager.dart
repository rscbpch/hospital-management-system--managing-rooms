import 'dart:convert';
import 'dart:io';
import 'package:hospital_management_system__managing_rooms/data/bed_repository.dart';
import 'package:hospital_management_system__managing_rooms/data/room_repository.dart';
import 'package:hospital_management_system__managing_rooms/data/ward_repository.dart';
import 'package:hospital_management_system__managing_rooms/domain/bed.dart';
import 'package:hospital_management_system__managing_rooms/domain/room.dart';
import 'package:hospital_management_system__managing_rooms/domain/ward.dart';

class WardManager {
  final String wardFilePath;
  final WardRepository wardRepo;
  final RoomRepository roomRepo;
  final BedRepository bedRepo;

  List<Ward> wards = [];
  Map<String, Room> roomById = {};
  Map<String, Ward> wardById = {};
  Map<String, Bed> bedById = {};

  WardManager({
    required this.wardFilePath,
    required this.wardRepo,
    required this.roomRepo,
    required this.bedRepo,
  }) {
    initialize();
  }

  void ensureFileExist(String filePath) {
    final file = File(filePath);
    final dir = file.parent;
    if (!dir.existsSync()) dir.createSync(recursive: true);
    if (!file.existsSync()) file.writeAsString(jsonEncode({'ward': []}));
  }

  void initialize() {
    ensureFileExist(wardFilePath);

    //load room
    final rooms = roomRepo.readRooms({});
    roomById = {for (var room in rooms) room.id: room};

    //load bed
    final beds = bedRepo.readBeds(roomById);
    bedById = {for (var bed in beds) bed.id: bed};
    for (var bed in beds) {
      bed.room.beds.add(bed);
    }

    // load ward
    wards = wardRepo.readWards(roomById);
    wardById = {for (var ward in wards) ward.id: ward};

    print('WardManager initialized: ${wards.length} wards loaded.');
  }

  void viewAllWards() {
    if (wards.isEmpty) {
      print('No wards found');
      return;
    }
    for (var ward in wards) {
      print(
        "Ward: ${ward.name} ${ward.type.name} - ${ward.rooms.length} rooms",
      );
      for (var room in ward.rooms) {
        print('Room ${room.roomNumber} - ${room.beds.length} bed (s)');
      }
    }
  }

  void addWard() {
    print("\n==== Add New Ward ====");
    stdout.write("Ward Name: ");
    final name = stdin.readLineSync()?.trim() ?? '';
    if (name.isEmpty) {
      print("Invalid name");
      return;
    }

    print("\nWard Type:");
    print("1.General");
    print("2.Surgery");
    print("3.ICU");
    print("4.Maternity");
    stdout.write("Enter Ward Type: ");
    stdout.write("Select (1-4): ");
    final choice = int.tryParse(stdin.readLineSync() ?? '') ?? 1;
    final types = [
      WardType.general,
      WardType.surgery,
      WardType.icu,
      WardType.maternity,
    ];
    final selectedType = types[choice - 1];
    final ward = Ward(name: name, type: selectedType, rooms: []);
    wards.add(ward);
    wardById[ward.id] = ward;
    wardRepo.writeWards(wards);
    print('Ward ${ward.name} added successfully!');
  }

  void assignRoomToWard() {
    stdout.write("Enter ward ID: ");
    final wardId = stdin.readLineSync()?.trim();
    final ward = wardById[wardId];
    if (ward == null) {
      print("ID not found");
      return;
    }

    stdout.write("Enter room number to add: ");
    final roomNumber = stdin.readLineSync()?.trim() ?? '';
    Room? room;
    try {
      room = roomById.values.firstWhere((r) => r.roomNumber == roomNumber);
    } catch (_) {
      room = null;
    }
    if (room == null) {
      print("Room not found");
      return;
    }
    if (ward.rooms.contains(room)) {
      print("Room already exists in this ward");
      return;
    }

    final roomAlreadyInWard = wards.any((w) => w.rooms.contains(room));
    if (roomAlreadyInWard) {
      print("Room ${room.roomNumber} is already in another ward");
      return;
    }
    if (!ward.type.allowedRoomTypes.contains(room.type)) {
      print(
        "\n==== Failed ====\n"
        "Room type ${room.type.name} is not allowed in ${ward.type.name} ward. "
        "Room type must be the same type as Ward Type!",
      );
      return;
    }

    ward.rooms.add(room);
    roomRepo.writeRooms(roomById.values.toList());
    wardRepo.writeWards(wards);
    print('Room ${room.roomNumber} added to Ward ${ward.name}');
  }

  void removeRoomFromWard() {
    stdout.write("Enter Ward ID: ");
    final wardId = stdin.readLineSync()?.trim();
    final ward = wardById[wardId];
    if (ward == null) {
      print("Ward ID not found!");
      return;
    }
    print("Rooms in ${ward.name}: ");
    for (var room in ward.rooms) {
      print("- Room ${room.roomNumber}");
    }

    stdout.write("Enter room number to remove: ");
    final roomNumber = stdin.readLineSync()?.trim();
    if (roomNumber == null || roomNumber.isEmpty) {
      print("Invalid Room Number");
      return;
    }

    final room = ward.rooms.where((r) => r.roomNumber == roomNumber).isNotEmpty
        ? ward.rooms.firstWhere((r) => r.roomNumber == roomNumber)
        : null;
    if (room == null) {
      print("Room not found in Ward");
      return;
    }

    ward.rooms.remove(room);
    wardRepo.writeWards(wards);
    print("Room ${room.roomNumber} removed from Ward ${ward.name}.");
  }

  void updateWard() {
    stdout.write("Enter Ward ID to update: ");
    final wardId = stdin.readLineSync()?.trim();
    final ward = wardById[wardId];
    if (ward == null) {
      print("Ward ID not found");
      return;
    }

    print("\n ==== Editing ${ward.name} (${ward.type.name}) ====");
    stdout.write("Enter a new name (or press Enter to keep '${ward.name}'): ");
    final newName = stdin.readLineSync()?.trim();
    if (newName != null && newName.isNotEmpty) {
      ward.name = newName;
    }
    print("\nWard Type:");
    print("1.General");
    print("2.Surgery");
    print("3.ICU");
    print("4.Maternity");
    stdout.write(
      "\nEnter Ward Type (or press Enter to keep '${ward.type.name}')\n",
    );
    stdout.write("Select (1-4): ");
    final typeInput = stdin.readLineSync()?.trim();
    if (typeInput != null && typeInput.isNotEmpty) {
      final typeIndex = int.tryParse(typeInput);
      if (typeIndex != null && typeIndex >= 1 && typeIndex <= 4) {
        final types = [
          WardType.general,
          WardType.surgery,
          WardType.icu,
          WardType.maternity,
        ];
        final newType = types[typeIndex - 1];
        ward.type = newType;
        for (var room in ward.rooms) {
          if (!newType.allowedRoomTypes.contains(room.type)) {
            print(
              "Changing room ${room.roomNumber} type from ${room.type.name} to ${newType.allowedRoomTypes.first.name}",
            );
            room.type = newType.allowedRoomTypes.first;
          }
        }
        ward.type = newType;
      }
    }
    wardRepo.writeWards(wards);
    print("Ward ${ward.name} updated successfully!");
  }
}
