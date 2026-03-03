import 'package:uuid/uuid.dart';

class Event {
  final String id;
  final String personUuid;
  final String emoji;
  final String title;
  final String description;
  final DateTime date;

  Event({
    required this.personUuid,
    required this.title,
    this.emoji = '🗓️',
    this.description = '',
    DateTime? date,
    String? id,
  })  : id = id ?? const Uuid().v4(),
        date = date ?? DateTime.now();

  Event copyWith({
    String? personUuid,
    String? emoji,
    String? title,
    String? description,
    DateTime? date,
  }) {
    return Event(
      id: id,
      personUuid: personUuid ?? this.personUuid,
      emoji: emoji ?? this.emoji,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'personUuid': personUuid,
      'emoji': emoji,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
    };
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      personUuid: map['personUuid'],
      emoji: map['emoji'] ?? '🗓️',
      title: map['title'],
      description: map['description'] ?? '',
      date: map['date'] != null
          ? DateTime.tryParse(map['date']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Event && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => "{title: $title, date: $date}";
}
