import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'main.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  // 1. FUNGSI LOGIN GOOGLE
  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      final googleSignIn = GoogleSignIn.instance;
      await googleSignIn.initialize(
        serverClientId: '343296288430-k8avc2kauot2ms4umf7vplqc5mf1j8sj.apps.googleusercontent.com',
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.authenticate();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      
      if (context.mounted) {
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (context) => const HomePage())
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  // 2. FUNGSI LOGIN TAMU (ANONYMOUS)
  Future<void> _signInAnonymously(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signInAnonymously();
      if (context.mounted) {
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (context) => const HomePage())
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error Tamu: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sageGreen = const Color(0xFFB2C8BA);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1C19),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),
            // Logo dibuat lebih subtle
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF242822),
                shape: BoxShape.circle,
              ),
              child: Image.asset('assets/images/kita462logo.png', height: 80),
            ),
            const SizedBox(height: 48),
            Text(
              "Kita 46.2",
              style: TextStyle(
                color: sageGreen,
                fontSize: 32,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Teman ibadah harianmu.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 16, height: 1.5),
            ),
            const Spacer(),
            
            // Tombol Utama ala Pixel
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                onPressed: () => _signInWithGoogle(context),
                style: FilledButton.styleFrom(
                  backgroundColor: sageGreen,
                  foregroundColor: const Color(0xFF1A1C19),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.login),
                label: const Text("Masuk dengan Google", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            
            const SizedBox(height: 16),
            
            TextButton(
              onPressed: () => _signInAnonymously(context),
              child: Text(
                "Masuk sebagai Tamu",
                style: TextStyle(color: sageGreen.withOpacity(0.7)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}