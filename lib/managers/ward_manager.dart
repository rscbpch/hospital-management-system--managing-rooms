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
      WardType.icu,
      WardType.maternity,
      WardType.surgery,
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

    ward.rooms.add(room);
    wardRepo.writeWards(wards);
    print('Room ${room.roomNumber} added to Ward ${ward.name}');
  }
}
