import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'detail_sholat_page.dart';

class SholatSunnahPage extends StatefulWidget {
  const SholatSunnahPage({super.key});

  @override
  State<SholatSunnahPage> createState() => _SholatSunnahPageState();
}

class _SholatSunnahPageState extends State<SholatSunnahPage> {
  List _listSholat = [];

  // Palet Warna
  final sageColor = const Color(0xFFB2C8BA);
  final surfaceColor = const Color(0xFF242822);
  final bgColor = const Color(0xFF1A1C19);

  Future<void> readJson() async {
    final String response = await rootBundle.loadString('assets/Sholat sunnah/Sholatsunnah.json');
    final data = await json.decode(response);
    setState(() => _listSholat = data);
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
        title: const Text('Sholat Sunnah', style: TextStyle(fontWeight: FontWeight.w400)),
        backgroundColor: bgColor,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
      ),
      body: _listSholat.isEmpty
          ? Center(child: CircularProgressIndicator(color: sageColor))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              itemCount: _listSholat.length,
              itemBuilder: (context, index) {
                final item = _listSholat[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DetailSholatPage(sholatData: item)),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: surfaceColor, // Warna Card
                      foregroundColor: Colors.white,
                      elevation: 0, // Datar (tanpa bayangan keras)
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), // Lengkungan Pixel
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: sageColor.withValues(alpha: 0.15),
                          radius: 20,
                          child: Icon(Icons.wb_sunny_outlined, color: sageColor, size: 20),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            item['title'] ?? 'Nama Sholat',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.white24),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}