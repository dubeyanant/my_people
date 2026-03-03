import 'package:flutter/material.dart';

import 'package:my_people/helpers/analytics_helper.dart';
import 'package:my_people/model/chat_message.dart';
import 'package:my_people/model/person.dart';
import 'package:my_people/modules/chat/chat_controller.dart';
import 'package:my_people/modules/chat/widgets/chat_input_section.dart';
import 'package:my_people/modules/chat/widgets/chat_message_list.dart';
import 'package:my_people/modules/chat/widgets/chat_unavailable_view.dart';
import 'package:my_people/modules/chat/widgets/scroll_to_bottom_button.dart';
import 'package:my_people/modules/chat/widgets/suggestion_chips.dart';
import 'package:my_people/utility/constants.dart';

class ChatScreen extends StatefulWidget {
  final Person person;

  const ChatScreen(this.person, {super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final ChatController _chatController;
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  bool _isTextFieldEmpty = true;
  bool _showScrollToBottomButton = false;
  bool _isFirstFocus = true;

  @override
  void initState() {
    super.initState();
    _chatController = ChatController(person: widget.person);
    _chatController.addListener(_onControllerUpdated);
    _scrollController.addListener(_onScrollChanged);
    _textController.addListener(_onTextChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _initChat());
    AnalyticsHelper.trackFeatureUsage('chat_screen_opened');
  }

  @override
  void dispose() {
    _chatController.removeListener(_onControllerUpdated);
    _chatController.dispose();
    _textController.removeListener(_onTextChanged);
    _scrollController.removeListener(_onScrollChanged);
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Controller listener
  // ---------------------------------------------------------------------------

  void _onControllerUpdated() {
    if (mounted) setState(() {});

    // Auto-focus on first successful load
    if (!_chatController.isLoading && _isFirstFocus) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          FocusScope.of(context).requestFocus(_focusNode);
          _isFirstFocus = false;
        }
      });
    }
  }

  // ---------------------------------------------------------------------------
  // Initialisation
  // ---------------------------------------------------------------------------

  Future<void> _initChat() async {
    await _chatController.initChat();
  }

  // ---------------------------------------------------------------------------
  // Scroll
  // ---------------------------------------------------------------------------

  void _onScrollChanged() {
    if (_scrollController.hasClients) {
      final shouldShow = _scrollController.position.pixels != 0;
      if (_showScrollToBottomButton != shouldShow) {
        setState(() => _showScrollToBottomButton = shouldShow);
      }
    }
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  // ---------------------------------------------------------------------------
  // Text field
  // ---------------------------------------------------------------------------

  void _onTextChanged() {
    final isEmpty = _textController.text.isEmpty;
    if (_isTextFieldEmpty != isEmpty) {
      setState(() => _isTextFieldEmpty = isEmpty);
    }
  }

  // ---------------------------------------------------------------------------
  // Send message
  // ---------------------------------------------------------------------------

  Future<void> _sendMessage() async {
    if (_textController.text.isEmpty) return;

    final text = _textController.text;
    _textController.clear();
    setState(() => _isTextFieldEmpty = true);

    final error = await _chatController.sendMessage(text);
    if (error != null && mounted) {
      _showError(error);
    }
  }

  // ---------------------------------------------------------------------------
  // Report
  // ---------------------------------------------------------------------------

  Future<void> _onReport(ChatMessage chatMessage) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
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
      ),
    );

    if (confirm == true && mounted) {
      final success = _chatController.reportMessage(chatMessage);
      if (!success) _showError(AppStrings.couldntReport);
    }
  }

  // ---------------------------------------------------------------------------
  // Error dialog
  // ---------------------------------------------------------------------------

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.wentWrong),
        content: SingleChildScrollView(child: SelectableText(message)),
        titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        actionsPadding: const EdgeInsets.only(right: 8, bottom: 8),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.ok),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.chat)),
      body: _chatController.isChatUnavailable
          ? const ChatUnavailableView()
          : Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: ChatMessageList(
                        messages: _chatController.messages,
                        isThinking: _chatController.isThinking,
                        scrollController: _scrollController,
                        onReport: _onReport,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _chatController.userMessageCount < 2
                          ? Padding(
                              key: const ValueKey('suggestions'),
                              padding: const EdgeInsets.only(bottom: 4),
                              child: SuggestionChips(
                                personName: widget.person.name,
                                onSuggestionTap: (suggestion) {
                                  _textController.text = suggestion;
                                  _onTextChanged();
                                  _sendMessage();
                                },
                              ),
                            )
                          : const SizedBox.shrink(
                              key: ValueKey('no-suggestions')),
                    ),
                    ChatInputSection(
                      controller: _textController,
                      focusNode: _focusNode,
                      loading: _chatController.isLoading,
                      isTextFieldEmpty: _isTextFieldEmpty,
                      onSendMessage: _sendMessage,
                    ),
                  ],
                ),
                if (_showScrollToBottomButton)
                  ScrollToBottomButton(onPressed: _scrollToBottom),
              ],
            ),
    );
  }
}
