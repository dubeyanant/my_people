import 'package:flutter/material.dart';

import 'package:my_people/utility/shared_preferences.dart';

/// Encapsulates the one-time "swipe pro-tip" bottom sheet logic.
///
/// Tracks how many times the user has opened the radial menu via long-press
/// and shows a tip after [triggerCount] opens.
class SwipeTipHelper {
  static const int triggerCount = 3;

  /// Increments the long-press count and returns `true` if the tip should be
  /// shown on this interaction.
  static bool trackAndCheck() {
    if (SharedPrefs.getSwipeTipShown()) return false;
    SharedPrefs.incrementRadialLongPressCount();
    return SharedPrefs.getRadialLongPressCount() >= triggerCount;
  }

  /// Shows the swipe pro-tip bottom sheet and marks it as shown.
  static void show(BuildContext context) {
    SharedPrefs.setSwipeTipShown(true);

    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.colorScheme.primary.withAlpha(60),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withAlpha(30),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.swipe_rounded,
                size: 40,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                'Pro Tip',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Swipe directly towards an option\nto skip the menu!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withAlpha(180),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  'Got it!',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
