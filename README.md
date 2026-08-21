# 📖 Kita 46.2

> **All-in-one mobile utility application** untuk membaca literatur digital dan mengelola jadwal harian secara praktis dan efisien.

---

## 📌 Tentang Aplikasi

**Kita 46.2** dirancang untuk menyederhanakan kebutuhan harian pengguna dalam mengakses literatur terdigitalisasi—menggantikan beban membawa banyak buku fisik ke dalam satu genggaman—sekaligus menyediakan utilitas manajemen jadwal yang intuitif dan mudah digunakan.

Aplikasi ini mengusung antarmuka yang bersih (*clean UI*), performa ringan, serta alur navigasi yang terfokus pada kenyamanan membaca dan produktivitas.

---

## ✨ Fitur Utama

- 📚 **Digital Literature Reader**: Akses cepat ke berbagai teks dan dokumen digital terstruktur tanpa repot membawa buku fisik.
- 📅 **Schedule & Daily Manager**: Manajemen jadwal kegiatan harian yang terintegrasi dan mudah disesuaikan.
- ⚡ **Minimalist & Clean Interface**: Desain antarmuka modern yang nyaman di mata untuk sesi membaca lama.
- 🔍 **Fast Search & Navigation**: Temukan bab, teks, atau jadwal tertentu dalam hitungan detik.
- 📱 **Offline & Cloud Sync**: Sinkronisasi data yang andal dan tetap nyaman digunakan kapan saja.

---

## 🛠️ Tech Stack

- **Flutter**
- **Dart**
- **Firebase**

---

## 📁 Struktur Proyek

```text
lib/
├── core/            # Utilitas global, tema, konstanta, dan helper
├── features/        # Fitur modular (reader, schedule, dll.)
│   ├── reader/
│   │   ├── models/
│   │   ├── services/
│   │   └── screens/
│   └── schedule/
│       ├── models/
│       ├── services/
│       └── screens/
└── main.dart        # Entry point aplikasi
