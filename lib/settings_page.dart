import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'app_settings.dart';
import 'login_page.dart';
import 'main.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final user = FirebaseAuth.instance.currentUser;
  final AppSettings _settings = AppSettings();

  final Color sageColor = const Color(0xFFB2C8BA);
  final Color surfaceColor = const Color(0xFF242822);
  final Color bgColor = const Color(0xFF1A1C19);

  @override
  void initState() {
    super.initState();
    _settings.addListener(_onSettingsChange);
  }

  @override
  void dispose() {
    _settings.removeListener(_onSettingsChange);
    super.dispose();
  }

  void _onSettingsChange() => setState(() {});

  Future<void> _clearHistory() async {
    if (user == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({
        'last_read_surah': FieldValue.delete(),
        'last_pr13_title': FieldValue.delete(),
        'last_pr13_count': FieldValue.delete(),
      });
      if (mounted) {
        showTopNotification(context, "Riwayat berhasil dibersihkan");
      }
    } catch (e) {
      debugPrint("Gagal hapus riwayat: $e");
    }
  }

  void _showConfirmDialog(String title, String content, VoidCallback onConfirm,
      {Color confirmColor = Colors.redAccent}) {
    const surface = Color(0xFF242822);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surface,
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
            child: Text("Ya, Lanjut", style: TextStyle(color: confirmColor)),
          ),
        ],
      ),
    );
  }

  void _showAboutApp() {
    const surface = Color(0xFF242822);
    const bg = Color(0xFF1A1C19);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: sageColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.info_outline, color: sageColor, size: 40),
            ),
            const SizedBox(height: 20),
            const Text("Kita 46.2",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text("Versi 1.1.5",
                style: TextStyle(color: Colors.white38, fontSize: 12)),
            const SizedBox(height: 20),
            const Text(
              "Kita 46.2 adalah platform all-in-one ibadah yang menggantikan buku fisik jadi digital — lebih praktis dan mudah diakses kapan saja.",
              textAlign: TextAlign.center,
              style:
                  TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(
                    backgroundColor: sageColor, foregroundColor: bg),
                child: const Text("Tutup"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        buildSlideRoute(const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF1A1C19);
    const surface = Color(0xFF242822);
    const textColor = Colors.white;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text("Pengaturan",
            style: TextStyle(fontSize: 18, color: textColor)),
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          // ── Profil Akun ────────────────────────────────────────────
          _sectionTitle("Akun", textColor),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: surface, borderRadius: BorderRadius.circular(24)),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: sageColor.withOpacity(0.2),
                  backgroundImage: user?.photoURL != null
                      ? NetworkImage(user!.photoURL!)
                      : null,
                  child: user?.photoURL == null
                      ? Icon(Icons.person, color: sageColor)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.displayName ?? "Hamba Allah",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: textColor),
                      ),
                      Text(
                        user?.isAnonymous == true
                            ? "Mode Tamu"
                            : (user?.email ?? "-"),
                        style: TextStyle(
                            color: textColor.withOpacity(0.4), fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (user?.isAnonymous == true)
                  TextButton(
                    onPressed: () => Navigator.push(
                        context, buildSlideRoute(const LoginPage())),
                    child: Text("Login",
                        style: TextStyle(color: sageColor, fontSize: 13)),
                  ),
              ],
            ),
          ).animate().fadeIn(duration: 350.ms),

          const SizedBox(height: 28),

          // ── Tampilan ────────────────────────────────────────────────
          _sectionTitle("Tampilan", textColor),
          _buildCard(
            surface: surface,
            child: Column(
              children: [
                // Font Size Arab
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: sageColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.text_fields_rounded,
                              color: sageColor, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Ukuran Font Arab",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: textColor)),
                              Text(
                                  "Ukuran: ${_settings.arabicFontSize.toInt()}px",
                                  style: TextStyle(
                                      color: textColor.withOpacity(0.4),
                                      fontSize: 12)),
                            ],
                          ),
                        ),
                      ]),
                      Slider(
                        value: _settings.arabicFontSize,
                        min: 20,
                        max: 40,
                        divisions: 4,
                        activeColor: sageColor,
                        inactiveColor: sageColor.withOpacity(0.2),
                        onChanged: (val) async {
                          if (_settings.hapticEnabled) {
                            HapticFeedback.selectionClick();
                          }
                          await _settings.setArabicFontSize(val);
                        },
                      ),
                      // Preview
                      Center(
                        child: Text(
                          "بِسْمِ اللَّهِ",
                          style: TextStyle(
                            fontFamily: 'LPMQ',
                            fontSize: _settings.arabicFontSize,
                            color: sageColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 50.ms, duration: 350.ms),

          const SizedBox(height: 24),

          // ── Bacaan ─────────────────────────────────────────────────
          _sectionTitle("Bacaan", textColor),
          _buildCard(
            surface: surface,
            child: _buildSwitchTile(
              icon: Icons.translate_rounded,
              iconColor: const Color(0xFFD2E0FB),
              title: "Tampilkan Terjemahan",
              subtitle: "Terjemahan ayat Al-Qur'an",
              value: _settings.showTranslation,
              textColor: textColor,
              onChanged: (val) => _settings.setShowTranslation(val),
            ),
          ).animate().fadeIn(delay: 100.ms, duration: 350.ms),

          const SizedBox(height: 24),

          // ── Interaksi ──────────────────────────────────────────────
          _sectionTitle("Interaksi", textColor),
          _buildCard(
            surface: surface,
            child: _buildSwitchTile(
              icon: Icons.vibration_rounded,
              iconColor: const Color(0xFFCDE8E5),
              title: "Haptic Feedback",
              subtitle: "Getaran saat menekan tombol",
              value: _settings.hapticEnabled,
              textColor: textColor,
              onChanged: (val) => _settings.setHaptic(val),
            ),
          ).animate().fadeIn(delay: 150.ms, duration: 350.ms),

          const SizedBox(height: 24),

          // ── Data & Riwayat ────────────────────────────────────────
          _sectionTitle("Data & Riwayat", textColor),
          _buildCard(
            surface: surface,
            child: Column(
              children: [
                _buildTappableTile(
                  icon: Icons.history_rounded,
                  iconColor: const Color(0xFFFFE5E5),
                  title: "Bersihkan Riwayat Baca",
                  subtitle: "Hapus data resume Quran & PR 13",
                  textColor: textColor,
                  onTap: () => _showConfirmDialog(
                    "Hapus Riwayat",
                    "Semua progres terakhir di Quran & PR 13 akan dihapus.",
                    _clearHistory,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 350.ms),

          const SizedBox(height: 24),

          // ── Tentang ────────────────────────────────────────────────
          _sectionTitle("Tentang", textColor),
          _buildCard(
            surface: surface,
            child: Column(
              children: [
                _buildTappableTile(
                  icon: Icons.info_outline_rounded,
                  iconColor: sageColor,
                  title: "Tentang Aplikasi",
                  subtitle: "Versi 1.1.0",
                  textColor: textColor,
                  onTap: _showAboutApp,
                ),
                _divider(textColor),
                _buildTappableTile(
                  icon: Icons.star_border_rounded,
                  iconColor: const Color(0xFFEADFB4),
                  title: "Beri Rating",
                  subtitle: "Bantu kami berkembang",
                  textColor: textColor,
                  onTap: () =>
                      showTopNotification(context, "Fitur segera hadir!"),
                ),
                _divider(textColor),
                _buildTappableTile(
                  icon: Icons.share_rounded,
                  iconColor: const Color(0xFFD2E0FB),
                  title: "Bagikan Aplikasi",
                  subtitle: "Ajak temanmu belajar",
                  textColor: textColor,
                  onTap: () =>
                      showTopNotification(context, "Membuka menu berbagi..."),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 250.ms, duration: 350.ms),

          const SizedBox(height: 24),

          // ── Donasi ────────────────────────────────────────────────
          _sectionTitle("Donasi", textColor),
          _buildCard(
            surface: surface,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: sageColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.volunteer_activism_rounded,
                        color: sageColor),
                  ),
                  Text(
                    "Dukung Operasional Kita",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Biar karya ini jalan terus tanpa iklan, yuk dukung operasional & kopi dev via Saweria! Terima kasih, Alhamdulillahijazakumullahukhoiro",
                    style: TextStyle(
                      color: textColor.withOpacity(0.7),
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      if (_settings.hapticEnabled) HapticFeedback.lightImpact();
                      final url = Uri.parse('https://saweria.co/Kita462');
                      if (!await launchUrl(url)) {
                        debugPrint('Could not launch \$url');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: sageColor,
                      foregroundColor: bg,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Donasi via Saweria",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 280.ms, duration: 350.ms),

          const SizedBox(height: 24),

          // ── Aksi Akun ─────────────────────────────────────────────
          if (user != null && !user!.isAnonymous) ...[
            _buildCard(
              surface: surface,
              child: _buildTappableTile(
                icon: Icons.logout_rounded,
                iconColor: Colors.redAccent,
                title: "Keluar",
                subtitle: "Logout dari akun Google",
                textColor: Colors.redAccent,
                onTap: () => _showConfirmDialog(
                  "Keluar?",
                  "Kamu akan logout dari akun ini.",
                  _logout,
                  confirmColor: Colors.redAccent,
                ),
              ),
            ).animate().fadeIn(delay: 300.ms, duration: 350.ms),
            const SizedBox(height: 24),
          ],

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────

  Widget _sectionTitle(String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: textColor.withOpacity(0.4),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildCard({required Color surface, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
          color: surface, borderRadius: BorderRadius.circular(24)),
      child: child,
    );
  }

  Widget _divider(Color textColor) => Divider(
        color: textColor.withOpacity(0.07),
        height: 1,
        indent: 68,
        endIndent: 16,
      );

  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required Color textColor,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.w500, color: textColor)),
                Text(subtitle,
                    style: TextStyle(
                        color: textColor.withOpacity(0.4), fontSize: 12)),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: sageColor,
          ),
        ],
      ),
    );
  }

  Widget _buildTappableTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        if (_settings.hapticEnabled) HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontWeight: FontWeight.w500, color: textColor)),
                  Text(subtitle,
                      style: TextStyle(
                          color: textColor.withOpacity(0.4), fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: textColor.withOpacity(0.2)),
          ],
        ),
      ),
    );
  }
}
