import 'package:hospital_management_system__managing_rooms/domain/bed.dart';
import 'package:hospital_management_system__managing_rooms/domain/patient.dart';
import 'package:uuid/uuid.dart';

var uuid = Uuid();

enum ReservationStatus { pending, confirmed, cancelled }

class Reservation {
  final String id;
  final Patient patient;
  final Bed bed;
  ReservationStatus status;
  final DateTime reservedDate;

  Reservation({String? id, required this.patient, required this.bed, required this.status, required this.reservedDate}) 
    : id = id ?? uuid.v4();

  factory Reservation.fromJson(Map<String, dynamic> json, Map<String, Patient> patientById, Map<String, Bed> bedById) {
    final patientId = json['patientId'] as String?;
    if (patientId == null) {
      throw FormatException('Reservation missing patientId: $json');
    }
    final patient = patientById[patientId];
    if (patient == null) {
      throw FormatException('Reservation references unknown patientId: $patientId');
    }

    final bedId = json['bedId'] as String?;
    if (bedId == null) {
      throw FormatException('Reservation missing bedId: $json');
    }
    final bed = bedById[bedId];
    if (bed == null) {
      throw FormatException('Reservation references unknown bedId: $bedId');
    }

    final statusString = json['status'] as String? ?? 'pending';
    final parsedStatus = ReservationStatus.values.firstWhere((e) => e.name == statusString, orElse: () => ReservationStatus.pending);

    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(json['reservedDate'] as String? ?? DateTime.now().toIso8601String());
    } catch (e) {
      parsedDate = DateTime.now();
    }

    return Reservation(
      id: json['id'] as String?, 
      patient: patient, 
      bed: bed, 
      status: parsedStatus, 
      reservedDate: parsedDate
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id, 
      'patientId': patient.id, 
      'bedId': bed.id, 
      'status': status.name, 
      'reservedDate': reservedDate.toIso8601String()
    };
  }

  @override
  String toString() => 'Reservation(id: $id, patient: ${patient.name}, bed: ${bed.bedNumber}, status: ${status.name}, reservedDate: $reservedDate)';

  /// Confirms a pending reservation and reserves the bed
  void confirmReservation(Bed bed) {
    if (this.bed.id != bed.id) {
      throw ArgumentError('The provided bed does not match the reservation bed');
    }
    if (status != ReservationStatus.pending) {
      throw StateError('Only pending reservations can be confirmed');
    }
    status = ReservationStatus.confirmed;
    bed.reserve();
  }

  /// Cancels a reservation and releases the bed
  void cancelReservation() {
    if (status == ReservationStatus.cancelled) {
      throw StateError('Reservation is already cancelled');
    }
    status = ReservationStatus.cancelled;
    if (bed.status == BedStatus.reserved) {
      bed.release();
    }
  }

  /// Checks if the reservation is currently active and returns true if status is pending or confirmed
  bool isActive() {
    return status == ReservationStatus.pending || status == ReservationStatus.confirmed;
  }

  /// Expires an active reservation by cancelling it
  void expire() {
    if (!isActive()) {
      return;
    }
    status = ReservationStatus.cancelled;
    if (bed.status == BedStatus.reserved) {
      bed.release();
    }
  }
}
