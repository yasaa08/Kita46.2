import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'database_service.dart';
import 'login_page.dart';
import 'settings_page.dart';

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
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kita 46.2',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB2C8BA),
          brightness: Brightness.dark,
          surface: const Color(0xFF1A1C19),
          onSurface: const Color(0xFFE2E3DD),
        ),
        scaffoldBackgroundColor: const Color(0xFF1A1C19),
      ),
      home: FirebaseAuth.instance.currentUser == null ? const LoginPage() : const HomePage(),
      routes: {
        '/login': (context) => const LoginPage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin { 
  final List<Map<String, dynamic>> _searchData = [];
  late AnimationController _settingsController;

  @override
  void initState() {
    super.initState();
    _loadAllSearchData();
    _settingsController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _settingsController.dispose(); 
    super.dispose();
  }

  String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour >= 5 && hour < 11) return 'Selamat Pagi ✨';
    if (hour >= 11 && hour < 15) return 'Selamat Siang ☀️';
    if (hour >= 15 && hour < 18) return 'Selamat Sore ⛅';
    return 'Selamat Malam 🌙';
  }

  String _getSubGreeting() {
    var hour = DateTime.now().hour;
    if (hour >= 5 && hour < 11) return 'Jangan Lupa Sholat Dhuha ya!';
    if (hour >= 11 && hour < 15) return 'Waktunya istirahat sejenak, yuk baca doa!';
    if (hour >= 15 && hour < 18) return 'Jangan lupa Doa Pagi Sore ya!';
    return 'Istirahat nyaman dan jangan lupa baca Ayat Kursi sebelum tidur!';
  }

  // LOAD SEMUA DATA JSON SECARA BERTAHAP (Fix ANR & Loading Lama)
  Future<void> _loadAllSearchData() async {
    _searchData.clear();
    _searchData.addAll([
      {'title': "Baca Qur'an", 'type': 'Menu', 'icon': Icons.book, 'page': const DaftarSurahPage()},
      {'title': "PR 13", 'type': 'Menu', 'icon': Icons.fingerprint, 'page': const Pr13Page()},
      {'title': "Asmaul Husna", 'type': 'Menu', 'icon': Icons.bookmark_rounded, 'page': const AsmaulHusnaPage()},
      {'title': "Sholat Sunnah", 'type': 'Menu', 'icon': Icons.mosque, 'page': const SholatSunnahPage()},
      {'title': "Kumpulan Doa", 'type': 'Menu', 'icon': Icons.clean_hands, 'page': const KumpulanDoaPage()},
    ]);

    Future.microtask(() async {
      // 1. Load Surah
      try {
        final res = await rootBundle.loadString('assets/list_surah.json');
        final List list = json.decode(res);
        for (var s in list) {
          _searchData.add({
            'title': s['name_latin'] ?? s['name'] ?? 'Surah',
            'searchKey': "surah ${s['number']} ${s['name_latin']}",
            'type': 'Surah', 'icon': Icons.auto_stories, 'data': s
          });
        }
      } catch (_) {}

      // 2. Load Sholat Sunnah
      try {
        final res = await rootBundle.loadString('assets/Sholat sunnah/Sholatsunnah.json');
        final List list = json.decode(res);
        for (var sh in list) {
          _searchData.add({'title': sh['title'] ?? 'Sholat', 'type': 'Sholat', 'icon': Icons.wb_sunny_outlined, 'data': sh});
        }
      } catch (_) {}

      // 3. Load PR 13
      try {
        final res = await rootBundle.loadString('assets/PR 13/pr13.json');
        final List list = json.decode(res);
        for (var pr in list) {
          _searchData.add({'title': pr['title'] ?? 'PR 13', 'type': 'PR 13', 'icon': Icons.fingerprint, 'data': pr});
        }
      } catch (_) {}

      // 4. Load Doa
      try {
        final res = await rootBundle.loadString('assets/kumpulan doa/kumpulan_doa.json');
        final List list = json.decode(res);
        for (var d in list) {
          _searchData.add({'title': d['title'] ?? 'Doa', 'type': 'Doa', 'icon': Icons.clean_hands_outlined, 'data': d});
        }
      } catch (_) {}

      if (mounted) setState(() {});
    });
  }

  void _submitFeedback(String message) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) return;
    try {
      await FirebaseFirestore.instance.collection('feedbacks').add({
        'uid': user.uid, 'email': user.email, 'name': user.displayName ?? 'Pengguna',
        'message': message, 'timestamp': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Jazzakumullahu Khoiro!")));
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final sageColor = const Color(0xFFB2C8BA);
    final bgColor = const Color(0xFF1A1C19);
    final surfaceColor = const Color(0xFF242822);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: bgColor,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: const Text("Kita 46.2", style: TextStyle(color: Color(0xFFB2C8BA), fontWeight: FontWeight.bold, fontSize: 22)),
        actions: [
          SearchAnchor(
            viewBackgroundColor: bgColor,
            builder: (context, controller) => IconButton(icon: const Icon(Icons.search_rounded), onPressed: () => controller.openView()),
            suggestionsBuilder: (context, controller) {
              final keyword = controller.text.toLowerCase();
              final results = _searchData.where((item) => item['title'].toLowerCase().contains(keyword)).toList();
              
              return results.map((item) => ListTile(
                leading: Icon(item['icon'], color: sageColor),
                title: Text(item['title']),
                subtitle: Text(item['type']),
                onTap: () {
                  controller.closeView(item['title']);
                  if (item['type'] == 'Menu') Navigator.push(context, MaterialPageRoute(builder: (_) => item['page']));
                  else if (item['type'] == 'Surah') Navigator.push(context, MaterialPageRoute(builder: (_) => DetailSurahPage(surahNumber: int.parse(item['data']['number'].toString()), surahName: item['data']['name_latin'], revelation: item['data']['revelation'] ?? '')));
                  else if (item['type'] == 'Sholat') Navigator.push(context, MaterialPageRoute(builder: (_) => DetailSholatPage(sholatData: item['data'])));
                  else if (item['type'] == 'PR 13') Navigator.push(context, MaterialPageRoute(builder: (_) => Pr13DetailPage(doaData: item['data'])));
                  else if (item['type'] == 'Doa') Navigator.push(context, MaterialPageRoute(builder: (_) => DetailDoaPage(doaData: item['data'])));
                },
              )).toList();
            },
          ),
          IconButton(
            icon: RotationTransition(turns: _settingsController, child: const Icon(Icons.settings_outlined)),
            onPressed: () async {
              _settingsController.forward(from: 0.0);
              await Future.delayed(const Duration(milliseconds: 250));
              if (mounted) Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(_getGreeting(), style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 16)),
            const SizedBox(height: 6),
            Text(_getSubGreeting(), style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
            const SizedBox(height: 28),

            // WIDGET RIWAYAT
            StreamBuilder<DocumentSnapshot>(
              stream: DatabaseService().userHistory,
              builder: (context, snapshot) {
                final user = FirebaseAuth.instance.currentUser;
                if (user == null || user.isAnonymous) return _buildGuestHistory(sageColor, surfaceColor);
                
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return _buildPlaceholderHistory(surfaceColor);
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
                  decoration: BoxDecoration(color: const Color(0xFFDDE5D9), borderRadius: BorderRadius.circular(28)),
                  child: IntrinsicHeight(
                    child: Row(
                      children: [
                        Expanded(
                          child: _historySubCard("QURAN", lastAyah > 0 ? "$surahName: $lastAyah" : surahName, "Lanjut Baca", Icons.auto_stories, surfaceColor, () {
                            if (lastSurahNum > 0) Navigator.push(context, MaterialPageRoute(builder: (_) => DetailSurahPage(surahNumber: lastSurahNum, surahName: surahName, revelation: '')));
                          }),
                        ),
                        Container(width: 1, color: surfaceColor.withOpacity(0.1), margin: const EdgeInsets.symmetric(horizontal: 16)),
                        Expanded(
                          child: _historySubCard("PR 13", lastPrTitle, "Count: ${lastCount}x", Icons.fingerprint, surfaceColor, () {
                            if (lastPrTitle != '-') {
                              final prMatch = _searchData.firstWhere((item) => item['type'] == 'PR 13' && item['title'] == lastPrTitle, orElse: () => {});
                              if (prMatch.isNotEmpty) Navigator.push(context, MaterialPageRoute(builder: (_) => Pr13DetailPage(doaData: prMatch['data'], initialCount: lastCount)));
                            }
                          }),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // MENU GRID[cite: 5]
            GridView.count(
              shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 2.2,
              children: [
                _buildMenuTile(context, "Qur'an", Icons.book, const Color(0xFFB2C8BA), const DaftarSurahPage()),
                _buildMenuTile(context, "PR 13", Icons.fingerprint, const Color(0xFFCDE8E5), const Pr13Page()),
                _buildMenuTile(context, "Asmaul Husna", Icons.bookmark_rounded, const Color(0xFFEADFB4), const AsmaulHusnaPage()),
                _buildMenuTile(context, "Sholat Sunnah", Icons.mosque, const Color(0xFFFFE5E5), const SholatSunnahPage()),
                _buildMenuTile(context, "Kumpulan Doa", Icons.clean_hands, const Color(0xFFD2E0FB), const KumpulanDoaPage()),
              ],
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null && !user.isAnonymous) _showFeedbackDialog(context, sageColor, surfaceColor, user.email ?? '');
        },
        backgroundColor: surfaceColor,
        icon: Icon(Icons.chat_bubble_outline_rounded, color: sageColor, size: 20),
        label: Text("Saran", style: TextStyle(color: sageColor, fontSize: 13)),
      ),
    );
  }

  // --- HELPERS ---
  Widget _buildPlaceholderHistory(Color surface) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(28)),
      child: const Row(children: [Icon(Icons.auto_stories_outlined, color: Colors.white24), SizedBox(width: 12), Text("Belum ada riwayat", style: TextStyle(color: Colors.white24))]),
    );
  }

  Widget _historySubCard(String label, String title, String sub, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(icon, color: color, size: 16), const SizedBox(width: 6), Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold))]),
        const SizedBox(height: 8),
        Text(title, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
        Text(sub, style: TextStyle(color: color.withOpacity(0.5), fontSize: 10)),
      ]),
    );
  }

  Widget _buildMenuTile(BuildContext context, String title, IconData icon, Color color, Widget page) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(color: const Color(0xFF242822), borderRadius: BorderRadius.circular(24)),
        child: Row(children: [
          Hero(tag: 'icon_$title', child: CircleAvatar(backgroundColor: color.withOpacity(0.2), radius: 18, child: Icon(icon, color: color, size: 18))),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis)),
        ]),
      ),
    );
  }

  Widget _buildGuestHistory(Color sage, Color surface) {
    return Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(28)), child: Row(children: [Icon(Icons.account_circle_outlined, color: sage), const SizedBox(width: 12), const Text("Mode Tamu", style: TextStyle(fontWeight: FontWeight.bold))]));
  }

   void _showFeedbackDialog(BuildContext context, Color sage, Color surface, String email) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context, backgroundColor: surface, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(left: 24, right: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24, top: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 24),
            const Text("Kirim Saran & Masukan", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text("Email: $email", style: TextStyle(color: sage, fontSize: 12)),
            const SizedBox(height: 16),
            TextField(controller: controller, maxLines: 4, decoration: InputDecoration(hintText: "Tulis saranmu...", filled: true, fillColor: const Color(0xFF1A1C19), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none))),
            const SizedBox(height: 24),
            SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: () => _submitFeedback(controller.text), icon: const Icon(Icons.send_rounded), label: const Text("Kirim Sekarang"))),
          ],
        ),
      ),
    );
  }
}