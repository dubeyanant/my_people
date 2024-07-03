import 'package:flutter/material.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';

import 'package:my_people/screens/home_screen/home_screen.dart';
import 'package:my_people/screens/login_screen.dart';
import 'package:my_people/utility/shared_preferences.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  await SharedPrefs.init();
  bool isLoggedIn = SharedPrefs.getIsLoggedIn();
  runApp(MyApp(isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp(this.isLoggedIn, {super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'My People',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: isLoggedIn ? const HomeScreen() : const LoginScreen(),
    );
  }
}
