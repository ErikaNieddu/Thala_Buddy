import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/resting_heart_rate_provider.dart'; 
import 'providers/heart_rate_provider.dart';
import 'providers/steps_provider.dart';
import 'providers/sleep_provider.dart';

import 'screens/home.dart';
import 'screens/login.dart';
import 'screens/onboarding.dart';
import 'screens/splash.dart';
import 'screens/guide.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider 
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RestingHeartRateProvider()),
        ChangeNotifierProvider(create: (_) => HeartRateProvider()),
        ChangeNotifierProvider(create: (_) => StepsProvider()),
        ChangeNotifierProvider(create: (_) => SleepProvider()),
      ],
      child: MaterialApp(
        title: 'Thala Buddy',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 183, 38, 38),
          ),
          useMaterial3: true,
        ),
        home: const Splash(), 
        routes: {
          Home.route: (context) => const Home(),
          '/login/': (context) => const Login(), 
          '/onboarding/': (context) => const Onboarding(), 
          '/guide/': (context) => const GuideScreen(),
        },
      ),
    );
  }
}