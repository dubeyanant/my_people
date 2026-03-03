import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  // Private constructor
  SharedPrefs._privateConstructor();

  // Static instance of the class
  static final SharedPrefs _instance = SharedPrefs._privateConstructor();

  // Factory constructor to return the static instance
  factory SharedPrefs() {
    return _instance;
  }

  static SharedPreferences? _preferences;

  // Method to initialize SharedPreferences
  static Future<void> init() async {
    _preferences ??= await SharedPreferences.getInstance();
  }

  // Getter for the SharedPreferences instance
  static SharedPreferences? get instance => _preferences;

  // Method to set last update check date
  static Future<bool> setLastUpdateCheckDate(DateTime value) {
    return _preferences!
        .setString("lastUpdateCheckDate", value.toIso8601String());
  }

  // Method to get last update check date
  static DateTime? getLastUpdateCheckDate() {
    final String? dateString = _preferences!.getString("lastUpdateCheckDate");
    return dateString != null ? DateTime.parse(dateString) : null;
  }

  // Theme state
  static Future<bool> setThemeState(String theme) {
    return _preferences!.setString("themeState", theme);
  }

  static String getThemeState() {
    return _preferences!.getString("themeState") ?? "dynamic";
  }

  // Biometric state
  static Future<bool> setBiometricEnabled(bool enabled) {
    return _preferences!.setBool("biometricEnabled", enabled);
  }

  static bool getBiometricEnabled() {
    return _preferences!.getBool("biometricEnabled") ?? false;
  }

  // Radial menu swipe tip
  static int getRadialLongPressCount() {
    return _preferences!.getInt("radialLongPressCount") ?? 0;
  }

  static Future<bool> incrementRadialLongPressCount() {
    final count = getRadialLongPressCount() + 1;
    return _preferences!.setInt("radialLongPressCount", count);
  }

  static bool getSwipeTipShown() {
    return _preferences!.getBool("swipeTipShown") ?? false;
  }

  static Future<bool> setSwipeTipShown(bool shown) {
    return _preferences!.setBool("swipeTipShown", shown);
  }
}
