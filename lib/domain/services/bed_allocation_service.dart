import 'package:hospital_management_system__managing_rooms/domain/bed_allocation.dart';
import 'package:hospital_management_system__managing_rooms/domain/patient.dart';
import 'package:hospital_management_system__managing_rooms/domain/bed.dart';
import 'package:hospital_management_system__managing_rooms/domain/ward.dart';
import '../../data/bed_allocation_repository.dart';

class BedAllocationService {
  final BedAllocationRepository repository;
  List<BedAllocation> allocations;

  BedAllocationService({required this.repository, List<BedAllocation>? allocations}) 
    : allocations = allocations ?? [];

  BedAllocation admitPatient(Patient patient, Ward ward) {
    Bed? availableBed;

    for (var room in ward.rooms) {
      for (var bed in room.beds) {
        if (bed.status == BedStatus.available) {
          availableBed = bed;
          break;
        }
      }
      if (availableBed != null) {
        break;
      }
    }

    if (availableBed == null) {
      throw Exception('No available beds found in ward: ${ward.name}');
    }

    final allocation = BedAllocation(patient: patient, bed: availableBed, status: AllocationStatus.active, startDate: DateTime.now());
    availableBed.occupy(allocation);
    allocations.add(allocation);
    repository.writeBedAllocations(allocations);

    return allocation;
  }

  BedAllocation transferPatient(Patient patient, Ward newWard) {
    final currentAllocation = allocations.firstWhere(
      (a) => a.patient.id == patient.id && a.isActive(),
      orElse: () => throw Exception('No active allocation found for patient: ${patient.name}'),
    );

    Bed? availableBed;

    for (var room in newWard.rooms) {
      for (var bed in room.beds) {
        if (bed.status == BedStatus.available) {
          availableBed = bed;
          break;
        }
      }
      if (availableBed != null) {
        break;
      }
    }

    if (availableBed == null) {
      throw Exception('No available beds found in ward: ${newWard.name}');
    }

    currentAllocation.transferTo(availableBed);
    repository.writeBedAllocations(allocations);

    return currentAllocation;
  }

  void dischargePatient(Patient patient) {
    final allocation = allocations.firstWhere(
      (a) => a.patient.id == patient.id && a.isActive(),
      orElse: () => throw Exception('No active allocation found for patient: ${patient.name}'),
    );
    allocation.complete(DateTime.now());
    repository.writeBedAllocations(allocations);
  }
}
