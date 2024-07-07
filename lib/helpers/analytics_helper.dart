import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:my_people/firebase_options.dart';

class AnalyticsHelper {
  static final _instance = FirebaseAnalytics.instance;

  static Future<void> init() {
    return Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  static void userLoggedIn(String loginMethod, {String id = 'NA'}) async {
    return _instance.logLogin(loginMethod: loginMethod, parameters: {'id': id});
  }

  static void userLoginActivity(String loginMethod, String activity,
      {String id = 'NA'}) async {
    return _instance.logEvent(name: 'login_activity', parameters: {
      'login_method': loginMethod,
      'activity': activity,
      'id': id,
    });
  }

  static void appLaunched() async {
    return _instance.logAppOpen();
  }

  static void trackFeatureUsage(String featureName) async {
    return _instance.logEvent(
      name: 'feature_used',
      parameters: <String, dynamic>{
        'feature_name': featureName,
      },
    );
  }
}
