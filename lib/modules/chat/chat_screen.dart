import 'package:flutter/material.dart';

import 'package:my_people/helpers/analytics_helper.dart';
import 'package:my_people/model/person.dart';
import 'package:my_people/modules/chat/widgets/chat_input_section.dart';
import 'package:my_people/modules/chat/widgets/report_tooltip.dart';
import 'package:my_people/modules/chat/widgets/thinking_indicator.dart';
import 'package:my_people/services/gemini_ai_service.dart';
import 'package:my_people/model/chat_message.dart';
import 'package:my_people/modules/chat/widgets/message_bubble.dart';
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
  bool _isAiThinking = false;
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
        _isAiThinking = true;
      });

      if (userMessage.toLowerCase().contains(AppStrings.prompt)) {
        setState(() {
          _currentSession.messages.add(ChatMessage(
            text: AppStrings.blockedResponse,
            sender: AppStrings.bot,
          ));
          _loading = false;
          _isAiThinking = false;
        });
        _enableTextFieldAndFocus();
      } else {
        setState(() {
          _loading = true;
          _isAiThinking = true;
        });

        try {
          final aiResponse = await _geminiAIService.sendMessage(userMessage);
          if (!mounted) return;

          String finalResponseText;
          if (aiResponse.toLowerCase().contains(AppStrings.prompt)) {
            finalResponseText = AppStrings.blockedResponse;
          } else {
            finalResponseText = aiResponse;
          }

          setState(() {
            _isAiThinking = false;
            _currentSession.messages.add(ChatMessage(
              text: finalResponseText,
              sender: AppStrings.bot,
            ));
          });
          _enableTextFieldAndFocus();
        } catch (e) {
          if (!mounted) return;
          if (e.toString().contains('SocketException')) {
            _showError('Please check your internet connection and try again.');
          } else {
            _showError('Error sending message to Gemini AI.');
          }
          setState(() {
            _isAiThinking = false;
          });
          _enableTextFieldAndFocus();
        }
      }
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

  Future<void> _reportMessage(ChatMessage messageToReport) async {
    final bool? confirmReport = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(AppStrings.reportMessageTitle),
          content: const Text(AppStrings.reportMessageContent),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(AppStrings.cancelAction),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(AppStrings.reportAction),
            ),
          ],
        );
      },
    );

    if (confirmReport == true && mounted) {
      final int messageIndex =
          _currentSession.messages.indexOf(messageToReport);

      if (messageIndex != -1) {
        AnalyticsHelper.trackReportAIMessage(messageToReport.text);

        setState(() {
          _currentSession.messages[messageIndex] = ChatMessage(
            text: AppStrings.reportedMessageThankYou,
            sender: AppStrings.bot,
          );
        });
      } else {
        DebugPrint.log(
          'Error reporting message: Message not found in list.',
          color: DebugColor.red,
          tag: 'ChatScreen',
        );
        _showError('Could not report the message due to an internal error.');
      }
    }
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
                child: Stack(
                  children: [
                    ListView.builder(
                      itemCount: _currentSession.messages.length +
                          (_isAiThinking ? 1 : 0),
                      controller: _scrollController,
                      reverse: true,
                      itemBuilder: (context, index) {
                        if (_isAiThinking && index == 0) {
                          return const ThinkingIndicator();
                        }

                        final messageIndex = _isAiThinking ? index - 1 : index;
                        final actualMessageIndex =
                            _currentSession.messages.length - 1 - messageIndex;

                        if (actualMessageIndex < 0 ||
                            actualMessageIndex >=
                                _currentSession.messages.length) {
                          return const SizedBox.shrink();
                        }

                        final message =
                            _currentSession.messages[actualMessageIndex];
                        final bool isUserMessage =
                            message.sender == AppStrings.user;

                        return MessageBubble(
                          message: message,
                          isMe: isUserMessage,
                          onReport: isUserMessage ||
                                  message.text ==
                                      AppStrings.reportedMessageThankYou
                              ? null
                              : () => _reportMessage(message),
                        );
                      },
                    ),
                    if (_currentSession.messages
                            .any((m) => m.sender != AppStrings.user) &&
                        _currentSession.messages.length < 5)
                      ReportTooltip(),
                  ],
                ),
              ),
              ChatInputSection(
                controller: _controller,
                focusNode: _focusNode,
                loading: _loading,
                isTextFieldEmpty: _isTextFieldEmpty,
                onSendMessage: _sendMessage,
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
                  child: Icon(
                    Icons.arrow_downward,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
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
