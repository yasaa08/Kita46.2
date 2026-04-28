// lib/pr13_detail_page.dart
import 'package:flutter/material.dart';
import 'database_service.dart'; // <--- TAMBAHKAN INI

class Pr13DetailPage extends StatefulWidget {
  final Map<String, dynamic> doaData;

  const Pr13DetailPage({super.key, required this.doaData});

  @override
  State<Pr13DetailPage> createState() => _Pr13DetailPageState();
}

class _Pr13DetailPageState extends State<Pr13DetailPage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _saveCount() {
    // Fungsi ini sekarang bisa dipanggil karena import sudah ada
    DatabaseService().saveLastDzikir(
      category: 'PR 13',
      title: widget.doaData['title'] ?? 'Doa',
      counter: _counter,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Hitungan $_counter disimpan ke Cloud!')),
    );
  }
  
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
          IconButton(icon: const Icon(Icons.refresh), tooltip: 'Reset', onPressed: _resetCounter),
          IconButton(icon: const Icon(Icons.save_alt), tooltip: 'Simpan', onPressed: _saveCount),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (arabic.isNotEmpty)
              Text(arabic, textAlign: TextAlign.right, style: const TextStyle(fontFamily: 'LPMQ', fontSize: 28, color: Colors.white, height: 1.8)),
            const SizedBox(height: 16),
            if (latin.isNotEmpty)
              Text(latin, style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey.shade400, fontSize: 16)),
            const SizedBox(height: 16),
            if (translation.isNotEmpty)
              Text(translation, style: const TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 24),
            if (notes.isNotEmpty)
              Container(
                 padding: const EdgeInsets.all(12.0),
                 decoration: BoxDecoration(color: Colors.grey.shade900, borderRadius: BorderRadius.circular(8)),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                      const Text('Keterangan:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.tealAccent, fontSize: 14)),
                      const SizedBox(height: 8),
                      Text(notes, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                   ],
                 ),
              )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: _incrementCounter,
        backgroundColor: Colors.teal,
        child: Text(_counter.toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}