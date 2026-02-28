import 'dart:convert';

import 'package:uuid/uuid.dart';

import 'package:my_people/model/person_info.dart';

class Person {
  final String uuid;
  String name;
  String photo;
  List<PersonInfo> info = [];

  Person({
    required this.name,
    required this.photo,
    required this.info,
    String? uuid,
  }) : uuid = uuid ?? const Uuid().v4(); // Generate a UUID if not provided

  // Convert a Person into a Map object for database operations
  Map<String, dynamic> toMap() {
    final infoList = info.map((item) => item.toMap()).toList();
    return {
      'uuid': uuid,
      'name': name,
      'photo': photo,
      'info': jsonEncode(infoList), // Convert info list to JSON string
    };
  }

  // Create a Person object from a Map object
  factory Person.fromMap(Map<String, dynamic> map) {
    List<PersonInfo> parsedInfo = [];
    if (map['info'] != null) {
      final decodedList = jsonDecode(map['info']) as List;
      for (var element in decodedList) {
        if (element is String) {
          // Backward compatibility for old String-only entries
          parsedInfo.add(PersonInfo(text: element, date: null));
        } else if (element is Map<String, dynamic>) {
          parsedInfo.add(PersonInfo.fromMap(element));
        }
      }
    }

    parsedInfo.sort((a, b) {
      if (a.date == null && b.date == null) return 0;
      if (a.date == null) return 1;
      if (b.date == null) return -1;
      return b.date!.compareTo(a.date!);
    });

    return Person(
      uuid: map['uuid'],
      name: map['name'],
      photo: map['photo'],
      info: parsedInfo, // Decode JSON string to list
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
