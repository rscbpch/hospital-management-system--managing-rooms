import 'package:hospital_management_system__managing_rooms/domain/bed.dart';
import 'package:hospital_management_system__managing_rooms/domain/patient.dart';
import 'package:uuid/uuid.dart';

var uuid = Uuid();

enum ReservationStatus { pending, confirmed, cancelled }

class Reservation {
  final String id;
  final Patient patient;
  final Bed bed;
  final ReservationStatus status;
  final DateTime reservedDate;

  Reservation({String? id, required this.patient, required this.bed, required this.status, required this.reservedDate}) 
    : id = id ?? uuid.v4();

  Map<String, dynamic> toJson() => {
    'id': id, 
    'patientId': patient.id, 
    'bedId': bed.id, 
    'status': status.name, 
    'reservedDate': reservedDate.toIso8601String()
  };

  factory Reservation.fromJson(Map<String, dynamic> json, Patient patient, Bed bed) {
    return Reservation(
      id: json['id'],
      patient: patient,
      bed: bed,
      status: ReservationStatus.values.firstWhere((e) => e.name == json['status']),
      reservedDate: DateTime.parse(json['reservedDate']),
    );
  }

  @override
  String toString() => 'Reservation(id: $id, patient: ${patient.name}, bed: ${bed.bedNumber}, status: ${status.name}, reservedDate: $reservedDate)';
}
