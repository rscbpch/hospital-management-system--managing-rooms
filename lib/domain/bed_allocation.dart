import 'package:hospital_management_system__managing_rooms/domain/bed.dart';
import 'package:hospital_management_system__managing_rooms/domain/patient.dart';
import 'package:uuid/uuid.dart';

var uuid = Uuid();

enum AllocationStatus { active, completed, cancelled }

class BedAllocation {
  final String id;
  final Patient patient;
  final Bed bed;
  final DateTime startDate;
  final DateTime endDate;

  BedAllocation({String? id, required this.patient, required this.bed, required this.startDate, required this.endDate}) 
    : id = id ?? uuid.v4();
}
