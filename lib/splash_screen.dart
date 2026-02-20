// lib/splash_screen.dart

import 'dart:async'; // Diperlukan untuk Timer/Future.delayed
import 'package:flutter/material.dart';
import 'main.dart'; // Import main.dart untuk akses HomePage

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    // Jalankan fungsi _navigateToHome setelah beberapa detik
    _startSplashScreenTimer(); 
  }

  void _startSplashScreenTimer() {
    // Atur durasi splash screen (misalnya 3 detik)
    const splashDuration = Duration(seconds: 3); 

    Timer(splashDuration, () {
      // Setelah durasi selesai, pindah ke HomePage
      // pushReplacement agar tidak bisa kembali ke splash screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (BuildContext context) => const HomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Background hitam
      body: Center( // Taruh logo di tengah
        child: Column( // Pakai Column biar bisa atur ukuran lebih fleksibel
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/Merahldii.png', // Pastikan nama file logo benar
              height: 120, // Atur ukuran logo di sini (jangan terlalu besar)
              // width: 120, // Bisa pakai width juga jika perlu
            ),
            const SizedBox(height: 20), // Jarak sedikit ke bawah (opsional)
            // Bisa tambahkan CircularProgressIndicator jika mau ada loading
            // const CircularProgressIndicator(color: Colors.teal), 
          ],
        ),
      ),
    );
  }
}