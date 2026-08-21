import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class ArabicFontOption {
  final String key;
  final String name;
  final String subtitle;

  const ArabicFontOption({
    required this.key,
    required this.name,
    required this.subtitle,
  });
}

class AppSettings extends ChangeNotifier {
  static final AppSettings _instance = AppSettings._internal();
  factory AppSettings() => _instance;
  AppSettings._internal();

  static const List<ArabicFontOption> arabicFontOptions = [
    ArabicFontOption(
      key: 'LPMQ',
      name: 'Mushaf Standar Kemenag (LPMQ)',
      subtitle: 'Standar Indonesia, nyaman dibaca (Offline)',
    ),
    ArabicFontOption(
      key: 'Amiri',
      name: 'Amiri',
      subtitle: 'Naskh klasik, harakat sangat jelas',
    ),
    ArabicFontOption(
      key: 'Scheherazade New',
      name: 'Scheherazade New',
      subtitle: 'Gaya tradisional Timur Tengah',
    ),
    ArabicFontOption(
      key: 'Noto Naskh Arabic',
      name: 'Noto Naskh Arabic',
      subtitle: 'Desain modern, rapi & bersih',
    ),
    ArabicFontOption(
      key: 'Lateef',
      name: 'Lateef',
      subtitle: 'Gaya kaligrafi Naskh bersambung',
    ),
  ];

  double _arabicFontSize = 28.0;
  String _arabicFontFamily = 'LPMQ';
  bool _hapticEnabled = true;
  bool _showTranslation = true;

  double get arabicFontSize => _arabicFontSize;
  String get arabicFontFamily => _arabicFontFamily;
  bool get hapticEnabled => _hapticEnabled;
  bool get showTranslation => _showTranslation;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _arabicFontSize = prefs.getDouble('arabicFontSize') ?? 28.0;
    _arabicFontFamily = prefs.getString('arabicFontFamily') ?? 'LPMQ';
    _hapticEnabled = prefs.getBool('hapticEnabled') ?? true;
    _showTranslation = prefs.getBool('showTranslation') ?? true;
    notifyListeners();
  }

  Future<void> setArabicFontSize(double size) async {
    _arabicFontSize = size;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('arabicFontSize', size);
    notifyListeners();
  }

  Future<void> setArabicFontFamily(String font) async {
    _arabicFontFamily = font;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('arabicFontFamily', font);
    notifyListeners();
  }

  TextStyle getArabicStyle({
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
    double? height,
  }) {
    final baseStyle = TextStyle(
      fontSize: fontSize ?? _arabicFontSize,
      color: color,
      fontWeight: fontWeight,
      height: height,
    );

    return getStyleForFont(_arabicFontFamily, baseStyle: baseStyle);
  }

  static TextStyle getStyleForFont(
    String fontKey, {
    TextStyle? baseStyle,
  }) {
    switch (fontKey) {
      case 'Amiri':
        return GoogleFonts.amiri(textStyle: baseStyle);
      case 'Scheherazade New':
        return GoogleFonts.scheherazadeNew(textStyle: baseStyle);
      case 'Noto Naskh Arabic':
        return GoogleFonts.notoNaskhArabic(textStyle: baseStyle);
      case 'Lateef':
        return GoogleFonts.lateef(textStyle: baseStyle);
      case 'LPMQ':
      default:
        return (baseStyle ?? const TextStyle()).copyWith(fontFamily: 'LPMQ');
    }
  }

  Future<void> setHaptic(bool value) async {
    _hapticEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hapticEnabled', value);
    notifyListeners();
  }

  Future<void> setShowTranslation(bool value) async {
    _showTranslation = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showTranslation', value);
    notifyListeners();
  }

  // ── Last search ────────────────────────────────────────────────────────────
  Future<String?> getLastSearch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('lastSearch');
  }

  Future<void> setLastSearch(String query) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastSearch', query);
    notifyListeners();
  }
}