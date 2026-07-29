// lib/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _lottieController;
  bool _hasNavigated = false;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    // Tidak menggunakan immersive mode agar tidak ada "jump"/perubahan layout
    // saat pindah ke Home Screen.

    _lottieController = AnimationController(vsync: this);
    _lottieController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateToHome();
      }
    });
  }

  void _navigateToHome() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomePage(),
        transitionDuration: const Duration(milliseconds: 600),
        transitionsBuilder: (_, animation, __, child) {
          // Transisi fade mulus
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF1A1C19);

    return Scaffold(
      backgroundColor: bgColor,
      // SafeArea ditiadakan agar background full cover layar
      body: Center(
        child: ColorFiltered(
          colorFilter: const ColorFilter.mode(
            Color(0xFFB2C8BA),
            BlendMode.srcIn,
          ),
          child: Lottie.asset(
            'assets/lottie_splash/bismillah.json',
            controller: _lottieController,
            onLoaded: (composition) {
              setState(() => _isLoaded = true);
              _lottieController
                ..duration = composition.duration
                ..forward();
            },
            width: 280,
            height: 280,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              debugPrint('Lottie error: $error');
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _navigateToHome();
              });
              return const SizedBox.shrink();
            },
          ),
        ).animate(target: _isLoaded ? 1 : 0).fadeIn(duration: 400.ms),
        // Fade in perlahan agar tidak kaku saat pertama kali muncul
      ),
    );
  }
}
