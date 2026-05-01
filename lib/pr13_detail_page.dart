import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Pr13DetailPage extends StatefulWidget {
  final Map<String, dynamic> doaData;
  final int? initialCount;

  const Pr13DetailPage({super.key, required this.doaData, this.initialCount});

  @override
  State<Pr13DetailPage> createState() => _Pr13DetailPageState();
}

class _Pr13DetailPageState extends State<Pr13DetailPage> {
  int _counter = 0;
  // Variabel untuk mengatur skala animasi tombol
  double _buttonScale = 1.0;

  @override
  void initState() {
    super.initState();
    // Set counter ke angka terakhir yang disimpan, jika tidak ada baru 0[cite: 8]
    _counter = widget.initialCount ?? 0; 
  }

  // Palet Warna Khas Pixel
  final sageColor = const Color(0xFFB2C8BA);
  final surfaceColor = const Color(0xFF242822);
  final bgColor = const Color(0xFF1A1C19);

  // LOGIKA HITUNG + ANIMASI BOUNCE[cite: 8]
  void _incrementCounter() {
    setState(() {
      _counter++;
      _buttonScale = 0.92; // Tombol mengecil saat ditekan
    });

    // Mengembalikan ukuran tombol ke normal setelah 100 milidetik
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _buttonScale = 1.0;
        });
      }
    });
  }

  // Fungsi save ke cloud Firestore[cite: 8]
  Future<void> _saveCount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final String title = widget.doaData['title'] ?? 'Doa';
      try {
        final firestore = FirebaseFirestore.instance;

        // 1. Simpan ke sub-collection pr13_progress[cite: 8]
        await firestore
            .collection('users')
            .doc(user.uid)
            .collection('pr13_progress')
            .doc(title)
            .set({
          'count': _counter,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // 2. Simpan ringkasan ke dokumen utama biar muncul di Home[cite: 8]
        // Note: Gunakan .set(merge: true) jika dokumen user belum tentu ada
        await firestore.collection('users').doc(user.uid).update({
          'last_pr13_title': title,
          'last_pr13_count': _counter,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$title: $_counter berhasil disimpan!'),
              backgroundColor: sageColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          );
        }
      } catch (e) {
        print("Error Save: $e");
      }
    }
  }
  
  void _resetCounter() {
    setState(() {
      _counter = 0; 
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Hitungan direset!'),
        backgroundColor: surfaceColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
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
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 18)),
        backgroundColor: bgColor,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: Colors.white.withValues(alpha: 0.6)), 
            tooltip: 'Reset', 
            onPressed: _resetCounter
          ),
          IconButton(
            icon: Icon(Icons.save_rounded, color: sageColor), 
            tooltip: 'Simpan', 
            onPressed: _saveCount
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // BAGIAN ATAS: TEKS DOA (Bisa di-scroll)[cite: 8]
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (arabic.isNotEmpty)
                    Text(
                      arabic, 
                      textAlign: TextAlign.right, 
                      style: TextStyle(fontFamily: 'LPMQ', fontSize: 32, color: sageColor, height: 1.8)
                    ),
                  const SizedBox(height: 24),
                  if (latin.isNotEmpty)
                    Text(
                      latin, 
                      style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500)
                    ),
                  const SizedBox(height: 12),
                  if (translation.isNotEmpty)
                    Text(
                      translation, 
                      style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.5)
                    ),
                  const SizedBox(height: 32),
                  if (notes.isNotEmpty)
                    Container(
                       padding: const EdgeInsets.all(20.0),
                       decoration: BoxDecoration(
                         color: surfaceColor, 
                         borderRadius: BorderRadius.circular(24),
                         border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                       ),
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                            Row(
                              children: [
                                Icon(Icons.info_outline_rounded, color: sageColor, size: 20),
                                const SizedBox(width: 8),
                                Text('Keterangan:', style: TextStyle(fontWeight: FontWeight.bold, color: sageColor, fontSize: 14)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(notes, style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5)),
                         ],
                       ),
                    )
                ],
              ),
            ),
          ),

          // BAGIAN BAWAH: COUNTER RAKSASA DENGAN ANIMASI[cite: 8]
          Container(
            padding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 40),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                )
              ]
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Tap di mana saja untuk menghitung", 
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12)
                ),
                const SizedBox(height: 16),
                
                // PEMBUNGKUS ANIMASI BOUNCE[cite: 8]
                AnimatedScale(
                  scale: _buttonScale, 
                  duration: const Duration(milliseconds: 100),
                  curve: Curves.easeOut,
                  child: Material(
                    color: sageColor,
                    borderRadius: BorderRadius.circular(40),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: _incrementCounter,
                      child: Container(
                        width: double.infinity,
                        height: 140, 
                        alignment: Alignment.center,
                        child: Text(
                          '$_counter',
                          style: TextStyle(
                            fontSize: 64, 
                            fontWeight: FontWeight.bold, 
                            color: bgColor, 
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}