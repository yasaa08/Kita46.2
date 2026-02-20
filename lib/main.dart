// lib/main.dart

import 'package:flutter/material.dart';
import 'daftar_surah_page.dart';
import 'asmaul_husna_page.dart';
import 'pr13_page.dart'; 
import 'settings_page.dart';
import 'splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kita 46.2',
      theme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFF4DB6AC), // Soft Teal
        scaffoldBackgroundColor: const Color(0xFF121212), // Soft Charcoal
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          elevation: 0,
        ),
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Disamakan dengan page lain
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Padding(
                  padding: const EdgeInsets.only(top: 48.0, bottom: 48.0),
                  child: Image.asset(
                    'assets/images/Merahldii.png', 
                    height: 80,
                  ),
                ),

                // --- TOMBOL-TOMBOL MENU ---
                MenuButton(
                  text: "BACA QUR'AN",
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const DaftarSurahPage()));
                  },
                ),
                const SizedBox(height: 16),
                
                MenuButton(
                  text: "ASMAUL HUSNA",
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const AsmaulHusnaPage()));
                  },
                ),
                const SizedBox(height: 16),
                
                MenuButton(
                  text: "PR 13",
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const Pr13Page()));
                  },
                ),
                const SizedBox(height: 16),

                MenuButton(
                  text: "KUMPULAN DO'A",
                  onPressed: () {
                    // TODO: Nanti arahkan ke halaman KumpulanDoaPage()
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const Pr13Page()));
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SettingsPage()),
          );
        },
        backgroundColor: const Color(0xFF1E1E1E), // Soft dark
        foregroundColor: const Color(0xFFF5F5F5), // Soft white
        mini: true,
        shape: CircleBorder(
          side: BorderSide(color: const Color(0xFF4DB6AC).withOpacity(0.5), width: 1) // Border soft teal
        ),
        elevation: 2,
        child: const Icon(Icons.settings),
      ),
    );
  }
}

// Widget Tombol
class MenuButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  
  const MenuButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E1E1E), // Permukaan soft dark
          foregroundColor: const Color(0xFFF5F5F5), // Teks off-white
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(
              color: Color(0xFF2C2C2C), // Border abu-abu gelap
              width: 1,
            ),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2, // Tambahan spasi huruf agar lebih elegan
          ),
        ),
      ),
    );
  }
}