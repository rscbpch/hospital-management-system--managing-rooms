import 'package:test/test.dart';
import 'package:hospital_management_system__managing_rooms/domain/reservation.dart';
import 'package:hospital_management_system__managing_rooms/domain/services/reservation_service.dart';
import 'package:hospital_management_system__managing_rooms/domain/patient.dart';
import 'package:hospital_management_system__managing_rooms/domain/bed.dart';
import 'package:hospital_management_system__managing_rooms/domain/room.dart';
import 'package:hospital_management_system__managing_rooms/domain/value_objects/contact_info.dart';
import 'package:hospital_management_system__managing_rooms/data/reservation_repository.dart';
import 'dart:io';

void main() {
  group('Reservation:', () {
    late Patient patient1;
    late Patient patient2;
    late Room room1;
    late Room room2;
    late Bed bed1;
    late Bed bed2;
    late Bed bed3;
    late Reservation pendingReservation;
    late Map<String, Patient> patientById;
    late Map<String, Bed> bedById;

    setUp(() {
      // Create mock patients
      final contactInfo1 = ContactInfo(phone: '123-456-7890', email: 'patient1@example.com', address: '123 Phnum Penh');
      final contactInfo2 = ContactInfo(phone: '234-567-8901', email: 'patient2@example.com', address: '456 Phnum Penh');
      patient1 = Patient(name: 'Poy1', age: 45, gender: 'Male', contactInfo: contactInfo1);
      patient2 = Patient(name: 'Poy2', age: 32, gender: 'Female', contactInfo: contactInfo2);
      patientById = {patient1.id: patient1, patient2.id: patient2};

      // Create mock rooms and beds
      room1 = Room(roomNumber: '101', type: RoomType.generalWard);
      room2 = Room(roomNumber: '102', type: RoomType.semiPrivate);

      bed1 = Bed(room: room1, bedNumber: 'A', status: BedStatus.available);
      bed2 = Bed(room: room1, bedNumber: 'B', status: BedStatus.available);
      bed3 = Bed(room: room2, bedNumber: 'A', status: BedStatus.available);

      room1.addBed(bed1);
      room1.addBed(bed2);
      room2.addBed(bed3);

      bedById = {bed1.id: bed1, bed2.id: bed2, bed3.id: bed3};

      // Create mock reservations
      pendingReservation = Reservation(patient: patient1, bed: bed1, status: ReservationStatus.pending, reservedDate: DateTime.now());


    });

    test('Create reservation from json', () {
      final jsonData = {'id': 'test-reservation-id', 'patientId': patient1.id, 'bedId': bed1.id, 'status': 'pending', 'reservedDate': DateTime.now().toIso8601String()};

      final reservation = Reservation.fromJson(jsonData, patientById, bedById);

      expect(reservation.id, equals('test-reservation-id'));
      expect(reservation.patient.id, equals(patient1.id));
      expect(reservation.bed.id, equals(bed1.id));
      expect(reservation.status, equals(ReservationStatus.pending));
    });

    test('Convert reservation to json', () {
      final json = pendingReservation.toJson();

      expect(json['id'], equals(pendingReservation.id));
      expect(json['patientId'], equals(patient1.id));
      expect(json['bedId'], equals(bed1.id));
      expect(json['status'], equals('pending'));
      expect(json['reservedDate'], isA<String>());
    });

    test('Successfully confirm pending reservation', () {
      final reservation = Reservation(patient: patient1, bed: bed1, status: ReservationStatus.pending, reservedDate: DateTime.now());
      final bed = reservation.bed;

      reservation.confirmReservation(bed);

      expect(reservation.status, equals(ReservationStatus.confirmed));
      expect(bed.status, equals(BedStatus.reserved));
    });

    group('Successfully cancel', () {
      test('pending reservation', () {
        final reservation = Reservation(patient: patient1, bed: bed1, status: ReservationStatus.pending, reservedDate: DateTime.now());
        final bed = reservation.bed;
        bed.reserve(); 

        reservation.cancelReservation();

        expect(reservation.status, equals(ReservationStatus.cancelled));
        expect(bed.status, equals(BedStatus.available));
      });

      test('confirmed reservation', () {
        final reservation = Reservation(patient: patient1, bed: bed1, status: ReservationStatus.confirmed, reservedDate: DateTime.now());
        final bed = reservation.bed;
        bed.reserve();

        reservation.cancelReservation();

        expect(reservation.status, equals(ReservationStatus.cancelled));
        expect(bed.status, equals(BedStatus.available));
      });
    });

    group('Expire', () {
      test('pending reservation', () {
        final reservation = Reservation(patient: patient1, bed: bed1, status: ReservationStatus.pending, reservedDate: DateTime.now());
        final bed = reservation.bed;
        bed.status = BedStatus.reserved; 

        reservation.expire();

        expect(reservation.status, equals(ReservationStatus.cancelled));
        expect(bed.status, equals(BedStatus.available));
      });

      test('confirmed reservation', () {
        final reservation = Reservation(patient: patient1, bed: bed1, status: ReservationStatus.confirmed, reservedDate: DateTime.now());
        final bed = reservation.bed;
        bed.status = BedStatus.reserved; 

        reservation.expire();

        expect(reservation.status, equals(ReservationStatus.cancelled));
        expect(bed.status, equals(BedStatus.available));
      });
    });
  });

  group('ReservationService: ', () {
    late List<Room> rooms;
    late Patient patient;
    late Bed availableBed1;
    late Bed availableBed2;
    late ReservationRepository repository;

    setUp(() {
      // Create mock rooms with available beds
      final room1 = Room(roomNumber: '101', type: RoomType.generalWard);
      final room2 = Room(roomNumber: '102', type: RoomType.semiPrivate);

      availableBed1 = Bed(room: room1, bedNumber: 'A', status: BedStatus.available);
      availableBed2 = Bed(room: room2, bedNumber: 'A', status: BedStatus.available);

      room1.addBed(availableBed1);
      room2.addBed(availableBed2);

      rooms = [room1, room2];

      final contactInfo = ContactInfo(phone: '123-456-7890', email: 'patient@example.com', address: '123 Phnum Penh');
      patient = Patient(name: 'Test Patient', age: 30, gender: 'Male', contactInfo: contactInfo);

      // Create repository with a temporary file path for testing
      final tempFile = File('${Directory.systemTemp.path}/test_reservations.json');
      repository = ReservationRepository(tempFile.path);
    });

    test('Successfully create reservation for available bed', () {
      final service = ReservationService(rooms: rooms, repository: repository);

      final reservation = service.createReservation(patient, RoomType.generalWard);

      expect(reservation, isA<Reservation>());
      expect(reservation.patient, equals(patient));
      expect(reservation.status, equals(ReservationStatus.pending));
      expect(service.reservations, contains(reservation));
    });

    test('Successfully cancel reservation by id', () {
      final service = ReservationService(rooms: rooms, repository: repository);

      final reservation = service.createReservation(patient, RoomType.generalWard);
      final reservationId = reservation.id;

      service.cancelReservation(reservationId);

      expect(reservation.status, equals(ReservationStatus.cancelled));
    });

    test('Successfully confirm reservation by id', () {
      final service = ReservationService(rooms: rooms, repository: repository);

      final reservation = service.createReservation(patient, RoomType.generalWard);
      final reservationId = reservation.id;
      final bed = reservation.bed;

      service.confirmReservation(reservationId);

      expect(reservation.status, equals(ReservationStatus.confirmed));
      expect(bed.status, equals(BedStatus.reserved));
    });
  });
}
