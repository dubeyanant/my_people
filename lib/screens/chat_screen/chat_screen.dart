import 'package:flutter/material.dart';

import 'package:my_people/services/gemini_ai_service.dart';
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
  final List<ChatMessage> _messages = ChatMessage.messages;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final GeminiAIService _geminiAIService = GeminiAIService();
  bool _isTextFieldEmpty = true;
  bool _loading = false;
  ChatMessage? _thinkingMessage;
  bool _showScrollToBottomButton = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
    _scrollController.addListener(_scrollListener);
    _controller.addListener(_handleTextFieldChange);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTextFieldChange);
    _scrollController.removeListener(_scrollListener);
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.hasClients) {
      final currentScroll = _scrollController.position.pixels;
      setState(() {
        _showScrollToBottomButton = currentScroll != 0;
      });
    }
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _handleTextFieldChange() {
    bool isEmpty = _controller.text.isEmpty;
    if (_isTextFieldEmpty != isEmpty) {
      setState(() {
        _isTextFieldEmpty = isEmpty;
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      final userMessage = _controller.text;
      setState(() {
        _messages.add(ChatMessage(
          text: userMessage,
          sender: AppStrings.user,
        ));
        _controller.clear();
        _isTextFieldEmpty = true; // Reset the flag
        _loading = true;
        _addThinkingMessage();
      });

      try {
        final aiResponse = await _geminiAIService.sendMessage(userMessage);
        setState(() {
          _loading = false;
          _removeThinkingMessage();
          _messages.add(ChatMessage(
            text: aiResponse,
            sender: AppStrings.bot,
          ));
        });
      } catch (e) {
        if (e.toString().contains('SocketException')) {
          _showError('Please check your internet connection and try again.');
        } else {
          _showError('Error sending message to Gemini AI: $e');
        }
        setState(() {
          _loading = false;
          _removeThinkingMessage();
        });
      }
    }
  }

  void _addThinkingMessage() {
    _thinkingMessage = ChatMessage(
      text: AppStrings.thinking,
      sender: AppStrings.bot,
    );
    _messages.add(_thinkingMessage!);
  }

  void _removeThinkingMessage() {
    if (_thinkingMessage != null) {
      _messages.remove(_thinkingMessage);
      _thinkingMessage = null;
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(AppStrings.wentWrong),
          content: SingleChildScrollView(
            child: SelectableText(message),
          ),
          titlePadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          actionsPadding: const EdgeInsets.only(right: 8, bottom: 8),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(AppStrings.ok),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.chat),
      ),
      body: Stack(
        children: [
          Column(
            children: <Widget>[
              Expanded(
                child: ListView.builder(
                  itemCount: _messages.length,
                  controller: _scrollController,
                  reverse: true,
                  itemBuilder: (context, index) {
                    final message = _messages[_messages.length - 1 - index];
                    return MessageBubble(
                      message: message,
                      isMe: message.sender == AppStrings.user,
                    );
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        maxLines: 3,
                        minLines: 1,
                        onTapOutside: (event) =>
                            FocusScope.of(context).unfocus(),
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
                          fillColor:
                              Theme.of(context).colorScheme.primaryContainer,
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
                      _loading
                          ? const Padding(
                              padding: EdgeInsets.only(left: 16, right: 8),
                              child: CircularProgressIndicator.adaptive(),
                            )
                          : Container(
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
          if (_showScrollToBottomButton)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 90),
                child: FloatingActionButton(
                  mini: true,
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                  onPressed: _scrollToBottom,
                  child: const Icon(Icons.arrow_downward, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
