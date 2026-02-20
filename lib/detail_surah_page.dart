// lib/detail_surah_page.dart
// VERSI BARU - INFO SURAH BARU + EFEK SCROLL HILANG + FIX NOMOR AYAT

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    // ... (Fungsi readJson tidak berubah) ...
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
  }

  @override
  Widget build(BuildContext context) {
    final int numberOfAyahs = int.tryParse(_surahData['number_of_ayah'] ?? '0') ?? 0;
    final Map<String, dynamic> arabicText = _surahData['text'] ?? {};
    final String translatedName = _surahData['translations']?['id']?['name'] ?? widget.surahName; 
    final String? bismillahPre = _surahData['preBismillah']?['text']?['arab'];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.surahName),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [ 
          IconButton(icon: const Icon(Icons.play_circle_outline), onPressed: () {}),
          IconButton(icon: const Icon(Icons.bookmark_border), onPressed: () {}),
          IconButton(icon: const Icon(Icons.share), onPressed: () {}),
        ],
      ),
      // BODY SEKARANG LANGSUNG LISTVIEW
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : numberOfAyahs == 0 
              ? const Center(child: Text('Gagal memuat data ayat.'))
              : ListView.builder(
                  // Jumlah item = Jumlah ayat + 1 (untuk bagian info di atas)
                  itemCount: numberOfAyahs + 1, 
                  itemBuilder: (context, index) {
                    
                    // ============ ITEM PERTAMA (INDEX 0): BAGIAN INFO SURAH ============
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Card(
                          color: const Color(0xFF1F1F1F), // Abu gelap
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0), // Padding lebih besar
                            child: Column(
                              children: [
                                // --- Baris Info Atas ---
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Jaga jarak
                                  children: [
                                    // Oval Juz (Placeholder)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        // color: Colors.teal.shade700, // Warna oval
                                        borderRadius: BorderRadius.circular(20), // Bentuk lonjong
                                        border: Border.all(color: Colors.teal.shade300, width: 1),
                                      ),
                                      child: Text( 
                                        // Ambil nomor Juz dari contekan berdasarkan nomor surah
                                        'Juz ${surahToJuzMap[widget.surahNumber] ?? '?'}', 
                                        style: const TextStyle(color: Colors.white, fontSize: 12),
                                      ),
                                    ),
                                    
                                    // Nama Terjemahan
                                    Text(
                                      translatedName, 
                                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                                    ),
                                    
                                    // Jumlah Ayat
                                    Text(
                                      '$numberOfAyahs Ayat', 
                                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),

                                // --- Bismillah (jika ada) ---
                                if (bismillahPre != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 20.0), // Jarak lebih besar
                                    child: Text(
                                      bismillahPre,
                                      style: const TextStyle(
                                        fontFamily: 'LPMQ',
                                        fontSize: 28, // Perbesar Bismillah
                                        color: Colors.white,
                                      ),
                                      textDirection: TextDirection.rtl, 
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    // ============ ITEM SELANJUTNYA (INDEX > 0): AYAT-AYAT ============
                    // Nomor ayat asli = index (karena index 0 sudah dipakai info)
                    final String verseNumber = index.toString(); 
                    final String arab = arabicText[verseNumber] ?? 'Teks tidak ditemukan';

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      child: Row( 
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- Nomor Ayat dengan Ornament ---
                          SizedBox(
                            width: 40, 
                            child: Stack( 
                              alignment: Alignment.center,
                              children: [
                                // 1. Gambar Ornamen
                                Image.asset( 
                                  'assets/images/ornamenayat1.png', 
                                  width: 36, 
                                  height: 36,
                                  errorBuilder: (context, error, stackTrace) => 
                                    const Icon(Icons.circle_outlined, color: Colors.teal, size: 36), 
                                ),
                                // 2. Teks Nomor Ayat (di atas ornamen)
                                Text(
                                  verseNumber,
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 255, 255, 255), // Coba Hitam agar kontras
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16), 
                          
                          // --- Teks Arab ---
                          Expanded( 
                            child: Text(
                              arab,
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontSize: 28, 
                                fontFamily: 'LPMQ',
                                color: Colors.white, 
                                height: 1.8, 
                              ),
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

// Widget InfoChip tidak dipakai lagi, bisa dihapus atau di-comment
/*
class InfoChip extends StatelessWidget {
  // ...
}
*/