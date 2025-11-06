import 'package:uuid/uuid.dart';
import 'package:hospital_management_system__managing_rooms/domain/ward.dart';

var uuid = Uuid();

class Hospital {
  final String id;
  final String name;
  final String address;
  final List<Ward> wards;

  Hospital({String? id, required this.name, required this.address, List<Ward>? wards}) 
    : id = id ?? uuid.v4(), wards = wards ?? [];

  factory Hospital.fromJson(Map<String, dynamic> json, Map<String, Ward> wardById) {
    final wardsJson = json['wards'] as List<dynamic>? ?? [];
    final List<Ward> wards = [];

    for (var wardData in wardsJson) {
      if (wardData is String) {
        final ward = wardById[wardData];
        if (ward != null) {
          wards.add(ward);
        }
      } else if (wardData is Map<String, dynamic>) {
        final wardId = wardData['id'] as String?;
        if (wardId != null) {
          final ward = wardById[wardId];
          if (ward != null) {
            wards.add(ward);
          }
        }
      }
    }

    return Hospital(
      id: json['id'] as String?, 
      name: json['id'] as String? ?? '', 
      address: json['address'] as String? ?? '', 
      wards: wards
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id, 
    'name': name, 
    'address': address, 
    'wards': wards.map((w) => w.toJson()).toList()
  };

  @override
  String toString() => 'Hospital $name, Address: $address';

  void addWard(Ward ward) {
    if (wards.any((w) => w.id == ward.id)) {
      throw ArgumentError('Ward with id ${ward.id} already exists in this hospital');
    }
    wards.add(ward);
  }
}
