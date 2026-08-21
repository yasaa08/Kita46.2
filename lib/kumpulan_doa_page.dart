import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'detail_doa_page.dart';
import 'app_settings.dart';
import 'main.dart';

class KumpulanDoaPage extends StatefulWidget {
  const KumpulanDoaPage({super.key});

  @override
  State<KumpulanDoaPage> createState() => _KumpulanDoaPageState();
}

class _KumpulanDoaPageState extends State<KumpulanDoaPage> {
  List _listDoa = [];
  List _filteredDoa = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  final sageColor = const Color(0xFFB2C8BA);
  final surfaceColor = const Color(0xFF242822);
  final bgColor = const Color(0xFF1A1C19);

  Future<void> readJson() async {
    try {
      final String response =
          await rootBundle.loadString('assets/kumpulan doa/kumpulan_doa.json');
      final data = json.decode(response);
      if (mounted) {
        setState(() {
          _listDoa = data;
          _filteredDoa = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading doa: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filter(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredDoa = _listDoa;
      } else {
        _filteredDoa = _listDoa
            .where((d) => (d['title'] ?? '')
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    readJson();
    _searchController.addListener(() => _filter(_searchController.text));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        title: Text('Kumpulan Doa',
            style: TextStyle(fontWeight: FontWeight.w500, color: textColor)),
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Premium Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: sageColor.withOpacity(0.15), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: sageColor.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                style: TextStyle(color: textColor, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Pencarian doa...',
                  hintStyle: TextStyle(color: textColor.withOpacity(0.4), fontSize: 14),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 16, right: 12),
                    child: Icon(Icons.search_rounded, color: sageColor.withOpacity(0.8), size: 22),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 50),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.close_rounded,
                              color: textColor.withOpacity(0.4), size: 18),
                          onPressed: () {
                            _searchController.clear();
                            _filter('');
                          })
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1),

          // Daftar Doa
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: sageColor))
                : _filteredDoa.isEmpty
                    ? Center(
                        child: Text('Doa tidak ditemukan',
                            style:
                                TextStyle(color: textColor.withOpacity(0.4))))
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                        itemCount: _filteredDoa.length,
                        itemBuilder: (context, index) {
                          final item = _filteredDoa[index];
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
                                    buildSlideRoute(DetailDoaPage(
                                      doaData: item,
                                      doaList:
                                          _filteredDoa.cast<Map<String, dynamic>>(),
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
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                        child: Icon(Icons.clean_hands_outlined,
                                            color: sageColor, size: 20),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Text(
                                          item['title'] ?? 'Doa',
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                              color: textColor),
                                        ),
                                      ),
                                      Icon(Icons.arrow_forward_ios_rounded,
                                          size: 13,
                                          color: textColor.withOpacity(0.2)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
