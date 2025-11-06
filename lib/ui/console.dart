import 'dart:io';
import 'package:hospital_management_system__managing_rooms/managers/patient_manager.dart';
import 'package:hospital_management_system__managing_rooms/managers/room_manager.dart';
import 'package:hospital_management_system__managing_rooms/managers/ward_manager.dart';

void start(
  RoomManager roomManager,
  PatientManager patientManager,
  WardManager wardManager,
) {
  bool running = true;
  while (running) {
    print("\n ==== Hospital (Room Management System) ====");
    // print("1. View All Rooms");
    // print("2. Add New Room");
    // print("3. Allocate Room to Patient");
    // print("4. Check Room Availability");
    // print("5. Release Bed");
    // print("6. Exit");
    print("1. Manage Wards");
    print("2. Manage Rooms");
    print("3. Manage Patients");
    print("4. Manage Bed Allocations");
    print("5. View Reservations");
    print("6. Exit");
    stdout.write("Enter your choice: ");

    final choice = stdin.readLineSync()?.trim() ?? '';
    switch (choice) {
      case '1':
        wardOperation(wardManager, roomManager);
        break;
      case '2':
        roomOperation(roomManager, patientManager);
        break;
      case '3':
        patientOperation(patientManager);
        break;
      case '4':
        roomManager.checkRoomAvailability();
        break;
      case '5':
        roomManager.releaseBed();
        break;
      case '6':
        running = false;
        print("Exiting...");
        break;
      default:
        print("Invalid choice, try again.");
    }
  }
}

void viewAllRooms(RoomManager roomManager) {
  final rooms = roomManager.getAllRooms();
  if (rooms.isEmpty) {
    print("Room not found");
    return;
  }

  for (var room in rooms) {
    print(
      'Room ${room.roomNumber} (${room.type.name}) - ${room.beds.length} beds',
    );
    for (var bed in room.beds) {
      print('- Bed ${bed.bedNumber}: ${bed.status.name}');
    }
  }
}

void viewAllPatient(PatientManager patientManager) {
  print("\n==== View All Patients ====");
  final patients = patientManager.getAllPatients();
  if (patients.isEmpty) {
    print("No patients found");
    return;
  }

  for (var p in patients) {
    // print('Patient: ${p.name} Age:${p.age} ${p.gender} ${p.contactInfo}');
    print('\nName: ${p.name}');
    print('\nAge: ${p.age}');
    print('\nGender: ${p.gender}');
    print('\nContact Info: \n${p.contactInfo}');
    print("\n=============\n");
  }
}

void wardOperation(WardManager wardManager, RoomManager roomManager) {
  while (true) {
    print("\n==== Manage Wards ====");
    print("1. View All Wards");
    print("2. Add New Ward");
    print("3. Add Room to Ward");
    print("4. Remove Room from Ward");
    print("5. Update Ward");
    print("6. Exit");
    stdout.write("Enter choice: ");
    final choice = stdin.readLineSync()?.trim();
    switch (choice) {
      case '1':
        wardManager.viewAllWards();
        break;
      case '2':
        wardManager.addWard();
        break;
      case '3':
        wardManager.assignRoomToWard();
        break;
      case '4':
        wardManager.removeRoomFromWard();
        break;
      case '5':
        wardManager.updateWard();
        break;
      case '6':
        print("Returning to main menu...");
        return;
      default:
        print("Invalid choice");
    }
  }
}

void roomOperation(RoomManager roomManager, PatientManager patientManager) {
  while (true) {
    print("\n==== Manage Rooms ====");
    print("1. View All Rooms");
    print("2. Add New Room");
    print("3. Check Room Availability");
    print("4. Allocate Bed To Patient");
    print("5. Release Bed");
    print("6. Exit");
    stdout.write("Enter Choice: ");
    final choice = stdin.readLineSync()?.trim();
    switch (choice) {
      case '1':
        viewAllRooms(roomManager);
        break;
      case '2':
        roomManager.addNewRoom('', '', 0);
        break;
      case '3':
        roomManager.checkRoomAvailability();
        break;
      case '4':
        roomManager.allocateBedToPatient(patientManager);
        break;
      case '5':
        roomManager.releaseBed();
        break;
      case '6':
        print("Returning to Main menu...");
        return;
      default:
        print("Invalid Choice");
    }
  }
}

void patientOperation(PatientManager patientManager) {
  while (true) {
    print("\n==== Manage Patients ====");
    print("1. View All Patients");
    print("2. Create Patient");
    print("3. Remove Patient");
    print("4. Exit");
    stdout.write("Enter Choice: ");
    final choice = stdin.readLineSync()?.trim();
    switch (choice) {
      case '1':
        viewAllPatient(patientManager);
        break;
      case '2':
        patientManager.createPatient();
        break;
      case '3':
        patientManager.printAllPatientIds();
        stdout.write("Enter Patient ID to remove: ");
        final patientId = stdin.readLineSync()?.trim();
        if (patientId != null && patientId.isNotEmpty) {
          final removed = patientManager.removePatient(patientId);
          if (removed) {
            print("Patient removed successfully");
          } else {
            print("Patient not found");
          }
        } else {
          print("Invalid patient Id");
        }
        break;
      case '4':
        print("Returning to main menu ...");
        return;
      default:
        print("Invalid Choice");
    }
  }
}
