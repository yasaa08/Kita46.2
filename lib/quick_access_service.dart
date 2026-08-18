import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Represents a single Quick Access item pinned by the user.
class QuickAccessItem {
  final String id;
  final String title;
  final String type; // 'surah', 'doa', 'sholat', 'asmaul_husna'
  final Map<String, dynamic> data;

  QuickAccessItem({
    required this.id,
    required this.title,
    required this.type,
    required this.data,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'type': type,
        'data': data,
      };

  factory QuickAccessItem.fromJson(Map<String, dynamic> json) {
    return QuickAccessItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      type: json['type'] ?? '',
      data: Map<String, dynamic>.from(json['data'] ?? {}),
    );
  }

  /// Returns the appropriate icon based on item type.
  IconData get icon {
    switch (type) {
      case 'surah':
        return Icons.auto_stories;
      case 'doa':
        return Icons.clean_hands;
      case 'sholat':
        return Icons.mosque;
      case 'asmaul_husna':
        return Icons.bookmark_rounded;
      default:
        return Icons.star_rounded;
    }
  }

  /// Returns the accent color for the item type.
  Color get accentColor {
    switch (type) {
      case 'surah':
        return const Color(0xFFB2C8BA);
      case 'doa':
        return const Color(0xFFD2E0FB);
      case 'sholat':
        return const Color(0xFFFFE5E5);
      case 'asmaul_husna':
        return const Color(0xFFEADFB4);
      default:
        return const Color(0xFFB2C8BA);
    }
  }
}

/// Singleton service that manages Quick Access items via SharedPreferences.
class QuickAccessService extends ChangeNotifier {
  static final QuickAccessService _instance = QuickAccessService._internal();
  factory QuickAccessService() => _instance;
  QuickAccessService._internal();

  static const String _storageKey = 'quick_access_items';

  List<QuickAccessItem> _items = [];
  List<QuickAccessItem> get items => List.unmodifiable(_items);

  bool get isEmpty => _items.isEmpty;

  /// Load items from SharedPreferences. Call once at startup.
  Future<void> loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final List decoded = json.decode(raw);
        _items = decoded
            .map((e) => QuickAccessItem.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      } catch (_) {
        _items = [];
      }
    }
    notifyListeners();
  }

  /// Persist current items to SharedPreferences.
  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(_items.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  /// Add an item to Quick Access.
  Future<void> addItem(QuickAccessItem item) async {
    if (hasItem(item.id)) return;
    _items.add(item);
    await _save();
    notifyListeners();
  }

  /// Remove an item by its ID.
  Future<void> removeItem(String id) async {
    _items.removeWhere((e) => e.id == id);
    await _save();
    notifyListeners();
  }

  /// Check if an item is already in Quick Access.
  bool hasItem(String id) => _items.any((e) => e.id == id);
}
