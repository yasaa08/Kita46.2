// lib/settings_page.dart
// VERSI BARU DENGAN URL_LAUNCHER & SHARE_PLUS AKTIF

import 'package:flutter/material.dart';
// Import package yang dibutuhkan
import 'package:url_launcher/url_launcher.dart'; 
import 'package:share_plus/share_plus.dart'; 

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  // Fungsi untuk membuka URL 
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(
      uri,
      // mode: LaunchMode.externalApplication, // Buka di browser luar, bukan di dalam app
    )) {
      // Tampilkan pesan error jika gagal membuka link
      debugPrint('Could not launch $url'); 
      // ScaffoldMessenger.of(context).showSnackBar( // Butuh context di sini
      //   SnackBar(content: Text('Tidak bisa membuka link: $url')),
      // );
    }
  }

  // Fungsi untuk share
  void _shareApp(BuildContext context) { // Butuh context untuk posisi share (di iPad)
     // Nanti ganti link ini dengan link Play Store/App Store aplikasimu
     final String appLink = "https://play.google.com/store/apps/details?id=com.nama_kamu.kita_46_2"; // Contoh
     final String shareText = "Yuk download aplikasi Kita 46.2 untuk baca Qur'an dan doa harian!\n$appLink";

     Share.share(shareText, subject: 'Cobain Aplikasi Kita 46.2!'); // Subject untuk email
  }


  @override
  Widget build(BuildContext context) { // Tambahkan context di sini
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Pengaturan'),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: [
            // --- ABOUT THIS APP ---
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.tealAccent),
              title: const Text('Tentang Aplikasi Ini', style: TextStyle(color: Colors.white)),
              onTap: () {
                // ... (Kode showDialog tidak berubah) ...
                 showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: const Color(0xFF1F1F1F),
                    title: const Text('Tentang Kita 46.2', style: TextStyle(color: Colors.white)),
                    content: const Text(
                      'Aplikasi sederhana untuk membaca Al-Qur\'an, Asmaul Husna, PR 13, dan Kumpulan Do\'a.\n\nSemoga bermanfaat!',
                      style: TextStyle(color: Colors.white70),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK', style: TextStyle(color: Colors.tealAccent)),
                      ),
                    ],
                  ),
                );
              },
            ),
            const Divider(color: Color(0xFF1F1F1F)),

            // --- SHARE THIS APP ---
            ListTile(
              leading: const Icon(Icons.share, color: Colors.tealAccent),
              title: const Text('Bagikan Aplikasi Ini', style: TextStyle(color: Colors.white)),
              onTap: () {
                // Panggil fungsi share
                _shareApp(context); 
              },
            ),
            const Divider(color: Color(0xFF1F1F1F)),

            // --- FOLLOW IG ---
            ListTile(
              leading: const Icon(Icons.link, color: Colors.tealAccent), 
              title: const Text('Follow Instagram Kami', style: TextStyle(color: Colors.white)),
              onTap: () {
                // V V V GANTI 'USERNAME_IG_KAMU' DENGAN USERNAME ASLI V V V
                _launchURL('https://www.instagram.com/maskennan_'); 
              },
            ),
            const Divider(color: Color(0xFF1F1F1F)),

            const Spacer(), 

            // --- FOOTER ---
            Center( 
              child: Text(
                'App by K.Elyasa',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ),
            const SizedBox(height: 16), 
          ],
        ),
      ),
    );
  }
}