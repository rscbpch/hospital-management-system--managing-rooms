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
  final DateTime reservedDare;

  Reservation({String? id, required this.patient, required this.bed, required this.status, required this.reservedDare}) 
    : id = id ?? uuid.v4();
}
