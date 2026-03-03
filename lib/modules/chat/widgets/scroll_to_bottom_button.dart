import 'package:flutter/material.dart';

/// A mini FAB that scrolls the chat to the bottom when pressed.
class ScrollToBottomButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ScrollToBottomButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 90),
        child: FloatingActionButton(
          mini: true,
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          onPressed: onPressed,
          child: Icon(
            Icons.arrow_downward,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }
}
