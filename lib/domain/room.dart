import 'package:uuid/uuid.dart';

var uuid = Uuid();

enum RoomType {
  generalWard(8),
  semiPrivate(2),
  private(1),
  surgical(2),
  icu(1),
  isolation(1),
  maternity(2);

  final int defaultBedCount;
  const RoomType(this.defaultBedCount);
}

class Room {
  final String id;
  final String roomNumber;
  final RoomType type;
  final List<String> bedNumbers;

  Room({String? id, required this.roomNumber, required this.type, List<String>? bedNumbers})
    : id = id ?? uuid.v4(),
      bedNumbers = bedNumbers ?? List.generate(type.defaultBedCount, (index) => '$roomNumber-${index + 1}');

  @override
  String toString() {
    return 'Room{id: $id, roomNumber: $roomNumber, type: $type, bedNumbers: $bedNumbers}';
  }
}
