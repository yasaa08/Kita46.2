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
  User? get user => FirebaseAuth.instance.currentUser;
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
              "Kita 46.2 adalah platform all-in-one ibadah yang menggantikan buku fisik jadi digital lebih praktis dan mudah diakses kapan saja.",
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

  void _showFontSelectorModal(BuildContext context) {
    final textColor = Colors.white;
    showModalBottomSheet(
      context: context,
      backgroundColor: bgColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: sageColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.font_download_rounded,
                            color: sageColor, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Pilih Font Arab",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          Text(
                            "Berlaku untuk Al-Qur'an, Doa, & semua bacaan",
                            style: TextStyle(
                              fontSize: 12,
                              color: textColor.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: AppSettings.arabicFontOptions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final option = AppSettings.arabicFontOptions[index];
                      final isSelected =
                          _settings.arabicFontFamily == option.key;

                      return InkWell(
                        onTap: () async {
                          if (_settings.hapticEnabled) {
                            HapticFeedback.selectionClick();
                          }
                          await _settings.setArabicFontFamily(option.key);
                          if (ctx.mounted) Navigator.pop(ctx);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? sageColor.withOpacity(0.15)
                                : surfaceColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? sageColor.withOpacity(0.6)
                                  : Colors.white.withOpacity(0.06),
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          option.name,
                                          style: TextStyle(
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.w500,
                                            color: isSelected
                                                ? sageColor
                                                : textColor,
                                            fontSize: 14,
                                          ),
                                        ),
                                        if (isSelected) ...[
                                          const SizedBox(width: 8),
                                          Icon(
                                            Icons.check_circle_rounded,
                                            size: 16,
                                            color: sageColor,
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      option.subtitle,
                                      style: TextStyle(
                                        color: textColor.withOpacity(0.4),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                "بِسْمِ اللَّهِ",
                                style: AppSettings.getStyleForFont(
                                  option.key,
                                  baseStyle: TextStyle(
                                    fontSize: 18,
                                    color: isSelected
                                        ? sageColor
                                        : textColor.withOpacity(0.85),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bg = bgColor;
    final surface = surfaceColor;
    const textColor = Colors.white;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text("Pengaturan",
            style: TextStyle(fontWeight: FontWeight.w500)),
        backgroundColor: bg,
        foregroundColor: textColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          // ── Akun ───────────────────────────────────────────────────
          _sectionTitle("Akun", textColor),
          Builder(builder: (context) {
            final currentUser = user;
            final isGuest = currentUser == null || currentUser.isAnonymous;

            return _buildCard(
              surface: surface,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: isGuest
                      ? () {
                          if (_settings.hapticEnabled) {
                            HapticFeedback.lightImpact();
                          }
                          Navigator.push(
                                  context, buildSlideRoute(const LoginPage()))
                              .then((_) => setState(() {}));
                        }
                      : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: sageColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: !isGuest && currentUser.photoURL != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.network(
                                    currentUser.photoURL!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Icon(
                                      Icons.person_rounded,
                                      color: sageColor,
                                      size: 24,
                                    ),
                                  ),
                                )
                              : Icon(
                                  isGuest
                                      ? Icons.account_circle_outlined
                                      : Icons.person_rounded,
                                  color: sageColor,
                                  size: 24,
                                ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isGuest
                                    ? "Hamba Allah"
                                    : (currentUser.displayName ??
                                        "Hamba Allah"),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: textColor),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                isGuest ? "" : (currentUser.email ?? "-"),
                                style: TextStyle(
                                    color: textColor.withOpacity(0.4),
                                    fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        if (isGuest) ...[
                          const SizedBox(width: 12),
                          FilledButton.tonal(
                            onPressed: () {
                              if (_settings.hapticEnabled) {
                                HapticFeedback.lightImpact();
                              }
                              Navigator.push(context,
                                      buildSlideRoute(const LoginPage()))
                                  .then((_) => setState(() {}));
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: sageColor.withOpacity(0.18),
                              foregroundColor: sageColor,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            child: const Text(
                              "Login",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).animate().fadeIn(duration: 350.ms),

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
                          child: Icon(Icons.format_size_rounded,
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
                    ],
                  ),
                ),

                _divider(textColor),

                // Pilihan Jenis Font Arab
                _buildTappableTile(
                  icon: Icons.font_download_rounded,
                  iconColor: const Color(0xFFCDE8E5),
                  title: "Jenis Font Arab",
                  subtitle: AppSettings.arabicFontOptions
                      .firstWhere(
                        (f) => f.key == _settings.arabicFontFamily,
                        orElse: () => AppSettings.arabicFontOptions.first,
                      )
                      .name,
                  textColor: textColor,
                  onTap: () => _showFontSelectorModal(context),
                ),

                _divider(textColor),

                // Preview Box
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: bgColor.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: sageColor.withOpacity(0.15),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيم",
                          textAlign: TextAlign.center,
                          style: _settings.getArabicStyle(
                            fontSize: _settings.arabicFontSize,
                            color: sageColor,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: sageColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "${_settings.arabicFontFamily} • ${_settings.arabicFontSize.toInt()}px",
                            style: TextStyle(
                              color: sageColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 50.ms, duration: 350.ms),

          const SizedBox(height: 24),

          // ── Terjemahan ─────────────────────────────────────────────────
          _sectionTitle("Terjemahan", textColor),
          _buildCard(
            surface: surface,
            child: Column(
              children: [
                _buildSwitchTile(
                  icon: Icons.translate_rounded,
                  iconColor: const Color(0xFFD2E0FB),
                  title: "Tampilkan Terjemahan",
                  subtitle: "Terjemahan ayat Al-Qur'an",
                  value: _settings.showTranslation,
                  textColor: textColor,
                  onChanged: (val) => _settings.setShowTranslation(val),
                ),
                _divider(textColor),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.verified_rounded,
                              color: sageColor, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            "Sumber & Referensi Terjemahan",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: textColor.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Item 1: Al-Qur'an
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: bgColor.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: sageColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.menu_book_rounded,
                                  color: sageColor, size: 17),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Al-Qur'an & Terjemahan",
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "Kementerian Agama RI (Kemenag RI)",
                                    style: TextStyle(
                                      color: textColor.withOpacity(0.45),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Item 2: Doa, Sholat & PR 13
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: bgColor.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color:
                                    const Color(0xFFD2E0FB).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.import_contacts_rounded,
                                  color: Color(0xFFD2E0FB), size: 17),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Kumpulan Doa, Sholat & PR 13",
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "Buku himpunan doa fisik",
                                    style: TextStyle(
                                      color: textColor.withOpacity(0.45),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
                  subtitle: "Versi 1.0.1",
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
                  onTap: () async {
                    if (_settings.hapticEnabled) HapticFeedback.lightImpact();
                    final url = Uri.parse(
                        'https://apkpure.com/reviews/com.kita462.quran');
                    if (!await launchUrl(url)) {
                      debugPrint('Gagal membuka link rating');
                    }
                  },
                ),
                _divider(textColor),
                _buildTappableTile(
                  icon: Icons.share_rounded,
                  iconColor: const Color(0xFFD2E0FB),
                  title: "Bagikan Aplikasi",
                  subtitle: "Ajak temanmu",
                  textColor: textColor,
                  onTap: () async {
                    if (_settings.hapticEnabled) HapticFeedback.lightImpact();
                    final url =
                        Uri.parse('https://apkpure.com/p/com.kita462.quran');
                    if (!await launchUrl(url)) {
                      debugPrint('Gagal membuka link bagikan');
                    }
                  },
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
