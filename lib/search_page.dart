import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'main.dart';
import 'app_settings.dart';

// Import halaman kategori
import 'daftar_surah_page.dart';
import 'asmaul_husna_page.dart';
import 'pr13_page.dart';
import 'sholat_sunnah_page.dart';
import 'kumpulan_doa_page.dart';

// Import halaman detail
import 'detail_surah_page.dart';
import 'detail_sholat_page.dart';
import 'detail_doa_page.dart';
import 'pr13_detail_page.dart';

class SearchPage extends StatefulWidget {
  final List<Map<String, dynamic>> searchData;

  const SearchPage({super.key, required this.searchData});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final AppSettings _settings = AppSettings();

  List<String> _searchHistory = [];
  String _query = '';

  // ─── Colors ──────────────────────────────────────────────────────────────
  static const _bgColor = Color(0xFF1A1C19);
  static const _surfaceColor = Color(0xFF242822);
  static const _sageColor = Color(0xFFB2C8BA);
  static const _textColor = Colors.white;

  // ─── Kategori ────────────────────────────────────────────────────────────
  static const _categories = [
    {'label': 'Surat', 'icon': Icons.auto_stories, 'color': Color(0xFFB2C8BA)},
    {'label': 'Doa', 'icon': Icons.clean_hands, 'color': Color(0xFFD2E0FB)},
    {'label': 'Sholat', 'icon': Icons.mosque, 'color': Color(0xFFFFE5E5)},
    {'label': 'PR 13', 'icon': Icons.fingerprint, 'color': Color(0xFFCDE8E5)},
    {
      'label': 'Asmaul Husna',
      'icon': Icons.bookmark_rounded,
      'color': Color(0xFFEADFB4),
    },
  ];

  // ─── Pencarian Populer ───────────────────────────────────────────────────
  static const _popularSearches = [
    'Doa Perlindungan Asad',
    'Al-Hasyr',
    'Ya-sin',
    'Al-Fatihah',
    'Ar-Rahman',
    'Dhuha',
    'Sholat Hajat',
    'Pr-9',
    'Doa Mohon diselamatkan dari neraka',
  ];

  // ─── SharedPreferences key ───────────────────────────────────────────────
  static const _historyKey = 'search_history';

