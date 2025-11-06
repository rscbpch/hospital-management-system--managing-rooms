import 'package:test/test.dart';
import 'package:hospital_management_system__managing_rooms/domain/room.dart';
import 'package:hospital_management_system__managing_rooms/domain/bed.dart';

void main() {
  group('Room:', () {
    late Room room;
    late Bed bed1;
    late Bed bed2;

    setUp(() {
      room = Room(roomNumber: '101', type: RoomType.generalWard);
      bed1 = Bed(room: room, bedNumber: '1', status: BedStatus.available);
      bed2 = Bed(room: room, bedNumber: '2', status: BedStatus.available);
    });

    test('Create room from json', () {
      final bedsJson = [
        {'id': bed1.id, 'bedNumber': '1', 'status': 'available'},
        {'id': bed2.id, 'bedNumber': '2', 'status': 'available'},
      ];
      final jsonData = {'id': 'test-room-id', 'roomNumber': '201', 'type': 'private', 'beds': bedsJson};

      final beds = [bed1, bed2];
      final room = Room.fromJson(jsonData, beds);

      expect(room.id, equals('test-room-id'));
      expect(room.roomNumber, equals('201'));
      expect(room.type, equals(RoomType.private));
      expect(room.beds.length, equals(2));
    });

    test('Convert room to json', () {
      room.addBed(bed1);
      room.addBed(bed2);

      final json = room.toJson();

      expect(json['id'], equals(room.id));
      expect(json['roomNumber'], equals(room.roomNumber));
      expect(json['type'], equals(room.type.name));
      expect(json['beds'], isA<List>());
      expect(json['beds'].length, equals(2));
    });

    test('Successfully add a bed to the room', () {
      expect(room.beds.length, equals(0));
      room.addBed(bed1);
      expect(room.beds.length, equals(1));
      expect(room.beds, contains(bed1));
    });

    test('Successfully remove an available bed', () {
      room.addBed(bed1);
      room.addBed(bed2);
      expect(room.beds.length, equals(2));

      final removed = room.removeBed(bed1.id);
      expect(removed, isTrue);
      expect(room.beds.length, equals(1));
      expect(room.beds, isNot(contains(bed1)));
      expect(room.beds, contains(bed2));
    });

    test('Return false when bed does not exist', () {
      room.addBed(bed1);
      final removed = room.removeBed('non-existent-id');
      expect(removed, isFalse);
      expect(room.beds.length, equals(1));
    });
  });
}
