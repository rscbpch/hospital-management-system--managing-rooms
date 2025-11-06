import 'dart:convert';
import 'dart:io';
import 'package:hospital_management_system__managing_rooms/data/bed_allocation_repository.dart';
import 'package:hospital_management_system__managing_rooms/domain/bed_allocation.dart';
import 'package:hospital_management_system__managing_rooms/domain/services/bed_allocation_service.dart';
import 'package:hospital_management_system__managing_rooms/ui/managers/patient_manager.dart';
import 'package:hospital_management_system__managing_rooms/ui/managers/ward_manager.dart';

class BedAllocationManager {
  final String allocationFilePath;
  final BedAllocationRepository allocationRepo;
  final PatientManager patientManager;
  final WardManager wardManager;

  List<BedAllocation> allocations = [];
  BedAllocationService? allocationService;

  BedAllocationManager({required this.allocationFilePath, required this.allocationRepo, required this.patientManager, required this.wardManager}) {
    initialize();
  }

  void ensureFileExists(String filePath) {
    final file = File(filePath);
    final dir = file.parent;
    if (!dir.existsSync()) dir.createSync(recursive: true);
    if (!file.existsSync()) {
      file.writeAsStringSync(jsonEncode({'bedAllocations': []}));
    }
  }

  void initialize() {
    ensureFileExists(allocationFilePath);

    allocations = allocationRepo.readBedAllocations(patientManager.patientById, wardManager.bedById);

    allocationService = BedAllocationService(repository: allocationRepo, allocations: allocations);

    print('BedAllocationManager initialized: ${allocations.length} allocations loaded.');
  }

  void viewAllAllocations() {
    if (allocations.isEmpty) {
      print('No bed allocations found');
      return;
    }

    print('\n==== All Bed Allocations ====');
    for (var allocation in allocations) {
      print('\nAllocation ID: ${allocation.id}');
      print('Patient: ${allocation.patient.name}');
      print('Room: ${allocation.bed.room.roomNumber}, Bed: ${allocation.bed.bedNumber}');
      print('Status: ${allocation.status.name}');
      print('Start Date: ${allocation.startDate}');
      if (allocation.endDate != null) {
        print('End Date: ${allocation.endDate}');
        print('Duration: ${allocation.getDuration().inDays} day(s)');
      } else if (allocation.isActive()) {
        print('Duration: Allocation not completed yet');
      } else {
        print('Duration: ${allocation.getDuration().inDays} day(s)');
      }
      print('---');
    }
  }

  void viewActiveAllocations() {
    final activeAllocations = allocations.where((a) => a.isActive()).toList();
    if (activeAllocations.isEmpty) {
      print('No active bed allocations found');
      return;
    }

    print('\n==== Active Bed Allocations ====');
    for (var allocation in activeAllocations) {
      print('\nAllocation ID: ${allocation.id}');
      print('Patient: ${allocation.patient.name}');
      print('Room: ${allocation.bed.room.roomNumber}, Bed: ${allocation.bed.bedNumber}');
      print('Start Date: ${allocation.startDate}');
      print('Duration: Allocation not completed yet');
      print('---');
    }
  }

  void admitPatient() {
    print('\n==== Admit Patient to Ward ====');

    patientManager.printAllPatientIds();
    stdout.write('Enter Patient ID: ');
    final patientId = stdin.readLineSync()?.trim() ?? '';
    final patient = patientManager.findPatientById(patientId);
    if (patient == null) {
      print('Patient not found');
      return;
    }

    final hasActiveAllocation = allocations.any((a) => a.patient.id == patient.id && a.isActive());
    if (hasActiveAllocation) {
      print('Patient ${patient.name} already has an active bed allocation.');
      return;
    }

    print('\nAvailable Wards:');
    for (var ward in wardManager.wards) {
      final availableBeds = ward.getAvailableBeds().length;
      print('- ${ward.name} (${ward.type.name}) - $availableBeds available bed(s)');
    }

    stdout.write('Enter Ward ID: ');
    final wardId = stdin.readLineSync()?.trim() ?? '';
    final ward = wardManager.wardById[wardId];
    if (ward == null) {
      print('Ward not found');
      return;
    }

    try {
      final allocation = allocationService!.admitPatient(patient, ward);
      allocations = allocationService!.allocations;
      print('\nSuccessfully admitted ${patient.name} to ${ward.name}');
      print('Room: ${allocation.bed.room.roomNumber}, Bed: ${allocation.bed.bedNumber}');
    } catch (e) {
      print('Error: $e');
    }
  }

  void transferPatient() {
    print('\n==== Transfer Patient to New Ward ====');

    patientManager.printAllPatientIds();
    stdout.write('Enter Patient ID: ');
    final patientId = stdin.readLineSync()?.trim() ?? '';
    final patient = patientManager.findPatientById(patientId);
    if (patient == null) {
      print('Patient not found');
      return;
    }

    print('\nAvailable Wards:');
    for (var ward in wardManager.wards) {
      final availableBeds = ward.getAvailableBeds().length;
      print('- ${ward.name} (${ward.type.name}) - $availableBeds available bed(s)');
    }

    stdout.write('Enter New Ward ID: ');
    final wardId = stdin.readLineSync()?.trim() ?? '';
    final ward = wardManager.wardById[wardId];
    if (ward == null) {
      print('Ward not found');
      return;
    }

    try {
      final allocation = allocationService!.transferPatient(patient, ward);
      allocations = allocationService!.allocations;
      print('\nSuccessfully transferred ${patient.name} to ${ward.name}');
      print('New Room: ${allocation.bed.room.roomNumber}, Bed: ${allocation.bed.bedNumber}');
    } catch (e) {
      print('Error: $e');
    }
  }

  void dischargePatient() {
    print('\n==== Discharge Patient ====');

    final activeAllocations = allocations.where((a) => a.isActive()).toList();
    if (activeAllocations.isEmpty) {
      print('No patients with active allocations found');
      return;
    }

    print('\nPatients with Active Allocations:');
    for (var allocation in activeAllocations) {
      print('- Name: ${allocation.patient.name} - ID: ${allocation.patient.id}');
      print('  Room: ${allocation.bed.room.roomNumber}, Bed: ${allocation.bed.bedNumber}');
    }

    stdout.write('\nEnter Patient ID: ');
    final patientId = stdin.readLineSync()?.trim() ?? '';
    final patient = patientManager.findPatientById(patientId);
    if (patient == null) {
      print('Patient not found');
      return;
    }

    final hasActiveAllocation = allocations.any((a) => a.patient.id == patient.id && a.isActive());
    if (!hasActiveAllocation) {
      print('Patient ${patient.name} does not have an active allocation.');
      return;
    }

    try {
      allocationService!.dischargePatient(patient);
      allocations = allocationService!.allocations;
      print('\nSuccessfully discharged ${patient.name}');
    } catch (e) {
      print('Error: $e');
    }
  }
}
