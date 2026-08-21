import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'widget_service.dart';

class StreakService {
  static final StreakService _instance = StreakService._internal();
  factory StreakService() => _instance;
  StreakService._internal();

  String? _lastActiveDate;
  bool _isTodayCompleted = false;

  String? get lastActiveDate => _lastActiveDate;
  bool get isTodayCompleted => _isTodayCompleted;

  /// Calculates number of inactive days since last active date.
  int get daysInactive {
    if (_lastActiveDate == null) return 0;
    try {
      final lastDate = DateTime.parse(_lastActiveDate!);
      final now = DateTime.now();
      final todayDate = DateTime(now.year, now.month, now.day);
      final cleanLastDate = DateTime(lastDate.year, lastDate.month, lastDate.day);
      return todayDate.difference(cleanLastDate).inDays;
    } catch (_) {
      return 0;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Loads last active date from SharedPreferences and optionally Firestore.
  Future<void> loadStreak() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _lastActiveDate = prefs.getString('user_last_active_date');

      final todayStr = _formatDate(DateTime.now());
      _isTodayCompleted = _lastActiveDate == todayStr;

      // Check Firestore if logged in
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.isAnonymous) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data();
          if (data != null) {
            final cloudLastDate = data['last_active_date'] as String?;
            if (_lastActiveDate == null && cloudLastDate != null) {
              _lastActiveDate = cloudLastDate;
              _isTodayCompleted = _lastActiveDate == todayStr;
              await prefs.setString('user_last_active_date', _lastActiveDate!);
            }
          }
        }
      }

      await _syncWidgetData();
    } catch (e) {
      debugPrint('Error loading active date: $e');
    }
  }

  /// Records an activity (e.g. 'pr13', 'quran', 'doa') to update last active date for the widget.
  Future<void> recordActivity(String activityType) async {
    try {
      final todayStr = _formatDate(DateTime.now());
      final prefs = await SharedPreferences.getInstance();

      _lastActiveDate = todayStr;
      _isTodayCompleted = true;
      await prefs.setString('user_last_active_date', todayStr);

      // Sync to Firestore if logged in
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.isAnonymous) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'last_active_date': todayStr,
          'last_activity_type': activityType,
          'last_activity_timestamp': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      await _syncWidgetData();
    } catch (e) {
      debugPrint('Error recording activity: $e');
    }
  }

  /// Duolingo-style reminder message based on inactivity for home screen widget.
  String getInactiveReminderText() {
    if (_isTodayCompleted) {
      return 'Alhamdulillah, amalan hari ini terjaga! ✨';
    }

    final diff = daysInactive;
    if (diff == 0 || diff == 1) {
      return 'Yuk sempatkan 1 amalan hari ini! ✨';
    } else if (diff == 2) {
      return '2 hari tanpa kabar... 🥺';
    } else if (diff == 3) {
      return '3 hari menghilang... Qur\'an kangen nih 🥀';
    } else if (diff >= 4 && diff <= 9) {
      return '$diff hari tanpa kabar... Masih ingat Kita 46.2? 😢';
    } else if (diff >= 10 && diff <= 14) {
      return '10 hari tanpa kabar... Yuk mulai lagi dari 1 ayat 🤲';
    } else {
      return '15 hari tanpa kabar... Pintu kebaikan selalu terbuka ✨';
    }
  }

  Future<void> _syncWidgetData() async {
    try {
      final msg = getInactiveReminderText();
      await WidgetService.updateStreakData(
        streakCount: 0,
        streakMessage: msg,
      );
    } catch (_) {}
  }
}
