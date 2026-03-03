import 'package:flutter/material.dart';

import 'package:my_people/model/chat_message.dart';
import 'package:my_people/modules/chat/widgets/message_bubble.dart';
import 'package:my_people/modules/chat/widgets/report_tooltip.dart';
import 'package:my_people/modules/chat/widgets/thinking_indicator.dart';
import 'package:my_people/utility/constants.dart';

/// The scrollable list of chat messages with an optional thinking indicator
/// and a first-message report tooltip.
class ChatMessageList extends StatelessWidget {
  final List<ChatMessage> messages;
  final bool isThinking;
  final ScrollController scrollController;
  final void Function(ChatMessage message) onReport;

  const ChatMessageList({
    super.key,
    required this.messages,
    required this.isThinking,
    required this.scrollController,
    required this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView.builder(
          itemCount: messages.length + (isThinking ? 1 : 0),
          controller: scrollController,
          reverse: true,
          itemBuilder: (context, index) {
            if (isThinking && index == 0) {
              return const ThinkingIndicator();
            }

            final messageIndex = isThinking ? index - 1 : index;
            final actualMessageIndex = messages.length - 1 - messageIndex;

            if (actualMessageIndex < 0 ||
                actualMessageIndex >= messages.length) {
              return const SizedBox.shrink();
            }

            final message = messages[actualMessageIndex];
            final bool isUserMessage = message.sender == AppStrings.user;

            return MessageBubble(
              message: message,
              isMe: isUserMessage,
              onReport: isUserMessage ||
                      message.text == AppStrings.reportedMessageThankYou
                  ? null
                  : () => onReport(message),
            );
          },
        ),
        if (messages.any((m) => m.sender != AppStrings.user) &&
            messages.length <= 1)
          const ReportTooltip(),
      ],
    );
  }
}
