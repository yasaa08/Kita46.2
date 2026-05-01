import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  List<Map<String, String>> _verses = [];
  bool _isLoading = true;

  final sageColor = const Color(0xFFB2C8BA);
  final surfaceColor = const Color(0xFF242822);
  final bgColor = const Color(0xFF1A1C19);

  Future<void> readJson() async {
    try {
      // Load file JSON sesuai nomor surah[cite: 9]
      final String response = await rootBundle.loadString('assets/surah/${widget.surahNumber}.json');
      final data = await json.decode(response);
      final surahData = data[widget.surahNumber.toString()];

      if (surahData != null) {
        final Map<String, dynamic> textMap = surahData['text'] ?? {};
        final Map<String, dynamic> translationMap = surahData['translations']?['id']?['text'] ?? {};

        List<Map<String, String>> parsedVerses = [];
        int numAyahs = int.tryParse(surahData['number_of_ayah'].toString()) ?? 0;
        
        // Parsing data ayat dari JSON[cite: 9]
        for (int i = 1; i <= numAyahs; i++) {
          String key = i.toString();
          parsedVerses.add({
            'verseNumber': key,
            'arab': textMap[key] ?? '',
            'translation': translationMap[key] ?? 'Terjemahan tidak tersedia',
          });
        }

        setState(() {
          _verses = parsedVerses;
          _isLoading = false;
        });
        
        // Simpan surahnya saja dulu saat baru buka halaman[cite: 9]
        _saveLastRead(0); 
      }
    } catch (e) {
      debugPrint("Error reading surah JSON: $e");
      setState(() => _isLoading = false);
    }
  }

  // FIXED: Fungsi simpan progres menggunakan .set(merge: true)[cite: 9]
  Future<void> _saveLastRead(int ayahNumber) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null && !user.isAnonymous) {
    try {
      // Kunci utama agar tidak error "NOT_FOUND": gunakan .set dengan merge: true[cite: 9]
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'last_read_surah': {
          'name': widget.surahName,
          'number': widget.surahNumber,
          'ayah': ayahNumber,
        }
      }, SetOptions(merge: true)); 
    } catch (e) {
      debugPrint("Error Save: $e");
    }
  }
}

  @override
  void initState() {
    super.initState();
    readJson();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Detail Surah', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18)),
        backgroundColor: bgColor,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: sageColor))
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 40),
              itemCount: _verses.length + 2,
              itemBuilder: (context, index) {
                // Header Surah[cite: 9]
                if (index == 0) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Column(
                      children: [
                        Text(widget.surahName, style: TextStyle(fontSize: 28, color: sageColor, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('Surah ke-${widget.surahNumber} • ${widget.revelation}',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14)),
                      ],
                    ),
                  );
                }

                // Tampilan Bismillah[cite: 9]
                if (index == 1) {
                  if (widget.surahNumber == 1 || widget.surahNumber == 9) return const SizedBox(height: 16);
                  return Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 32),
                    child: Center(
                      child: Text("بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيم",
                          style: TextStyle(fontFamily: 'LPMQ', fontSize: 26, color: sageColor)),
                    ),
                  );
                }

                // Daftar Ayat dengan fitur klik untuk simpan riwayat[cite: 9]
                final verse = _verses[index - 2];
                final verseNumber = verse['verseNumber']!;
                
                return InkWell(
                  onTap: () => _saveLastRead(int.parse(verseNumber)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundColor: sageColor.withValues(alpha: 0.15),
                          radius: 18,
                          child: Text(verseNumber,
                              style: TextStyle(color: sageColor, fontSize: 13, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(verse['arab']!,
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(fontSize: 28, fontFamily: 'LPMQ', color: Colors.white, height: 1.8)),
                              const SizedBox(height: 12),
                              Text(verse['translation']!,
                                  style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.7), height: 1.5)),
                              const SizedBox(height: 16),
                              Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}