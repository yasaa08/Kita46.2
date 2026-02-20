// lib/main.dart
// VERSI DENGAN TOMBOL "KUMPULAN DO'A" DITAMBAHKAN KEMBALI

import 'package:flutter/material.dart';
import 'daftar_surah_page.dart';
import 'asmaul_husna_page.dart';
import 'pr13_page.dart'; // Halaman untuk PR 13 / Kumpulan Do'a
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
        primaryColor: Colors.teal,
        scaffoldBackgroundColor: Colors.black,
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
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            "assets/images/BaitulMunirBlur.png", // Nama file blurmu
            fit: BoxFit.cover,
          ),
          // Overlay Gelap
          Container(
            color: Colors.black.withOpacity(0.5),
          ),
          // Konten Utama
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Padding(
                      padding: const EdgeInsets.only(top: 48.0, bottom: 32.0),
                      child: Image.asset(
                        'assets/images/Merahldii.png', // Logo kamu
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

                    // =============================================
                    // TOMBOL KUMPULAN DO'A DITAMBAHKAN KEMBALI
                    // =============================================
                    MenuButton(
                      text: "KUMPULAN DO'A", // Teks tombol
                      onPressed: () {
                        // Arahkan ke halaman yang sama dengan PR 13
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const Pr13Page()));
                      },
                    ),
                    // =============================================

                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SettingsPage()),
          );
        },
        backgroundColor: Colors.white.withOpacity(0.2),
        foregroundColor: Colors.white,
        mini: true,
        shape: CircleBorder(
          side: BorderSide(color: Colors.white.withOpacity(0.5), width: 1)
        ),
        elevation: 2,
        child: const Icon(Icons.settings),
      ),
    );
  }
}

// Widget Tombol (Tidak perlu diubah)
class MenuButton extends StatelessWidget {
  // ... (kode MenuButton tidak perlu diubah) ...
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
          backgroundColor: Colors.white.withOpacity(0.2),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Colors.white.withOpacity(0.5),
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
          ),
        ),
      ),
    );
  }
}