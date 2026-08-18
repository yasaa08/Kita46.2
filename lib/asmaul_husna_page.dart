// lib/asmaul_husna_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_settings.dart';

class AsmaulHusnaPage extends StatefulWidget {
  const AsmaulHusnaPage({super.key});

  @override
  State<AsmaulHusnaPage> createState() => _AsmaulHusnaPageState();
}

class _AsmaulHusnaPageState extends State<AsmaulHusnaPage> {
  List _asmaulHusna = [];
  bool _isLoading = true;

  final sageColor = const Color(0xFFB2C8BA);
  final surfaceColor = const Color(0xFF242822);
  final bgColor = const Color(0xFF1A1C19);

  Future<void> readJson() async {
    try {
      final String response =
          await rootBundle.loadString('assets/Asmaul husna/asmaul_husna.json');
      final data = json.decode(response);
      if (mounted) {
        setState(() {
          _asmaulHusna = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error reading Asmaul Husna JSON: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    readJson();
  }

  @override
  Widget build(BuildContext context) {
    final bg = bgColor;
    final surface = surfaceColor;
    final textColor = Colors.white;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text('Asmaul Husna',
            style: TextStyle(fontWeight: FontWeight.w500, color: textColor)),
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: sageColor))
          : GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
              // 3 kolom biar lebih kecil
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
                childAspectRatio: 1.05,
              ),
              itemCount: _asmaulHusna.length,
              itemBuilder: (context, index) {
                final item = _asmaulHusna[index];
                if (index >= 12) {
                  return AsmaulHusnaCard(itemData: item, surface: surface);
                }
                return TweenAnimationBuilder(
                  duration:
                      Duration(milliseconds: 200 + (index % 12 * 60).toInt()),
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  builder: (context, double value, child) => Opacity(
                    opacity: value,
                    child: Transform.scale(
                        scale: 0.85 + (0.15 * value), child: child),
                  ),
                  child:   AsmaulHusnaCard(
                      itemData: item, surface: surface),
                );
              },
            ),
    );
  }
}

// ─── Kartu Asmaul Husna ───────────────────────────────────────────────────────
class AsmaulHusnaCard extends StatefulWidget {
  final Map<String, dynamic> itemData;
  final Color surface;

  const AsmaulHusnaCard({
    super.key,
    required this.itemData,
    required this.surface,
  });

  @override
  State<AsmaulHusnaCard> createState() => _AsmaulHusnaCardState();
}

class _AsmaulHusnaCardState extends State<AsmaulHusnaCard> {
  bool _pressed = false;

  void _showDetail(BuildContext context) {
    final sageColor = const Color(0xFFB2C8BA);
    final surface = widget.surface;
    final bg = const Color(0xFF1A1C19);
    const textColor = Colors.white;

    if (AppSettings().hapticEnabled) HapticFeedback.lightImpact();

    showModalBottomSheet(
      context: context,
      backgroundColor: surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.only(
              left: 24.0, right: 24.0, bottom: 40.0, top: 12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: textColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 32),
              Text(
                widget.itemData['arabic'] ?? '',
                style: TextStyle(
                    fontFamily: 'LPMQ',
                    fontSize: AppSettings().arabicFontSize.clamp(30.0, 60.0), // Ensure it's not too small or too big
                    color: sageColor,
                    height: 1.6),
              ),
              const SizedBox(height: 12),
              Text(
                widget.itemData['latin'] ?? '',
                style: TextStyle(
                    fontSize: 20,
                    color: textColor,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: bg, borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: [
                    Text('Arti:',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: sageColor,
                            fontSize: 13)),
                    const SizedBox(height: 8),
                    Text(
                      widget.itemData['translation_id'] ?? '',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: textColor.withOpacity(0.7),
                          fontSize: 15,
                          height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sageColor = const Color(0xFFB2C8BA);
    final surface = widget.surface;
    const textColor = Colors.white70;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        _showDetail(context);
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.itemData['arabic'] ?? '',
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'LPMQ',
                  fontSize: 20,
                  color: sageColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.itemData['latin'] ?? '',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
