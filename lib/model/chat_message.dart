class ChatMessage {
  final String text;
  final String sender;

  ChatMessage({required this.text, required this.sender});

  static List<ChatMessage> messages = [];
}
