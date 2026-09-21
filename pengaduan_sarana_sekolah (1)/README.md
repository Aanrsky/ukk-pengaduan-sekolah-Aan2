# Pengaduan Sarana SMP Negeri 3 Bantul

Aplikasi Pengaduan Sarana SMP Negeri 3 Bantul adalah aplikasi berbasis Flutter yang digunakan untuk membantu siswa menyampaikan pengaduan mengenai sarana dan prasarana sekolah.

## Identitas Project

**Nama Project:** Pengaduan Sarana SMP Negeri 3 Bantul  
**Jenis Project:** UKK RPL  
**Platform:** Android  
**Framework:** Flutter  
**Backend:** Firebase  
**Database:** Cloud Firestore  
**Authentication:** Firebase Authentication  
**Storage:** Firebase Storage  

## Studi Kasus

Aplikasi ini dibuat untuk mempermudah proses penyampaian dan pengelolaan pengaduan sarana sekolah.

Siswa dapat membuat pengaduan mengenai sarana sekolah yang mengalami kerusakan atau membutuhkan penanganan. Admin dapat melihat pengaduan yang masuk, memperbarui status pengaduan, serta memberikan feedback kepada siswa.

## Fitur Aplikasi

### Siswa
- Registrasi akun
- Login
- Membuat pengaduan
- Mengisi nama, judul, deskripsi, dan kategori pengaduan
- Menambahkan foto pengaduan
- Melihat riwayat pengaduan sendiri
- Melihat tanggal pengaduan
- Melihat status terbaru pengaduan
- Melihat feedback dari admin

### Admin
- Login admin
- Melihat seluruh pengaduan siswa
- Melihat detail pengaduan
- Melihat foto pengaduan
- Memperbarui status pengaduan
- Memberikan feedback kepada siswa
- Melakukan filter pengaduan

## Alur Aplikasi

1. Siswa melakukan registrasi atau login.
2. Siswa membuat pengaduan sarana sekolah.
3. Pengaduan tersimpan ke Firebase.
4. Admin menerima dan melihat pengaduan.
5. Admin memperbarui status pengaduan.
6. Admin memberikan feedback.
7. Siswa dapat melihat status dan feedback melalui riwayat pengaduan.

## Teknologi yang Digunakan

- Flutter
- Dart
- Firebase Authentication
- Cloud Firestore
- Firebase Storage
- Image Picker
- PDF
- Printing

## Struktur Project

```text
pengaduan_sarana_sekolah/
├── android/
├── assets/
├── lib/
│   ├── pages/
│   ├── services/
│   ├── models/
│   └── main.dart
├── web/
├── pubspec.yaml
└── README.md
