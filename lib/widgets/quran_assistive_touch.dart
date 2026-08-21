import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../app_settings.dart';
import '../quick_access_service.dart';
import '../main.dart';

class QuranAssistiveTouch extends StatefulWidget {
  final ScrollController scrollController;
  final int surahNumber;
  final String surahName;
  final String revelation;
  final int totalVerses;
  final List<dynamic> allSurahList;
  final Function(int targetAyah) onJumpToAyah;
  final Function(Map<String, dynamic> surah) onJumpToSurah;
  final VoidCallback onOpenDisplaySettings;

  const QuranAssistiveTouch({
    super.key,
    required this.scrollController,
    required this.surahNumber,
    required this.surahName,
    required this.revelation,
    required this.totalVerses,
    required this.allSurahList,
    required this.onJumpToAyah,
    required this.onJumpToSurah,
    required this.onOpenDisplaySettings,
  });

  @override
  State<QuranAssistiveTouch> createState() => _QuranAssistiveTouchState();
}

class _QuranAssistiveTouchState extends State<QuranAssistiveTouch>
    with TickerProviderStateMixin {
  // Position
  double _x = 0;
  double _y = 0;
  bool _isInitialized = false;

  // Auto dimming
  bool _isDimmed = false;
  Timer? _dimTimer;

  // Auto scroll
  bool _isAutoScrolling = false;
  bool _isAutoScrollPaused = false;
  double _autoScrollSpeed = 1.0; // 1.0 = normal, 2.0 = fast, 3.0 = very fast
  Timer? _autoScrollTimer;

  // Colors & styling
  final Color _sageColor = const Color(0xFFB2C8BA);
  final Color _surfaceColor = const Color(0xFF242822);
  final Color _bgColor = const Color(0xFF1A1C19);

  final QuickAccessService _quickAccess = QuickAccessService();
  final AppSettings _settings = AppSettings();

  @override
  void initState() {
    super.initState();
    _startDimTimer();
  }

  @override
  void dispose() {
    _dimTimer?.cancel();
    _stopAutoScroll();
    super.dispose();
  }

  void _startDimTimer() {
    _dimTimer?.cancel();
    _dimTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && !_isAutoScrolling) {
        setState(() => _isDimmed = true);
      }
    });
  }

  void _wakeUp() {
    _startDimTimer();
    if (_isDimmed) {
      setState(() => _isDimmed = false);
    }
  }

  // ── Auto Scroll Engine ──────────────────────────────────────────────────────

  void _toggleAutoScroll() {
    if (_isAutoScrolling) {
      _stopAutoScroll();
    } else {
      _startAutoScroll();
    }
  }

  void _startAutoScroll() {
    _wakeUp();
    setState(() {
      _isAutoScrolling = true;
      _isAutoScrollPaused = false;
    });

    _autoScrollTimer?.cancel();
    _autoScrollTimer =
        Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_isAutoScrollPaused) return;

      if (widget.scrollController.hasClients) {
        final max = widget.scrollController.position.maxScrollExtent;
        final current = widget.scrollController.offset;
        final step = 0.9 * _autoScrollSpeed;

        if (current + step < max) {
          widget.scrollController.jumpTo(current + step);
        } else {
          _stopAutoScroll();
        }
      }
    });
  }

  void _pauseResumeAutoScroll() {
    if (_settings.hapticEnabled) HapticFeedback.selectionClick();
    setState(() {
      _isAutoScrollPaused = !_isAutoScrollPaused;
    });
  }

  void _changeAutoScrollSpeed() {
    if (_settings.hapticEnabled) HapticFeedback.selectionClick();
    setState(() {
      if (_autoScrollSpeed == 1.0) {
        _autoScrollSpeed = 2.0;
      } else if (_autoScrollSpeed == 2.0) {
        _autoScrollSpeed = 3.0;
      } else {
        _autoScrollSpeed = 1.0;
      }
    });
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
    if (mounted) {
      setState(() {
        _isAutoScrolling = false;
        _isAutoScrollPaused = false;
      });
      _startDimTimer();
    }
  }

  // ── Menu Modal ─────────────────────────────────────────────────────────────

  void _openAssistiveMenu() {
    _wakeUp();
    if (_settings.hapticEnabled) HapticFeedback.mediumImpact();

    showModalBottomSheet(
      context: context,
      backgroundColor: _bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (ctx) {
        final isPinned = _quickAccess.hasItem('surah_${widget.surahNumber}');
        const textColor = Colors.white;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _sageColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.touch_app_rounded,
                              color: _sageColor, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Assistive Touch",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            Text(
                              "Navigasi & Alat Membaca Cepat",
                              style: TextStyle(
                                fontSize: 12,
                                color: textColor.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    // 4 Grid Feature Cards
                    Row(
                      children: [
                        // Feature 1: Auto Scroll
                        Expanded(
                          child: _buildMenuCard(
                            icon: _isAutoScrolling
                                ? Icons.pause_circle_filled_rounded
                                : Icons.play_circle_fill_rounded,
                            iconColor: _sageColor,
                            title: "Auto Scroll",
                            subtitle: _isAutoScrolling
                                ? "Sedang berjalan"
                                : "Scroll santai",
                            onTap: () {
                              Navigator.pop(ctx);
                              _toggleAutoScroll();
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Feature 2: Lompat Ayat / Surat
                        Expanded(
                          child: _buildMenuCard(
                            icon: Icons.rocket_launch_rounded,
                            iconColor: const Color(0xFFD2E0FB),
                            title: "Lompat Surat/Ayat",
                            subtitle: "Cari ayat & surat",
                            onTap: () {
                              Navigator.pop(ctx);
                              _showJumpDialog();
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        // Feature 3: Quick Access
                        Expanded(
                          child: _buildMenuCard(
                            icon: isPinned
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            iconColor: const Color(0xFFEADFB4),
                            title: isPinned ? "Hapus Pin" : "Quick Access",
                            subtitle: isPinned
                                ? "Sudah disematkan"
                                : "Pin ke Beranda",
                            onTap: () async {
                              final user = FirebaseAuth.instance.currentUser;
                              if (user == null || user.isAnonymous) {
                                if (ctx.mounted) Navigator.pop(ctx);
                                if (context.mounted) {
                                  showTopNotification(
                                    context,
                                    "Harap login terlebih dahulu untuk menyimpan ke Quick Access",
                                  );
                                }
                                return;
                              }

                              final id = 'surah_${widget.surahNumber}';
                              if (isPinned) {
                                await _quickAccess.removeItem(id);
                                if (context.mounted) {
                                  showTopNotification(
                                      context, "Dihapus dari Quick Access");
                                }
                              } else {
                                await _quickAccess.addItem(QuickAccessItem(
                                  id: id,
                                  title: widget.surahName,
                                  type: 'surah',
                                  data: {
                                    'number': widget.surahNumber,
                                    'name': widget.surahName,
                                    'revelation': widget.revelation,
                                  },
                                ));
                                if (context.mounted) {
                                  showTopNotification(context,
                                      "${widget.surahName} ditambahkan ke Quick Access! ⭐");
                                }
                              }
                              if (ctx.mounted) {
                                setSheetState(() {});
                                Navigator.pop(ctx);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Feature 4: Tampilan Cepat
                        Expanded(
                          child: _buildMenuCard(
                            icon: Icons.text_format_rounded,
                            iconColor: const Color(0xFFFFE5E5),
                            title: "Tampilan",
                            subtitle: "Font, ukuran & arti",
                            onTap: () {
                              Navigator.pop(ctx);
                              widget.onOpenDisplaySettings();
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    const textColor = Colors.white;

    return InkWell(
      onTap: () {
        if (_settings.hapticEnabled) HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.06),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: textColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: textColor.withOpacity(0.45),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ── Jump to Surah / Ayah Dialog ───────────────────────────────────────────

  void _showJumpDialog() {
    int selectedSurahNum = widget.surahNumber;
    final ayahController = TextEditingController();
    String? errorText;
    const textColor = Colors.white;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final currentSurahData = widget.allSurahList.firstWhere(
              (s) => (s['number'] as int?) == selectedSurahNum,
              orElse: () => <String, dynamic>{
                'name': widget.surahName,
                'numberOfAyahs': widget.totalVerses,
              },
            );
            final maxAyahs =
                (currentSurahData['numberOfAyahs'] as int?) ?? widget.totalVerses;

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD2E0FB).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.rocket_launch_rounded,
                            color: Color(0xFFD2E0FB), size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Lompat ke Surat & Ayat",
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: textColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Surat Dropdown (Hanya nama surat, tanpa tulisan ayat)
                  Text("Pilih Surat",
                      style: TextStyle(
                          color: textColor.withOpacity(0.5), fontSize: 12)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: _surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: selectedSurahNum,
                        dropdownColor: _surfaceColor,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded,
                            color: Colors.white70),
                        items: widget.allSurahList.map((s) {
                          final num = s['number'] as int;
                          final name = s['name'] as String;
                          return DropdownMenuItem<int>(
                            value: num,
                            child: Text(
                              "$num. $name",
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 14),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setSheetState(() {
                              selectedSurahNum = val;
                              ayahController.clear();
                              errorText = null;
                            });
                          }
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Ayat Input with Live Validation
                  Text("Nomor Ayat",
                      style: TextStyle(
                          color: textColor.withOpacity(0.5), fontSize: 12)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: ayahController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                    onChanged: (val) {
                      final input = int.tryParse(val.trim());
                      setSheetState(() {
                        if (val.trim().isNotEmpty) {
                          if (input == null || input < 1) {
                            errorText = "Nomor ayat minimal 1";
                          } else if (input > maxAyahs) {
                            errorText =
                                "Surat ini hanya memiliki $maxAyahs ayat";
                          } else {
                            errorText = null;
                          }
                        } else {
                          errorText = null;
                        }
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Contoh: 1",
                      hintStyle: TextStyle(color: textColor.withOpacity(0.3)),
                      filled: true,
                      fillColor: errorText != null
                          ? Colors.redAccent.withOpacity(0.1)
                          : _surfaceColor,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: errorText != null
                            ? const BorderSide(
                                color: Colors.redAccent, width: 1.5)
                            : BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: errorText != null
                            ? const BorderSide(
                                color: Colors.redAccent, width: 1.5)
                            : BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: errorText != null
                              ? Colors.redAccent
                              : _sageColor,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Helper / Error Text
                  if (errorText != null)
                    Row(
                      children: [
                        const Icon(Icons.error_outline_rounded,
                            color: Colors.redAccent, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          errorText!,
                          style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    )
                  else
                    Text(
                      "Surat ini memiliki $maxAyahs ayat (1 - $maxAyahs)",
                      style: TextStyle(
                          color: textColor.withOpacity(0.4), fontSize: 11),
                    ),

                  const SizedBox(height: 24),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        if (errorText != null) {
                          if (_settings.hapticEnabled) {
                            HapticFeedback.vibrate();
                          }
                          return;
                        }

                        final inputAyah =
                            int.tryParse(ayahController.text.trim()) ?? 1;
                        if (inputAyah > maxAyahs) {
                          setSheetState(() {
                            errorText =
                                "Surat ini hanya memiliki $maxAyahs ayat";
                          });
                          return;
                        }

                        final clampedAyah = inputAyah.clamp(1, maxAyahs);
                        Navigator.pop(ctx);

                        if (selectedSurahNum == widget.surahNumber) {
                          // Jump directly inside this surah
                          widget.onJumpToAyah(clampedAyah);
                        } else {
                          // Change surah & target ayah
                          final targetSurah = widget.allSurahList.firstWhere(
                            (s) => s['number'] == selectedSurahNum,
                            orElse: () => null,
                          );
                          if (targetSurah != null) {
                            widget.onJumpToSurah(targetSurah);
                          }
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: errorText != null
                            ? Colors.redAccent.withOpacity(0.4)
                            : _sageColor,
                        foregroundColor: _bgColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text("Buka & Lompat Sekarang",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ── Build Draggable Floating Button & Auto-Scroll Controller ───────────────

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final safePadding = MediaQuery.of(context).padding;

    // Initial positioning at bottom right
    if (!_isInitialized) {
      _x = screenSize.width - 68;
      _y = screenSize.height - 230;
      _isInitialized = true;
    }

    const pillWidth = 148.0;
    final mid = screenSize.width / 2;
    final currentX = _isAutoScrolling
        ? (_x > mid
            ? (_x + 52.0 - pillWidth)
                .clamp(16.0, screenSize.width - pillWidth - 16.0)
            : _x.clamp(16.0, screenSize.width - pillWidth - 16.0))
        : _x.clamp(12.0, screenSize.width - 64.0);

    return Positioned(
      left: currentX,
      top: _y,
      child: _isAutoScrolling
          ? _buildAutoScrollControlPill()
          : _buildDraggableTouchDot(screenSize, safePadding),
    );
  }

  /// Compact floating controller while auto-scrolling
  Widget _buildAutoScrollControlPill() {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: _surfaceColor.withOpacity(0.96),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: _sageColor.withOpacity(0.4), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Play / Pause Button
            InkWell(
              onTap: _pauseResumeAutoScroll,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _sageColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isAutoScrollPaused
                      ? Icons.play_arrow_rounded
                      : Icons.pause_rounded,
                  color: _sageColor,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Speed Button
            InkWell(
              onTap: _changeAutoScrollSpeed,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "${_autoScrollSpeed.toInt()}x",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Stop Button (Returns to AssistiveTouch)
            InkWell(
              onTap: () {
                if (_settings.hapticEnabled) HapticFeedback.lightImpact();
                _stopAutoScroll();
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 200.ms).scale(begin: const Offset(0.85, 0.85));
  }

  /// iOS-style floating draggable dot with auto-dimming
  Widget _buildDraggableTouchDot(Size screenSize, EdgeInsets safePadding) {
    return GestureDetector(
      onPanDown: (_) => _wakeUp(),
      onPanUpdate: (details) {
        _wakeUp();
        setState(() {
          _x += details.delta.dx;
          _y += details.delta.dy;

          // Clamp within screen bounds
          _x = _x.clamp(12.0, screenSize.width - 64.0);
          _y = _y.clamp(safePadding.top + 50.0, screenSize.height - 180.0);
        });
      },
      onPanEnd: (details) {
        // Snap smoothly to left or right edge
        final mid = screenSize.width / 2;
        setState(() {
          if (_x < mid) {
            _x = 16.0; // Snap left
          } else {
            _x = screenSize.width - 68.0; // Snap right
          }
        });
        _startDimTimer();
      },
      onTap: _openAssistiveMenu,
      child: AnimatedOpacity(
        opacity: _isDimmed ? 0.28 : 0.95,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFF1E211C).withOpacity(0.92),
            shape: BoxShape.circle,
            border: Border.all(
              color: _sageColor.withOpacity(_isDimmed ? 0.2 : 0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_isDimmed ? 0.15 : 0.35),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer ring
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _sageColor.withOpacity(0.4),
                      width: 2,
                    ),
                  ),
                ),
                // Inner center core
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _sageColor.withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
