import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends ChangeNotifier {
  static final AppSettings _instance = AppSettings._internal();
  factory AppSettings() => _instance;
  AppSettings._internal();

  double _arabicFontSize = 28.0;
  bool _hapticEnabled = true;
  bool _showTranslation = true;


  double get arabicFontSize => _arabicFontSize;
  bool get hapticEnabled => _hapticEnabled;
  bool get showTranslation => _showTranslation;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _arabicFontSize = prefs.getDouble('arabicFontSize') ?? 28.0;
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
}
