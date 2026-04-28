import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String? uid = FirebaseAuth.instance.currentUser?.uid;

  // Menyimpan riwayat terakhir baca surah
  Future<void> saveLastReadSurah({
    required int surahNumber,
    required String surahName,
    required int ayahNumber,
  }) async {
    if (uid == null) return;
    await _db.collection('users').doc(uid).set({
      'last_read_surah': {
        'number': surahNumber,
        'name': surahName,
        'ayah': ayahNumber,
        'updated_at': FieldValue.serverTimestamp(),
      }
    }, SetOptions(merge: true));
  }

  // Menyimpan riwayat terakhir dzikir
  Future<void> saveLastDzikir({
    required String category, 
    required String title,
    required int counter,
  }) async {
    if (uid == null) return;
    await _db.collection('users').doc(uid).set({
      'last_dzikir': {
        'category': category,
        'title': title,
        'counter': counter,
        'updated_at': FieldValue.serverTimestamp(),
      }
    }, SetOptions(merge: true));
  }

  // Mengambil aliran data (stream) riwayat user
  Stream<DocumentSnapshot> get userHistory => 
      _db.collection('users').doc(uid).snapshots();
}