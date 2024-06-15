import 'dart:developer' as developer;

enum DebugColor {
  black,
  red,
  green,
  yellow,
  blue,
  magenta,
  cyan,
  white,
}

class DebugPrint {
  static void log(
    String message, {
    String tag = 'DEBUG',
    DebugColor color = DebugColor.cyan,
  }) {
    final coloredMessage = _applyColor(message, color);
    developer.log(coloredMessage, name: tag);
  }

  static String _applyColor(String message, DebugColor color) {
    const Map<DebugColor, String> colorCodes = {
      DebugColor.black: '\x1B[30m',
      DebugColor.red: '\x1B[31m',
      DebugColor.green: '\x1B[32m',
      DebugColor.yellow: '\x1B[33m',
      DebugColor.blue: '\x1B[34m',
      DebugColor.magenta: '\x1B[35m',
      DebugColor.cyan: '\x1B[36m',
      DebugColor.white: '\x1B[37m',
    };

    final colorCode = colorCodes[color] ?? colorCodes[DebugColor.cyan];
    const resetCode = '\x1B[0m';

    return '$colorCode$message$resetCode';
  }
}
