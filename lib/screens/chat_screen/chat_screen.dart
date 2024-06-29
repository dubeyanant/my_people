import 'package:flutter/material.dart';

import 'package:my_people/model/chat_message.dart';
import 'package:my_people/screens/chat_screen/message_bubble.dart';
import 'package:my_people/utility/constants.dart';

class ChatScreen extends StatefulWidget {
  final String uuid;

  const ChatScreen(this.uuid, {super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = ChatMessage.demoMessages;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isTextFieldEmpty = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });

    _controller.addListener(_handleTextFieldChange);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTextFieldChange);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleTextFieldChange() {
    bool isEmpty = _controller.text.isEmpty;
    if (_isTextFieldEmpty != isEmpty) {
      setState(() {
        _isTextFieldEmpty = isEmpty;
      });
    }
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _messages.add(ChatMessage(
          text: _controller.text,
          sender: AppStrings.user,
        ));
        _controller.clear();
        _isTextFieldEmpty = true; // Reset the flag
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.chat),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return MessageBubble(
                  message: message,
                  isMe: message.sender == AppStrings.user,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    maxLines: 3,
                    minLines: 1,
                    onTapOutside: (event) => FocusScope.of(context).unfocus(),
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.secondary,
                          width: 0.5,
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(36),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.secondary,
                          width: 1.5,
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(36),
                        ),
                      ),
                      fillColor: Theme.of(context).colorScheme.primaryContainer,
                      filled: true,
                      contentPadding: const EdgeInsets.all(16),
                      hintText: AppStrings.ask,
                      hintStyle: const TextStyle(
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ),
                if (!_isTextFieldEmpty)
                  Container(
                    padding: const EdgeInsets.only(left: 4),
                    margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(36),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _sendMessage,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
