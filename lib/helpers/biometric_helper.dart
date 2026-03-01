import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

import 'package:my_people/utility/shared_preferences.dart';

class BiometricHelper {
  static final _auth = LocalAuthentication();

  static Future<bool> hasBiometrics() async {
    try {
      return await _auth.canCheckBiometrics;
    } on PlatformException catch (_) {
      return false;
    }
  }

  static Future<bool> authenticate() async {
    final isAvailable = await hasBiometrics();
    if (!isAvailable) return false;

    try {
      return await _auth.authenticate(
        localizedReason: 'Please authenticate to access My People',
        biometricOnly: true,
      );
    } catch (e) {
      return false;
    }
  }

  static Future<bool> checkAuthIfEnabled() async {
    final isEnabled = SharedPrefs.getBiometricEnabled();
    if (isEnabled) {
      return await authenticate();
    }
    return true; // Not enabled, so authentication succeeds implicitly
  }
}
