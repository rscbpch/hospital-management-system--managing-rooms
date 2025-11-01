import 'package:hospital_management_system__managing_rooms/domain/bed_allocation.dart';

class BedAllocationService extends BedAllocation {
  BedAllocationService({required super.patient, required super.bed, required super.startDate, required super.endDate});

  @override
  String toString() => 'BedAllocationService(${super.toString()})';
}
