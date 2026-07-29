import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:home_widget/home_widget.dart';

class WidgetService {
  static const _widgetName = 'KitaWidget';

  static Future<void> updateWidget({
    String? surahName,
    String? ayahNumber,
    String? prTitle,
    String? prCount,
    String? prDate,
  }) async {
    try {
      if (surahName != null) {
        await HomeWidget.saveWidgetData('widget_surah', surahName);
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
      String? ayahNumber;
      if (surahRaw is Map) {
        surahName = surahRaw['name']?.toString();
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
        ayahNumber: ayahNumber,
        prTitle: prTitle,
        prCount: prCount,
        prDate: prDate,
      );
    } catch (_) {}
  }
}
