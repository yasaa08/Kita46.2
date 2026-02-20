// lib/splash_screen.dart

import 'dart:async'; 
import 'package:flutter/material.dart';
import 'main.dart'; 

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _startSplashScreenTimer(); 
  }

  void _startSplashScreenTimer() {
    const splashDuration = Duration(seconds: 3); 
    Timer(splashDuration, () {
      // PENGAMAN: Cek apakah widget masih aktif di layar sebelum pindah halaman
      if (mounted) { 
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (BuildContext context) => const HomePage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Disamakan dengan tema utama
      body: Center( 
        child: Column( 
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/Merahldii.png', 
              height: 120, 
            ),
            const SizedBox(height: 20), 
          ],
        ),
      ),
    );
  }
}