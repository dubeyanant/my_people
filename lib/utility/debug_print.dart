import 'dart:developer' as developer;

enum DebugColor {
  red,
  green,
  yellow,
  magenta,
  cyan,
  white,
}

// Utility class for logging debug messages with color
class DebugPrint {
  // Method for logging debug messages with optional tag and color
  static void log(
    String message, {
    String tag = 'DEBUG', // Default tag for debug messages
    DebugColor color = DebugColor.cyan, // Default color for debug messages
  }) {
    // Apply color to the message using ANSI escape codes
    final coloredMessage = _applyColor(message, color);
    // Log the colored message using dart:developer's log function
    developer.log(coloredMessage, name: tag);
  }

  // Private method to apply color to the message based on DebugColor
  static String _applyColor(String message, DebugColor color) {
    // ANSI escape codes for different colors
    const Map<DebugColor, String> colorCodes = {
      DebugColor.red: '\x1B[31m',
      DebugColor.green: '\x1B[32m',
      DebugColor.yellow: '\x1B[33m',
      DebugColor.magenta: '\x1B[35m',
      DebugColor.cyan: '\x1B[36m',
      DebugColor.white: '\x1B[37m',
    };

    // Get the ANSI color code from the map; fallback to cyan if not found
    final colorCode = colorCodes[color] ?? colorCodes[DebugColor.cyan];
    // ANSI escape code to reset color to default
    const resetCode = '\x1B[0m';

    // Return the message wrapped with color codes for terminal display
    return '$colorCode$message$resetCode';
  }
}
