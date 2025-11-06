import 'package:test/test.dart';
import 'package:hospital_management_system__managing_rooms/domain/bed.dart';
import 'package:hospital_management_system__managing_rooms/domain/room.dart';
import 'package:hospital_management_system__managing_rooms/domain/bed_allocation.dart';
import 'package:hospital_management_system__managing_rooms/domain/patient.dart';
import 'package:hospital_management_system__managing_rooms/domain/value_objects/contact_info.dart';

void main() {
  group('Bed:', () {
    late Room room1;
    late Room room2;
    late Bed bed1;
    late Bed bed2;
    late Bed bed3;
    late Bed bed4;
    late Bed bed5;
    late Map<String, Room> roomById;
    late Patient patient;
    late ContactInfo contactInfo;

    setUp(() {
      // Create mock rooms
      room1 = Room(roomNumber: '101', type: RoomType.generalWard);
      room2 = Room(roomNumber: '102', type: RoomType.semiPrivate);

      // Create mock beds with different statuses
      bed1 = Bed(room: room1, bedNumber: 'A', status: BedStatus.available);
      bed2 = Bed(room: room1, bedNumber: 'B', status: BedStatus.occupied);
      bed3 = Bed(room: room1, bedNumber: 'C', status: BedStatus.reserved);
      bed4 = Bed(room: room2, bedNumber: 'A', status: BedStatus.available);
      bed5 = Bed(room: room2, bedNumber: 'B', status: BedStatus.occupied);

      // Add beds to rooms
      room1.addBed(bed1);
      room1.addBed(bed2);
      room1.addBed(bed3);
      room2.addBed(bed4);
      room2.addBed(bed5);

      roomById = {room1.id: room1, room2.id: room2};

      // Create mock patient for allocation tests
      contactInfo = ContactInfo(phone: '123-456-7890', email: 'test@example.com', address: '123 Test St');
      patient = Patient(name: 'Test Patient', age: 30, gender: 'Male', contactInfo: contactInfo);
    });

    test('Create bed from json', () {
      final jsonData = {'id': 'test-bed-id', 'roomId': room1.id, 'bedNumber': 'X', 'status': 'available'};

      final bed = Bed.fromJson(jsonData, roomById);

      expect(bed.id, equals('test-bed-id'));
      expect(bed.bedNumber, equals('X'));
      expect(bed.status, equals(BedStatus.available));
      expect(bed.room.id, equals(room1.id));
    });

    test('Convert bed to json', () {
      final json = bed1.toJson();

      expect(json['id'], equals(bed1.id));
      expect(json['bedNumber'], equals(bed1.bedNumber));
      expect(json['status'], equals(bed1.status.name));
      expect(json['roomId'], equals(room1.id));
    });

    test('Return true for available beds', () {
      expect(bed1.isAvailable(), isTrue);
      expect(bed4.isAvailable(), isTrue);
    });

    test('Successfully assign allocation to available bed', () {
      final testBed = Bed(room: room1, bedNumber: 'D', status: BedStatus.available);
      final allocation = BedAllocation(patient: patient, bed: testBed, startDate: DateTime.now());

      testBed.assign(allocation);

      expect(testBed.status, equals(BedStatus.occupied));
      expect(testBed.currentAllocation, equals(allocation));
    });

    test('Successfully occupy bed with allocation', () {
      final testBed = Bed(room: room1, bedNumber: 'E', status: BedStatus.available);
      final allocation = BedAllocation(patient: patient, bed: testBed, startDate: DateTime.now());

      testBed.occupy(allocation);

      expect(testBed.status, equals(BedStatus.occupied));
      expect(testBed.currentAllocation, equals(allocation));
    });

    test('Successfully release bed and set to available', () {
      final testBed = Bed(room: room1, bedNumber: 'G', status: BedStatus.occupied);
      final allocation = BedAllocation(patient: patient, bed: testBed, startDate: DateTime.now());
      testBed.currentAllocation = allocation;

      testBed.release();

      expect(testBed.status, equals(BedStatus.available));
      expect(testBed.currentAllocation, isNull);
    });

    test('Successfully reserve bed', () {
      final testBed = Bed(room: room1, bedNumber: 'H', status: BedStatus.available);

      testBed.reserve();

      expect(testBed.status, equals(BedStatus.reserved));
    });
  });
}
