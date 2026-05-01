import 'package:flutter/material.dart';

class DetailDoaPage extends StatelessWidget {
  final Map<String, dynamic> doaData;

  const DetailDoaPage({super.key, required this.doaData});

  @override
  Widget build(BuildContext context) {
    // Palet Warna Khas Pixel
    final sageColor = const Color(0xFFB2C8BA);
    final surfaceColor = const Color(0xFF242822);
    final bgColor = const Color(0xFF1A1C19);

    final String title = doaData['title'] ?? 'Detail Doa';
    final String arabic = doaData['arabic'] ?? '';
    final String latin = doaData['latin'] ?? '';
    final String translation = doaData['translation'] ?? '';
    final String notes = doaData['notes'] ?? '';

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 18)),
        backgroundColor: bgColor,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (arabic.isNotEmpty)
              Text(
                arabic,
                textAlign: TextAlign.right,
                style: TextStyle(fontFamily: 'LPMQ', fontSize: 32, color: sageColor, height: 1.8),
              ),
            const SizedBox(height: 24),
            if (latin.isNotEmpty)
              Text(
                latin,
                style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500),
              ),
            const SizedBox(height: 12),
            if (translation.isNotEmpty)
              Text(
                translation,
                style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.5),
              ),
            const SizedBox(height: 32),
            if (notes.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(20),
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
                    Text(
                      notes,
                      style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.6),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}