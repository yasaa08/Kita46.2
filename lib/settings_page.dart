import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final user = FirebaseAuth.instance.currentUser;
  
  // Palet warna yang konsisten dengan HomePage
  final Color sageColor = const Color(0xFFB2C8BA);
  final Color surfaceColor = const Color(0xFF242822);
  final Color bgColor = const Color(0xFF1A1C19);

  // FUNGSI: Hapus Riwayat Baca (Resume Data) di Firestore
  Future<void> _clearHistory() async {
    if (user == null) return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
        'last_read_surah': FieldValue.delete(),
        'last_pr13_title': FieldValue.delete(),
        'last_pr13_count': FieldValue.delete(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Riwayat berhasil dibersihkan"), 
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint("Gagal hapus riwayat: $e");
    }
  }

  // FUNGSI: Bagikan Aplikasi
  void _shareApp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Membuka menu berbagi..."), behavior: SnackBarBehavior.floating),
    );
  }

  // FUNGSI: Buka Instagram[cite: 2]
  void _launchInstagram() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Menuju Instagram @Kita46.2..."), behavior: SnackBarBehavior.floating),
    );
  }

  // FUNGSI: Dialog Tentang Aplikasi[cite: 2]
  void _showAboutApp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: sageColor.withOpacity(0.1), 
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.info_outline, color: sageColor, size: 40),
            ),
            const SizedBox(height: 20),
            const Text("Kita 46.2", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text("Versi 1.0.2", style: TextStyle(color: Colors.white38, fontSize: 12)),
            const SizedBox(height: 20),
            const Text(
              "Kita 46.2 adalah platform all-in-one buat ibadah yang ngeganti buku fisik jadi digital, jadi lebih praktis dan gampang diakses kapan aja.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(
                  backgroundColor: sageColor, 
                  foregroundColor: bgColor,
                ),
                child: const Text("Tutup"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // FUNGSI: Dialog Konfirmasi (Hapus/Logout)[cite: 2]
  void _showConfirmDialog(String title, String content, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text(title),
        content: Text(content, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("Batal", style: TextStyle(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () { 
              Navigator.pop(context); 
              onConfirm(); 
            }, 
            child: const Text("Ya, Lanjut", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text("Pengaturan", style: TextStyle(fontSize: 18)),
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          // KATEGORI: AKUN[cite: 2]
          _buildSectionTitle("Akun"),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(24)),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: sageColor.withOpacity(0.2),
                  backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                  child: user?.photoURL == null ? Icon(Icons.person, color: sageColor) : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.displayName ?? "Hamba Allah", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(user?.email ?? "Tamu", style: const TextStyle(color: Colors.white38, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // KATEGORI: IBADAH & DATA[cite: 2]
          _buildSectionTitle("Ibadah & Data"),
          _buildSettingTile(
            icon: Icons.history_rounded,
            title: "Bersihkan Riwayat Baca",
            subtitle: "Menghapus data resume di halaman depan",
            onTap: () => _showConfirmDialog(
              "Hapus Riwayat", 
              "Semua progres terakhir kamu di Quran & PR 13 akan dihapus.", 
              _clearHistory,
            ),
          ),
          _buildSettingTile(
            icon: Icons.text_fields_rounded,
            title: "Ukuran Font Arab",
            subtitle: "Sesuaikan kenyamanan membaca ayat",
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Fitur Font segera hadir!")));
            },
          ),

          const SizedBox(height: 32),

          // KATEGORI: DUKUNGAN & SOSMED[cite: 2]
          _buildSectionTitle("Dukungan & Sosial Media"),
          _buildSettingTile(
            icon: Icons.share_rounded,
            title: "Bagikan Aplikasi",
            subtitle: "Ajak orang lain untuk beribadah bersama",
            onTap: _shareApp,
          ),
          _buildSettingTile(
            icon: Icons.camera_alt_outlined,
            title: "Instagram Kami",
            subtitle: "Follow untuk info dan update terbaru",
            onTap: _launchInstagram,
          ),
          _buildSettingTile(
            icon: Icons.info_outline_rounded,
            title: "Tentang Aplikasi",
            subtitle: "Kenali lebih dekat Kita 46.2",
            onTap: _showAboutApp,
          ),

          const SizedBox(height: 32),

          // KATEGORI: LAINNYA[cite: 2]
          _buildSectionTitle("Lainnya"),
          _buildSettingTile(
            icon: Icons.logout_rounded,
            title: "Keluar Akun",
            subtitle: "Logout dari perangkat ini",
            color: Colors.redAccent,
            onTap: () => _showConfirmDialog("Logout", "Kamu yakin mau keluar?", () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) Navigator.pushReplacementNamed(context, '/login');
            }),
          ),
          
          const SizedBox(height: 40),
          const Center(child: Text("Kita 46.2 • Versi 1.0.2", style: TextStyle(color: Colors.white12, fontSize: 12))),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // WIDGET HELPER: Judul Kategori[cite: 2]
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title.toUpperCase(), 
        style: TextStyle(color: sageColor, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.2),
      ),
    );
  }

  // WIDGET HELPER: Baris Pengaturan[cite: 2]
  Widget _buildSettingTile({
    required IconData icon, 
    required String title, 
    required String subtitle, 
    required VoidCallback onTap, 
    Color? color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: color ?? Colors.white70),
        title: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: color)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.white38)),
        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white12),
      ),
    );
  }
}