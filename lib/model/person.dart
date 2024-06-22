import 'package:uuid/uuid.dart';

class Person {
  final String uuid;
  String name;
  String photo;
  List<String> info = [];

  Person({
    required this.name,
    required this.photo,
    required this.info,
    String? uuid,
  }) : uuid = uuid ?? const Uuid().v4(); // Generate a UUID if not provided

  // Convert a Person into a Map object for database operations
  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'name': name,
      'photo': photo,
      'info': info.join(','), // Convert info list to comma-separated string
    };
  }

  // Create a Person object from a Map object
  factory Person.fromMap(Map<String, dynamic> map) {
    return Person(
      uuid: map['uuid'],
      name: map['name'],
      photo: map['photo'],
      info: map['info'].split(','), // Convert comma-separated string to list
    );
  }

  // Override == and hashCode to compare Persons by UUID
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Person && other.uuid == uuid;
  }

  @override
  int get hashCode => uuid.hashCode;
}
