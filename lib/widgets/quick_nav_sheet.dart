// lib/widgets/quick_nav_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../app_settings.dart';

class QuickNavSheet extends StatefulWidget {
  final List<QuickNavItem> items;
  final Color sageColor;
  final Color bgColor;
  final Color surfaceColor;

  const QuickNavSheet({
    super.key,
    required this.items,
    required this.sageColor,
    required this.bgColor,
    required this.surfaceColor,
  });

  @override
  State<QuickNavSheet> createState() => _QuickNavSheetState();
}

class _QuickNavSheetState extends State<QuickNavSheet>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  void _toggle() {
    if (AppSettings().hapticEnabled) HapticFeedback.lightImpact();
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _rotationController.forward();
      } else {
        _rotationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = const Color(0xFF2A2D27);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
      decoration: BoxDecoration(
        color: widget.bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle + Header
          GestureDetector(
            onTap: _toggle,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _isExpanded ? "Tutup Menu" : "Menu Cepat",
                    style: TextStyle(
                      color: widget.sageColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  RotationTransition(
                    turns: Tween(begin: 0.0, end: 0.5)
                        .animate(_rotationController),
                    child: Icon(
                      Icons.keyboard_arrow_up_rounded,
                      color: widget.sageColor,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Grid Menu (hanya muncul saat expanded)
          AnimatedCrossFade(
            firstChild: const SizedBox(height: 0),
            secondChild: Padding(
              padding:
                  const EdgeInsets.only(left: 16, right: 16, bottom: 20),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.85,
                children: widget.items.asMap().entries.map((entry) {
                  final i = entry.key;
                  final item = entry.value;
                  return _QuickNavItemWidget(
                    item: item,
                    cardColor: cardColor,
                    sageColor: widget.sageColor,
                    delay: Duration(milliseconds: i * 50),
                  );
                }).toList(),
              ),
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }
}

class _QuickNavItemWidget extends StatefulWidget {
  final QuickNavItem item;
  final Color cardColor;
  final Color sageColor;
  final Duration delay;

  const _QuickNavItemWidget({
    required this.item,
    required this.cardColor,
    required this.sageColor,
    required this.delay,
  });

  @override
  State<_QuickNavItemWidget> createState() => _QuickNavItemWidgetState();
}

class _QuickNavItemWidgetState extends State<_QuickNavItemWidget> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        if (AppSettings().hapticEnabled) HapticFeedback.lightImpact();
        widget.item.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.93 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          decoration: BoxDecoration(
            color: widget.cardColor,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: widget.item.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  widget.item.icon,
                  color: widget.item.color,
                  size: 22,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.item.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ).animate(delay: widget.delay).fadeIn(duration: 250.ms).scale(
              begin: const Offset(0.8, 0.8),
              duration: 250.ms,
              curve: Curves.easeOutBack,
            ),
      ),
    );
  }
}

class QuickNavItem {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const QuickNavItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}
