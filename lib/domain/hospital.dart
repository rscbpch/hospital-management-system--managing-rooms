import 'package:uuid/uuid.dart';
import 'package:hospital_management_system__managing_rooms/domain/ward.dart';
import 'package:hospital_management_system__managing_rooms/domain/room.dart';
import 'package:hospital_management_system__managing_rooms/domain/bed.dart';

var uuid = Uuid();

class Hospital {
  final String id;
  final String name;
  final String address;
  final List<Ward> wards;

  Hospital({String? id, required this.name, required this.address, List<Ward>? wards}) : id = id ?? uuid.v4(), wards = wards ?? [];

  factory Hospital.fromJson(Map<String, dynamic> json, Map<String, Ward> wardById) {
    final wardsJson = json['wards'] as List<dynamic>? ?? [];
    final List<Ward> wards = [];

    for (var wardId in wardsJson) {
      if (wardId is String) {
        final ward = wardById[wardId];
        if (ward != null) {
          wards.add(ward);
        }
      }
    }

    return Hospital(id: json['id'] as String?, name: json['name'] as String? ?? '', address: json['address'] as String? ?? '', wards: wards);
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'address': address, 'wards': wards.map((w) => w.toJson()).toList()};

  @override
  String toString() => 'Hospital $name, Address: $address';

  /// Adds a ward to the hospital
  void addWard(Ward ward) {
    if (wards.any((w) => w.id == ward.id)) {
      throw ArgumentError('Ward with id ${ward.id} already exists in this hospital');
    }
    wards.add(ward);
  }

  /// Removes a ward from the hospital by ID
  bool removeWard(String wardId) {
    final wardIndex = wards.indexWhere((ward) => ward.id == wardId);
    if (wardIndex == -1) {
      return false;
    }

    final ward = wards[wardIndex];
    // Only allow removal if ward has no occupied beds
    final availableBeds = ward.getAvailableBeds();
    final totalBeds = ward.rooms.fold<int>(0, (sum, room) => sum + room.beds.length);
    if (availableBeds.length < totalBeds) {
      throw StateError('Cannot remove ward that has occupied beds. Ward must be empty.');
    }

    wards.removeAt(wardIndex);
    return true;
  }

  /// Finds a room by ID across all wards
  Room? findRoomById(String roomId) {
    for (var ward in wards) {
      final room = ward.rooms.firstWhere(
        (r) => r.id == roomId,
        orElse: () => ward.rooms.first, // fallback
      );
      if (room.id == roomId) {
        return room;
      }
    }
    return null;
  }

  /// Finds a ward by ID
  Ward? findWardById(String wardId) {
    try {
      return wards.firstWhere((ward) => ward.id == wardId);
    } catch (e) {
      return null;
    }
  }

  /// Finds all available beds, optionally filtered by room type
  List<Bed> findAvailableBeds({RoomType? type}) {
    final List<Bed> availableBeds = [];

    for (var ward in wards) {
      for (var room in ward.rooms) {
        // Filter by room type if specified
        if (type != null && room.type != type) {
          continue;
        }
        availableBeds.addAll(room.getAvailableBeds());
      }
    }

    return availableBeds;
  }

  /// Finds all rooms that have available beds
  List<Room> findAvailableRooms() {
    final List<Room> availableRooms = [];

    for (var ward in wards) {
      availableRooms.addAll(ward.getAvailableRooms());
    }

    return availableRooms;
  }
}
