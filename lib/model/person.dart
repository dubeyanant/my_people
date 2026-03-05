import 'dart:convert';

import 'package:uuid/uuid.dart';

import 'package:my_people/model/person_info.dart';
import 'package:my_people/model/event.dart';

class Person {
  final String uuid;
  String name;
  String photo;
  List<PersonInfo> info = [];
  List<Event> events = [];

  // New optional fields
  DateTime? birthday;
  List<String>? relationshipType;
  String? socialInstagram;
  String? socialTwitter;
  String? socialLinkedIn;
  String? occupation;
  List<String>? interests;
  List<String>? dietaryRestrictions;
  String? introvertExtrovert;
  String? relationshipStatus;

  Person({
    required this.name,
    required this.photo,
    required this.info,
    this.events = const [],
    this.birthday,
    this.relationshipType,
    this.socialInstagram,
    this.socialTwitter,
    this.socialLinkedIn,
    this.occupation,
    this.interests,
    this.dietaryRestrictions,
    this.introvertExtrovert,
    this.relationshipStatus,
    String? uuid,
  }) : uuid = uuid ?? const Uuid().v4(); // Generate a UUID if not provided

  Person copyWith({
    String? name,
    String? photo,
    List<PersonInfo>? info,
    List<Event>? events,
    DateTime? birthday,
    List<String>? relationshipType,
    String? socialInstagram,
    String? socialTwitter,
    String? socialLinkedIn,
    String? occupation,
    List<String>? interests,
    List<String>? dietaryRestrictions,
    String? introvertExtrovert,
    String? relationshipStatus,
  }) {
    return Person(
      uuid: uuid,
      name: name ?? this.name,
      photo: photo ?? this.photo,
      info: info ?? this.info,
      events: events ?? this.events,
      birthday: birthday ?? this.birthday,
      relationshipType: relationshipType ?? this.relationshipType,
      socialInstagram: socialInstagram ?? this.socialInstagram,
      socialTwitter: socialTwitter ?? this.socialTwitter,
      socialLinkedIn: socialLinkedIn ?? this.socialLinkedIn,
      occupation: occupation ?? this.occupation,
      interests: interests ?? this.interests,
      dietaryRestrictions: dietaryRestrictions ?? this.dietaryRestrictions,
      introvertExtrovert: introvertExtrovert ?? this.introvertExtrovert,
      relationshipStatus: relationshipStatus ?? this.relationshipStatus,
    );
  }

  // Convert a Person into a Map object for database operations
  Map<String, dynamic> toMap() {
    final infoList = info.map((item) => item.toMap()).toList();
    return {
      'uuid': uuid,
      'name': name,
      'photo': photo,
      'info': jsonEncode(infoList), // Convert info list to JSON string
      'birthday': birthday?.toIso8601String(),
      'relationshipType':
          relationshipType != null ? jsonEncode(relationshipType) : null,
      'socialInstagram': socialInstagram,
      'socialTwitter': socialTwitter,
      'socialLinkedIn': socialLinkedIn,
      'occupation': occupation,
      'interests': interests != null ? jsonEncode(interests) : null,
      'dietaryRestrictions':
          dietaryRestrictions != null ? jsonEncode(dietaryRestrictions) : null,
      'introvertExtrovert': introvertExtrovert,
      'relationshipStatus': relationshipStatus,
    };
  }

  // Convert a Person into a Map object for profile sharing (includes events)
  Map<String, dynamic> toSharingMap() {
    final map = toMap();
    final eventList = events.map((item) => item.toMap()).toList();
    map['events'] = jsonEncode(eventList);
    return map;
  }

  // Create a Person object from a Map object
  factory Person.fromMap(Map<String, dynamic> map) {
    List<PersonInfo> parsedInfo = [];
    if (map['info'] != null) {
      final decodedList = jsonDecode(map['info']) as List;
      for (var element in decodedList) {
        if (element is String) {
          // Backward compatibility for old String-only entries
          parsedInfo.add(
              PersonInfo(personUuid: map['uuid'], text: element, date: null));
        } else if (element is Map<String, dynamic>) {
          parsedInfo
              .add(PersonInfo.fromMap(element, defaultPersonUuid: map['uuid']));
        }
      }
    }

    parsedInfo.sort((a, b) {
      if (a.date == null && b.date == null) return 0;
      if (a.date == null) return 1;
      if (b.date == null) return -1;
      return b.date!.compareTo(a.date!);
    });

    List<Event> parsedEvents = [];
    if (map['events'] != null) {
      final decodedEventsList = jsonDecode(map['events']) as List;
      for (var element in decodedEventsList) {
        if (element is Map<String, dynamic>) {
          parsedEvents.add(Event.fromMap(element));
        }
      }
    }

    return Person(
      uuid: map['uuid'],
      name: map['name'],
      photo: map['photo'],
      info: parsedInfo, // Decode JSON string to list
      events: parsedEvents,
      birthday:
          map['birthday'] != null ? DateTime.tryParse(map['birthday']) : null,
      relationshipType: map['relationshipType'] != null
          ? List<String>.from(jsonDecode(map['relationshipType']))
          : null,
      socialInstagram: map['socialInstagram'],
      socialTwitter: map['socialTwitter'],
      socialLinkedIn: map['socialLinkedIn'],
      occupation: map['occupation'],
      interests: map['interests'] != null
          ? List<String>.from(jsonDecode(map['interests']))
          : null,
      dietaryRestrictions: map['dietaryRestrictions'] != null
          ? List<String>.from(jsonDecode(map['dietaryRestrictions']))
          : null,
      introvertExtrovert: map['introvertExtrovert'],
      relationshipStatus: map['relationshipStatus'],
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