  @override
  void initState() {
    super.initState();
    _loadHistory();
    // Auto focus the search field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ─── History Persistence ─────────────────────────────────────────────────

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_historyKey) ?? [];
    if (mounted) setState(() => _searchHistory = list);
  }

  Future<void> _addToHistory(String query) async {
    if (query.trim().isEmpty) return;
    _searchHistory.remove(query);
    _searchHistory.insert(0, query);
    if (_searchHistory.length > 10) {
      _searchHistory = _searchHistory.sublist(0, 10);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_historyKey, _searchHistory);
  }

  Future<void> _removeFromHistory(String query) async {
    setState(() => _searchHistory.remove(query));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_historyKey, _searchHistory);
  }

  Future<void> _clearHistory() async {
    setState(() => _searchHistory.clear());
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  // ─── Search Logic ────────────────────────────────────────────────────────

  List<Map<String, dynamic>> get _filteredResults {
    if (_query.isEmpty) return [];
    final q = _query.toLowerCase();
    return widget.searchData.where((item) {
      final title = (item['title'] ?? '').toString().toLowerCase();
      final searchKey = (item['searchKey'] ?? '').toString().toLowerCase();
      return title.contains(q) || searchKey.contains(q);
    }).toList();
  }

  // ─── Navigation ──────────────────────────────────────────────────────────

  void _navigate(Map<String, dynamic> item) {
    if (_settings.hapticEnabled) HapticFeedback.lightImpact();
    _addToHistory(item['title'] ?? _query);

    if (item['type'] == 'Menu') {
      Navigator.push(context, buildSlideRoute(item['page']));
    } else if (item['type'] == 'Surah') {
      Navigator.push(
        context,
        buildSlideRoute(
          DetailSurahPage(
            surahNumber: int.parse(item['data']['number'].toString()),
            surahName: item['data']['name_latin'] ?? item['data']['name'],
            revelation: item['data']['revelation'] ?? '',
          ),
        ),
      );
    } else if (item['type'] == 'Sholat') {
      Navigator.push(
        context,
        buildSlideRoute(DetailSholatPage(sholatData: item['data'])),
      );
    } else if (item['type'] == 'PR 13') {
      Navigator.push(
        context,
        buildSlideRoute(Pr13DetailPage(doaData: item['data'])),
      );
    } else if (item['type'] == 'Doa') {
      Navigator.push(
        context,
        buildSlideRoute(DetailDoaPage(doaData: item['data'])),
      );
    }
  }

  void _navigateToCategory(String label) {
    if (_settings.hapticEnabled) HapticFeedback.lightImpact();
    Widget page;
    switch (label) {
      case 'Surat':
        page = const DaftarSurahPage();
        break;
      case 'Doa':
        page = const KumpulanDoaPage();
        break;
      case 'Sholat':
        page = const SholatSunnahPage();
        break;
      case 'PR 13':
        page = const Pr13Page();
        break;
      case 'Asmaul Husna':
        page = const AsmaulHusnaPage();
        break;
      default:
        return;
    }
    Navigator.push(context, buildSlideRoute(page));
  }

  void _searchFromChip(String text) {
    if (_settings.hapticEnabled) HapticFeedback.lightImpact();
    setState(() {
      _query = text;
      _controller.text = text;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: text.length),
      );
    });
  }

  // ─── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isSearching = _query.isNotEmpty;

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        title: Text(
          'Pencarian',
          style: TextStyle(fontWeight: FontWeight.w500, color: _textColor),
        ),
        backgroundColor: _bgColor,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ── Search Field ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: _surfaceColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _sageColor.withOpacity(
                    _focusNode.hasFocus ? 0.4 : 0.15,
                  ),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: Icon(
                      Icons.search_rounded,
                      color: Color(0xFF8A9A8E),
                      size: 20,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      style: const TextStyle(
                        color: _textColor,
                        fontSize: 14,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Cari surah, doa, sholat...',
                        hintStyle: TextStyle(
                          color: Color(0xFF6B7A6E),
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                      ),
                      onChanged: (val) => setState(() => _query = val),
                      textInputAction: TextInputAction.search,
                      onSubmitted: (val) {
                        if (val.trim().isNotEmpty) {
                          _addToHistory(val.trim());
                        }
                      },
                    ),
                  ),
                  if (_query.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _controller.clear();
                        setState(() => _query = '');
                      },
                      child: const Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: Icon(
                          Icons.close_rounded,
                          color: Color(0xFF8A9A8E),
                          size: 20,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ── Content ───────────────────────────────────────────────────
          Expanded(
            child: isSearching ? _buildSearchResults() : _buildIdleContent(),
          ),
        ],
      ),
    );
  }

  // ─── Idle Content (History + Kategori + Populer) ─────────────────────────

  Widget _buildIdleContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Riwayat Pencarian ──────────────────────────────────────
          if (_searchHistory.isNotEmpty) ...[
            _buildSectionHeader(
              'Riwayat Pencarian',
              trailing: GestureDetector(
                onTap: () {
                  if (_settings.hapticEnabled) HapticFeedback.lightImpact();
                  _clearHistory();
                },
                child: Text(
                  'Hapus Semua',
                  style: TextStyle(
                    color: _sageColor.withOpacity(0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 300.ms),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _searchHistory.asMap().entries.map((entry) {
                final i = entry.key;
                final text = entry.value;
                return _buildHistoryChip(text, i);
              }).toList(),
            ).animate().fadeIn(delay: 100.ms, duration: 300.ms),
            const SizedBox(height: 28),
          ],

          _buildSectionHeader('Kategori Pencarian')
              .animate()
              .fadeIn(delay: 150.ms, duration: 300.ms),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _categories.asMap().entries.map((entry) {
              final i = entry.key;
              final cat = entry.value;
              return Expanded(
                child: _buildCategoryIcon(
                  cat['label'] as String,
                  cat['icon'] as IconData,
                  cat['color'] as Color,
                  i,
                ),
              );
            }).toList(),
          ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(
                begin: 0.1,
                duration: 400.ms,
                curve: Curves.easeOutCubic,
              ),
          const SizedBox(height: 28),

          // ── Pencarian Populer ──────────────────────────────────────
          _buildSectionHeader('Pencarian Populer')
              .animate()
              .fadeIn(delay: 250.ms, duration: 300.ms),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _popularSearches.asMap().entries.map((entry) {
              final i = entry.key;
              final text = entry.value;
              return _buildPopularChip(text, i);
            }).toList(),
          ).animate().fadeIn(delay: 300.ms, duration: 400.ms).slideY(
              begin: 0.05, duration: 400.ms, curve: Curves.easeOutCubic),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ─── Search Results ──────────────────────────────────────────────────────

  Widget _buildSearchResults() {
    final results = _filteredResults;

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 56,
              color: _textColor.withOpacity(0.15),
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ditemukan untuk "$_query"',
              style: TextStyle(
                color: _textColor.withOpacity(0.4),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: results.length,
      itemBuilder: (ctx, i) {
        final item = results[i];
        return _buildResultTile(item, i);
      },
    );
  }

  // ─── UI Components ───────────────────────────────────────────────────────

  Widget _buildSectionHeader(String title, {Widget? trailing}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title.toUpperCase(),
          style: TextStyle(
            color: _textColor.withOpacity(0.45),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _buildHistoryChip(String text, int index) {
    return GestureDetector(
      onTap: () => _searchFromChip(text),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _surfaceColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.history_rounded,
                size: 14,
                color: _textColor.withOpacity(0.35),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  text,
                  style: TextStyle(
                    color: _textColor.withOpacity(0.75),
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () {
                  if (_settings.hapticEnabled) HapticFeedback.lightImpact();
                  _removeFromHistory(text);
                },
                child: Icon(
                  Icons.close_rounded,
                  size: 14,
                  color: _textColor.withOpacity(0.3),
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 50))
        .fadeIn(duration: 250.ms)
        .slideX(begin: 0.05);
  }

  Widget _buildCategoryIcon(
    String label,
    IconData icon,
    Color color,
    int index,
  ) {
    return GestureDetector(
      onTap: () => _navigateToCategory(label),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: Text(
              label,
              style: TextStyle(
                color: _textColor.withOpacity(0.7),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularChip(String text, int index) {
    return GestureDetector(
      onTap: () => _searchFromChip(text),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _sageColor.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.trending_up_rounded,
              size: 14,
              color: _sageColor.withOpacity(0.5),
            ),
            const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(
                color: _textColor.withOpacity(0.7),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultTile(Map<String, dynamic> item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: _getTypeColor(item['type']).withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            item['icon'] ?? Icons.article_rounded,
            color: _getTypeColor(item['type']),
            size: 20,
          ),
        ),
        title: Text(
          item['title'] ?? '',
          style: const TextStyle(
            color: _textColor,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          item['type'] ?? '',
          style: TextStyle(
            color: _textColor.withOpacity(0.4),
            fontSize: 12,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14,
          color: _textColor.withOpacity(0.2),
        ),
        onTap: () => _navigate(item),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 40))
        .fadeIn(duration: 250.ms)
        .slideX(begin: 0.05);
  }

  Color _getTypeColor(String? type) {
    switch (type) {
      case 'Surah':
      case 'Menu':
        return const Color(0xFFB2C8BA);
      case 'Doa':
        return const Color(0xFFD2E0FB);
      case 'Sholat':
        return const Color(0xFFFFE5E5);
      case 'PR 13':
        return const Color(0xFFCDE8E5);
      case 'Asmaul Husna':
        return const Color(0xFFEADFB4);
      default:
        return _sageColor;
    }
  }
}
