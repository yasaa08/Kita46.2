// lib/daftar_surah_page.dart
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
  List _allSurah = [];        
  List _filteredSurah = [];  
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  // Palet Warna
  final sageColor = const Color(0xFFB2C8BA);
  final surfaceColor = const Color(0xFF242822);
  final bgColor = const Color(0xFF1A1C19);

  Future<void> readJson() async {
    try {
      final String response = await rootBundle.loadString('assets/list_surah.json');
      final data = await json.decode(response);
      setState(() {
        _allSurah = data;
        _filteredSurah = _allSurah; 
        _isLoading = false;
      });
    } catch (e) {
      print("Error reading list_surah JSON: $e");
      setState(() => _isLoading = false);
    }
  }

  void _filterSurah(String query) {
    List results = [];
    if (query.isEmpty) {
      results = _allSurah; 
    } else {
      results = _allSurah.where((surah) {
        final nameLower = surah['name'].toString().toLowerCase();
        final searchLower = query.toLowerCase();
        return nameLower.contains(searchLower);
      }).toList();
    }
    setState(() => _filteredSurah = results);
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
    return Scaffold(
      backgroundColor: bgColor, 
      appBar: AppBar(
        title: const Text('Daftar Surah', style: TextStyle(fontWeight: FontWeight.w400)),
        backgroundColor: bgColor,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: sageColor))
          : Column( 
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white), 
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: surfaceColor, // Warna kotak pencarian
                      hintText: 'Cari Surah...',
                      hintStyle: const TextStyle(color: Colors.white38), 
                      prefixIcon: const Icon(Icons.search, color: Colors.white38),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0), 
                        borderSide: BorderSide.none, 
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded( 
                  child: ListView.separated( 
                    itemCount: _filteredSurah.length, 
                    itemBuilder: (context, index) {
                      final surah = _filteredSurah[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                        leading: CircleAvatar(
                          radius: 22, 
                          backgroundColor: sageColor.withValues(alpha: 0.15), // Background nomor surah
                          child: Text(
                            surah["number"].toString(),
                            style: TextStyle(color: sageColor, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(
                          surah["name"],
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          '${surah["revelation"]} • ${surah["numberOfAyahs"]} Ayat',
                          style: const TextStyle(color: Colors.white54, fontSize: 13),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white12, size: 14),
                        onTap: () {
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
                    separatorBuilder: (context, index) => Divider(
                      color: Colors.white.withValues(alpha: 0.05), // Garis pemisah sangat tipis
                      height: 1, 
                      indent: 76, 
                      endIndent: 20,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}