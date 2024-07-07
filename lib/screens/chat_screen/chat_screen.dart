import 'package:flutter/material.dart';
import 'package:my_people/helpers/analytics_helper.dart';

import 'package:my_people/model/person.dart';
import 'package:my_people/services/gemini_ai_service.dart';
import 'package:my_people/model/chat_message.dart';
import 'package:my_people/screens/chat_screen/message_bubble.dart';
import 'package:my_people/utility/constants.dart';
import 'package:my_people/utility/debug_print.dart';

class ChatScreen extends StatefulWidget {
  final Person person;

  const ChatScreen(this.person, {super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  static final Map<String, ChatSession> _chatSessions = {};
  late ChatSession _currentSession;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  late final GeminiAIService _geminiAIService;
  bool _isTextFieldEmpty = true;
  bool _loading = false;
  ChatMessage? _thinkingMessage;
  bool _showScrollToBottomButton = false;
  bool _isFirstFocus = true;

  @override
  void initState() {
    super.initState();
    _currentSession = _chatSessions.putIfAbsent(
        widget.person.uuid, () => ChatSession(widget.person.uuid));
    _geminiAIService = GeminiAIService();
    _isFirstFocus = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendInitialPrompt();
    });
    _scrollController.addListener(_scrollListener);
    _controller.addListener(_handleTextFieldChange);
    AnalyticsHelper.trackFeatureUsage('chat_screen_opened');
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

  Future<void> _sendInitialPrompt() async {
    final initialPrompt = '''
  This is the information about the person I'm talking about:
  Name: ${widget.person.name}
  Info: ${widget.person.info.join(', ')}

  Strictly use this info while answering any of the next prompts. Do not hallucinate or generate information that is not present in this info. If you understood, say "Hi, how may I help you?"
  ''';

    setState(() {
      _loading = true;
    });

    try {
      final aiResponse =
          await _geminiAIService.sendInitialPrompt(initialPrompt);
      if (aiResponse.trim().toLowerCase() == "hi, how may i help you?") {
        setState(() {
          _currentSession.messages.add(ChatMessage(
            text: aiResponse,
            sender: AppStrings.bot,
          ));
        });
      }
      _enableTextFieldAndFocus();
    } catch (e) {
      DebugPrint.log(
        'Error sending initial prompt: $e',
        color: DebugColor.red,
        tag: 'ChatScreen',
      );
      _enableTextFieldAndFocus();
    }
  }

  void _enableTextFieldAndFocus() {
    setState(() {
      _loading = false;
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        if (_isFirstFocus) {
          FocusScope.of(context).requestFocus(_focusNode);
          _isFirstFocus = false;
        }
      }
    });
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
      AnalyticsHelper.trackFeatureUsage('send_AI_message');
      final userMessage = _controller.text;
      setState(() {
        _currentSession.messages.add(ChatMessage(
          text: userMessage,
          sender: AppStrings.user,
        ));
        _controller.clear();
        _isTextFieldEmpty = true;
        _loading = true;
        _addThinkingMessage();
      });

      try {
        final aiResponse = await _geminiAIService.sendMessage(userMessage);
        setState(() {
          _removeThinkingMessage();
          _currentSession.messages.add(ChatMessage(
            text: aiResponse,
            sender: AppStrings.bot,
          ));
        });
        _enableTextFieldAndFocus();
      } catch (e) {
        if (e.toString().contains('SocketException')) {
          _showError('Please check your internet connection and try again.');
        } else {
          _showError('Error sending message to Gemini AI: $e');
        }
        setState(() {
          _removeThinkingMessage();
        });
        _enableTextFieldAndFocus();
      }
    }
  }

  void _addThinkingMessage() {
    _thinkingMessage = ChatMessage(
      text: AppStrings.thinking,
      sender: AppStrings.bot,
    );
    _currentSession.messages.add(_thinkingMessage!);
  }

  void _removeThinkingMessage() {
    if (_thinkingMessage != null) {
      _currentSession.messages.remove(_thinkingMessage);
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
                  itemCount: _currentSession.messages.length,
                  controller: _scrollController,
                  reverse: true,
                  itemBuilder: (context, index) {
                    final message = _currentSession
                        .messages[_currentSession.messages.length - 1 - index];
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
                        enabled: !_loading,
                        onTap: () => _focusNode.requestFocus(),
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
                          disabledBorder: OutlineInputBorder(
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
                          fillColor: _loading
                              ? Colors.grey[200]
                              : Theme.of(context).colorScheme.primaryContainer,
                          filled: true,
                          contentPadding: const EdgeInsets.all(16),
                          hintText:
                              _loading ? AppStrings.waiting : AppStrings.ask,
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

class ChatSession {
  final String personUuid;
  final List<ChatMessage> messages;

  ChatSession(this.personUuid) : messages = [];
}
