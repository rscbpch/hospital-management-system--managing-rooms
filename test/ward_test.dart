import 'package:test/test.dart';
import 'package:hospital_management_system__managing_rooms/domain/ward.dart';
import 'package:hospital_management_system__managing_rooms/domain/room.dart';
import 'package:hospital_management_system__managing_rooms/domain/bed.dart';

void main() {
  group('Ward:', () {
    late Room room1;
    late Room room2;
    late Room room3;
    late Bed bed1;
    late Bed bed2;
    late Bed bed3;
    late Bed bed4;
    late Bed bed5;
    late Bed bed6;
    late Ward ward;

    setUp(() {
      // Create mock rooms
      room1 = Room(roomNumber: '101', type: RoomType.generalWard);
      room2 = Room(roomNumber: '102', type: RoomType.semiPrivate);
      room3 = Room(roomNumber: '201', type: RoomType.private);

      // Create mock beds
      bed1 = Bed(room: room1, bedNumber: 'A', status: BedStatus.available);
      bed2 = Bed(room: room1, bedNumber: 'B', status: BedStatus.occupied);
      bed3 = Bed(room: room1, bedNumber: 'C', status: BedStatus.reserved);

      bed4 = Bed(room: room2, bedNumber: 'A', status: BedStatus.available);
      bed5 = Bed(room: room2, bedNumber: 'B', status: BedStatus.available);

      bed6 = Bed(room: room3, bedNumber: 'A', status: BedStatus.occupied);

      // Add beds to rooms
      room1.addBed(bed1);
      room1.addBed(bed2);
      room1.addBed(bed3);
      room2.addBed(bed4);
      room2.addBed(bed5);
      room3.addBed(bed6);

      // Create mock ward
      ward = Ward(name: 'General Ward A', type: WardType.general, rooms: [room1, room2, room3]);
    });

    test('Create ward from json', () {
      final roomById = {room1.id: room1, room2.id: room2, room3.id: room3};
      final jsonData = {
        'id': 'test-ward-id',
        'name': 'Test Ward',
        'type': 'general',
        'rooms': [
          {'id': room1.id},
          {'id': room2.id},
        ],
      };

      final ward = Ward.fromJson(jsonData, roomById);

      expect(ward.id, equals('test-ward-id'));
      expect(ward.name, equals('Test Ward'));
      expect(ward.type, equals(WardType.general));
      expect(ward.rooms.length, equals(2));
      expect(ward.rooms, contains(room1));
      expect(ward.rooms, contains(room2));
    });

    test('Convert ward to json', () {
      final json = ward.toJson();

      expect(json['id'], equals(ward.id));
      expect(json['name'], equals(ward.name));
      expect(json['type'], equals(ward.type.name));
      expect(json['rooms'], isA<List>());
      expect(json['rooms'].length, equals(ward.rooms.length));
    });

    test('Return all available beds in ward', () {
      final availableBeds = ward.getAvailableBeds();

      expect(availableBeds.length, equals(3)); 
      expect(availableBeds, contains(bed1));
      expect(availableBeds, contains(bed4));
      expect(availableBeds, contains(bed5));
      expect(availableBeds.every((b) => b.status == BedStatus.available), isTrue);
    });

    test('Return rooms with available beds', () {
      final availableRooms = ward.getAvailableRooms();

      expect(availableRooms.length, equals(2));
      expect(availableRooms, contains(room1));
      expect(availableRooms, contains(room2));
      expect(availableRooms.every((r) => r.hasAvailableBeds()), isTrue);
    });

    test('Successfully add compatible room to ward', () {
      final newRoom = Room(roomNumber: '301', type: RoomType.private);
      final newBed = Bed(room: newRoom, bedNumber: '1', status: BedStatus.available);
      newRoom.addBed(newBed);

      final originalRoomCount = ward.rooms.length;
      ward.addRoom(newRoom);

      expect(ward.rooms.length, equals(originalRoomCount + 1));
      expect(ward.rooms, contains(newRoom));
    });

    test('Successfully remove room with no occupied beds', () {
      final roomToRemove = room2; 
      final originalRoomCount = ward.rooms.length;

      final removed = ward.removeRoom(roomToRemove.id);

      expect(removed, isTrue);
      expect(ward.rooms.length, equals(originalRoomCount - 1));
      expect(ward.rooms, isNot(contains(roomToRemove)));

      ward.rooms.add(roomToRemove);
    });

    test('Successfully update ward type when all rooms are compatible', () {
      final compatibleRoom1 = Room(roomNumber: '301', type: RoomType.semiPrivate);
      final compatibleRoom2 = Room(roomNumber: '302', type: RoomType.private);
      final compatibleBed1 = Bed(room: compatibleRoom1, bedNumber: 'A', status: BedStatus.available);
      final compatibleBed2 = Bed(room: compatibleRoom2, bedNumber: 'A', status: BedStatus.available);
      compatibleRoom1.addBed(compatibleBed1);
      compatibleRoom2.addBed(compatibleBed2);

      final compatibleWard = Ward(name: 'Surgery Ward', type: WardType.general, rooms: [compatibleRoom1, compatibleRoom2]);

      compatibleWard.updateWard(type: WardType.surgery);

      expect(compatibleWard.type, equals(WardType.surgery));
    });

    test('Successfully update both name and type', () {
      final compatibleRoom1 = Room(roomNumber: '401', type: RoomType.semiPrivate);
      final compatibleRoom2 = Room(roomNumber: '402', type: RoomType.private);
      final compatibleBed1 = Bed(room: compatibleRoom1, bedNumber: 'A', status: BedStatus.available);
      final compatibleBed2 = Bed(room: compatibleRoom2, bedNumber: 'A', status: BedStatus.available);
      compatibleRoom1.addBed(compatibleBed1);
      compatibleRoom2.addBed(compatibleBed2);

      final compatibleWard = Ward(name: 'Test Ward', type: WardType.general, rooms: [compatibleRoom1, compatibleRoom2]);
      final newName = 'Updated Ward';

      compatibleWard.updateWard(name: newName, type: WardType.surgery);

      expect(compatibleWard.name, equals(newName));
      expect(compatibleWard.type, equals(WardType.surgery));
    });
  });
}
