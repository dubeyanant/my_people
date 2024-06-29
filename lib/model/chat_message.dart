class ChatMessage {
  final String text;
  final String sender;

  ChatMessage({required this.text, required this.sender});

  // Create demo messages
  static List<ChatMessage> demoMessages = [
    ChatMessage(
      text: 'Hello!',
      sender: 'User',
    ),
    ChatMessage(
      text: 'Hi there!',
      sender: 'Bot',
    ),
    ChatMessage(
      text: 'How are you?',
      sender: 'Bot',
    ),
    ChatMessage(
      text: 'I am fine, thank you.',
      sender: 'User',
    ),
  ];
}
