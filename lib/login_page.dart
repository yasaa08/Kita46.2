import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'main.dart';
import 'app_settings.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoadingGoogle = false;
  bool _isLoadingGuest = false;

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoadingGoogle = true);
    try {
      if (AppSettings().hapticEnabled) HapticFeedback.mediumImpact();

      // google_sign_in v7.x: gunakan instance singleton + initialize
      // Tidak perlu serverClientId jika google-services.json sudah benar dan hanya butuh Firebase auth
      await GoogleSignIn.instance.initialize();

      GoogleSignInAccount? googleUser;

      if (GoogleSignIn.instance.supportsAuthenticate()) {
        googleUser = await GoogleSignIn.instance.authenticate();
      } else {
        throw Exception('Platform tidak mendukung Google Sign-In');
      }

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          _buildPageRoute(const HomePage()),
        );
      }
    } catch (e) {
      if (mounted) {
        String errMsg = "Gagal masuk: $e";

        // Cek jika error adalah karena SHA-1 belum didaftarkan di Firebase
        if (e.toString().contains('[16]')) {
          errMsg =
              "Error [16]: SHA-1 Debug Key belum ditambahkan di Firebase Console. Buka Terminal -> jalankan 'cd android && gradlew signingReport' lalu copy SHA-1 ke setelan Firebase.";
        }

        showTopNotification(context, errMsg,
            bgColor: Colors.redAccent);
      }
    } finally {
      if (mounted) setState(() => _isLoadingGoogle = false);
    }
  }

  Future<void> _signInAnonymously() async {
    setState(() => _isLoadingGuest = true);
    try {
      if (AppSettings().hapticEnabled) HapticFeedback.lightImpact();
      await FirebaseAuth.instance.signInAnonymously();
      if (mounted) {
        Navigator.pushReplacement(context, _buildPageRoute(const HomePage()));
      }
    } catch (e) {
      if (mounted) {
        showTopNotification(context, "Error: $e",
            bgColor: Colors.redAccent);
      }
    } finally {
      if (mounted) setState(() => _isLoadingGuest = false);
    }
  }

  PageRoute _buildPageRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, animation, __) => page,
      transitionDuration: const Duration(milliseconds: 400),
      transitionsBuilder: (_, animation, __, child) => FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sageGreen = const Color(0xFFB2C8BA);
    const bgColor = Color(0xFF1A1C19);
    const surfaceColor = Color(0xFF242822);
    const textColor = Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Logo
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: sageGreen.withOpacity(0.15),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Image.asset('assets/images/kita462logo.png', height: 72),
              ).animate().fadeIn(duration: 600.ms, delay: 200.ms).scale(
                  begin: const Offset(0.8, 0.8),
                  duration: 600.ms,
                  curve: Curves.easeOutBack),

              const SizedBox(height: 40),

              Text(
                "Kita 46.2",
                style: TextStyle(
                  color: sageGreen,
                  fontSize: 34,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 1.0,
                ),
              )
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 500.ms)
                  .slideY(begin: 0.2),

              const SizedBox(height: 12),

              Text(
                "Teman ibadah harianmu.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor.withOpacity(0.5),
                  fontSize: 16,
                  height: 1.5,
                ),
              ).animate().fadeIn(delay: 600.ms, duration: 500.ms),

              const Spacer(flex: 3),

              // Google Sign In Button
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: _isLoadingGoogle ? null : _signInWithGoogle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: sageGreen,
                    foregroundColor: const Color(0xFF1A1C19),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
                  ),
                  child: _isLoadingGoogle
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF1A1C19),
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.login_rounded, size: 20),
                            SizedBox(width: 10),
                            Text(
                              "Masuk dengan Google",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                ),
              )
                  .animate()
                  .fadeIn(delay: 800.ms, duration: 500.ms)
                  .slideY(begin: 0.3),

              const SizedBox(height: 16),

              // Guest Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: _isLoadingGuest ? null : _signInAnonymously,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: sageGreen,
                    side: BorderSide(color: sageGreen.withOpacity(0.3)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
                  ),
                  child: _isLoadingGuest
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: sageGreen,
                          ),
                        )
                      : Text(
                          "Masuk sebagai Tamu",
                          style: TextStyle(
                            color: sageGreen.withOpacity(0.8),
                            fontSize: 15,
                          ),
                        ),
                ),
              )
                  .animate()
                  .fadeIn(delay: 950.ms, duration: 500.ms)
                  .slideY(begin: 0.3),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
