// lib/settings_page.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; 
import 'package:share_plus/share_plus.dart'; 

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      debugPrint('Could not launch $url'); 
    }
  }

  void _shareApp(BuildContext context) { 
     final String appLink = "https://play.google.com/store/apps/details?id=com.nama_kamu.kita_46_2"; 
     final String shareText = "Yuk download aplikasi Kita 46.2 untuk baca Qur'an dan doa harian!\n$appLink";

     Share.share(shareText, subject: 'Cobain Aplikasi Kita 46.2!'); 
  }

  @override
  Widget build(BuildContext context) { 
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Pengaturan', style: TextStyle(color: Color(0xFFF5F5F5))),
        iconTheme: const IconThemeData(color: Color(0xFFF5F5F5)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: [
            ListTile(
              leading: const Icon(Icons.info_outline, color: Color(0xFF4DB6AC)),
              title: const Text('Tentang Aplikasi Ini', style: TextStyle(color: Color(0xFFF5F5F5))),
              onTap: () {
                 showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: const Color(0xFF1E1E1E),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    title: const Text('Tentang Kita 46.2', style: TextStyle(color: Color(0xFFF5F5F5))),
                    content: const Text(
                      'Aplikasi sederhana untuk membaca Al-Qur\'an, Asmaul Husna, PR 13, dan Kumpulan Do\'a.\n\nSemoga bermanfaat!',
                      style: TextStyle(color: Color(0xFFE0E0E0)),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK', style: TextStyle(color: Color(0xFF4DB6AC))),
                      ),
                    ],
                  ),
                );
              },
            ),
            const Divider(color: Color(0xFF2C2C2C)),

            ListTile(
              leading: const Icon(Icons.share, color: Color(0xFF4DB6AC)),
              title: const Text('Bagikan Aplikasi Ini', style: TextStyle(color: Color(0xFFF5F5F5))),
              onTap: () {
                _shareApp(context); 
              },
            ),
            const Divider(color: Color(0xFF2C2C2C)),

            ListTile(
              leading: const Icon(Icons.link, color: Color(0xFF4DB6AC)), 
              title: const Text('Follow Instagram Kami', style: TextStyle(color: Color(0xFFF5F5F5))),
              onTap: () {
                _launchURL('https://www.instagram.com/maskennan_'); 
              },
            ),
            const Divider(color: Color(0xFF2C2C2C)),

            const Spacer(), 

            Center( 
              child: Text(
                'App by K.Elyasa',
                style: TextStyle(color: Color(0xFFA0A0A0), fontSize: 12),
              ),
            ),
            const SizedBox(height: 16), 
          ],
        ),
      ),
    );
  }
}