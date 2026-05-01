import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'detail_doa_page.dart'; 

class KumpulanDoaPage extends StatefulWidget {
  const KumpulanDoaPage({super.key});

  @override
  State<KumpulanDoaPage> createState() => _KumpulanDoaPageState();
}

class _KumpulanDoaPageState extends State<KumpulanDoaPage> {
  List _listDoa = [];

  final sageColor = const Color(0xFFB2C8BA);
  final surfaceColor = const Color(0xFF242822);
  final bgColor = const Color(0xFF1A1C19);

  Future<void> readJson() async {
    final String response = await rootBundle.loadString('assets/kumpulan doa/kumpulan_doa.json');
    final data = await json.decode(response);
    setState(() => _listDoa = data);
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
        title: const Text('Kumpulan Doa', style: TextStyle(fontWeight: FontWeight.w400)),
        backgroundColor: bgColor,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
      ),
      body: _listDoa.isEmpty
          ? Center(child: CircularProgressIndicator(color: sageColor))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              itemCount: _listDoa.length,
              itemBuilder: (context, index) {
                final item = _listDoa[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DetailDoaPage(doaData: item)),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: surfaceColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: sageColor.withValues(alpha: 0.15),
                          radius: 20,
                          child: Icon(Icons.clean_hands_outlined, color: sageColor, size: 20),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            item['title'] ?? 'Judul Doa',
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