import 'package:flutter/material.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';

import 'package:my_people/helpers/analytics_helper.dart';
import 'package:my_people/view/screens/home_screen/home_screen.dart';
import 'package:my_people/utility/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp();
  SharedPrefs.init();
  AnalyticsHelper.appLaunched();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'My People',
      home: const HomeScreen(),
    );
  }
}
