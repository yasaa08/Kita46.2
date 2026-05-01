import 'package:flutter/material.dart';

class DetailSholatPage extends StatelessWidget {
  final Map<String, dynamic> sholatData;

  const DetailSholatPage({super.key, required this.sholatData});

  @override
  Widget build(BuildContext context) {
    // Palet Warna Khas Pixel
    final sageColor = const Color(0xFFB2C8BA);
    final surfaceColor = const Color(0xFF242822);
    final bgColor = const Color(0xFF1A1C19);

    // Ambil data dari JSON
    final String title = sholatData['title'] ?? 'Detail';
    final String arabic = sholatData['arabic'] ?? '';
    final String latin = sholatData['latin'] ?? '';
    final String keutamaan = sholatData['keutamaan'] ?? '';
    final String riwayat = sholatData['riwayat_hadis'] ?? '';
    final String notes = sholatData['notes'] ?? '';

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 18)),
        backgroundColor: bgColor,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- SEKSI BACAAN ---
            if (arabic.isNotEmpty)
              Text(
                arabic,
                textAlign: TextAlign.right,
                style: TextStyle(fontFamily: 'LPMQ', fontSize: 32, color: sageColor, height: 1.8),
              ),
            const SizedBox(height: 24),
            if (latin.isNotEmpty)
              Text(
                latin,
                style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500),
              ),
            
            const SizedBox(height: 32),

            // --- SEKSI KEUTAMAAN ---
            if (keutamaan.isNotEmpty)
              _buildInfoSection(
                title: "Keutamaan",
                content: keutamaan,
                icon: Icons.star_border_rounded,
                iconColor: const Color(0xFFEADFB4), // Pastel Yellow
                surfaceColor: surfaceColor,
              ),

            // --- SEKSI RIWAYAT HADIS ---
            if (riwayat.isNotEmpty)
              _buildInfoSection(
                title: "Riwayat Hadis",
                content: riwayat,
                icon: Icons.history_edu_rounded,
                iconColor: const Color(0xFFD2E0FB), // Pastel Blue
                surfaceColor: surfaceColor,
              ),

            // --- SEKSI NOTES ---
            if (notes.isNotEmpty)
              _buildInfoSection(
                title: "Catatan Amalan",
                content: notes,
                icon: Icons.edit_note_rounded,
                iconColor: sageColor,
                surfaceColor: surfaceColor,
              ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Widget helper untuk bikin kotak informasi
  Widget _buildInfoSection({
    required String title,
    required String content,
    required IconData icon,
    required Color iconColor,
    required Color surfaceColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24), // Melengkung empuk
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)), // Garis tipis banget
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: iconColor, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.6),
          ),
        ],
      ),
    );
  }
}