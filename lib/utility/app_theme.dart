import 'package:flutter/material.dart';

class HeaderGradientTheme extends ThemeExtension<HeaderGradientTheme> {
  final List<Color> colors;

  const HeaderGradientTheme({required this.colors});

  @override
  HeaderGradientTheme copyWith({List<Color>? colors}) {
    return HeaderGradientTheme(colors: colors ?? this.colors);
  }

  @override
  HeaderGradientTheme lerp(
      ThemeExtension<HeaderGradientTheme>? other, double t) {
    if (other is! HeaderGradientTheme) {
      return this;
    }
    return HeaderGradientTheme(
      colors: List.generate(
        colors.length,
        (index) => Color.lerp(colors[index], other.colors[index], t)!,
      ),
    );
  }
}

class AppTheme {
  static ThemeData getThemeForCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour >= 5 && hour < 13) {
      return _morningTheme;
    } else if (hour >= 13 && hour < 18) {
      return _afternoonTheme;
    } else if (hour >= 18 && hour < 21) {
      return _eveningTheme;
    } else {
      return _nightTheme;
    }
  }

  static ThemeData getTheme(String themeString) {
    switch (themeString) {
      case 'morning':
        return _morningTheme;
      case 'noon':
      case 'afternoon':
        return _afternoonTheme;
      case 'evening':
        return _eveningTheme;
      case 'night':
        return _nightTheme;
      case 'dynamic':
      default:
        return getThemeForCurrentTime();
    }
  }

  static final ThemeData _morningTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF5F7FA),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF4A90E2),
      brightness: Brightness.light,
      primary: const Color(0xFF4A90E2),
      secondary: const Color(0xFF4A90E2),
      surface: Colors.white,
      onSurface: Colors.black87,
    ),
    cardColor: Colors.white,
    extensions: const <ThemeExtension<dynamic>>[
      HeaderGradientTheme(
        colors: [
          Color(0xFF4A90E2),
          Color(0xFF6FB1FC),
        ],
      ),
    ],
  );

  static final ThemeData _afternoonTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFFFF8F0),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFF7971E),
      brightness: Brightness.light,
      primary: const Color(0xFFF7971E),
      secondary: const Color(0xFFFFD166),
      surface: Colors.white,
      onSurface: Colors.black87,
    ),
    cardColor: Colors.white,
    extensions: const <ThemeExtension<dynamic>>[
      HeaderGradientTheme(
        colors: [
          Color(0xFFF7971E),
          Color(0xFFFFD166),
        ],
      ),
    ],
  );

  static final ThemeData _eveningTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF1A102B),
    colorScheme: ColorScheme.fromSeed(
      seedColor: Color(0xFFFF9966),
      brightness: Brightness.dark,
      primary: Color(0xFFFF9966),
      secondary: Color(0xFFB388FF),
      surface: Color(0xFF24173A),
      onSurface: Color(0xFFF3EFFF),
    ),
    cardColor: const Color(0xFF24173A),
    extensions: const <ThemeExtension<dynamic>>[
      HeaderGradientTheme(
        colors: [
          Color(0xFFFF9966),
          Color(0xFF6E48AA),
        ],
      ),
    ],
  );

  static final ThemeData _nightTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF121212),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF7A5CFF),
      brightness: Brightness.dark,
      primary: const Color(0xFFB388FF),
      secondary: const Color(0xFFFF8DA1),
      surface: const Color(0xFF1C1238),
      onSurface: const Color(0xFFEDE6FF),
    ),
    cardColor: const Color(0xFF1C1238),
    extensions: const <ThemeExtension<dynamic>>[
      HeaderGradientTheme(
        colors: [
          Color(0xFF2C1B47),
          Color(0xFF121212),
        ],
      ),
    ],
  );
}
