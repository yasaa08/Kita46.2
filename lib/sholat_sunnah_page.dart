import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'detail_sholat_page.dart';
import 'app_settings.dart';
import 'main.dart';

class SholatSunnahPage extends StatefulWidget {
  const SholatSunnahPage({super.key});

  @override
  State<SholatSunnahPage> createState() => _SholatSunnahPageState();
}

class _SholatSunnahPageState extends State<SholatSunnahPage> {
  List _listSholat = [];
  bool _isLoading = true;

  final sageColor = const Color(0xFFB2C8BA);
  final surfaceColor = const Color(0xFF242822);
  final bgColor = const Color(0xFF1A1C19);

  Future<void> readJson() async {
    try {
      final String response =
          await rootBundle.loadString('assets/Sholat sunnah/Sholatsunnah.json');
      final data = json.decode(response);
      if (mounted) {
        setState(() {
          _listSholat = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading sholat: $e");
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
    final settings = AppSettings();
    final bg = bgColor;
    final surface = surfaceColor;
    const textColor = Colors.white;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text('Sholat Sunnah',
            style: TextStyle(fontWeight: FontWeight.w500, color: textColor)),
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: sageColor))
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
              itemCount: _listSholat.length,
              itemBuilder: (context, index) {
                final item = _listSholat[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Material(
                    color: surface,
                    borderRadius: BorderRadius.circular(20),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () {
                        if (settings.hapticEnabled) {
                          HapticFeedback.lightImpact();
                        }
                        Navigator.push(
                          context,
                          buildSlideRoute(DetailSholatPage(
                            sholatData: item,
                            sholatList:
                                _listSholat.cast<Map<String, dynamic>>(),
                            currentIndex: index,
                          )),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 20),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: sageColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(Icons.wb_sunny_outlined,
                                  color: sageColor, size: 20),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                item['title'] ?? 'Sholat',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: textColor),
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios_rounded,
                                size: 13, color: textColor.withOpacity(0.2)),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
