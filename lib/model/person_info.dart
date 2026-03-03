import 'package:uuid/uuid.dart';

class PersonInfo {
  final String id;
  final String personUuid;
  final String text;
  final DateTime? date;

  PersonInfo({
    required this.personUuid,
    required this.text,
    this.date,
    String? id,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'personUuid': personUuid,
      'text': text,
      'date': date?.toIso8601String(),
    };
  }

  factory PersonInfo.fromMap(Map<String, dynamic> map,
      {String? defaultPersonUuid}) {
    return PersonInfo(
      id: map['id'] ?? const Uuid().v4(),
      personUuid: map['personUuid'] ?? defaultPersonUuid ?? '',
      text: map['text'] ?? '',
      date: map['date'] != null ? DateTime.tryParse(map['date']) : null,
    );
  }

  @override
  String toString() => "{text: $text, date: $date}";
}
