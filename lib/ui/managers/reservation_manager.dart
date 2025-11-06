import 'dart:convert';
import 'dart:io';
import 'package:hospital_management_system__managing_rooms/data/reservation_repository.dart';
import 'package:hospital_management_system__managing_rooms/domain/reservation.dart';
import 'package:hospital_management_system__managing_rooms/domain/services/reservation_service.dart';
import 'package:hospital_management_system__managing_rooms/domain/room.dart';
import 'package:hospital_management_system__managing_rooms/ui/managers/patient_manager.dart';
import 'package:hospital_management_system__managing_rooms/ui/managers/room_manager.dart';

class ReservationManager {
  final String reservationFilePath;
  final ReservationRepository reservationRepo;
  final PatientManager patientManager;
  final RoomManager roomManager;

  List<Reservation> reservations = [];
  ReservationService? reservationService;

  ReservationManager({required this.reservationFilePath, required this.reservationRepo, required this.patientManager, required this.roomManager}) {
    initialize();
  }

  void ensureFileExists(String filePath) {
    final file = File(filePath);
    final dir = file.parent;
    if (!dir.existsSync()) dir.createSync(recursive: true);
    if (!file.existsSync()) {
      file.writeAsStringSync(jsonEncode({'reservations': []}));
    }
  }

  void initialize() {
    ensureFileExists(reservationFilePath);

    reservations = reservationRepo.readReservations(patientManager.patientById, roomManager.bedById);

    reservationService = ReservationService(rooms: roomManager.rooms, repository: reservationRepo, reservations: reservations);

    print('ReservationManager initialized: ${reservations.length} reservations loaded.');
  }

  void viewAllReservations() {
    if (reservations.isEmpty) {
      print('No reservations found');
      return;
    }

    print('\n==== All Reservations ====');
    for (var reservation in reservations) {
      print('\nReservation ID: ${reservation.id}');
      print('Patient: ${reservation.patient.name}');
      print('Room: ${reservation.bed.room.roomNumber}, Bed: ${reservation.bed.bedNumber}');
      print('Status: ${reservation.status.name}');
      print('Reserved Date: ${reservation.reservedDate}');
      print('Active: ${reservation.isActive()}');
      print('---');
    }
  }

  void viewActiveReservations() {
    final activeReservations = reservations.where((r) => r.isActive()).toList();
    if (activeReservations.isEmpty) {
      print('No active reservations found');
      return;
    }

    print('\n==== Active Reservations ====');
    for (var reservation in activeReservations) {
      print('\nReservation ID: ${reservation.id}');
      print('Patient: ${reservation.patient.name}');
      print('Room: ${reservation.bed.room.roomNumber}, Bed: ${reservation.bed.bedNumber}');
      print('Status: ${reservation.status.name}');
      print('Reserved Date: ${reservation.reservedDate}');
      print('---');
    }
  }

  void createReservation() {
    print('\n==== Create Reservation ====');

    patientManager.printAllPatientIds();
    stdout.write('Enter Patient ID: ');
    final patientId = stdin.readLineSync()?.trim() ?? '';
    final patient = patientManager.findPatientById(patientId);
    if (patient == null) {
      print('Patient not found');
      return;
    }

    print('\nRoom Types:');
    print('1. generalWard');
    print('2. semiPrivate');
    print('3. private');
    print('4. surgical');
    print('5. icu');
    print('6. isolation');
    print('7. maternity');
    stdout.write('Select room type (1-7): ');
    final typeChoice = stdin.readLineSync()?.trim() ?? '';

    final roomTypes = [RoomType.generalWard, RoomType.semiPrivate, RoomType.private, RoomType.surgical, RoomType.icu, RoomType.isolation, RoomType.maternity];

    RoomType? selectedType;
    final typeIndex = int.tryParse(typeChoice);
    if (typeIndex != null && typeIndex >= 1 && typeIndex <= 7) {
      selectedType = roomTypes[typeIndex - 1];
    } else {
      print('Invalid room type.');
      return;
    }

    try {
      final reservation = reservationService!.createReservation(patient, selectedType);
      reservations = reservationService!.reservations;
      print('\nSuccessfully created reservation for ${patient.name}');
      print('Room: ${reservation.bed.room.roomNumber}, Bed: ${reservation.bed.bedNumber}');
      print('Status: ${reservation.status.name}');
    } catch (e) {
      print('Error: $e');
    }
  }

  void confirmReservation() {
    print('\n==== Confirm Reservation ====');

    final pendingReservations = reservations.where((r) => r.status == ReservationStatus.pending).toList();
    if (pendingReservations.isEmpty) {
      print('No pending reservations found');
      return;
    }

    print('\nPending Reservations:');
    for (var reservation in pendingReservations) {
      print('\nReservation ID: ${reservation.id}');
      print('Patient: ${reservation.patient.name}');
      print('Room: ${reservation.bed.room.roomNumber}, Bed: ${reservation.bed.bedNumber}');
      print('Reserved Date: ${reservation.reservedDate}');
      print('---');
    }

    stdout.write('\nEnter Reservation ID: ');
    final reservationId = stdin.readLineSync()?.trim() ?? '';

    if (reservationId.isEmpty) {
      print('Invalid reservation ID');
      return;
    }

    final reservation = reservations.firstWhere((r) => r.id == reservationId, orElse: () => throw Exception('Reservation not found: $reservationId'));

    if (reservation.status != ReservationStatus.pending) {
      print('Only pending reservations can be confirmed. This reservation is ${reservation.status.name}.');
      return;
    }

    try {
      reservationService!.confirmReservation(reservationId);
      reservations = reservationService!.reservations;
      print('Reservation confirmed successfully');
    } catch (e) {
      print('Error: $e');
    }
  }

  void cancelReservation() {
    print('\n==== Cancel Reservation ====');

    viewActiveReservations();
    stdout.write('Enter Reservation ID: ');
    final reservationId = stdin.readLineSync()?.trim() ?? '';

    if (reservationId.isEmpty) {
      print('Invalid reservation ID');
      return;
    }

    try {
      reservationService!.cancelReservation(reservationId);
      reservations = reservationService!.reservations;
      print('Reservation cancelled successfully');
    } catch (e) {
      print('Error: $e');
    }
  }
}
