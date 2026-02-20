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
      setState(() {
        _isLoading = false;
      });
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
    setState(() {
      _filteredSurah = results;
    });
  }

  @override
  void initState() {
    super.initState();
    readJson();
    _searchController.addListener(() {
      _filterSurah(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), 
      appBar: AppBar(
        title: const Text('Daftar Surah', style: TextStyle(color: Color(0xFFF5F5F5))),
        iconTheme: const IconThemeData(color: Color(0xFFF5F5F5)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4DB6AC)))
          : Column( 
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Color(0xFFF5F5F5)), 
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF1E1E1E), 
                      hintText: 'Cari Surah...',
                      hintStyle: const TextStyle(color: Color(0xFFA0A0A0)), 
                      prefixIcon: const Icon(
                        Icons.search, 
                        color: Color(0xFFA0A0A0)
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0), 
                        borderSide: BorderSide.none, 
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                    ),
                  ),
                ),
                Expanded( 
                  child: ListView.separated( 
                    itemCount: _filteredSurah.length, 
                    itemBuilder: (context, index) {
                      final surah = _filteredSurah[index];
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 20, 
                          backgroundColor: const Color(0xFF1E1E1E), // Soft dark
                          child: Text(
                            surah["number"].toString(),
                            style: const TextStyle(
                              color: Color(0xFF4DB6AC), // Teks nomor warna Soft Teal
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          surah["name"],
                          style: const TextStyle(
                            color: Color(0xFFF5F5F5), 
                            fontSize: 16,
                            fontWeight: FontWeight.w500, 
                          ),
                        ),
                        subtitle: Text(
                          '${surah["revelation"]} - ${surah["numberOfAyahs"]} Ayat',
                          style: const TextStyle(
                            color: Color(0xFFA0A0A0), 
                            fontSize: 14,
                          ),
                        ),
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
                    separatorBuilder: (context, index) => const Divider(
                      color: Color(0xFF2C2C2C), // Garis pemisah soft
                      thickness: 1,
                      height: 1, 
                      indent: 72, 
                      endIndent: 16,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}