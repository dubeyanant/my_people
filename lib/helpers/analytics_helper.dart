import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsHelper {
  static final _instance = FirebaseAnalytics.instance;

  static void appLaunched() async {
    return _instance.logAppOpen();
  }

  static void trackFeatureUsage(String featureName) async {
    return _instance.logEvent(
      name: 'feature_used',
      parameters: <String, Object>{'feature_name': featureName},
    );
  }
}
