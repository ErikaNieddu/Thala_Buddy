import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/impact.dart'; 

import 'login.dart';
import 'home.dart'; 
import 'guide.dart'; 

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    _checkNavigation();
  }

  Future<void> _checkNavigation() async {
    await Future.delayed(const Duration(seconds: 2));

    final sp = await SharedPreferences.getInstance();
    final isLoggedIn = sp.getBool('isLoggedIn') ?? false;
    final rememberMe = sp.getBool('remember_me') ?? false;
  
    final hasSeenGuide = sp.getBool('hasSeenGuide') ?? false;

    if (!mounted) return;

    if (!hasSeenGuide) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const GuideScreen()),
      );
      return; 
    }

    if (isLoggedIn && rememberMe) {
      final impact = Impact();
     
      String? validToken = await impact.getValidAccessToken();

      if (validToken != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const Home()),
        );
      } else {
        await sp.clear();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const Login()),
        );
      }
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const Login()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
      body: Center(
        child: Image.asset(
          'assets/logo.jpeg',
          scale: 2,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.bloodtype, 
              size: 80, 
              color: Color.fromARGB(255, 183, 38, 38),
            );
          },
        ),
      ),
    );
  }
}