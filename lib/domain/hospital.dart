import 'package:uuid/uuid.dart';

var uuid = Uuid();

class Hospital {
  final String id;
  final String name;
  final String address;
  
  Hospital({String? id, required this.name, required this.address}) 
    : id = id ?? uuid.v4();
}
