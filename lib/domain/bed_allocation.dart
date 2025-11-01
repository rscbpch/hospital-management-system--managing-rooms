import 'package:hospital_management_system__managing_rooms/domain/bed.dart';
import 'package:hospital_management_system__managing_rooms/domain/patient.dart';
import 'package:uuid/uuid.dart';

var uuid = Uuid();

enum AllocationStatus { active, completed, cancelled }

class BedAllocation {
  final String id;
  final Patient patient;
  final Bed bed;
  AllocationStatus status;
  final DateTime startDate;
  final DateTime endDate;

  BedAllocation({String? id, required this.patient, required this.bed, this.status = AllocationStatus.active, required this.startDate, required this.endDate})
    : id = id ?? uuid.v4();

  Map<String, dynamic> toJson() => {
    'id': id,
    'patientId': patient.id,
    'bedId': bed.id,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'status': status.name,
  };

  factory BedAllocation.fromJson(Map<String, dynamic> json, Patient patient, Bed bed) {
    return BedAllocation(
      id: json['id'],
      patient: patient,
      bed: bed,
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      status: AllocationStatus.values.firstWhere((e) => e.name == json['status']),
    );
  }

  @override
  String toString() => 'BedAllocation(id: $id, patient: ${patient.name}, bed: ${bed.bedNumber}, status: ${status.name}, startDate: $startDate, endDate: $endDate)';
}
