import 'dart:io';
import 'package:test/test.dart';
import 'package:hospital_management_system__managing_rooms/domain/bed_allocation.dart';
import 'package:hospital_management_system__managing_rooms/domain/services/bed_allocation_service.dart';
import 'package:hospital_management_system__managing_rooms/domain/patient.dart';
import 'package:hospital_management_system__managing_rooms/domain/bed.dart';
import 'package:hospital_management_system__managing_rooms/domain/room.dart';
import 'package:hospital_management_system__managing_rooms/domain/ward.dart';
import 'package:hospital_management_system__managing_rooms/domain/value_objects/contact_info.dart';
import 'package:hospital_management_system__managing_rooms/data/bed_allocation_repository.dart';

void main() {
  group('BedAllocation test:', () {
    late Patient patient1;
    late Patient patient2;
    late Room room1;
    late Room room2;
    late Bed bed1;
    late Bed bed2;
    late Bed bed3;
    late BedAllocation activeAllocation;
    late Map<String, Patient> patientById;
    late Map<String, Bed> bedById;

    setUp(() {
      // Create mock patients
      final contactInfo1 = ContactInfo(phone: '123-456-7890', email: 'patient1@example.com', address: '123 Phnum Penh');
      final contactInfo2 = ContactInfo(phone: '234-567-8901', email: 'patient2@example.com', address: '456 Phnum Penh');
      patient1 = Patient(id: 'patient-1', name: 'Poy1', age: 45, gender: 'Male', contactInfo: contactInfo1);
      patient2 = Patient(id: 'patient-2', name: 'Poy2', age: 32, gender: 'Female', contactInfo: contactInfo2);
      patientById = {patient1.id: patient1, patient2.id: patient2};

      // Create mock rooms and beds
      room1 = Room(id: 'room-1', roomNumber: '101', type: RoomType.generalWard);
      room2 = Room(id: 'room-2', roomNumber: '102', type: RoomType.semiPrivate);

      bed1 = Bed(id: 'bed-1', room: room1, bedNumber: 'A', status: BedStatus.available);
      bed2 = Bed(id: 'bed-2', room: room1, bedNumber: 'B', status: BedStatus.occupied);
      bed3 = Bed(id: 'bed-3', room: room2, bedNumber: 'A', status: BedStatus.available);

      room1.addBed(bed1);
      room1.addBed(bed2);
      room2.addBed(bed3);

      bedById = {bed1.id: bed1, bed2.id: bed2, bed3.id: bed3};

      // Create mock allocations
      final startDate1 = DateTime.now().subtract(const Duration(days: 2));
      DateTime.now().subtract(const Duration(days: 5));
      DateTime.now().subtract(const Duration(days: 1));

      activeAllocation = BedAllocation(id: 'allocation-1', patient: patient1, bed: bed1, status: AllocationStatus.active, startDate: startDate1);


    });

    test('Create allocation from json', () {
      final jsonData = {'id': 'test-allocation-id', 'patientId': patient1.id, 'bedId': bed1.id, 'status': 'active', 'startDate': DateTime.now().toIso8601String()};

      final allocation = BedAllocation.fromJson(jsonData, patientById, bedById);

      expect(allocation.id, equals('test-allocation-id'));
      expect(allocation.patient.id, equals(patient1.id));
      expect(allocation.bed.id, equals(bed1.id));
      expect(allocation.status, equals(AllocationStatus.active));
    });

    test('Convert allocation to json', () {
      final json = activeAllocation.toJson();

      expect(json['id'], equals(activeAllocation.id));
      expect(json['patientId'], equals(patient1.id));
      expect(json['bedId'], equals(bed1.id));
      expect(json['status'], equals('active'));
    });

    test('Patient successfully complete active allocation', () {
      final testBed = Bed(room: room1, bedNumber: 'C', status: BedStatus.available);
      final testAllocation = BedAllocation(patient: patient1, bed: testBed, status: AllocationStatus.active, startDate: DateTime.now());
      testBed.occupy(testAllocation);

      final endTime = DateTime.now();
      testAllocation.complete(endTime);

      expect(testAllocation.status, equals(AllocationStatus.completed));
      expect(testAllocation.endDate, equals(endTime));
      expect(testBed.status, equals(BedStatus.available));
    });

    test('Patient successfully transfer to available bed', () {
      final testBed1 = Bed(room: room1, bedNumber: 'D', status: BedStatus.available);
      final testBed2 = Bed(room: room2, bedNumber: 'B', status: BedStatus.available);
      final testAllocation = BedAllocation(patient: patient1, bed: testBed1, status: AllocationStatus.active, startDate: DateTime.now());
      testBed1.occupy(testAllocation);

      testAllocation.transferTo(testBed2);

      expect(testAllocation.bed, equals(testBed2));
      expect(testBed1.status, equals(BedStatus.available));
      expect(testBed2.status, equals(BedStatus.occupied));
      expect(testBed2.currentAllocation, equals(testAllocation));
    });

    test('Calculate duration correctly when the allocation is completed', () {
      final startDate = DateTime.now().subtract(const Duration(days: 5));
      final endDate = DateTime.now();
      final testAllocation = BedAllocation(patient: patient1, bed: bed1, status: AllocationStatus.completed, startDate: startDate, endDate: endDate);

      final duration = testAllocation.getDuration();

      expect(duration.inDays, equals(5));
    });
  });

  group('BedAllocationService:', () {
    late Patient patient1;
    late Patient patient2;
    late Room room1;
    late Room room2;
    late Room room3;
    late Bed bed1;
    late Bed bed2;
    late Bed bed3;
    late Bed bed4;
    late Bed bed5;
    late Ward ward1;
    late Ward ward2;
    late BedAllocationRepository repository;

    setUp(() {
      // Create mock patients
      final contactInfo1 = ContactInfo(phone: '123-456-7890', email: 'patient1@example.com', address: '123 Phnum Penh');
      final contactInfo2 = ContactInfo(phone: '234-567-8901', email: 'patient2@example.com', address: '456 Phnum Penh');
      patient1 = Patient(id: 'patient-1', name: 'Poy1', age: 45, gender: 'Male', contactInfo: contactInfo1);
      patient2 = Patient(id: 'patient-2', name: 'Poy2', age: 32, gender: 'Female', contactInfo: contactInfo2);

      // Create mock rooms and beds
      room1 = Room(id: 'room-1', roomNumber: '101', type: RoomType.generalWard);
      room2 = Room(id: 'room-2', roomNumber: '102', type: RoomType.semiPrivate);
      room3 = Room(id: 'room-3', roomNumber: '201', type: RoomType.private);

      bed1 = Bed(id: 'bed-1', room: room1, bedNumber: 'A', status: BedStatus.available);
      bed2 = Bed(id: 'bed-2', room: room1, bedNumber: 'B', status: BedStatus.available);
      bed3 = Bed(id: 'bed-3', room: room2, bedNumber: 'A', status: BedStatus.available);
      bed4 = Bed(id: 'bed-4', room: room3, bedNumber: 'A', status: BedStatus.occupied);
      bed5 = Bed(id: 'bed-5', room: room3, bedNumber: 'B', status: BedStatus.occupied);

      room1.addBed(bed1);
      room1.addBed(bed2);
      room2.addBed(bed3);
      room3.addBed(bed4);
      room3.addBed(bed5);

      // Create mock wards
      ward1 = Ward(id: 'ward-1', name: 'General Ward A', type: WardType.general, rooms: [room1, room2]);
      ward2 = Ward(id: 'ward-2', name: 'Private Ward', type: WardType.general, rooms: [room3]);


      // Create repository with a temporary file path for testing
      final tempFile = File('${Directory.systemTemp.path}/test_bed_allocations.json');
      repository = BedAllocationRepository(tempFile.path);
    });

    test('Successfully admit patient to ward with available bed', () {
      final service = BedAllocationService(repository: repository);

      final allocation = service.admitPatient(patient1, ward1);

      expect(allocation, isA<BedAllocation>());
      expect(allocation.patient, equals(patient1));
      expect(allocation.status, equals(AllocationStatus.active));
      expect(allocation.bed.status, equals(BedStatus.occupied));
      expect(service.allocations, contains(allocation));
    });

    test('Successfully transfered patient to new ward', () {
      final service = BedAllocationService(repository: repository);

      // Admit patient to ward1
      final originalAllocation = service.admitPatient(patient1, ward1);
      final originalBed = originalAllocation.bed;

      // Transfer to ward2 
      bed4.status = BedStatus.available;
      final transferredAllocation = service.transferPatient(patient1, ward2);

      expect(transferredAllocation.patient, equals(patient1));
      expect(transferredAllocation.bed.room, isNot(equals(originalBed.room)));
      expect(originalBed.status, equals(BedStatus.available));
      expect(transferredAllocation.bed.status, equals(BedStatus.occupied));
    });

    test('Successfully discharged patient', () {
      final service = BedAllocationService(repository: repository);

      final allocation = service.admitPatient(patient2, ward1);
      final bed = allocation.bed;

      service.dischargePatient(patient2);

      expect(allocation.status, equals(AllocationStatus.completed));
      expect(allocation.endDate, isNotNull);
      expect(bed.status, equals(BedStatus.available));
    });
  });
}
