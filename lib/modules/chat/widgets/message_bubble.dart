import 'package:flutter/material.dart';

import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:my_people/model/chat_message.dart';
import 'package:my_people/utility/constants.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  final VoidCallback? onReport;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    final bool isReportedMessage =
        message.text == AppStrings.reportedMessageThankYou;
    final bool canBeReported = !isMe && !isReportedMessage && onReport != null;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onLongPress: canBeReported ? onReport : null,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: isMe
                      ? Theme.of(context).colorScheme.secondary
                      : isReportedMessage
                          ? Colors.grey[300]
                          : Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: isMe
                      ? const BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                          bottomLeft: Radius.circular(15),
                        )
                      : const BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                          bottomRight: Radius.circular(15),
                        ),
                ),
                child: FormattedTextWidget(
                  message.text,
                  style: TextStyle(
                    color: isMe
                        ? Theme.of(context).colorScheme.onSecondary
                        : isReportedMessage
                            ? Colors.black54
                            : Theme.of(context).colorScheme.onPrimaryContainer,
                    fontStyle:
                        isReportedMessage ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FormattedTextWidget extends StatelessWidget {
  final String text;
  final TextStyle? style;
  const FormattedTextWidget(this.text, {this.style, super.key});

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: text,
      styleSheet: MarkdownStyleSheet(
        p: style ?? Theme.of(context).textTheme.bodyMedium,
        code: style ??
            TextStyle(
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerHighest,
              fontFamily: 'monospace',
              fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
            ),
      ),
    );
  }
}
