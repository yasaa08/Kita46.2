import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'firebase_options.dart';
import 'database_service.dart';
import 'login_page.dart';
import 'widget_service.dart';
import 'settings_page.dart';
import 'splash_screen.dart';
import 'app_settings.dart';

// Import Halaman Menu
import 'daftar_surah_page.dart';
import 'asmaul_husna_page.dart';
import 'pr13_page.dart';
import 'sholat_sunnah_page.dart';
import 'kumpulan_doa_page.dart';

// Import Halaman Detail
import 'detail_surah_page.dart';
import 'detail_sholat_page.dart';
import 'detail_doa_page.dart';
import 'pr13_detail_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await AppSettings().loadSettings();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppSettings _settings = AppSettings();

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

  static const _sageColor = Color(0xFFB2C8BA);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kita 46.2',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _sageColor,
          brightness: Brightness.dark,
          surface: const Color(0xFF1A1C19),
          onSurface: const Color(0xFFE2E3DD),
        ),
        scaffoldBackgroundColor: const Color(0xFF1A1C19),
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginPage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

// ─── Page Route Helper ───────────────────────────────────────────────────────
PageRoute buildSlideRoute(Widget page, {Offset begin = const Offset(1.0, 0.0)}) {
  return PageRouteBuilder(
    pageBuilder: (_, __, ___) => page,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (_, animation, __, child) {
      return SlideTransition(
        position: Tween<Offset>(begin: begin, end: Offset.zero)
            .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
        child: child,
      );
    },
  );
}

Timer? _notifTimer;
OverlayEntry? _activeNotif;

void showTopNotification(BuildContext context, String message, {Color? bgColor}) {
  _notifTimer?.cancel();
  
  if (_activeNotif != null && _activeNotif!.mounted) {
    _activeNotif!.remove();
  }
  
  _activeNotif = OverlayEntry(
    builder: (_) => _TopNotifWidget(message: message, bgColor: bgColor),
  );
  Overlay.of(context).insert(_activeNotif!);
  
  _notifTimer = Timer(const Duration(seconds: 2), () {
    if (_activeNotif != null && _activeNotif!.mounted) {
      _activeNotif!.remove();
      _activeNotif = null;
    }
  });
}

class _TopNotifWidget extends StatefulWidget {
  final String message;
  final Color? bgColor;
  const _TopNotifWidget({required this.message, this.bgColor});
  @override
  State<_TopNotifWidget> createState() => _TopNotifWidgetState();
}

