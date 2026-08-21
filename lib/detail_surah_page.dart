import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'app_settings.dart';
import 'main.dart';
import 'widget_service.dart';
import 'widgets/quran_assistive_touch.dart';
import 'streak_service.dart';

String _cleanAyahText(String text) {
  int end = text.length;
  while (end > 0) {
    int code = text.codeUnitAt(end - 1);
    if (code == 0x0020) {
      end--;
    } else if ((code >= 0x06D6 && code <= 0x06EC) ||
        (code >= 0x08D0 && code <= 0x08DF)) {
      end--;
    } else {
      break;
    }
  }
  return text.substring(0, end);
}

List<Map<String, String>> _parseSurahJson(Map<String, String> params) {
  final data = json.decode(params['response']!);
  final surahData = data[params['surahNumber']!];
  final Map<String, dynamic> textMap = surahData['text'] ?? {};
  final Map<String, dynamic> translationMap =
      surahData['translations']?['id']?['text'] ?? {};
  int numAyahs = int.tryParse(surahData['number_of_ayah'].toString()) ?? 0;
  List<Map<String, String>> parsedVerses = [];
  for (int i = 1; i <= numAyahs; i++) {
    String key = i.toString();
    parsedVerses.add({
      'verseNumber': key,
      'arab': _cleanAyahText(textMap[key] ?? ''),
      'translation': translationMap[key] ?? 'Terjemahan tidak tersedia',
    });
  }
  return parsedVerses;
}

class DetailSurahPage extends StatefulWidget {
  final int surahNumber;
  final String surahName;
  final String revelation;

  const DetailSurahPage({
    super.key,
    required this.surahNumber,
    required this.surahName,
    required this.revelation,
  });

  @override
  State<DetailSurahPage> createState() => _DetailSurahPageState();
}

