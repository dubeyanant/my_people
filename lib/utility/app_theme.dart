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

    if (hour >= 6 && hour < 12) {
      return _morningTheme;
    } else if (hour >= 12 && hour < 16) {
      return _afternoonTheme;
    } else if (hour >= 16 && hour < 20) {
      return _eveningTheme;
    } else {
      return _nightTheme;
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
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF1A1035),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF6B3FA0),
      brightness: Brightness.dark,
      primary: const Color(0xFF9B59B6),
      secondary: const Color(0xFFE8736C),
      surface: const Color(0xFF231640),
      onSurface: const Color(0xFFEDE0F5),
    ),
    cardColor: const Color(0xFF231640),
    extensions: const <ThemeExtension<dynamic>>[
      HeaderGradientTheme(
        colors: [
          Color(0xFF6B3FA0),
          Color(0xFFE8736C),
        ],
      ),
    ],
  );

  static final ThemeData _nightTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0F172A),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF141E30),
      brightness: Brightness.dark,
      primary: const Color(0xFF243B55),
      secondary: const Color(0xFF243B55),
      surface: const Color(0xFF1E293B),
      onSurface: const Color(0xFFE2E8F0), // Light gray text
    ),
    cardColor: const Color(0xFF1E293B),
    extensions: const <ThemeExtension<dynamic>>[
      HeaderGradientTheme(
        colors: [
          Color(0xFF141E30),
          Color(0xFF243B55),
        ],
      ),
    ],
  );
}
