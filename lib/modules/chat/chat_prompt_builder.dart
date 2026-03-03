import 'package:my_people/model/person.dart';

/// Builds the system prompt sent to the AI to establish context
/// about the person being discussed.
abstract final class ChatPromptBuilder {
  static String buildSystemPrompt(Person person) {
    return '''
This is the information about the person I'm talking about:
Name: ${person.name}
Info: ${person.info.map((e) => e.text).join(', ')}
Extra Info: ${person.birthday}, ${person.dietaryRestrictions}, ${person.interests}, ${person.introvertExtrovert}, ${person.occupation}, ${person.relationshipType}, ${person.relationshipStatus}, 

Strictly use this info while answering in effective and concise manner in any of the next prompts. Do not hallucinate or generate information that is not present in this info. If you understood, say "Hi, how may I help you?"
''';
  }

  /// The expected AI acknowledgement when the system prompt is understood.
  static const String expectedAck = 'hi, how may i help you?';
}
