// lib/asmaul_husna_page.dart

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

  // Palet Warna Khas Pixel
  final sageColor = const Color(0xFFB2C8BA);
  final surfaceColor = const Color(0xFF242822);
  final bgColor = const Color(0xFF1A1C19);

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
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Asmaul Husna', style: TextStyle(fontWeight: FontWeight.w400)),
        backgroundColor: bgColor,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: sageColor))
          : GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, 
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 1.0, 
              ),
              itemCount: _asmaulHusna.length,
              itemBuilder: (context, index) {
                final item = _asmaulHusna[index];
                
                // ANIMASI: Membungkus kartu agar muncul bergantian (staggered)
                return TweenAnimationBuilder(
                  // Efek delay berdasarkan index agar muncul satu-persatu
                  duration: Duration(milliseconds: 300 + (index % 10 * 100)),
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  builder: (context, double value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.scale(
                        scale: 0.8 + (0.2 * value), // Membesar dari 0.8 ke 1.0
                        child: child,
                      ),
                    );
                  },
                  child: AsmaulHusnaCard(itemData: item),
                );
              },
            ),
    );
  }
}

class AsmaulHusnaCard extends StatelessWidget {
  final Map<String, dynamic> itemData; 

  const AsmaulHusnaCard({super.key, required this.itemData});

  void _showDetailBottomSheet(BuildContext context) {
    final sageColor = const Color(0xFFB2C8BA);
    final surfaceColor = const Color(0xFF242822);

    showModalBottomSheet(
      context: context,
      backgroundColor: surfaceColor,
      isScrollControlled: true, 
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 40.0, top: 12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                itemData['arabic'],
                style: TextStyle(
                  fontFamily: 'LPMQ', 
                  fontSize: 36, 
                  color: sageColor,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                itemData['latin'],
                style: const TextStyle(
                  fontSize: 18, 
                  color: Colors.white, 
                  fontWeight: FontWeight.bold
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1C19), 
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text(
                      'Arti:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600, 
                        color: sageColor, 
                        fontSize: 14
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      itemData['translation_id'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70, 
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final sageColor = const Color(0xFFB2C8BA);
    final surfaceColor = const Color(0xFF242822);

    return Material(
      color: surfaceColor, 
      borderRadius: BorderRadius.circular(24), 
      clipBehavior: Clip.antiAlias, 
      child: InkWell( 
        onTap: () => _showDetailBottomSheet(context), 
        child: Padding(
          padding: const EdgeInsets.all(16.0), 
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, 
            crossAxisAlignment: CrossAxisAlignment.stretch, 
            children: [
              Text(
                itemData['arabic'],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'LPMQ',
                  fontSize: 26, 
                  color: sageColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                itemData['latin'],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13, 
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}