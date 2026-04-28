// lib/detail_surah_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'database_service.dart'; // <--- TAMBAHKAN INI

const Map<int, int> surahToJuzMap = {
  1: 1, 2: 1, 3: 3, 4: 4, 5: 6, 6: 7, 7: 8, 8: 9, 9: 10, 
  10: 11, 11: 11, 12: 12, 13: 13, 14: 13, 15: 14, 16: 14, 17: 15, 18: 15, 
  19: 16, 20: 16, 21: 17, 22: 17, 23: 18, 24: 18, 25: 18, 26: 19, 27: 19, 
  28: 20, 29: 20, 30: 21, 31: 21, 32: 21, 33: 21, 34: 22, 35: 22, 36: 22, 
  37: 23, 38: 23, 39: 23, 40: 24, 41: 24, 42: 25, 43: 25, 44: 25, 45: 25, 
  46: 26, 47: 26, 48: 26, 49: 26, 50: 26, 51: 27, 52: 27, 53: 27, 54: 27, 
  55: 27, 56: 27, 57: 27, 58: 28, 59: 28, 60: 28, 61: 28, 62: 28, 63: 28, 
  64: 28, 65: 28, 66: 28, 67: 29, 68: 29, 69: 29, 70: 29, 71: 29, 72: 29, 
  73: 29, 74: 29, 75: 29, 76: 29, 77: 29, 78: 30, 79: 30, 80: 30, 81: 30, 
  82: 30, 83: 30, 84: 30, 85: 30, 86: 30, 87: 30, 88: 30, 89: 30, 90: 30, 
  91: 30, 92: 30, 93: 30, 94: 30, 95: 30, 96: 30, 97: 30, 98: 30, 99: 30, 
  100: 30, 101: 30, 102: 30, 103: 30, 104: 30, 105: 30, 106: 30, 107: 30, 
  108: 30, 109: 30, 110: 30, 111: 30, 112: 30, 113: 30, 114: 30
};

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

class _DetailSurahPageState extends State<DetailSurahPage> {
  Map<String, dynamic> _surahData = {};
  bool _isLoading = true;

  Future<void> readJson() async {
    try {
      final String response = await rootBundle.loadString('assets/surah/${widget.surahNumber}.json');
      final data = await json.decode(response);
      final Map<String, dynamic> surahContent = data[widget.surahNumber.toString()];
      setState(() {
        _surahData = surahContent;
        _isLoading = false;
      });
    } catch (e) {
      print("Error reading surah JSON: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    readJson();
    // Simpan otomatis ke database saat halaman dibuka
    DatabaseService().saveLastReadSurah(
      surahNumber: widget.surahNumber,
      surahName: widget.surahName,
      ayahNumber: 1, 
    );
  }

  @override
  Widget build(BuildContext context) {
    final int numberOfAyahs = int.tryParse(_surahData['number_of_ayah'] ?? '0') ?? 0;
    final Map<String, dynamic> arabicText = _surahData['text'] ?? {};
    final String translatedName = _surahData['translations']?['id']?['name'] ?? widget.surahName; 
    final String? bismillahPre = _surahData['preBismillah']?['text']?['arab'];

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(widget.surahName, style: const TextStyle(color: Color(0xFFF5F5F5))),
        iconTheme: const IconThemeData(color: Color(0xFFF5F5F5)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4DB6AC)))
          : numberOfAyahs == 0 
              ? const Center(child: Text('Gagal memuat data ayat.', style: TextStyle(color: Color(0xFFF5F5F5))))
              : ListView.builder(
                  itemCount: numberOfAyahs + 1, 
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Card(
                          color: const Color(0xFF1E1E1E), 
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0), 
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20), 
                                        border: Border.all(color: const Color(0xFF4DB6AC), width: 1),
                                      ),
                                      child: Text( 
                                        'Juz ${surahToJuzMap[widget.surahNumber] ?? '?'}', 
                                        style: const TextStyle(color: Color(0xFF4DB6AC), fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Text(
                                      translatedName, 
                                      style: const TextStyle(color: Color(0xFFF5F5F5), fontSize: 14, fontWeight: FontWeight.w500),
                                    ),
                                    Text(
                                      '$numberOfAyahs Ayat', 
                                      style: const TextStyle(color: Color(0xFFF5F5F5), fontSize: 14, fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                if (bismillahPre != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 20.0),
                                    child: Text(
                                      bismillahPre,
                                      style: const TextStyle(fontFamily: 'LPMQ', fontSize: 28, color: Color(0xFFF5F5F5)),
                                      textDirection: TextDirection.rtl, 
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                    final String verseNumber = index.toString(); 
                    final String arab = arabicText[verseNumber] ?? 'Teks tidak ditemukan';
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      child: Row( 
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 40, 
                            child: Stack( 
                              alignment: Alignment.center,
                              children: [
                                Image.asset( 
                                  'assets/images/ornamenayat1.png', 
                                  width: 36, height: 36,
                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.circle_outlined, color: Color(0xFF4DB6AC), size: 36), 
                                ),
                                Text(verseNumber, style: const TextStyle(color: Color(0xFFF5F5F5), fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16), 
                          Expanded( 
                            child: Text(
                              arab,
                              textAlign: TextAlign.right,
                              style: const TextStyle(fontSize: 28, fontFamily: 'LPMQ', color: Color(0xFFF5F5F5), height: 1.8),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}