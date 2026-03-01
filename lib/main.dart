import 'package:flutter/material.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:my_people/helpers/analytics_helper.dart';
import 'package:my_people/modules/home/home_screen.dart';
import 'package:my_people/utility/shared_preferences.dart';
import 'package:my_people/utility/app_theme.dart';

import 'package:my_people/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp();
  await SharedPrefs.init();
  AnalyticsHelper.appLaunched();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeStateProvider);
    return MaterialApp(
      title: 'My People',
      theme: AppTheme.getTheme(themeState),
      home: const HomeScreen(),
    );
  }
}
