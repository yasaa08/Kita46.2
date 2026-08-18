import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:home_widget/home_widget.dart';

class WidgetService {
  static const _widgetName = 'KitaWidget';

  static Future<void> updateWidget({
    String? surahName,
    String? surahNumber,
    String? ayahNumber,
    String? prTitle,
    String? prCount,
    String? prDate,
  }) async {
    try {
      if (surahName != null) {
        await HomeWidget.saveWidgetData('widget_surah', surahName);
      }
      if (surahNumber != null) {
        await HomeWidget.saveWidgetData('widget_surah_number', surahNumber);
      }
      if (ayahNumber != null) {
        await HomeWidget.saveWidgetData('widget_ayah', ayahNumber);
      }
      if (prTitle != null) {
        await HomeWidget.saveWidgetData('widget_pr_title', prTitle);
      }
      if (prCount != null) {
        await HomeWidget.saveWidgetData('widget_pr_count', prCount);
      }
      if (prDate != null) {
        await HomeWidget.saveWidgetData('widget_pr_date', prDate);
      }
      await HomeWidget.updateWidget(
        iOSName: _widgetName,
        qualifiedAndroidName: 'com.example.kita_46_2.KitaWidgetProvider',
      );
    } catch (_) {}
  }

  static String _todayStr() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  static Future<void> refreshFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (!doc.exists) return;
      final data = doc.data()!;

      final surahRaw = data['last_read_surah'];
      String? surahName;
      String? surahNumber;
      String? ayahNumber;
      if (surahRaw is Map) {
        surahName = surahRaw['name']?.toString();
        surahNumber = surahRaw['number']?.toString();
        ayahNumber = surahRaw['ayah']?.toString();
      }

      final today = _todayStr();
      final prDate = data['last_pr13_date']?.toString();
      String? prTitle;
      String? prCount;
      if (prDate == today) {
        prTitle = data['last_pr13_title']?.toString();
        prCount = data['last_pr13_count']?.toString();
      }

      await updateWidget(
        surahName: surahName,
        surahNumber: surahNumber,
        ayahNumber: ayahNumber,
        prTitle: prTitle,
        prCount: prCount,
        prDate: prDate,
      );
    } catch (_) {}
  }

  /// Read the last-read surah data from widget SharedPreferences.
  /// Used for widget click → navigate to correct surah without Firestore query.
  static Future<Map<String, dynamic>?> getLastReadSurah() async {
    try {
      final surahName = await HomeWidget.getWidgetData<String>('widget_surah');
      final surahNumStr = await HomeWidget.getWidgetData<String>('widget_surah_number');
      final ayahStr = await HomeWidget.getWidgetData<String>('widget_ayah');
      if (surahName == null || surahName.isEmpty) return null;
      return {
        'name': surahName,
        'number': int.tryParse(surahNumStr ?? '0') ?? 0,
        'ayah': int.tryParse(ayahStr ?? '0') ?? 0,
      };
    } catch (_) {
      return null;
    }
  }

  /// Check if the app was launched from a widget click.
  /// Returns the URI string (e.g., 'kita462://quran' or 'kita462://pr13') or null.
  static Future<Uri?> getWidgetClickUri() async {
    try {
      final uri = await HomeWidget.initiallyLaunchedFromHomeWidget();
      return uri;
    } catch (_) {
      return null;
    }
  }

  /// Stream of widget click events when app is already running.
  static Stream<Uri?> get widgetClicked => HomeWidget.widgetClicked;
}
