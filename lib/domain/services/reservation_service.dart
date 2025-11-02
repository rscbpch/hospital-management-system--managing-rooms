import 'package:hospital_management_system__managing_rooms/domain/reservation.dart';
import 'package:hospital_management_system__managing_rooms/domain/patient.dart';
import 'package:hospital_management_system__managing_rooms/domain/bed.dart';
import 'package:hospital_management_system__managing_rooms/domain/room.dart';

class ReservationService {
  final List<Room> rooms;
  final List<Bed> beds;

  ReservationService({required this.rooms, required this.beds});

  /// Creates a new reservation for a patient and room type
  Reservation createReservation(Patient patient, RoomType type) {
    final roomsOfType = rooms.where((room) => room.type == type).toList();

    if (roomsOfType.isEmpty) {
      throw Exception('No rooms found with type: ${type.name}');
    }

    Bed? availableBed;
    for (var room in roomsOfType) {
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
      throw Exception('No available beds found for room type: ${type.name}');
    }

    return Reservation(
      patient: patient, 
      bed: availableBed, 
      status: ReservationStatus.pending, 
      reservedDate: DateTime.now()
    );
  }
}
