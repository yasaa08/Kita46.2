import 'package:flutter/material.dart'; // Wajib untuk BuildContext dan Color
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. Getter UID agar selalu mendapatkan ID terbaru (mencegah error saat logout-login)
  String? get uid => FirebaseAuth.instance.currentUser?.uid;

  // 2. Cek apakah user adalah tamu (Anonymous)
  bool get isGuest => FirebaseAuth.instance.currentUser?.isAnonymous ?? true;

  // 3. Simpan riwayat terakhir baca surah
  Future<void> saveLastReadSurah({
    required int surahNumber,
    required String surahName,
    required int ayahNumber,
  }) async {
    // PROTEKSI: Jika user belum login atau dia adalah TAMU, jangan simpan ke database
    if (uid == null || isGuest) return;

    await _db.collection('users').doc(uid).set({
      'last_read_surah': {
        'number': surahNumber,
        'name': surahName,
        'ayah': ayahNumber,
        'updated_at': FieldValue.serverTimestamp(),
      }
    }, SetOptions(merge: true));
  }

  // 4. Simpan ringkasan dzikir PR 13 (format: last_pr13_title + last_pr13_count)
  Future<void> saveLastDzikir({
    required String title,
    required int counter,
  }) async {
    // PROTEKSI: Jika user belum login atau dia adalah TAMU, jangan simpan ke database
    if (uid == null || isGuest) return;

    await _db.collection('users').doc(uid).set({
      'last_pr13_title': title,
      'last_pr13_count': counter,
    }, SetOptions(merge: true));
  }

  // 5. Mengambil aliran data (stream) riwayat user
  Stream<DocumentSnapshot> get userHistory {
    if (uid == null) {
      // Jika logout, kirim stream kosong agar tidak error
      return const Stream.empty();
    }
    return _db.collection('users').doc(uid).snapshots();
  }
}

// FUNGSI GLOBAL: Dialog untuk membatasi fitur Tamu
void tampilkanDialogLogin(BuildContext context) {
  final surface = const Color(0xFF242822);
  final textColor = Colors.white;
  
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      title: Row(
        children: [
          const Icon(Icons.lock_outline, color: Colors.orange),
          const SizedBox(width: 10),
          Text("Akses Terbatas", style: TextStyle(color: textColor)),
        ],
      ),
      content: Text(
        "Fitur simpan hanya tersedia untuk pengguna yang sudah login. Yuk masuk pakai Google agar riwayatmu aman!", 
        style: TextStyle(color: textColor.withOpacity(0.6))
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), 
          child: Text("Nanti saja", style: TextStyle(color: textColor.withOpacity(0.4)))
        ),
        ElevatedButton(
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            if (context.mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            }
          }, 
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFB2C8BA),
            foregroundColor: const Color(0xFF1A1C19),
          ),
          child: const Text("Login Sekarang"),
        ),
      ],
    ),
  );
}