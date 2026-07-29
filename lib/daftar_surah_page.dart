// lib/daftar_surah_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'app_settings.dart';
import 'detail_surah_page.dart';
import 'main.dart';

// Peta nama Arab 114 surah
const List<String> _arabicNames = [
  'الْفَاتِحَة',
  'الْبَقَرَة',
  'آلِ عِمْرَان',
  'النِّسَاء',
  'الْمَائِدَة',
  'الْأَنْعَام',
  'الْأَعْرَاف',
  'الْأَنْفَال',
  'التَّوْبَة',
  'يُونُس',
  'هُود',
  'يُوسُف',
  'الرَّعْد',
  'إِبْرَاهِيم',
  'الْحِجْر',
  'النَّحْل',
  'الْإِسْرَاء',
  'الْكَهْف',
  'مَرْيَم',
  'طه',
  'الْأَنْبِيَاء',
  'الْحَج',
  'الْمُؤْمِنُون',
  'النُّور',
  'الْفُرْقَان',
  'الشُّعَرَاء',
  'النَّمْل',
  'الْقَصَص',
  'الْعَنْكَبُوت',
  'الرُّوم',
  'لُقْمَان',
  'السَّجْدَة',
  'الْأَحْزَاب',
  'سَبَأ',
  'فَاطِر',
  'يس',
  'الصَّافَّات',
  'ص',
  'الزُّمَر',
  'غَافِر',
  'فُصِّلَت',
  'الشُّورَى',
  'الزُّخْرُف',
  'الدُّخَان',
  'الْجَاثِيَة',
  'الْأَحْقَاف',
  'مُحَمَّد',
  'الْفَتْح',
  'الْحُجُرَات',
  'ق',
  'الذَّارِيَات',
  'الطُّور',
  'النَّجْم',
  'الْقَمَر',
  'الرَّحْمن',
  'الْوَاقِعَة',
  'الْحَدِيد',
  'الْمُجَادَلَة',
  'الْحَشْر',
  'الْمُمْتَحَنَة',
  'الصَّف',
  'الْجُمُعَة',
  'الْمُنَافِقُون',
  'التَّغَابُن',
  'الطَّلَاق',
  'التَّحْرِيم',
  'الْمُلْك',
  'الْقَلَم',
  'الْحَاقَّة',
  'الْمَعَارِج',
  'نُوح',
  'الْجِن',
  'الْمُزَّمِّل',
  'الْمُدَّثِّر',
  'الْقِيَامَة',
  'الْإِنسَان',
  'الْمُرْسَلَات',
  'النَّبَأ',
  'النَّازِعَات',
  'عَبَسَ',
  'التَّكْوِير',
  'الْإِنفِطَار',
  'الْمُطَفِّفِين',
  'الْإِنشِقَاق',
  'الْبُرُوج',
  'الطَّارِق',
  'الْأَعْلَى',
  'الْغَاشِيَة',
  'الْفَجْر',
  'الْبَلَد',
  'الشَّمْس',
  'اللَّيْل',
  'الضُّحَى',
  'الشَّرْح',
  'التِّين',
  'الْعَلَق',
  'الْقَدْر',
  'الْبَيِّنَة',
  'الزَّلْزَلَة',
  'الْعَادِيَات',
  'الْقَارِعَة',
  'التَّكَاثُر',
  'الْعَصْر',
  'الْهُمَزَة',
  'الْفِيل',
  'قُرَيْش',
  'الْمَاعُون',
  'الْكَوْثَر',
  'الْكَافِرُون',
  'النَّصْر',
  'الْمَسَد',
  'الْإِخْلَاص',
  'الْفَلَق',
  'النَّاس',
];

class DaftarSurahPage extends StatefulWidget {
  const DaftarSurahPage({super.key});

  @override
  State<DaftarSurahPage> createState() => _DaftarSurahPageState();
}

