class PersonInfo {
  final String text;
  final DateTime? date;

  PersonInfo({required this.text, this.date});

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'date': date?.toIso8601String(),
    };
  }

  factory PersonInfo.fromMap(Map<String, dynamic> map) {
    return PersonInfo(
      text: map['text'] ?? '',
      date: map['date'] != null ? DateTime.tryParse(map['date']) : null,
    );
  }

  @override
  String toString() => "{text: $text, date: $date}";
}
