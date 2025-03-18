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
}
