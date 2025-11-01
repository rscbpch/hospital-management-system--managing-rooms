import 'package:uuid/uuid.dart';

var uuid = Uuid();

class Hospital {
  final String id;
  final String name;
  final String address;
  
  Hospital({String? id, required this.name, required this.address}) 
    : id = id ?? uuid.v4();

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'address': address,
  };

  factory Hospital.fromJson(Map<String, dynamic> json) {
    return Hospital(
      id: json['id'],
      name: json['name'],
      address: json['address'],
    );
  }

  @override
  String toString() => 'Hospital $name, Address: $address';
}
