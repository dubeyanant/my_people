import 'package:flutter/material.dart';

/// Displayed when the AI service is unavailable (e.g. 503).
class ChatUnavailableView extends StatelessWidget {
  const ChatUnavailableView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 64,
              color: colorScheme.onSurface.withAlpha(120),
            ),
            const SizedBox(height: 16),
            Text(
              'Chat Unavailable',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'The AI service is currently downtime. Please try again after some time.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurface.withAlpha(180),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
