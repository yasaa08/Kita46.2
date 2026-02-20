// lib/daftar_surah_page.dart
// VERSI BARU DENGAN SEARCH BAR & DESAIN LIST TILE BARU

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'detail_surah_page.dart';

class DaftarSurahPage extends StatefulWidget {
  const DaftarSurahPage({super.key});

  @override
  State<DaftarSurahPage> createState() => _DaftarSurahPageState();
}

class _DaftarSurahPageState extends State<DaftarSurahPage> {
  List _allSurah = [];        // Menyimpan semua data surah asli
  List _filteredSurah = [];  // Menyimpan data surah yang sudah difilter
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  // Method untuk membaca data JSON
  Future<void> readJson() async {
    try {
      final String response = await rootBundle.loadString('assets/list_surah.json');
      final data = await json.decode(response);
      setState(() {
        _allSurah = data;
        _filteredSurah = _allSurah; // Awalnya, tampilkan semua
        _isLoading = false;
      });
    } catch (e) {
      print("Error reading list_surah JSON: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Method untuk filter surah berdasarkan input pencarian
  void _filterSurah(String query) {
    List results = [];
    if (query.isEmpty) {
      results = _allSurah; // Jika kosong, tampilkan semua
    } else {
      results = _allSurah.where((surah) {
        final nameLower = surah['name'].toString().toLowerCase();
        final searchLower = query.toLowerCase();
        return nameLower.contains(searchLower);
      }).toList();
    }
    setState(() {
      _filteredSurah = results;
    });
  }

  @override
  void initState() {
    super.initState();
    readJson();
    // Tambahkan listener ke search controller
    _searchController.addListener(() {
      _filterSurah(_searchController.text);
    });
  }

  // Jangan lupa dispose controller saat widget dihapus
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Background hitam
      appBar: AppBar(
        title: const Text('Daftar Surah'),
        backgroundColor: Colors.black, // AppBar hitam
        elevation: 0, // Hilangkan bayangan AppBar
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : Column( // Kita bungkus dengan Column
              children: [
                // ================== SEARCH BAR ==================
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white), // Warna teks input
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF1F1F1F), // #1F1F1F Abu gelap
                      hintText: 'Cari Surah...',
                      hintStyle: const TextStyle(color: Color(0xFF9E9E9E)), // #9E9E9E Abu
                      prefixIcon: const Icon(
                        Icons.search, 
                        color: Color(0xFF9E9E9E) // #9E9E9E Abu
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0), // Membulat penuh
                        borderSide: BorderSide.none, // Tanpa border luar
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                    ),
                  ),
                ),
                
                // ================== LIST VIEW ==================
                Expanded( // Agar ListView mengisi sisa ruang
                  child: ListView.separated( // Menggunakan separated untuk pemisah
                    itemCount: _filteredSurah.length, // Gunakan list yang sudah difilter
                    itemBuilder: (context, index) {
                      final surah = _filteredSurah[index];
                      return ListTile(
                        // --- Lingkaran Nomor ---
                        leading: CircleAvatar(
                          radius: 20, // Sesuai spek
                          backgroundColor: const Color(0xFF00796B), // #00796B Teal
                          child: Text(
                            surah["number"].toString(),
                            style: const TextStyle(
                              color: Colors.white, // #FFFFFF
                              fontSize: 14,
                            ),
                          ),
                        ),
                        // --- Teks Judul (Nama Surah) ---
                        title: Text(
                          surah["name"],
                          style: const TextStyle(
                            color: Colors.white, // #FFFFFF
                            fontSize: 16,
                            fontWeight: FontWeight.w500, // Medium
                          ),
                        ),
                        // --- Teks Subtitle (Keterangan) ---
                        subtitle: Text(
                          '${surah["revelation"]} - ${surah["numberOfAyahs"]} Ayat',
                          style: const TextStyle(
                            color: Color(0xFFBDBDBD), // #BDBDBD Abu terang
                            fontSize: 14,
                          ),
                        ),
                        onTap: () {
                          // Navigasi ke Halaman Detail (tidak berubah)
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailSurahPage(
                                surahNumber: surah["number"],
                                surahName: surah["name"], revelation: '',
                              ) as Widget,
                            ),
                          );
                        },
                      );
                    },
                    // --- Pemisah (Divider) ---
                    separatorBuilder: (context, index) => const Divider(
                      color: Color(0xFF1F1F1F), // #1F1F1F Abu gelap
                      thickness: 1,
                      height: 1, // Penting agar tidak terlalu tebal
                      indent: 72, // Agar sejajar dengan teks (lebar CircleAvatar + padding)
                      endIndent: 16,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}