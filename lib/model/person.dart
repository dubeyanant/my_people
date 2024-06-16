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

  // Override == and hashCode to compare Persons by UUID
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Person && other.uuid == uuid;
  }

  @override
  int get hashCode => uuid.hashCode;
}