class _DaftarSurahPageState extends State<DaftarSurahPage> {
  List _allSurah = [];
  List _filteredSurah = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  final sageColor = const Color(0xFFB2C8BA);
  final surfaceColor = const Color(0xFF242822);
  final bgColor = const Color(0xFF1A1C19);

  Future<void> readJson() async {
    try {
      final String response =
          await rootBundle.loadString('assets/list_surah.json');
      final data = json.decode(response);
      if (mounted) {
        setState(() {
          _allSurah = data;
          _filteredSurah = _allSurah;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error reading list_surah JSON: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filterSurah(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredSurah = _allSurah;
      } else {
        _filteredSurah = _allSurah.where((surah) {
          final nameLower = surah['name'].toString().toLowerCase();
          final searchLower = query.toLowerCase();
          final number = surah['number'].toString();
          return nameLower.contains(searchLower) ||
              number.contains(searchLower);
        }).toList();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    readJson();
    _searchController.addListener(() => _filterSurah(_searchController.text));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = AppSettings();
    const bg = Color(0xFF1A1C19);
    const surface = Color(0xFF242822);
    const textColor = Colors.white;
    final sage = sageColor;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text('Daftar Surah',
            style: TextStyle(fontWeight: FontWeight.w500, color: textColor)),
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                filled: true,
                fillColor: surface,
                hintText: 'Cari surah atau nomor...',
                hintStyle: TextStyle(color: textColor.withOpacity(0.35)),
                prefixIcon:
                    Icon(Icons.search, color: textColor.withOpacity(0.35)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear_rounded,
                            color: textColor.withOpacity(0.35), size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _filterSurah('');
                        })
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              ),
            ),
          ).animate().fadeIn(duration: 300.ms),

          const SizedBox(height: 4),

          // Daftar Surah
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: sage))
                : _filteredSurah.isEmpty
                    ? Center(
                        child: Text('Surah tidak ditemukan',
                            style:
                                TextStyle(color: textColor.withOpacity(0.4))))
                    : ListView.separated(
                        itemCount: _filteredSurah.length,
                        itemBuilder: (context, index) {
                          final surah = _filteredSurah[index];
                          final num = (surah['number'] as int?) ?? 1;
                          final arabicName = num >= 1 && num <= 114
                              ? _arabicNames[num - 1]
                              : '';

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 6),
                            leading: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: sage.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Center(
                                child: Text(
                                  num.toString(),
                                  style: TextStyle(
                                      color: sage,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            title: Text(
                              surah['name'],
                              style: TextStyle(
                                  color: textColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500),
                            ),
                            subtitle: Text(
                              '${surah["revelation"]} • ${surah["numberOfAyahs"]} Ayat',
                              style: TextStyle(
                                  color: textColor.withOpacity(0.5),
                                  fontSize: 12),
                            ),
                            // Nama Arab di kanan
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (arabicName.isNotEmpty)
                                  Text(
                                    arabicName,
                                    style: TextStyle(
                                      fontFamily: 'LPMQ',
                                      fontSize: 20,
                                      color: sage.withOpacity(0.85),
                                    ),
                                  ),
                                const SizedBox(width: 8),
                                Icon(Icons.arrow_forward_ios_rounded,
                                    color: textColor.withOpacity(0.15),
                                    size: 13),
                              ],
                            ),
                            onTap: () {
                              if (settings.hapticEnabled) {
                                HapticFeedback.lightImpact();
                              }
                              Navigator.push(
                                context,
                                buildSlideRoute(DetailSurahPage(
                                  surahNumber: num,
                                  surahName: surah['name'],
                                  revelation: surah['revelation'] ?? '',
                                )),
                              );
                            },
                          )
                              .animate(
                                  delay: Duration(
                                      milliseconds:
                                          index * 20 > 400 ? 400 : index * 20))
                              .fadeIn(duration: 250.ms);
                        },
                        separatorBuilder: (context, index) => Divider(
                          color: textColor.withOpacity(0.05),
                          height: 1,
                          indent: 80,
                          endIndent: 20,
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