class _DetailSurahPageState extends State<DetailSurahPage>
    with SingleTickerProviderStateMixin {
  List<Map<String, String>> _verses = [];
  List<dynamic> _allSurah = [];
  bool _isLoading = true;
  int _selectedAyah = 0; // Ayah yang dipilih user sebelum di-save

  Map<String, dynamic>? _cachedPrevSurah;
  Map<String, dynamic>? _cachedNextSurah;

  final sageColor = const Color(0xFFB2C8BA);
  final surface = const Color(0xFF242822);
  final bg = const Color(0xFF1A1C19);
  final textColor = Colors.white;

  late AnimationController _floatingBarController;
  bool _floatingBarVisible = true;
  double _lastScrollOffset = 0;

  final ScrollController _scrollController = ScrollController();

  final Map<int, List<int>> _sujudTilawahVerses = {
    7: [206],
    13: [15],
    16: [49],
    17: [107],
    19: [58],
    22: [18, 77],
    25: [60],
    27: [25],
    32: [15],
    38: [24],
    41: [37],
    53: [62],
    84: [21],
    96: [19],
  };

  bool _isSujudTilawah(int surah, int ayah) {
    return _sujudTilawahVerses[surah]?.contains(ayah) ?? false;
  }

  void _showSujudTilawahDialog(BuildContext context) {
    bool showLatinAndTranslation = false;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: bg,
              title: Text('Doa Sujud Tilawah',
                  style: TextStyle(color: sageColor, fontWeight: FontWeight.bold, fontSize: 18)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "سَجَدَ وَجْهِي لِلَّذِي خَلَقَهُ وَشَقَّ سَمْعَهُ وَبَصَرَهُ بِحَوْلِهِ وَقُوَّتِهِ",
                      textAlign: TextAlign.center,
                      style: AppSettings().getArabicStyle(
                        fontSize: 24,
                        color: Colors.white,
                        height: 1.9,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Tampilkan Latin & Arti',
                            style: TextStyle(color: Colors.white70, fontSize: 14)),
                        Switch(
                          value: showLatinAndTranslation,
                          onChanged: (val) {
                            setState(() {
                              showLatinAndTranslation = val;
                            });
                          },
                          activeColor: bg,
                          activeTrackColor: sageColor,
                          inactiveThumbColor: Colors.white54,
                          inactiveTrackColor: surface,
                        ),
                      ],
                    ),
                    if (showLatinAndTranslation) ...[
                      const SizedBox(height: 16),
                      Text(
                        "Sajada wajhī lilladhī khalaqahu wa shaqqa sam'ahu wa baṣarahu biḥawlihi wa quwwatih.",
                        style: TextStyle(
                            fontSize: 14, color: sageColor, fontStyle: FontStyle.italic),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Wajahku sujud kepada Dzat yang telah menciptakannya dan membentuknya dengan sangat bagus, lalu Ia menciptakan pendengaran dan penglihatannya dengan segala daya dan kekuatan-Nya.",
                        style: TextStyle(fontSize: 14, color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Tutup', style: TextStyle(color: sageColor)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    AppSettings().addListener(_onSettingsChange);
    _floatingBarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      value: 1.0,
    );
    readJson();
    _loadAllSurah();
    _scrollController.addListener(_onScroll);
  }

  void _onSettingsChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    AppSettings().removeListener(_onSettingsChange);
    _floatingBarController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    final delta = offset - _lastScrollOffset;
    _lastScrollOffset = offset;

    if (delta > 8 && _floatingBarVisible) {
      _floatingBarVisible = false;
      _floatingBarController.reverse();
    } else if (delta < -8 && !_floatingBarVisible) {
      _floatingBarVisible = true;
      _floatingBarController.forward();
    }

    if (_scrollController.hasClients &&
        _scrollController.position.maxScrollExtent > 0 &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 80) {
      StreakService().recordActivity('quran');
    }
  }

  Future<void> _loadAllSurah() async {
    try {
      final res = await rootBundle.loadString('assets/list_surah.json');
      if (mounted) {
        setState(() {
          _allSurah = json.decode(res);
          _computeCachedSurah();
        });
      }
    } catch (_) {}
  }

  void _computeCachedSurah() {
    if (_allSurah.isEmpty) return;
    if (widget.surahNumber > 1) {
      _cachedPrevSurah = _allSurah.cast<Map<String, dynamic>>().firstWhere(
          (s) => s['number'] == widget.surahNumber - 1,
          orElse: () => <String, dynamic>{});
    }
    if (widget.surahNumber < 114) {
      _cachedNextSurah = _allSurah.cast<Map<String, dynamic>>().firstWhere(
          (s) => s['number'] == widget.surahNumber + 1,
          orElse: () => <String, dynamic>{});
    }
  }

  Future<void> readJson() async {
    try {
      final String response = await rootBundle
          .loadString('assets/surah/${widget.surahNumber}.json');

      List<Map<String, String>> parsedVerses = await compute(
        _parseSurahJson,
        {
          'response': response,
          'surahNumber': widget.surahNumber.toString(),
        },
      );

      if (mounted) {
        setState(() {
          _verses = parsedVerses;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error reading surah JSON: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<bool> _saveLastRead(int ayahNumber) async {
    StreakService().recordActivity('quran');
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.isAnonymous) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'last_read_surah': {
            'name': widget.surahName,
            'number': widget.surahNumber,
            'ayah': ayahNumber,
          }
        }, SetOptions(merge: true));
        WidgetService.updateWidget(
          surahName: widget.surahName,
          surahNumber: widget.surahNumber.toString(),
          ayahNumber: ayahNumber.toString(),
        );
        return true;
      } catch (e) {
        debugPrint("Error Save: $e");
      }
    }
    return false;
  }

  Map<String, dynamic>? get _prevSurah => _cachedPrevSurah;

  Map<String, dynamic>? get _nextSurah => _cachedNextSurah;

  void _goToSurah(Map<String, dynamic> surah, {bool isNext = true}) {
    if (AppSettings().hapticEnabled) HapticFeedback.lightImpact();
    
    // Gunakan custom PageRoute agar transisi tidak glitchy
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => DetailSurahPage(
          surahNumber: surah['number'],
          surahName: surah['name'],
          revelation: surah['revelation'] ?? '',
        ),
        transitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (_, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: Offset(isNext ? 0.05 : -0.05, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
      ),
    );
  }

  void _jumpToAyah(int targetAyah) {
    if (_verses.isEmpty) return;
    final clamped = targetAyah.clamp(1, _verses.length);
    setState(() {
      _selectedAyah = clamped;
    });

    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final progress = (clamped - 1) / _verses.length;
      final targetOffset = (progress * maxScroll).clamp(0.0, maxScroll);

      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    }
    showTopNotification(context, "${widget.surahName} Ayat $clamped");
  }

  void _showQuickDisplaySettings(BuildContext context) {
    final settings = AppSettings();
    showModalBottomSheet(
      context: context,
      backgroundColor: bg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (ctx) {
        return ListenableBuilder(
          listenable: settings,
          builder: (context, _) {
            return SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: sageColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.display_settings_rounded,
                              color: sageColor, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "Pengaturan Tampilan Cepat",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Slider Ukuran Font
                    Text(
                        "Ukuran Font Arab: ${settings.arabicFontSize.toInt()}px",
                        style: TextStyle(
                            color: textColor.withOpacity(0.6), fontSize: 13)),
                    Slider(
                      value: settings.arabicFontSize,
                      min: 20,
                      max: 40,
                      divisions: 4,
                      activeColor: sageColor,
                      inactiveColor: sageColor.withOpacity(0.2),
                      onChanged: (val) async {
                        if (settings.hapticEnabled) {
                          HapticFeedback.selectionClick();
                        }
                        await settings.setArabicFontSize(val);
                      },
                    ),

                    const SizedBox(height: 12),

                    // Pilihan Font Arab
                    Text("Jenis Font Arab",
                        style: TextStyle(
                            color: textColor.withOpacity(0.6), fontSize: 13)),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: AppSettings.arabicFontOptions.map((f) {
                          final isSelected = settings.arabicFontFamily == f.key;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(f.name),
                              selected: isSelected,
                              selectedColor: sageColor.withOpacity(0.25),
                              backgroundColor: surface,
                              labelStyle: TextStyle(
                                color: isSelected ? sageColor : Colors.white70,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 12,
                              ),
                              side: BorderSide(
                                color: isSelected
                                    ? sageColor
                                    : Colors.white.withOpacity(0.08),
                              ),
                              onSelected: (_) async {
                                if (settings.hapticEnabled) {
                                  HapticFeedback.selectionClick();
                                }
                                await settings.setArabicFontFamily(f.key);
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Switch Terjemahan
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.translate_rounded,
                                  color: Color(0xFFD2E0FB), size: 18),
                              SizedBox(width: 10),
                              Text(
                                "Tampilkan Terjemahan",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 13),
                              ),
                            ],
                          ),
                          Switch(
                            value: settings.showTranslation,
                            activeColor: sageColor,
                            onChanged: (val) async {
                              await settings.setShowTranslation(val);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = AppSettings();
    final arabFontSize = settings.arabicFontSize;

    final prev = _prevSurah;
    final next = _nextSurah;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text(widget.surahName,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 18, color: Colors.white)),
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: const [
          SizedBox(width: 4),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Daftar Ayat ────────────────────────────────────────────
          _isLoading
              ? Center(child: CircularProgressIndicator(color: sageColor))
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(bottom: 140),
                  // Optimasi performa
                  addAutomaticKeepAlives: false,
                  addRepaintBoundaries: true,
                  cacheExtent: 300,
                  itemCount: _verses.length + 2,
                  itemBuilder: (context, index) {
                    // Header Surah
                    if (index == 0) {
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        padding: const EdgeInsets.symmetric(
                            vertical: 32, horizontal: 24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              surface,
                              sageColor.withOpacity(0.08),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Column(
                          children: [
                            Text(widget.surahName,
                                style: TextStyle(
                                    fontSize: 28,
                                    color: sageColor,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text(
                                'Surah ke-${widget.surahNumber} • ${widget.revelation}',
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.6),
                                    fontSize: 14)),
                          ],
                        ),
                      ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1);
                    }

                    // Bismillah
                    if (index == 1) {
                      if (widget.surahNumber == 1 || widget.surahNumber == 9) {
                        return const SizedBox(height: 8);
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 24),
                        child: Center(
                          child: Text("بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيم",
                              style: settings.getArabicStyle(
                                  fontSize: 26,
                                  color: sageColor,
                                  height: 2.0)),
                        ),
                      );
                    }

                    // Ayat
                    final verse = _verses[index - 2];
                    final verseNumber = verse['verseNumber']!;
                    final isSelected = _selectedAyah.toString() == verseNumber;

                    return RepaintBoundary(
                      child: InkWell(
                        onTap: () {
                          if (AppSettings().hapticEnabled) {
                            HapticFeedback.selectionClick();
                          }
                          setState(() {
                            _selectedAyah = int.parse(verseNumber);
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          color: isSelected ? sageColor.withOpacity(0.1) : Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: isSelected ? sageColor : surface,
                                    radius: 18,
                                    child: Text(verseNumber,
                                        style: TextStyle(
                                            color: isSelected ? bg : sageColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  const SizedBox(height: 12),
                                  IconButton(
                                    icon: Icon(
                                      isSelected ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                                      color: isSelected ? sageColor : Colors.white.withOpacity(0.3),
                                      size: 24,
                                    ),
                                    onPressed: () async {
                                      if (AppSettings().hapticEnabled) HapticFeedback.lightImpact();
                                      setState(() {
                                        _selectedAyah = int.parse(verseNumber);
                                      });
                                      bool saved = await _saveLastRead(int.parse(verseNumber));
                                      if (mounted) {
                                        if (saved) {
                                          showTopNotification(context, "Tersimpan: ${widget.surahName} Ayat $verseNumber");
                                        } else {
                                          showTopNotification(context, "Login dulu ya biar bisa menyimpan", bgColor: Colors.orangeAccent);
                                        }
                                      }
                                    },
                                    tooltip: 'Simpan Ayat',
                                  ),
                                  if (_isSujudTilawah(widget.surahNumber, int.parse(verseNumber))) ...[
                                    const SizedBox(height: 8),
                                    InkWell(
                                      onTap: () {
                                        if (AppSettings().hapticEnabled) HapticFeedback.lightImpact();
                                        _showSujudTilawahDialog(context);
                                      },
                                      borderRadius: BorderRadius.circular(8),
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Column(
                                          children: [
                                            Icon(Icons.accessibility_new_rounded, color: sageColor, size: 22),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Sujud',
                                              style: TextStyle(
                                                color: sageColor,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      verse['arab']!,
                                      textAlign: TextAlign.right,
                                      style: settings.getArabicStyle(
                                          fontSize: arabFontSize,
                                          color: textColor,
                                          height: 1.9),
                                    ),
                                    if (settings.showTranslation) ...[
                                      const SizedBox(height: 12),
                                      Text(
                                        verse['translation']!,
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: textColor.withOpacity(0.6),
                                            height: 1.5),
                                      ),
                                    ],
                                    const SizedBox(height: 16),
                                    Divider(
                                        color: Colors.white.withOpacity(0.07),
                                        height: 1),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

          // ── Floating Navigation Bar ────────────────────────────────
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: AnimatedBuilder(
              animation: _floatingBarController,
              builder: (_, child) {
                // Efek Bounce dan Scale
                final springVal = Curves.elasticOut.transform(
                    _floatingBarController.value);
                final clamped = springVal.clamp(0.0, 1.2);
                
                return Transform.translate(
                  offset: Offset(0, 100 * (1 - clamped)),
                  child: Opacity(
                    opacity: _floatingBarController.value.clamp(0.0, 1.0),
                    child: Transform.scale(
                      scale: 0.8 + (0.2 * clamped),
                      child: child,
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2D27).withOpacity(0.97),
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
                ),
                child: Row(
                  children: [
                    // Prev Button
                    if (prev != null && prev.isNotEmpty)
                      _FloatingNavBtn(
                        icon: Icons.arrow_back_ios_rounded,
                        label: prev['name'] ?? '',
                        onTap: () => _goToSurah(prev, isNext: false),
                        sageColor: sageColor,
                        align: CrossAxisAlignment.start,
                      )
                    else
                      const Expanded(child: SizedBox()),

                    // Divider Center
                    Container(
                      width: 1.5,
                      height: 24,
                      color: Colors.white.withOpacity(0.1),
                    ),

                    // Next Button
                    if (next != null && next.isNotEmpty)
                      _FloatingNavBtn(
                        icon: Icons.arrow_forward_ios_rounded,
                        label: next['name'] ?? '',
                        onTap: () => _goToSurah(next, isNext: true),
                        sageColor: sageColor,
                        align: CrossAxisAlignment.end,
                      )
                    else
                      const Expanded(child: SizedBox()),
                  ],
                ),
              ),
            ),
          ),

          // ── Assistive Touch Floating Overlay ────────────────────────
          if (!_isLoading)
            QuranAssistiveTouch(
              scrollController: _scrollController,
              surahNumber: widget.surahNumber,
              surahName: widget.surahName,
              revelation: widget.revelation,
              totalVerses: _verses.length,
              allSurahList: _allSurah,
              onJumpToAyah: _jumpToAyah,
              onJumpToSurah: (surah) => _goToSurah(surah),
              onOpenDisplaySettings: () => _showQuickDisplaySettings(context),
            ),
        ],
      ),
    );
  }
}

class _FloatingNavBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color sageColor;
  final CrossAxisAlignment align;

  const _FloatingNavBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.sageColor,
    required this.align,
  });

  @override
  Widget build(BuildContext context) {
    final isLeft = align == CrossAxisAlignment.start;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(100),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Row(
            mainAxisAlignment: isLeft
                ? MainAxisAlignment.start
                : MainAxisAlignment.end,
            children: [
              if (isLeft) Icon(icon, color: sageColor, size: 16),
              if (isLeft) const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                ),
              ),
              if (!isLeft) const SizedBox(width: 8),
              if (!isLeft) Icon(icon, color: sageColor, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
