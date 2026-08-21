import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pr13_detail_page.dart';
import 'app_settings.dart';
import 'main.dart';

class Pr13Page extends StatefulWidget {
  const Pr13Page({super.key});

  @override
  State<Pr13Page> createState() => _Pr13PageState();
}

class _Pr13PageState extends State<Pr13Page> {
  List _pr13List = [];
  bool _isLoading = true;
  final Map<String, bool> _completedToday = {};

  final sageColor = const Color(0xFFB2C8BA);
  final surfaceColor = const Color(0xFF242822);
  final bgColor = const Color(0xFF1A1C19);

  Future<void> readJson() async {
    try {
      final String response =
          await rootBundle.loadString('assets/PR 13/pr13.json');
      final data = json.decode(response);
      if (mounted) {
        setState(() {
          _pr13List = data;
          _isLoading = false;
        });
        _loadCompletedStatus();
      }
    } catch (e) {
      debugPrint("Error reading PR13 JSON: $e");
      if (mounted) {
        setState(() => _isLoading = false);
        _loadCompletedStatus();
      }
    }
  }

  String _todayStr() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> _loadCompletedStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) return;

    final today = _todayStr();
    _completedToday.clear();

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('pr13_progress')
          .where('lastResetDate', isEqualTo: today)
          .where('completedToday', isEqualTo: true)
          .get();

      for (var doc in snapshot.docs) {
        _completedToday[doc.id] = true;
      }
    } catch (_) {}

    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    readJson();
  }

  Future<void> _openDetail(Map<String, dynamic> doa) async {
    if (AppSettings().hapticEnabled) HapticFeedback.lightImpact();

    int? savedCount;
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.isAnonymous) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('pr13_progress')
            .doc(doa['title'] ?? '')
            .get();
        if (doc.exists) {
          savedCount = doc.data()?['count'] as int?;
        }
      } catch (_) {}
    }

    if (context.mounted) {
      await Navigator.push(
        context,
        buildSlideRoute(Pr13DetailPage(
          doaData: doa,
          initialCount: savedCount,
        )),
      );
      if (mounted) {
        _loadCompletedStatus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = bgColor;
    final surface = surfaceColor;
    final textColor = Colors.white;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text('PR 13',
            style: TextStyle(fontWeight: FontWeight.w500, color: textColor)),
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: sageColor))
          : RefreshIndicator(
              onRefresh: () async {
                await _loadCompletedStatus();
              },
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                itemCount: _pr13List.length,
                itemBuilder: (context, index) {
                  final doa = _pr13List[index];
                  final title = doa['title'] ?? '';
                  final isPR9 = title == 'PR-9';
                  final isCompleted = _completedToday[title] == true;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Material(
                      color: surface,
                      borderRadius: BorderRadius.circular(20),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => _openDetail(doa),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 20),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: isCompleted
                                      ? sageColor.withOpacity(0.25)
                                      : sageColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: isCompleted
                                    ? Icon(Icons.check_circle_rounded,
                                        color: sageColor, size: 26)
                                    : Icon(Icons.fingerprint,
                                        color: sageColor, size: 22),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  title,
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: isCompleted
                                          ? sageColor
                                          : textColor),
                                ),
                              ),
                              if (isCompleted)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Text(
                                    'Selesai',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: sageColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              if (isPR9)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Text(
                                    '3x Pagi & Sore',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.white38,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              Icon(Icons.arrow_forward_ios_rounded,
                                  size: 13,
                                  color: isCompleted
                                      ? sageColor.withOpacity(0.4)
                                      : textColor.withOpacity(0.2)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
