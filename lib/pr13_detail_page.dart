import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'app_settings.dart';
import 'main.dart';
import 'widget_service.dart';
import 'streak_service.dart';

class Pr13DetailPage extends StatefulWidget {
  final Map<String, dynamic> doaData;
  final int? initialCount;

  const Pr13DetailPage({super.key, required this.doaData, this.initialCount});

  @override
  State<Pr13DetailPage> createState() => _Pr13DetailPageState();
}

class _Pr13DetailPageState extends State<Pr13DetailPage>
    with TickerProviderStateMixin {
  int _counter = 0;
  bool _isCompleted = false;
  bool _showCompletionAnim = false;

  String _pr9Session = 'pagi';
  late int _maxCount;

  int get _prId => widget.doaData['id'] ?? 0;
  bool get _isPr9 => _prId == 9;
  bool get _isPr13 => _prId == 13;

  late AnimationController _checkAnimCtrl;
  late Animation<double> _checkAnim;

  late AnimationController _counterPulseCtrl;
  Timer? _saveTimer;

  final sageColor = const Color(0xFFB2C8BA);
  final surfaceColor = const Color(0xFF242822);
  final bgColor = const Color(0xFF1A1C19);

  @override
  void initState() {
    super.initState();
    _counter = widget.initialCount ?? 0;
    _maxCount = _isPr9 ? 3 : 100;

    _checkAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _checkAnim = CurvedAnimation(parent: _checkAnimCtrl, curve: Curves.elasticOut);

    _counterPulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
  }

  Future<void> _initialize() async {
    if (_isPr9) _determineSession();
    await _checkDailyReset();
    if (_isPr9) await _checkPr9SessionReset();
  }

  String _todayStr() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> _checkDailyReset() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) return;

    final title = widget.doaData['title'] ?? '';
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('pr13_progress')
          .doc(title)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        final lastResetDate = data['lastResetDate'] as String?;
        final today = _todayStr();

        if (lastResetDate != today) {
          _counter = 0;
          _isCompleted = false;
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('pr13_progress')
              .doc(title)
              .set({
            'count': 0,
            'lastResetDate': today,
            'completedToday': false,
            'lastUpdated': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        } else {
          _isCompleted = data['completedToday'] == true;
          _counter = (data['count'] as int?) ?? _counter;
        }
      }
      if (mounted) setState(() {});
    } catch (_) {}
  }

  void _determineSession() {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 11) {
      _pr9Session = 'pagi';
      _maxCount = 3;
    } else if (hour >= 11 && hour < 19) {
      _pr9Session = 'sore';
      _maxCount = 3;
    } else {
      _pr9Session = 'malam';
      _maxCount = 999999;
    }
  }

  Future<void> _checkPr9SessionReset() async {
    _determineSession();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) {
      if (mounted) setState(() {});
      return;
    }

    final title = widget.doaData['title'] ?? '';
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('pr13_progress')
          .doc(title)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        final lastSession = data['sessionType'] as String?;
        final lastSessionDate = data['sessionDate'] as String?;
        final today = _todayStr();

        if (lastSession != _pr9Session || lastSessionDate != today) {
          _counter = 0;
          _isCompleted = false;
          await _savePr9Session();
        } else {
          _counter = (data['count'] as int?) ?? 0;
        }
      } else {
        _counter = 0;
        await _savePr9Session();
      }
      if (mounted) setState(() {});
    } catch (_) {
      _counter = 0;
      if (mounted) setState(() {});
    }
  }

  Future<void> _savePr9Session() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('pr13_progress')
        .doc(widget.doaData['title'] ?? '')
        .set({
      'sessionType': _pr9Session,
      'sessionDate': _todayStr(),
      'count': _counter,
      'completedToday': false,
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  void _debouncedSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 1500), () {
      _autoSaveCounter();
    });
  }

  void _incrementCounter() {
    if (_isCompleted) return;
    if (_counter >= _maxCount) return;

    if (AppSettings().hapticEnabled) HapticFeedback.mediumImpact();
    setState(() {
      _counter++;
    });
    _counterPulseCtrl.forward(from: 0.0);

    _debouncedSave();

    if (_counter >= _maxCount && _maxCount < 999999) {
      _onReachMax();
    }
  }

  void _onReachMax() {
    if (AppSettings().hapticEnabled) {
      HapticFeedback.heavyImpact();
      Future.delayed(const Duration(milliseconds: 200), () {
        HapticFeedback.heavyImpact();
      });
    }
    setState(() {
      _isCompleted = true;
      _showCompletionAnim = true;
    });
    _checkAnimCtrl.forward(from: 0.0);

    _saveTimer?.cancel();
    if (!_isPr9) {
      _saveCompletion();
    }
    StreakService().recordActivity('pr13');

    showTopNotification(
      context,
      _isPr9 ? 'Selesai sesi $_pr9Session!' : 'Alhamdulillah, selesai!',
      bgColor: sageColor,
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.pop(context, true);
    });
  }

  Future<void> _saveCompletion() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) return;

    final title = widget.doaData['title'] ?? '';
    final today = _todayStr();
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('pr13_progress')
        .doc(title)
        .set({
      'count': _counter,
      'completedToday': true,
      'lastResetDate': today,
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'last_pr13_title': title,
      'last_pr13_count': _counter,
      'last_pr13_date': today,
    }, SetOptions(merge: true));

    WidgetService.updateWidget(
      prTitle: title,
      prCount: _counter.toString(),
      prDate: today,
    );
  }

  Future<void> _autoSaveCounter() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) return;
    try {
      final title = widget.doaData['title'] ?? '';
      final today = _todayStr();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('pr13_progress')
          .doc(title)
          .set({
        'count': _counter,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!_isPr9) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'last_pr13_title': title,
          'last_pr13_count': _counter,
          'last_pr13_date': today,
        }, SetOptions(merge: true));

        WidgetService.updateWidget(
          prTitle: title,
          prCount: _counter.toString(),
          prDate: today,
        );
      }
    } catch (_) {}
  }

  void _resetCounter() {
    if (_isPr9) {
      _determineSession();
    }
    setState(() {
      _counter = 0;
      _isCompleted = false;
      _showCompletionAnim = false;
    });
    
    _saveTimer?.cancel();
    
    if (_isPr9) {
      _savePr9Session();
    } else {
      _autoSaveCounter();
    }
    showTopNotification(context, 'Hitungan direset!');
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _autoSaveCounter();
    _counterPulseCtrl.dispose();
    _checkAnimCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = AppSettings();
    const bg = Color(0xFF1A1C19);
    const surface = Color(0xFF242822);
    const textColor = Colors.white;

    final String title = widget.doaData['title'] ?? '';
    final String arabic = widget.doaData['arabic'] ?? '';
    final String latin = widget.doaData['latin'] ?? '';
    final String translation = widget.doaData['translation'] ?? '';
    final String notes = widget.doaData['notes'] ?? '';

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _saveTimer?.cancel();
          _autoSaveCounter();
        }
      },
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          title: Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w500, fontSize: 18, color: Colors.white)),
          backgroundColor: bg,
          surfaceTintColor: Colors.transparent,
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.refresh_rounded, color: textColor.withOpacity(0.5)),
              tooltip: 'Reset',
              onPressed: () {
                if (settings.hapticEnabled) HapticFeedback.lightImpact();
                _resetCounter();
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (arabic.isNotEmpty)
                    Text(
                      arabic,
                      textAlign: TextAlign.right,
                      style: settings.getArabicStyle(
                          fontSize: settings.arabicFontSize + 4,
                          color: sageColor,
                          height: 1.9),
                    ).animate().fadeIn(duration: 400.ms),
                  const SizedBox(height: 24),
                  if (latin.isNotEmpty)
                    Text(
                      latin,
                      style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w500),
                    ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                  const SizedBox(height: 12),
                  if (translation.isNotEmpty)
                    Text(
                      translation,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.65),
                          fontSize: 15,
                          height: 1.5),
                    ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                  const SizedBox(height: 32),
                  if (notes.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Icon(Icons.info_outline_rounded,
                                color: sageColor, size: 20),
                            const SizedBox(width: 8),
                            Text('Keterangan:',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: sageColor,
                                    fontSize: 14)),
                          ]),
                          const SizedBox(height: 12),
                          Text(notes,
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 14,
                                  height: 1.5)),
                        ],
                      ),
                    ).animate().fadeIn(delay: 300.ms),
                ],
              ),
            ),
          ),

          Container(
            padding:
                const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 40),
            decoration: BoxDecoration(
              color: _isCompleted ? sageColor.withOpacity(0.15) : surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(40)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isPr9 && _pr9Session == 'malam')
                  Text(
                    "Malam: unlimited",
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  )
                else if (_isPr9)
                  Text(
                    "Sesi $_pr9Session: sisa ${_maxCount - _counter}x",
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  )
                else
                  Text(
                    "Tap untuk menghitung",
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                const SizedBox(height: 16),
                Material(
                  color: _isCompleted
                      ? sageColor
                      : _maxCount < 999999 && _counter > 0
                          ? sageColor.withOpacity(0.3)
                          : sageColor,
                  borderRadius: BorderRadius.circular(40),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: _isCompleted ? null : _incrementCounter,
                    child: Container(
                      width: double.infinity,
                      height: 140,
                      alignment: Alignment.center,
                        child: _showCompletionAnim && _isCompleted
                            ? ScaleTransition(
                                scale: _checkAnim,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.check_circle_rounded,
                                        size: 48, color: bgColor),
                                    const SizedBox(height: 8),
                                    Text(
                                      _isPr9
                                          ? 'Selesai $_pr9Session!'
                                          : 'Selesai!',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: bgColor,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ScaleTransition(
                                    scale: Tween<double>(begin: 1.0, end: 1.08).animate(
                                      CurvedAnimation(
                                        parent: _counterPulseCtrl,
                                        curve: Curves.easeOut,
                                      ),
                                    ),
                                    child: Text(
                                      '$_counter',
                                      style: TextStyle(
                                        fontSize: 64,
                                        fontWeight: FontWeight.bold,
                                        color: _isCompleted
                                            ? Colors.white
                                            : bgColor,
                                      ),
                                    ),
                                  ),
                                  if (!_isPr9 || _pr9Session == 'malam')
                                    const SizedBox.shrink()
                                  else
                                    Text(
                                      '/ $_maxCount',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: _isCompleted
                                            ? Colors.white70
                                            : bgColor.withOpacity(0.6),
                                      ),
                                    ),
                                ],
                              ),
                    ),
                  ),
                ).animate(key: ValueKey(_counter)).scale(
                  begin: const Offset(0.96, 0.96),
                  end: const Offset(1.0, 1.0),
                  duration: 150.ms,
                  curve: Curves.easeOut,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
}
