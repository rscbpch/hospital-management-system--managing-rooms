import 'package:hospital_management_system__managing_rooms/domain/reservation.dart';
import 'package:hospital_management_system__managing_rooms/domain/patient.dart';
import 'package:hospital_management_system__managing_rooms/domain/bed.dart';
import 'package:hospital_management_system__managing_rooms/domain/room.dart';
import '../../data/reservation_repository.dart';

class ReservationService {
  final List<Room> rooms;
  final ReservationRepository repository;
  List<Reservation> reservations;

  ReservationService({required this.rooms, required this.repository, List<Reservation>? reservations}) 
    : reservations = reservations ?? [];

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

    final reservation = Reservation(patient: patient, bed: availableBed, status: ReservationStatus.pending, reservedDate: DateTime.now());

    reservations.add(reservation);
    repository.writeReservations(reservations);

    return reservation;
  }

  void cancelReservation(String reservationId) {
    final reservation = reservations.firstWhere((r) => r.id == reservationId, orElse: () => throw Exception('Reservation not found: $reservationId'));

    reservation.cancelReservation();
    repository.writeReservations(reservations);
  }

  void confirmReservation(String reservationId) {
    final reservation = reservations.firstWhere((r) => r.id == reservationId, orElse: () => throw Exception('Reservation not found: $reservationId'));

    reservation.confirmReservation(reservation.bed);
    repository.writeReservations(reservations);
  }
}
