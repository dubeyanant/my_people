import 'package:my_people/model/chat_message.dart';

class ChatSession {
  final String personUuid;
  final List<ChatMessage> messages;

  ChatSession(this.personUuid) : messages = [];
}
