[# Aplikasi Pengaduan Sarana SMP Negeri 3 Bantul

Aplikasi Pengaduan Sarana SMP Negeri 3 Bantul merupakan aplikasi berbasis Flutter yang dibuat untuk membantu siswa melaporkan permasalahan sarana dan prasarana di lingkungan sekolah. Pengaduan yang dikirim siswa dapat dipantau dan ditindaklanjuti oleh admin.

## Identitas Project

**Nama Pengembang:** Aan Risy Ramadhanni  
**Kelas:** RPL 2  
**Nama Project:** Pengaduan Sarana SMP Negeri 3 Bantul  
**Jenis Project:** UKK RPL  
**Platform:** Android  
**Framework:** Flutter  
**Bahasa Pemrograman:** Dart  
**Backend:** Firebase  
**Database:** Cloud Firestore  
**Autentikasi:** Firebase Authentication  
**Penyimpanan File:** Firebase Storage  

## Deskripsi Project

Aplikasi ini dikembangkan sebagai media pengaduan sarana sekolah. Siswa dapat mengirimkan laporan mengenai fasilitas sekolah yang rusak atau membutuhkan perbaikan.

Admin bertugas menerima dan memeriksa pengaduan yang masuk, kemudian memperbarui status serta memberikan feedback. Siswa dapat melihat perkembangan pengaduan melalui halaman riwayat.

## Fitur Aplikasi

### Fitur Siswa

- Registrasi akun
- Login pengguna
- Membuat pengaduan baru
- Memilih kategori pengaduan
- Mengisi judul dan deskripsi pengaduan
- Menambahkan foto sebagai bukti pengaduan
- Melihat riwayat pengaduan milik sendiri
- Melihat tanggal pengaduan
- Melihat status terbaru pengaduan
- Melihat feedback dari admin

### Fitur Admin

- Login admin
- Melihat daftar seluruh pengaduan
- Melihat detail pengaduan
- Melihat foto pengaduan
- Memperbarui status pengaduan
- Menambahkan feedback
- Melakukan filter data pengaduan

## Alur Sistem

1. Siswa melakukan registrasi atau login ke aplikasi.
2. Siswa mengisi formulir pengaduan.
3. Siswa dapat melampirkan foto pengaduan.
4. Data pengaduan disimpan ke Firebase.
5. Admin melihat pengaduan yang masuk.
6. Admin melakukan pemeriksaan terhadap pengaduan.
7. Admin memperbarui status dan memberikan feedback.
8. Siswa membuka riwayat untuk melihat status dan feedback terbaru.

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
](https://github.com/Aanrsky/ukk-pengaduan-sekolah-Aan2/tree/main/pengaduan_sarana_sekolah%20(1))
