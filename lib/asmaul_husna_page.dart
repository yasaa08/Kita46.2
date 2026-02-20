// lib/asmaul_husna_page.dart
// VERSI KARTU INTERAKTIF (HANYA ARTI, TANPA CONTOH)

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AsmaulHusnaPage extends StatefulWidget {
  const AsmaulHusnaPage({super.key});

  @override
  State<AsmaulHusnaPage> createState() => _AsmaulHusnaPageState();
}

class _AsmaulHusnaPageState extends State<AsmaulHusnaPage> {
  List _asmaulHusna = [];
  bool _isLoading = true;

  // Method baca JSON (tidak berubah)
  Future<void> readJson() async {
    try {
      final String response = await rootBundle.loadString('assets/Asmaul husna/asmaul_husna.json');
      final data = await json.decode(response);
      setState(() {
        _asmaulHusna = data;
        _isLoading = false;
      });
    } catch (e) {
      print("Error reading Asmaul Husna JSON: $e");
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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Asmaul Husna'),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : GridView.builder(
              padding: const EdgeInsets.all(12.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, 
                crossAxisSpacing: 12.0,
                mainAxisSpacing: 12.0,
                // Rasio mungkin bisa sedikit lebih kecil karena konten detail berkurang
                childAspectRatio: 1.0, // Coba 1.0
              ),
              itemCount: _asmaulHusna.length,
              itemBuilder: (context, index) {
                final item = _asmaulHusna[index];
                return AsmaulHusnaCard(itemData: item);
              },
            ),
    );
  }
}

// ================== WIDGET KARTU INTERAKTIF ==================
class AsmaulHusnaCard extends StatefulWidget {
  final Map<String, dynamic> itemData; 

  const AsmaulHusnaCard({super.key, required this.itemData});

  @override
  State<AsmaulHusnaCard> createState() => _AsmaulHusnaCardState();
}

class _AsmaulHusnaCardState extends State<AsmaulHusnaCard> {
  bool _isExpanded = false; 

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1F1F1F), 
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      clipBehavior: Clip.antiAlias, 
      child: InkWell( 
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded; 
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0), 
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start, 
            crossAxisAlignment: CrossAxisAlignment.stretch, 
            children: [
              // --- Tampilan Awal (Selalu Tampil) ---
              Text(
                widget.itemData['arabic'],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'LPMQ',
                  fontSize: 20, 
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.itemData['latin'],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12, 
                  color: Colors.grey,
                ),
              ),

              // --- Tampilan Detail (Hanya Arti) ---
              AnimatedSize(
                duration: const Duration(milliseconds: 300), 
                curve: Curves.easeInOut, 
                child: _isExpanded 
                    ? Padding(
                        padding: const EdgeInsets.only(top: 12.0), 
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Divider(color: Colors.grey.shade700), 
                            const SizedBox(height: 8),
                            // 1. Arti
                            const Text(
                              'Arti:',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.tealAccent, fontSize: 12),
                            ),
                            Text(
                              widget.itemData['translation_id'],
                              style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.white70, fontSize: 12),
                            ),
                           
                            // BAGIAN CONTOH SUDAH DIHAPUS DARI SINI

                          ],
                        ),
                      )
                    : const SizedBox.shrink(), 
              ),
            ],
          ),
        ),
      ),
    );
  }
}