import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'app_settings.dart';
import 'main.dart';

class DetailDoaPage extends StatefulWidget {
  final Map<String, dynamic> doaData;
  final List<Map<String, dynamic>> doaList;
  final int currentIndex;

  const DetailDoaPage({
    super.key,
    required this.doaData,
    this.doaList = const [],
    this.currentIndex = 0,
  });

  @override
  State<DetailDoaPage> createState() => _DetailDoaPageState();
}

class _DetailDoaPageState extends State<DetailDoaPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatingBarController;
  bool _floatingBarVisible = true;
  double _lastScrollOffset = 0;
  final ScrollController _scrollController = ScrollController();

  final sageColor = const Color(0xFFB2C8BA);
  final surfaceColor = const Color(0xFF242822);
  final bgColor = const Color(0xFF1A1C19);

  @override
  void initState() {
    super.initState();
    _floatingBarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      value: 1.0,
    );
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _floatingBarController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    final delta = offset - _lastScrollOffset;
    _lastScrollOffset = offset;
    if (delta > 8 && _floatingBarVisible) {
      setState(() => _floatingBarVisible = false);
      _floatingBarController.reverse();
    } else if (delta < -8 && !_floatingBarVisible) {
      setState(() => _floatingBarVisible = true);
      _floatingBarController.forward();
    }
  }

  void _navigate(int index) {
    if (index < 0 || index >= widget.doaList.length) return;
    if (AppSettings().hapticEnabled) HapticFeedback.lightImpact();
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => DetailDoaPage(
          doaData: widget.doaList[index],
          doaList: widget.doaList,
          currentIndex: index,
        ),
        transitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                  parent: animation, curve: Curves.easeOutCubic)),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = AppSettings();
    final bg = bgColor;
    final surface = surfaceColor;
    const textColor = Colors.white;

    final String title = widget.doaData['title'] ?? 'Detail Doa';
    final String arabic = widget.doaData['arabic'] ?? '';
    final String latin = widget.doaData['latin'] ?? '';
    final String translation = widget.doaData['translation'] ?? '';
    final String notes = widget.doaData['notes'] ?? '';

    final hasPrev = widget.doaList.isNotEmpty && widget.currentIndex > 0;
    final hasNext = widget.doaList.isNotEmpty &&
        widget.currentIndex < widget.doaList.length - 1;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text(title,
            style: TextStyle(
                fontWeight: FontWeight.w500, fontSize: 17, color: textColor)),
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 160),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (arabic.isNotEmpty) ...[
                  Text(
                    arabic,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        fontFamily: 'LPMQ',
                        fontSize: settings.arabicFontSize + 4,
                        color: sageColor,
                        height: 1.9),
                  ).animate().fadeIn(duration: 400.ms),
                  const SizedBox(height: 24),
                ],
                if (latin.isNotEmpty) ...[
                  Text(
                    latin,
                    style: TextStyle(
                        fontSize: 16,
                        color: textColor,
                        fontWeight: FontWeight.w500,
                        height: 1.6),
                  ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                  const SizedBox(height: 12),
                ],
                if (translation.isNotEmpty) ...[
                  Text(
                    translation,
                    style: TextStyle(
                        color: textColor.withOpacity(0.6),
                        fontSize: 15,
                        height: 1.5),
                  ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                  const SizedBox(height: 32),
                ],
                if (notes.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
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
                              color: sageColor, size: 18),
                          const SizedBox(width: 8),
                          Text('Keterangan:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: sageColor,
                                  fontSize: 13)),
                        ]),
                        const SizedBox(height: 12),
                        Text(
                          notes,
                          style: TextStyle(
                              color: textColor.withOpacity(0.7),
                              fontSize: 14,
                              height: 1.6),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 300.ms, duration: 350.ms)
                      .slideY(begin: 0.05),
              ],
            ),
          ),

          // ── Floating Navigation Bar ──────────────────────────────
          if (widget.doaList.isNotEmpty)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: AnimatedBuilder(
                animation: _floatingBarController,
                builder: (_, child) {
                final springVal = Curves.elasticOut.transform(_floatingBarController.value);
                final clamped = springVal.clamp(0.0, 1.2);
                return Transform.translate(
                  offset: Offset(0, 100 * (1 - clamped)),
                  child: Opacity(
                    opacity: _floatingBarController.value.clamp(0.0, 1.0),
                    child: Transform.scale(
                      scale: 0.8 + (0.2 * clamped),
                      child: child,
                    ),
                  ),
                );
              },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2D27).withOpacity(0.97),
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Row(
                    children: [
                      if (hasPrev)
                        _NavBtn(
                          icon: Icons.arrow_back_ios_rounded,
                          onTap: () => _navigate(widget.currentIndex - 1),
                          sageColor: sageColor,
                        )
                      else
                        const SizedBox(width: 56),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.white),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              '${widget.currentIndex + 1} / ${widget.doaList.length}',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white38),
                            ),
                          ],
                        ),
                      ),
                      if (hasNext)
                        _NavBtn(
                          icon: Icons.arrow_forward_ios_rounded,
                          onTap: () => _navigate(widget.currentIndex + 1),
                          sageColor: sageColor,
                        )
                      else
                        const SizedBox(width: 56),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Nav Button ───────────────────────────────────────────────────────────────
class _NavBtn extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color sageColor;

  const _NavBtn(
      {required this.icon, required this.onTap, required this.sageColor});

  @override
  State<_NavBtn> createState() => _NavBtnState();
}

class _NavBtnState extends State<_NavBtn> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: widget.sageColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Icon(widget.icon, color: widget.sageColor, size: 18),
        ),
      ),
    );
  }
}