class _TopNotifWidgetState extends State<_TopNotifWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 60,
      left: 40,
      right: 40,
      child: ScaleTransition(
        scale: _anim,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: widget.bgColor ?? const Color(0xFFB2C8BA),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_rounded,
                    color: const Color(0xFF1A1C19), size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.message,
                    style: const TextStyle(
                      color: Color(0xFF1A1C19),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── HomePage ─────────────────────────────────────────────────────────────────
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final List<Map<String, dynamic>> _searchData = [];
  late AnimationController _settingsController;
  final AppSettings _settings = AppSettings();

  @override
  void initState() {
    super.initState();
    _loadAllSearchData();
    WidgetService.refreshFromFirestore();
    _settings.addListener(_onSettingsChange);
    _settingsController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _settingsController.dispose();
    _settings.removeListener(_onSettingsChange);
    super.dispose();
  }

  void _onSettingsChange() => setState(() {});

  Widget _getGreeting(Color color) {
    var hour = DateTime.now().hour;
    String text;
    IconData icon;
    
    if (hour >= 5 && hour < 11) {
      text = 'Selamat Pagi';
      icon = Icons.wb_twilight_rounded;
    } else if (hour >= 11 && hour < 15) {
      text = 'Selamat Siang';
      icon = Icons.wb_sunny_rounded;
    } else if (hour >= 15 && hour < 18) {
      text = 'Selamat Sore';
      icon = Icons.wb_cloudy_rounded;
    } else {
      text = 'Selamat Malam';
      icon = Icons.nights_stay_rounded;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(text, style: TextStyle(color: color, fontSize: 15)),
        const SizedBox(width: 6),
        Icon(icon, color: color, size: 16),
      ],
    );
  }

  String _getSubGreeting() {
    var hour = DateTime.now().hour;
    if (hour >= 5 && hour < 11) return 'Jangan Lupa Sholat Dhuha ya!';
    if (hour >= 11 && hour < 15) return 'Waktunya istirahat, yuk baca doa!';
    if (hour >= 15 && hour < 18) return 'Jangan lupa Doa Pagi Sore ya!';
    return 'Jangan lupa baca Ayat Kursi sebelum tidur!';
  }

  Future<void> _loadAllSearchData() async {
    _searchData.clear();
    _searchData.addAll([
      {
        'title': "Baca Qur'an",
        'type': 'Menu',
        'icon': Icons.book,
        'page': const DaftarSurahPage()
      },
      {
        'title': "PR 13",
        'type': 'Menu',
        'icon': Icons.fingerprint,
        'page': const Pr13Page()
      },
      {
        'title': "Asmaul Husna",
        'type': 'Menu',
        'icon': Icons.bookmark_rounded,
        'page': const AsmaulHusnaPage()
      },
      {
        'title': "Sholat Sunnah",
        'type': 'Menu',
        'icon': Icons.mosque,
        'page': const SholatSunnahPage()
      },
      {
        'title': "Kumpulan Doa",
        'type': 'Menu',
        'icon': Icons.clean_hands,
        'page': const KumpulanDoaPage()
      },
    ]);

    Future.microtask(() async {
      try {
        final res = await rootBundle.loadString('assets/list_surah.json');
        final List list = json.decode(res);
        for (var s in list) {
          _searchData.add({
            'title': s['name_latin'] ?? s['name'] ?? 'Surah',
            'searchKey': "surah ${s['number']} ${s['name_latin']}",
            'type': 'Surah',
            'icon': Icons.auto_stories,
            'data': s
          });
        }
      } catch (_) {}

      try {
        final res = await rootBundle
            .loadString('assets/Sholat sunnah/Sholatsunnah.json');
        final List list = json.decode(res);
        for (var sh in list) {
          _searchData.add({
            'title': sh['title'] ?? 'Sholat',
            'type': 'Sholat',
            'icon': Icons.wb_sunny_outlined,
            'data': sh
          });
        }
      } catch (_) {}

      try {
        final res = await rootBundle.loadString('assets/PR 13/pr13.json');
        final List list = json.decode(res);
        for (var pr in list) {
          _searchData.add({
            'title': pr['title'] ?? 'PR 13',
            'type': 'PR 13',
            'icon': Icons.fingerprint,
            'data': pr
          });
        }
      } catch (_) {}

      try {
        final res = await rootBundle
            .loadString('assets/kumpulan doa/kumpulan_doa.json');
        final List list = json.decode(res);
        for (var d in list) {
          _searchData.add({
            'title': d['title'] ?? 'Doa',
            'type': 'Doa',
            'icon': Icons.clean_hands_outlined,
            'data': d
          });
        }
      } catch (_) {}

      if (mounted) setState(() {});
    });
  }

  Future<void> _submitFeedback(String message) async {
    if (message.trim().isEmpty) {
      showTopNotification(context, 'Tulis pesan dulu ya!', bgColor: Colors.orangeAccent);
      return;
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) {
      showTopNotification(context, 'Kamu perlu login untuk mengirim saran', bgColor: Colors.orangeAccent);
      return;
    }
    try {
      await FirebaseFirestore.instance.collection('feedbacks').add({
        'uid': user.uid,
        'email': user.email,
        'name': user.displayName ?? 'Pengguna',
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        Navigator.pop(context);
        showTopNotification(context, "Jazzakumullahu Khoiro!");
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        showTopNotification(context, 'Gagal kirim: $e', bgColor: Colors.redAccent);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sageColor = const Color(0xFFB2C8BA);
    final bgColor = const Color(0xFF1A1C19);
    final surfaceColor = const Color(0xFF242822);
    final textColor = Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: GestureDetector(
          onTap: () {
            if (_settings.hapticEnabled) HapticFeedback.lightImpact();
            showSearch(
              context: context,
              delegate: _AppSearchDelegate(
                searchData: _searchData,
                sageColor: sageColor,
                bgColor: surfaceColor,
                context: context,
              ),
            );
          },
          child: Container(
            height: 42,
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(21),
              border: Border.all(color: sageColor.withOpacity(0.15), width: 1),
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(Icons.search_rounded, color: sageColor.withOpacity(0.8), size: 18),
                ),
                Text('Cari surah, doa...',
                    style: TextStyle(color: textColor.withOpacity(0.4), fontSize: 13)),
              ],
            ),
          ),
        ),
        actions: [
          // Settings Icon
          IconButton(
            icon: RotationTransition(
                turns: _settingsController,
                child: const Icon(Icons.settings_outlined)),
            onPressed: () async {
              if (_settings.hapticEnabled) HapticFeedback.lightImpact();
              _settingsController.forward(from: 0.0);
              await Future.delayed(const Duration(milliseconds: 250));
              if (mounted) {
                Navigator.push(
                    context, buildSlideRoute(const SettingsPage()));
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Greeting
                  _getGreeting(textColor.withOpacity(0.5))
                      .animate()
                      .fadeIn(duration: 400.ms),

                  const SizedBox(height: 6),

                  Text(
                    _getSubGreeting(),
                    style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

                  const SizedBox(height: 24),

                  // Riwayat Widget
                  StreamBuilder<DocumentSnapshot>(
                    stream: DatabaseService().userHistory,
                    builder: (context, snapshot) {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user == null) {
                        return _buildGuestHistory(sageColor, surfaceColor, textColor);
                      }
                      if (!snapshot.hasData || !snapshot.data!.exists) {
                        return _buildPlaceholderHistory(surfaceColor, textColor);
                      }

                      var data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
                      var surahDataRaw = data['last_read_surah'];
                      int lastSurahNum = surahDataRaw is Map ? (surahDataRaw['number'] ?? 0) : 0;
                      String surahName = surahDataRaw is Map ? (surahDataRaw['name'] ?? "-") : "-";
                      int lastAyah = surahDataRaw is Map ? (surahDataRaw['ayah'] ?? 0) : 0;
                      String lastPrTitle = data['last_pr13_title'] ?? '-';
                      int lastCount = (data['last_pr13_count'] ?? 0).toInt();

                      return Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            color: const Color(0xFFDDE5D9),
                            borderRadius: BorderRadius.circular(28)),
                        child: IntrinsicHeight(
                          child: Row(
                            children: [
                              Expanded(
                                child: _historySubCard(
                                    "QURAN",
                                    lastAyah > 0 ? "$surahName: $lastAyah" : surahName,
                                    "Lanjut Baca",
                                    Icons.auto_stories,
                                    surfaceColor,
                                    const Color(0xFF1A1C19), () {
                                  if (lastSurahNum > 0) {
                                    Navigator.push(
                                        context,
                                        buildSlideRoute(DetailSurahPage(
                                            surahNumber: lastSurahNum,
                                            surahName: surahName,
                                            revelation: '')));
                                  }
                                }),
                              ),
                              Container(
                                  width: 1,
                                  color: Colors.black12,
                                  margin: const EdgeInsets.symmetric(horizontal: 16)),
                              Expanded(
                                child: _historySubCard(
                                    "PR 13",
                                    lastPrTitle,
                                    "Count: ${lastCount}x",
                                    Icons.fingerprint,
                                    surfaceColor,
                                    const Color(0xFF1A1C19), () {
                                  if (lastPrTitle != '-') {
                                    final prMatch = _searchData.firstWhere(
                                        (item) =>
                                            item['type'] == 'PR 13' &&
                                            item['title'] == lastPrTitle,
                                        orElse: () => {});
                                    if (prMatch.isNotEmpty) {
                                      Navigator.push(
                                          context,
                                          buildSlideRoute(Pr13DetailPage(
                                              doaData: prMatch['data'],
                                              initialCount: lastCount)));
                                    }
                                  }
                                }),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: 200.ms, duration: 500.ms).slideY(begin: 0.1);
                    },
                  ),

                  const SizedBox(height: 24),

                  // Menu Grid
                  Text(
                    "Menu",
                    style: TextStyle(
                      color: textColor.withOpacity(0.5),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 2.2,
                    children: [
                      _buildMenuTile(context, "Qur'an", Icons.book,
                          const Color(0xFFB2C8BA), const DaftarSurahPage(), surfaceColor, 0),
                      _buildMenuTile(context, "PR 13", Icons.fingerprint,
                          const Color(0xFFCDE8E5), const Pr13Page(), surfaceColor, 1),
                      _buildMenuTile(context, "Asmaul Husna", Icons.bookmark_rounded,
                          const Color(0xFFEADFB4), const AsmaulHusnaPage(), surfaceColor, 2),
                      _buildMenuTile(context, "Sholat Sunnah", Icons.mosque,
                          const Color(0xFFFFE5E5), const SholatSunnahPage(), surfaceColor, 3),
                      _buildMenuTile(context, "Kumpulan Doa", Icons.clean_hands,
                          const Color(0xFFD2E0FB), const KumpulanDoaPage(), surfaceColor, 4),
                    ],
                  ),

                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
      // FAB Saran — Bisa diakses tamu juga
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_settings.hapticEnabled) HapticFeedback.lightImpact();
          final user = FirebaseAuth.instance.currentUser;
          if (user != null && !user.isAnonymous) {
            _showFeedbackDialog(
                context, sageColor, surfaceColor, user.email ?? '');
          } else {
            _showGuestFeedbackDialog(context, sageColor, surfaceColor);
          }
        },
        backgroundColor: surfaceColor,
        icon: Icon(Icons.chat_bubble_outline_rounded, color: sageColor, size: 20),
        label: Text("Saran", style: TextStyle(color: sageColor, fontSize: 13)),
      ),
    );
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────

  Widget _buildPlaceholderHistory(Color surface, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: surface, borderRadius: BorderRadius.circular(28)),
      child: Row(children: [
        Icon(Icons.auto_stories_outlined,
            color: textColor.withOpacity(0.2)),
        const SizedBox(width: 12),
        Text("Belum ada riwayat",
            style: TextStyle(color: textColor.withOpacity(0.3)))
      ]),
    );
  }

  Widget _historySubCard(String label, String title, String sub,
      IconData icon, Color cardColor, Color textColor, VoidCallback onTap) {
    return InkWell(
      onTap: () {
        if (_settings.hapticEnabled) HapticFeedback.lightImpact();
        onTap();
      },
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, color: textColor.withOpacity(0.5), size: 14),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: textColor.withOpacity(0.6))),
        ]),
        const SizedBox(height: 8),
        Text(title,
            style: TextStyle(
                color: textColor.withOpacity(0.85),
                fontSize: 15,
                fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        Text(sub,
            style: TextStyle(color: textColor.withOpacity(0.45), fontSize: 10)),
      ]),
    );
  }

  Widget _buildMenuTile(BuildContext context, String title, IconData icon,
      Color color, Widget page, Color surfaceColor, int index) {
    return GestureDetector(
      onTap: () {
        if (_settings.hapticEnabled) HapticFeedback.lightImpact();
        Navigator.push(context, buildSlideRoute(page));
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(24)),
        child: Row(children: [
          Hero(
              tag: 'icon_$title',
              child: CircleAvatar(
                  backgroundColor: color.withOpacity(0.2),
                  radius: 18,
                  child: Icon(icon, color: color, size: 18))),
          const SizedBox(width: 12),
          Expanded(
              child: Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis)),
        ]),
      ),
    )
        .animate(delay: Duration(milliseconds: 300 + index * 80))
        .fadeIn(duration: 400.ms)
        .slideX(begin: 0.1, duration: 400.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildGuestHistory(Color sage, Color surface, Color textColor) {
    return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
            color: surface, borderRadius: BorderRadius.circular(28)),
        child: Row(children: [
          Icon(Icons.account_circle_outlined, color: sage),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Mode Tamu",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: textColor)),
              Text("Login untuk simpan riwayat",
                  style: TextStyle(
                      color: textColor.withOpacity(0.4), fontSize: 12)),
            ],
          ),
          const Spacer(),
          TextButton(
            onPressed: () =>
                Navigator.push(context, buildSlideRoute(const LoginPage())),
            child: Text("Login", style: TextStyle(color: sage, fontSize: 13)),
          ),
        ]));
  }

  // Dialog Saran untuk user yang sudah login
  void _showFeedbackDialog(
      BuildContext context, Color sage, Color surface, String email) {
    final controller = TextEditingController();
    const textColor = Colors.white;
    showModalBottomSheet(
      context: context,
      backgroundColor: surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            top: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
                child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: textColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 24),
            const Text("Kirim Saran & Masukan",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text("Email: $email",
                style: TextStyle(color: sage, fontSize: 12)),
            const SizedBox(height: 16),
            TextField(
                controller: controller,
                maxLines: 4,
                decoration: InputDecoration(
                    hintText: "Tulis saranmu...",
                    filled: true,
                    fillColor: const Color(0xFF1A1C19),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none))),
            const SizedBox(height: 24),
            SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                    onPressed: () => _submitFeedback(controller.text),
                    icon: const Icon(Icons.send_rounded),
                    label: const Text("Kirim Sekarang"))),
          ],
        ),
      ),
    );
  }

  // Dialog Saran untuk tamu — notif harap login saat kirim
  void _showGuestFeedbackDialog(
      BuildContext context, Color sage, Color surface) {
    final controller = TextEditingController();
    const textColor = Colors.white;
    showModalBottomSheet(
      context: context,
      backgroundColor: surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            top: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
                child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: textColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 24),
            const Text("Kirim Saran & Masukan",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orangeAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      color: Colors.orangeAccent, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Kamu perlu login untuk mengirim saran",
                      style: TextStyle(
                          color: Colors.orangeAccent.withOpacity(0.9),
                          fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
                controller: controller,
                maxLines: 4,
                decoration: InputDecoration(
                    hintText: "Tulis saranmu dulu...",
                    filled: true,
                    fillColor: const Color(0xFF1A1C19),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none))),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(context,
                      buildSlideRoute(const LoginPage()));
                },
                icon: const Icon(Icons.login_rounded),
                label: const Text("Login untuk Kirim Saran"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Custom Search Delegate ───────────────────────────────────────────────────
class _AppSearchDelegate extends SearchDelegate<String> {
  final List<Map<String, dynamic>> searchData;
  final Color sageColor;
  final Color bgColor;
  final BuildContext context;

  _AppSearchDelegate({
    required this.searchData,
    required this.sageColor,
    required this.bgColor,
    required this.context,
  });

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      scaffoldBackgroundColor: const Color(0xFF1A1C19),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1A1C19),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white70),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.white38),
        border: InputBorder.none,
      ),
    );
  }

  @override
  String get searchFieldLabel => 'Cari surah, doa, sholat...';

  @override
  List<Widget> buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.clear_rounded),
            onPressed: () => query = '',
          ),
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => close(context, ''),
      );

  @override
  Widget buildResults(BuildContext context) => _buildList(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildList(context);

  Widget _buildList(BuildContext context) {
    const surfaceColor = Color(0xFF242822);
    const textColor = Colors.white;

    if (query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_rounded,
                size: 64, color: textColor.withOpacity(0.2)),
            const SizedBox(height: 16),
            Text("Ketik untuk mencari...",
                style: TextStyle(color: textColor.withOpacity(0.4))),
          ],
        ),
      );
    }

    final results = searchData
        .where((item) =>
            item['title'].toString().toLowerCase().contains(query.toLowerCase()))
        .toList();

    if (results.isEmpty) {
      return Center(
        child: Text("Tidak ditemukan untuk \"$query\"",
            style: TextStyle(color: textColor.withOpacity(0.4))),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: results.length,
      itemBuilder: (ctx, i) {
        final item = results[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            leading: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: sageColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item['icon'], color: sageColor, size: 20),
            ),
            title: Text(item['title'],
                style: TextStyle(
                    color: textColor, fontWeight: FontWeight.w500)),
            subtitle: Text(item['type'],
                style: TextStyle(
                    color: textColor.withOpacity(0.4), fontSize: 12)),
            trailing: Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: textColor.withOpacity(0.2)),
            onTap: () {
              HapticFeedback.lightImpact();
              close(context, item['title']);
              _navigate(context, item);
            },
          ),
        )
            .animate(delay: Duration(milliseconds: i * 40))
            .fadeIn(duration: 250.ms)
            .slideX(begin: 0.05);
      },
    );
  }

  void _navigate(BuildContext context, Map<String, dynamic> item) {
    if (item['type'] == 'Menu') {
      Navigator.push(context, buildSlideRoute(item['page']));
    } else if (item['type'] == 'Surah') {
      Navigator.push(
          context,
          buildSlideRoute(DetailSurahPage(
              surahNumber:
                  int.parse(item['data']['number'].toString()),
              surahName: item['data']['name_latin'] ?? item['data']['name'],
              revelation: item['data']['revelation'] ?? '')));
    } else if (item['type'] == 'Sholat') {
      Navigator.push(context,
          buildSlideRoute(DetailSholatPage(sholatData: item['data'])));
    } else if (item['type'] == 'PR 13') {
      Navigator.push(context,
          buildSlideRoute(Pr13DetailPage(doaData: item['data'])));
    } else if (item['type'] == 'Doa') {
      Navigator.push(context,
          buildSlideRoute(DetailDoaPage(doaData: item['data'])));
    }
  }
}
