import 'package:flutter/material.dart';

import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:my_people/model/chat_message.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const MessageBubble({super.key, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          color: isMe
              ? Theme.of(context).colorScheme.secondary
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
                : Theme.of(context).colorScheme.onPrimaryContainer,
          ),
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
