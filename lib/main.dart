import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'database_service.dart';
import 'login_page.dart';
import 'daftar_surah_page.dart';
import 'asmaul_husna_page.dart';
import 'pr13_page.dart'; 
import 'settings_page.dart';
import 'splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kita 46.2',
      theme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFF4DB6AC),
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF121212), elevation: 0),
      ),
      // Cek apakah user sudah login atau belum
      home: FirebaseAuth.instance.currentUser == null ? const LoginPage() : const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            children: [
              const SizedBox(height: 48),
              Image.asset('assets/images/Merahldii.png', height: 80),
              const SizedBox(height: 32),

              // Widget Riwayat Terakhir
              StreamBuilder<DocumentSnapshot>(
                stream: DatabaseService().userHistory,
                builder: (context, snapshot) {
                  if (!snapshot.hasData || !snapshot.data!.exists) return const SizedBox.shrink();
                  var data = snapshot.data!.data() as Map<String, dynamic>;
                  var surah = data['last_read_surah'];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF4DB6AC).withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.menu_book, color: Color(0xFF4DB6AC)),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Lanjutkan Membaca:", style: TextStyle(color: Colors.grey, fontSize: 12)),
                            Text("${surah['name']} (Ayat ${surah['ayah']})", style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),

              MenuButton(text: "BACA QUR'AN", onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DaftarSurahPage()))),
              const SizedBox(height: 16),
              MenuButton(text: "ASMAUL HUSNA", onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AsmaulHusnaPage()))),
              const SizedBox(height: 16),
              MenuButton(text: "PR 13", onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Pr13Page()))),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage())),
        backgroundColor: const Color(0xFF1E1E1E),
        child: const Icon(Icons.settings),
      ),
    );
  }
}

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
          backgroundColor: const Color(0xFF1E1E1E),
          foregroundColor: const Color(0xFFF5F5F5),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}