// lib/pr13_detail_page.dart
import 'package:flutter/material.dart';

class Pr13DetailPage extends StatefulWidget {
  final Map<String, dynamic> doaData; // Menerima data doa dari halaman list

  const Pr13DetailPage({super.key, required this.doaData});

  @override
  State<Pr13DetailPage> createState() => _Pr13DetailPageState();
}

class _Pr13DetailPageState extends State<Pr13DetailPage> {
  int _counter = 0; // State untuk menyimpan hitungan

  // Fungsi untuk menambah counter
  void _incrementCounter() {
    setState(() {
      _counter++;
      // Di sini nanti bisa ditambahkan logika untuk limit (misal 100x) jika diperlukan
    });
  }

  // Fungsi untuk menyimpan (saat ini hanya print)
  void _saveCount() {
    // Di sini nanti kita tambahkan logika penyimpanan (misal pakai shared_preferences)
    print('Hitungan disimpan: $_counter untuk ${widget.doaData['title']}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Hitungan $_counter disimpan!')),
    );
  }
  
  // Fungsi untuk reset counter
  void _resetCounter() {
     setState(() {
      _counter = 0; 
    });
     ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Hitungan direset!')),
    );
  }


  @override
  Widget build(BuildContext context) {
    // Ambil data dari map yang dikirim
    final String title = widget.doaData['title'] ?? 'Detail Doa';
    final String arabic = widget.doaData['arabic'] ?? '';
    final String latin = widget.doaData['latin'] ?? '';
    final String translation = widget.doaData['translation'] ?? '';
    final String notes = widget.doaData['notes'] ?? '';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          // Tombol Reset di AppBar
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset Hitungan',
            onPressed: _resetCounter,
          ),
          // Tombol Simpan di AppBar
          IconButton(
            icon: const Icon(Icons.save_alt),
            tooltip: 'Simpan Hitungan',
            onPressed: _saveCount,
          ),
        ],
      ),
      body: SingleChildScrollView( // Agar bisa di-scroll jika konten panjang
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, // Rata kiri-kanan
          children: [
            // Teks Arab
            if (arabic.isNotEmpty)
              Text(
                arabic,
                textAlign: TextAlign.right,
                style: const TextStyle(
                    fontFamily: 'LPMQ', fontSize: 28, color: Colors.white, height: 1.8),
              ),
            const SizedBox(height: 16),

            // Teks Latin
            if (latin.isNotEmpty)
              Text(
                latin,
                style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey.shade400, fontSize: 16),
              ),
            const SizedBox(height: 16),

            // Terjemahan
            if (translation.isNotEmpty)
              Text(
                translation,
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
            const SizedBox(height: 24), // Jarak lebih besar sebelum keterangan

            // Keterangan / Notes
            if (notes.isNotEmpty)
              Container( // Beri sedikit background biar beda
                 padding: const EdgeInsets.all(12.0),
                 decoration: BoxDecoration(
                   color: Colors.grey.shade900,
                   borderRadius: BorderRadius.circular(8)
                 ),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                      const Text(
                        'Keterangan:',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.tealAccent, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        notes,
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                   ],
                 ),
              )
          ],
        ),
      ),

      // ================== FLOATING ACTION BUTTON (COUNTER) ==================
      floatingActionButton: FloatingActionButton.small( // Pakai .small biar kecil
        onPressed: _incrementCounter,
        tooltip: 'Tambah Hitungan',
        backgroundColor: Colors.teal, // Warna tombol
        child: Text(
          _counter.toString(), // Tampilkan angka counter
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      // Atur posisi FAB (opsional, bisa diubah)
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat, 
    );
  }
}