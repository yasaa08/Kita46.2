// lib/pr13_page.dart
// VERSI BARU - LIST BIASA, PINDAH KE HALAMAN DETAIL

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pr13_detail_page.dart'; // Import halaman detail baru

class Pr13Page extends StatefulWidget {
  const Pr13Page({super.key});

  @override
  State<Pr13Page> createState() => _Pr13PageState();
}

class _Pr13PageState extends State<Pr13Page> {
  List _pr13List = [];
  bool _isLoading = true;

  // Method baca JSON (tidak berubah)
  Future<void> readJson() async {
    try {
      final String response = await rootBundle.loadString('assets/PR 13/pr13.json');
      final data = await json.decode(response);
      setState(() {
        _pr13List = data;
        _isLoading = false;
      });
    } catch (e) {
      print("Error reading Kumpulan Doa JSON: $e");
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
        title: const Text('PR 13'),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          // Gunakan ListView.separated untuk garis pemisah
          : ListView.separated( 
              padding: const EdgeInsets.symmetric(vertical: 12.0), // Padding atas bawah list
              itemCount: _pr13List.length,
              itemBuilder: (context, index) {
                final doa = _pr13List[index];

                // Gunakan ListTile di dalam Card (atau langsung ListTile)
                return ListTile(
                  title: Text(
                    doa['title'] ?? 'PR-${doa['id']}', // Tampilkan "PR-X"
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey), // Panah ke kanan
                  onTap: () {
                    // Pindah ke halaman detail saat di-klik
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Pr13DetailPage(doaData: doa), // Kirim data 'doa'
                      ),
                    );
                  },
                );
              },
              // Garis pemisah antar item
              separatorBuilder: (context, index) => const Divider(
                color: Color(0xFF1F1F1F), 
                thickness: 1,
                height: 1,
                indent: 16, // Sesuaikan indent
                endIndent: 16,
              ),
            ),
    );
  }
}