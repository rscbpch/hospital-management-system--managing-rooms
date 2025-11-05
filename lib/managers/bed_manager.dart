import 'dart:io';
import 'package:hospital_management_system__managing_rooms/data/bed_repository.dart';
import 'package:hospital_management_system__managing_rooms/data/room_repository.dart';
import 'package:hospital_management_system__managing_rooms/domain/bed.dart';
import 'package:hospital_management_system__managing_rooms/domain/room.dart';

class BedManager {
  final BedRepository bedRepo;
  final RoomRepository roomRepo;
  final String bedFilePath;

  List<Bed> beds = [];
  Map<String, Bed> bedById = {};

  BedManager({
    required this.bedFilePath,
    required this.bedRepo,
    required this.roomRepo,
  }) {
    initialize();
  }

  void initialize() {
    ensureFileExist(bedFilePath);

    //load rooms
    final rooms = roomRepo.readRooms(bedById);
    beds = bedRepo.readBeds({for (var room in rooms) room.id: room});
    bedById = {for (var bed in beds) bed.id: bed};

    for (var bed in beds) {
      if (!bed.room.beds.contains(bed)) {
        bed.room.beds.add(bed);
      }
    }
  }

  void ensureFileExist(String filePath) {
    final file = File(filePath);
    final dir = file.parent;

    if (!dir.existsSync()) dir.createSync(recursive: true);
    if (!file.existsSync()) file.writeAsStringSync('{"beds": []}');
  }

  List<Bed> getAllBeds() => beds;

  List<Bed> getAvailableBed() =>
      beds.where((b) => b.status == BedStatus.available).toList();

  void addBedToRoom(Room room, Bed bed) {
    if (room.beds.any((b) => b.id == bed.id)) {
      throw ArgumentError('Bed already exists in this room');
    }

    bed.room = room;
    room.beds.add(bed);
    beds.add(bed);
    bedById[bed.id] = bed;

    bedRepo.writeBeds([bed]);
  }

  void updateBedStatus(Bed bed, BedStatus status) {
    bed.status = status;
    bedRepo.writeBeds([bed]);
  }

  Bed? findBedById(String id) => bedById[id];
}
