import 'package:hospital_management_system__managing_rooms/domain/bed.dart';
import 'package:hospital_management_system__managing_rooms/domain/patient.dart';
import 'package:uuid/uuid.dart';

var uuid = Uuid();

enum AllocationStatus { active, completed, cancelled }

class BedAllocation {
  final String id;
  final Patient patient;
  Bed bed;
  AllocationStatus status;
  final DateTime startDate;
  DateTime? endDate;

  BedAllocation({String? id, required this.patient, required this.bed, this.status = AllocationStatus.active, required this.startDate, this.endDate}) 
    : id = id ?? uuid.v4();

  factory BedAllocation.fromJson(Map<String, dynamic> json, Map<String, Patient> patientById, Map<String, Bed> bedById) {
    final patientId = json['patientId'] as String?;
    if (patientId == null) {
      throw FormatException('BedAllocation missing patientId: $json');
    }
    final patient = patientById[patientId];
    if (patient == null) {
      throw FormatException('BedAllocation references unknown patientId: $patientId');
    }

    final bedId = json['bedId'] as String?;
    if (bedId == null) {
      throw FormatException('BedAllocation missing bedId: $json');
    }
    final bed = bedById[bedId];
    if (bed == null) {
      throw FormatException('BedAllocation references unknown bedId: $bedId');
    }

    final statusString = json['status'] as String? ?? 'active';
    final parsedStatus = AllocationStatus.values.firstWhere((e) => e.name == statusString, orElse: () => AllocationStatus.active);

    DateTime parsedStartDate;
    try {
      parsedStartDate = DateTime.parse(json['startDate'] as String? ?? DateTime.now().toIso8601String());
    } catch (e) {
      parsedStartDate = DateTime.now();
    }

    DateTime? parsedEndDate;
    if (json['endDate'] != null) {
      try {
        parsedEndDate = DateTime.parse(json['endDate'] as String);
      } catch (e) {
        parsedEndDate = null;
      }
    }

    return BedAllocation(
      id: json['id'] as String?, 
      patient: patient, 
      bed: bed, 
      status: parsedStatus, 
      startDate: parsedStartDate, 
      endDate: parsedEndDate
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id, 
      'patientId': patient.id, 
      'bedId': bed.id, 
      'startDate': startDate.toIso8601String(), 
      'endDate': endDate?.toIso8601String(), 
      'status': status.name
    };
  }

  @override
  String toString() => 'BedAllocation(id: $id, patient: ${patient.name}, bed: ${bed.bedNumber}, status: ${status.name}, startDate: $startDate, endDate: $endDate)';

  /// Gets detailed allocation information
  String getAllocationDetails() {
    return '''
      Bed Allocation Details:
      ID: $id
      Patient: ${patient.name} (${patient.id})
      Bed: ${bed.bedNumber} in Room ${bed.room.roomNumber}
      Status: ${status.name}
      Start Date: $startDate
      End Date: ${endDate ?? 'Not set'}
      Duration: ${getDuration().inDays} days''';
  }

  /// Completes the allocation with an end time
  void complete(DateTime endTime) {
    if (status == AllocationStatus.completed) {
      throw StateError('Allocation is already completed');
    }
    if (status == AllocationStatus.cancelled) {
      throw StateError('Cannot complete a cancelled allocation');
    }
    status = AllocationStatus.completed;
    endDate = endTime;
    bed.release();
  }

  /// Transfers the patient to a new bed
  void transferTo(Bed newBed) {
    if (status != AllocationStatus.active) {
      throw StateError('Can only transfer active allocations');
    }
    if (newBed.status != BedStatus.available) {
      throw StateError('Target bed is not available');
    }
    bed.release();
    bed = newBed;
    newBed.occupy(this);
  }

  /// Gets the duration of the allocation
  Duration getDuration() {
    final end = endDate ?? DateTime.now();
    return end.difference(startDate);
  }

  /// Checks if the allocation is currently active
  bool isActive() {
    return status == AllocationStatus.active;
  }
}
