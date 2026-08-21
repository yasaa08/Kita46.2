import 'dart:async';
import 'dart:convert';
import 'quick_access_service.dart';
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
import 'streak_service.dart';

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
import 'search_page.dart';

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
  final QuickAccessService _quickAccess = QuickAccessService();
  StreamSubscription<Uri?>? _widgetClickSub;

  @override
  void initState() {
    super.initState();
    _loadAllSearchData();
    WidgetService.refreshFromFirestore();
    _settings.addListener(_onSettingsChange);
    _quickAccess.addListener(_onQuickAccessChange);
    _quickAccess.loadItems();
    StreakService().loadStreak();
    _settingsController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Widget click navigation — cold start
    _checkWidgetLaunch();

    // Widget click navigation — warm start (app already running)
    _widgetClickSub = WidgetService.widgetClicked.listen(_handleWidgetClick);
  }

  @override
  void dispose() {
    _settingsController.dispose();
    _settings.removeListener(_onSettingsChange);
    _quickAccess.removeListener(_onQuickAccessChange);
    _widgetClickSub?.cancel();
    super.dispose();
  }

  void _onSettingsChange() => setState(() {});
  void _onQuickAccessChange() => setState(() {});

  // ─── Widget Click Navigation ──────────────────────────────────────────────

  Future<void> _checkWidgetLaunch() async {
    final uri = await WidgetService.getWidgetClickUri();
    if (uri != null && mounted) {
      // Small delay to ensure the page is fully built before navigating
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _handleWidgetClick(uri);
      });
    }
  }

  void _handleWidgetClick(Uri? uri) {
    if (uri == null || !mounted) return;

    final host = uri.host; // 'quran' or 'pr13'

    if (host == 'quran') {
      _navigateToQuranFromWidget();
    } else if (host == 'pr13') {
      Navigator.push(context, buildSlideRoute(const Pr13Page()));
    }
  }

  Future<void> _navigateToQuranFromWidget() async {
    final surahData = await WidgetService.getLastReadSurah();
    if (!mounted) return;

    if (surahData != null && surahData['number'] != null && surahData['number'] > 0) {
      Navigator.push(
        context,
        buildSlideRoute(DetailSurahPage(
          surahNumber: surahData['number'],
          surahName: surahData['name'] ?? '',
          revelation: '',
        )),
      );
    } else {
      // No reading history — open surah list
      Navigator.push(context, buildSlideRoute(const DaftarSurahPage()));
    }
  }

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
            Navigator.push(
              context,
              buildSlideRoute(SearchPage(searchData: _searchData)),
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
                      if (user == null || user.isAnonymous) {
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

                  const SizedBox(height: 24),

                  // Quick Access Section
                  _buildQuickAccessSection(sageColor, surfaceColor, textColor),

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

  // ─── Quick Access Section ──────────────────────────────────────────────────

  Widget _buildQuickAccessSection(Color sage, Color surface, Color textColor) {
    final user = FirebaseAuth.instance.currentUser;
    final isGuest = user == null || user.isAnonymous;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Quick Access",
              style: TextStyle(
                color: textColor.withOpacity(0.5),
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
              ),
            ),
            if (!isGuest && _quickAccess.items.isNotEmpty)
              GestureDetector(
                onTap: () {
                  if (_settings.hapticEnabled) HapticFeedback.lightImpact();
                  _showEditQuickAccessSheet(sage, surface, textColor);
                },
                child: Text(
                  "Edit",
                  style: TextStyle(
                    color: sage.withOpacity(0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        // Content — guest, empty, or populated
        isGuest
            ? _buildQuickAccessGuestCard(sage, surface, textColor)
            : _quickAccess.isEmpty
                ? _buildQuickAccessEmptyCard(sage, surface, textColor)
                : _buildQuickAccessList(sage, surface, textColor),
      ],
    ).animate(delay: 700.ms).fadeIn(duration: 400.ms).slideY(begin: 0.05);
  }

  Widget _buildQuickAccessGuestCard(Color sage, Color surface, Color textColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: sage.withOpacity(0.12),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: sage.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.lock_outline_rounded,
              color: sage.withOpacity(0.6),
              size: 18,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Login untuk Quick Access",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Simpan akses cepat ke surat favoritmu",
                  style: TextStyle(
                    color: textColor.withOpacity(0.4),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessEmptyCard(Color sage, Color surface, Color textColor) {
    return GestureDetector(
      onTap: () {
        if (_settings.hapticEnabled) HapticFeedback.lightImpact();
        _showAddQuickAccessSheet(sage, surface, textColor);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: sage.withOpacity(0.12),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: sage.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.add_rounded,
                color: sage.withOpacity(0.6),
                size: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Tambah",
              style: TextStyle(
                color: textColor.withOpacity(0.4),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessList(Color sage, Color surface, Color textColor) {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _quickAccess.items.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          // First card is always the "+ Tambah" button
          if (index == 0) {
            return _buildAddQuickAccessCard(sage, surface, textColor);
          }
          final item = _quickAccess.items[index - 1];
          return _buildQuickAccessItemCard(item, sage, surface, textColor)
              .animate(key: ValueKey(item.id))
              .fadeIn(duration: 300.ms)
              .slideX(begin: 0.2, end: 0, duration: 300.ms, curve: Curves.easeOut);
        },
      ),
    );
  }

  Widget _buildAddQuickAccessCard(Color sage, Color surface, Color textColor) {
    return GestureDetector(
      onTap: () {
        if (_settings.hapticEnabled) HapticFeedback.lightImpact();
        _showAddQuickAccessSheet(sage, surface, textColor);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: sage.withOpacity(0.12),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, color: sage.withOpacity(0.6), size: 16),
            const SizedBox(width: 6),
            Text(
              "Tambah",
              style: TextStyle(
                color: textColor.withOpacity(0.4),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessItemCard(
      QuickAccessItem item, Color sage, Color surface, Color textColor) {
    return GestureDetector(
      onTap: () {
        if (_settings.hapticEnabled) HapticFeedback.lightImpact();
        _navigateQuickAccessItem(item);
      },
      onLongPress: () {
        if (_settings.hapticEnabled) HapticFeedback.mediumImpact();
        _showRemoveQuickAccessDialog(item, sage, surface, textColor);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(item.icon, color: item.accentColor.withOpacity(0.7), size: 15),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 100),
              child: Text(
                item.title,
                style: TextStyle(
                  color: textColor.withOpacity(0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateQuickAccessItem(QuickAccessItem item) {
    switch (item.type) {
      case 'surah':
        final number = int.tryParse(item.data['number']?.toString() ?? '0') ?? 0;
        final name = item.data['name'] ?? item.data['name_latin'] ?? item.title;
        final revelation = item.data['revelation'] ?? '';
        Navigator.push(
          context,
          buildSlideRoute(DetailSurahPage(
            surahNumber: number,
            surahName: name,
            revelation: revelation,
          )),
        );
        break;
      case 'doa':
        Navigator.push(
          context,
          buildSlideRoute(DetailDoaPage(doaData: item.data)),
        );
        break;
      case 'sholat':
        Navigator.push(
          context,
          buildSlideRoute(DetailSholatPage(sholatData: item.data)),
        );
        break;
      case 'asmaul_husna':
        Navigator.push(
          context,
          buildSlideRoute(const AsmaulHusnaPage()),
        );
        break;
    }
  }

  void _showRemoveQuickAccessDialog(
      QuickAccessItem item, Color sage, Color surface, Color textColor) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          "Hapus dari Quick Access?",
          style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        content: Text(
          '"${item.title}" akan dihapus dari Quick Access.',
          style: TextStyle(color: textColor.withOpacity(0.5), fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Batal", style: TextStyle(color: textColor.withOpacity(0.4))),
          ),
          TextButton(
            onPressed: () {
              _quickAccess.removeItem(item.id);
              Navigator.pop(ctx);
              showTopNotification(context, "Dihapus dari Quick Access");
            },
            child: Text("Hapus", style: TextStyle(color: sage)),
          ),
        ],
      ),
    );
  }

  void _showEditQuickAccessSheet(Color sage, Color surface, Color textColor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (ctx) => _EditQuickAccessSheet(
        items: _quickAccess.items,
        sage: sage,
        surface: surface,
        textColor: textColor,
        onRemove: (id) {
          _quickAccess.removeItem(id);
        },
      ),
    );
  }

  void _showAddQuickAccessSheet(Color sage, Color surface, Color textColor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (ctx) => _AddQuickAccessSheet(
        searchData: _searchData,
        quickAccess: _quickAccess,
        sage: sage,
        surface: surface,
        textColor: textColor,
        onAdded: () {
          showTopNotification(context, "Ditambahkan ke Quick Access");
        },
      ),
    );
  }

  Widget _buildGuestHistory(Color sage, Color surface, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: sage.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.account_circle_outlined, color: sage, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Mode Tamu",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: textColor)),
                const SizedBox(height: 2),
                Text("Login untuk melihat riwayat",
                    style: TextStyle(
                        color: textColor.withOpacity(0.4), fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          FilledButton.tonal(
            onPressed: () {
              if (_settings.hapticEnabled) HapticFeedback.lightImpact();
              Navigator.push(context, buildSlideRoute(const LoginPage()));
            },
            style: FilledButton.styleFrom(
              backgroundColor: sage.withOpacity(0.15),
              foregroundColor: sage,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("Login",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
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

// ─── Edit Quick Access Sheet ──────────────────────────────────────────────────
class _EditQuickAccessSheet extends StatefulWidget {
  final List<QuickAccessItem> items;
  final Color sage;
  final Color surface;
  final Color textColor;
  final Function(String id) onRemove;

  const _EditQuickAccessSheet({
    required this.items,
    required this.sage,
    required this.surface,
    required this.textColor,
    required this.onRemove,
  });

  @override
  State<_EditQuickAccessSheet> createState() => _EditQuickAccessSheetState();
}

class _EditQuickAccessSheetState extends State<_EditQuickAccessSheet> {
  late List<QuickAccessItem> _localItems;

  @override
  void initState() {
    super.initState();
    _localItems = List.from(widget.items);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: widget.textColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Edit Quick Access",
            style: TextStyle(
              color: widget.textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Tekan ikon hapus untuk menghapus item",
            style: TextStyle(
              color: widget.textColor.withOpacity(0.4),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          if (_localItems.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  "Belum ada item",
                  style: TextStyle(color: widget.textColor.withOpacity(0.3)),
                ),
              ),
            )
          else
            ...List.generate(_localItems.length, (i) {
              final item = _localItems[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1C19),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(item.icon, color: item.accentColor.withOpacity(0.7), size: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.title,
                        style: TextStyle(
                          color: widget.textColor.withOpacity(0.8),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        widget.onRemove(item.id);
                        setState(() {
                          _localItems.removeAt(i);
                        });
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.remove_circle_outline_rounded,
                          color: Colors.redAccent.withOpacity(0.7),
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─── Add Quick Access Sheet ──────────────────────────────────────────────────
class _AddQuickAccessSheet extends StatefulWidget {
  final List<Map<String, dynamic>> searchData;
  final QuickAccessService quickAccess;
  final Color sage;
  final Color surface;
  final Color textColor;
  final VoidCallback onAdded;

  const _AddQuickAccessSheet({
    required this.searchData,
    required this.quickAccess,
    required this.sage,
    required this.surface,
    required this.textColor,
    required this.onAdded,
  });

  @override
  State<_AddQuickAccessSheet> createState() => _AddQuickAccessSheetState();
}

class _AddQuickAccessSheetState extends State<_AddQuickAccessSheet> {
  String _searchQuery = '';
  String _selectedCategory = 'Semua';
  final _searchController = TextEditingController();

  static const _categories = ['Semua', 'Surat', 'Doa', 'Sholat Sunnah', 'Asmaul Husna'];

  /// Map search data type strings to our Quick Access type strings.
  String _toQuickAccessType(String searchType) {
    switch (searchType) {
      case 'Surah':
        return 'surah';
      case 'Doa':
        return 'doa';
      case 'Sholat':
        return 'sholat';
      case 'Asmaul Husna':
        return 'asmaul_husna';
      default:
        return searchType.toLowerCase();
    }
  }

  /// Generate a unique ID for the item.
  String _generateId(Map<String, dynamic> item) {
    final type = _toQuickAccessType(item['type'] ?? '');
    final title = (item['title'] ?? '').toString().toLowerCase().replaceAll(' ', '_');
    if (item['data'] != null && item['data']['number'] != null) {
      return '${type}_${item['data']['number']}';
    }
    if (item['data'] != null && item['data']['id'] != null) {
      return '${type}_${item['data']['id']}';
    }
    return '${type}_$title';
  }

  /// Filter the search data based on category and search query.
  List<Map<String, dynamic>> get _filteredItems {
    // Only show content items, not Menu items
    var items = widget.searchData.where((item) {
      final type = item['type']?.toString() ?? '';
      return type != 'Menu';
    }).toList();

    // Category filter
    if (_selectedCategory != 'Semua') {
      items = items.where((item) {
        final type = item['type']?.toString() ?? '';
        switch (_selectedCategory) {
          case 'Surat':
            return type == 'Surah';
          case 'Doa':
            return type == 'Doa';
          case 'Sholat Sunnah':
            return type == 'Sholat';
          case 'Asmaul Husna':
            return type == 'Asmaul Husna';
          default:
            return true;
        }
      }).toList();
    }

    // Search filter
    if (_searchQuery.isNotEmpty) {
      items = items
          .where((item) => item['title']
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return items;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredItems;
    final sheetHeight = MediaQuery.of(context).size.height * 0.7;

    return SizedBox(
      height: sheetHeight,
      child: Padding(
        padding: const EdgeInsets.only(left: 24, right: 24, top: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: widget.textColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              "Tambah ke Quick Access",
              style: TextStyle(
                color: widget.textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Search field
            Container(
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1C19),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: widget.sage.withOpacity(0.12),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _searchController,
                style: TextStyle(color: widget.textColor, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Cari surah, doa...',
                  hintStyle: TextStyle(color: widget.textColor.withOpacity(0.3), fontSize: 13),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: widget.sage.withOpacity(0.5),
                    size: 18,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 11),
                ),
                onChanged: (val) => setState(() => _searchQuery = val),
              ),
            ),
            const SizedBox(height: 12),

            // Category filter chips
            SizedBox(
              height: 34,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final cat = _categories[i];
                  final isActive = _selectedCategory == cat;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: isActive
                            ? widget.sage.withOpacity(0.2)
                            : const Color(0xFF1A1C19),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isActive
                              ? widget.sage.withOpacity(0.4)
                              : widget.sage.withOpacity(0.08),
                          width: 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: isActive
                              ? widget.sage
                              : widget.textColor.withOpacity(0.5),
                          fontSize: 12,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Items list
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 48,
                            color: widget.textColor.withOpacity(0.15),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Tidak ditemukan",
                            style: TextStyle(
                              color: widget.textColor.withOpacity(0.3),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: filtered.length,
                      padding: const EdgeInsets.only(bottom: 24),
                      itemBuilder: (ctx, i) {
                        final item = filtered[i];
                        final itemId = _generateId(item);
                        final isAdded = widget.quickAccess.hasItem(itemId);
                        final type = item['type']?.toString() ?? '';

                        // Get icon for the type
                        IconData typeIcon;
                        Color typeColor;
                        switch (type) {
                          case 'Surah':
                            typeIcon = Icons.auto_stories;
                            typeColor = const Color(0xFFB2C8BA);
                            break;
                          case 'Doa':
                            typeIcon = Icons.clean_hands;
                            typeColor = const Color(0xFFD2E0FB);
                            break;
                          case 'Sholat':
                            typeIcon = Icons.mosque;
                            typeColor = const Color(0xFFFFE5E5);
                            break;
                          case 'Asmaul Husna':
                            typeIcon = Icons.bookmark_rounded;
                            typeColor = const Color(0xFFEADFB4);
                            break;
                          default:
                            typeIcon = Icons.star_rounded;
                            typeColor = const Color(0xFFB2C8BA);
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1C19),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: typeColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(typeIcon,
                                    color: typeColor.withOpacity(0.7),
                                    size: 16),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['title']?.toString() ?? '',
                                      style: TextStyle(
                                        color:
                                            widget.textColor.withOpacity(0.85),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      type,
                                      style: TextStyle(
                                        color:
                                            widget.textColor.withOpacity(0.35),
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: isAdded
                                    ? null
                                    : () {
                                        final qaItem = QuickAccessItem(
                                          id: itemId,
                                          title:
                                              item['title']?.toString() ?? '',
                                          type: _toQuickAccessType(type),
                                          data: Map<String, dynamic>.from(
                                              item['data'] ?? {}),
                                        );
                                        widget.quickAccess.addItem(qaItem);
                                        setState(() {});
                                        widget.onAdded();
                                      },
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: isAdded
                                        ? widget.sage.withOpacity(0.15)
                                        : widget.sage.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    isAdded
                                        ? Icons.check_rounded
                                        : Icons.add_rounded,
                                    color: isAdded
                                        ? widget.sage
                                        : widget.sage.withOpacity(0.6),
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

