import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

import '../services/notification_service.dart';
import 'history_page.dart';
import 'login_page.dart';
import 'pengaduan_page.dart';

// ============================================================
// WARNA TEMA
// ============================================================

const Color appNavy = Color(0xFF0B1F3A);
const Color appNavyDark = Color(0xFF061426);
const Color appTeal = Color(0xFF0F766E);
const Color appTealLight = Color(0xFF2DD4BF);
const Color appGold = Color(0xFFF4C95D);
const Color appCream = Color(0xFFFFFDF7);

final ValueNotifier<ThemeMode> localThemeNotifier =
    ValueNotifier<ThemeMode>(ThemeMode.light);

// ============================================================
// MODEL
// ============================================================

class StudentComplaint {
  final String id;
  final String title;
  final String status;

  StudentComplaint({
    required this.id,
    required this.title,
    required this.status,
  });

  factory StudentComplaint.fromFirestore(
    Map<String, dynamic> data,
    String id,
  ) {
    return StudentComplaint(
      id: id,
      title: (data['judul'] ?? data['title'] ?? 'Pengaduan').toString(),
      status: (data['status'] ?? 'Menunggu').toString(),
    );
  }
}

// ============================================================
// STUDENT HOME
// ============================================================

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  VideoPlayerController? _videoController;
  bool _videoReady = false;

  final ImagePicker _imagePicker = ImagePicker();

  String? _profilePhotoUrl;
  bool _uploadingProfilePhoto = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
    _loadProfilePhoto();
    _startNotificationListener();
  }

  // ==========================================================
  // NOTIFICATION LISTENER
  // ==========================================================

  void _startNotificationListener() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    unawaited(
      NotificationService.instance.startStudentNotificationListener(
        user.uid,
      ),
    );
  }

  // ==========================================================
  // VIDEO
  // ==========================================================

  Future<void> _initVideo() async {
    try {
      final controller = VideoPlayerController.asset(
        'assets/background1.mp4',
      );

      _videoController = controller;

      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(0);
      await controller.play();

      if (!mounted) return;

      setState(() {
        _videoReady = true;
      });
    } catch (e) {
      debugPrint('Background video error: $e');

      if (!mounted) return;

      setState(() {
        _videoReady = false;
      });
    }
  }

  // ==========================================================
  // LOAD FOTO PROFIL
  // ==========================================================

  Future<void> _loadProfilePhoto() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!doc.exists) return;

      final data = doc.data();

      if (data == null) return;

      final photo = data['photoUrl']?.toString();

      if (photo == null || photo.isEmpty) return;

      if (!mounted) return;

      setState(() {
        _profilePhotoUrl = photo;
      });
    } catch (e) {
      debugPrint('Load profile photo error: $e');
    }
  }

  // ==========================================================
  // UPLOAD FOTO PROFIL
  // ==========================================================

  Future<void> _pickProfilePhoto() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage('Akun tidak ditemukan.');
      return;
    }

    if (_uploadingProfilePhoto) return;

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 700,
        maxHeight: 700,
      );

      if (image == null) return;

      if (!mounted) return;

      setState(() {
        _uploadingProfilePhoto = true;
      });

      final bytes = await image.readAsBytes();

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_photos')
          .child('${user.uid}.jpg');

      await storageRef.putData(
        bytes,
        SettableMetadata(
          contentType: 'image/jpeg',
          cacheControl: 'public,max-age=31536000',
        ),
      );

      final downloadUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
        {
          'photoUrl': downloadUrl,
        },
        SetOptions(merge: true),
      );

      if (!mounted) return;

      setState(() {
        _profilePhotoUrl = downloadUrl;
        _uploadingProfilePhoto = false;
      });

      _showMessage('Foto profil berhasil diganti.');
    } catch (e) {
      debugPrint('Profile photo upload error: $e');

      if (!mounted) return;

      setState(() {
        _uploadingProfilePhoto = false;
      });

      _showMessage('Gagal mengganti foto profil.');
    }
  }

  // ==========================================================
  // LOGOUT
  // ==========================================================

  Future<void> _logout() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final isDark = localThemeNotifier.value == ThemeMode.dark;

        return AlertDialog(
          backgroundColor: isDark ? appNavyDark : appCream,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Text(
            'Keluar dari aplikasi?',
            style: TextStyle(
              color: isDark ? Colors.white : appNavy,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Text(
            'Kamu akan kembali ke halaman login.',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.grey.shade700,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: Text(
                'BATAL',
                style: TextStyle(
                  color: isDark ? Colors.white70 : appNavy,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: appGold,
                foregroundColor: appNavy,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'KELUAR',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const LoginPage(),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage('Gagal keluar dari aplikasi.');
    }
  }

  // ==========================================================
  // PESAN
  // ==========================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: appNavy,
      ),
    );
  }

  // ==========================================================
  // USER STREAM
  // ==========================================================

  Stream<DocumentSnapshot<Map<String, dynamic>>> _currentUserDocumentStream() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots();
  }

  // ==========================================================
  // COMPLAINT STREAM
  // ==========================================================

  Stream<List<StudentComplaint>> _getComplaintsStream() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Stream.value([]);
    }

    return FirebaseFirestore.instance
        .collection('pengaduan')
        .where(
          'userId',
          isEqualTo: user.uid,
        )
        .snapshots()
        .map(
      (snapshot) {
        return snapshot.docs
            .map(
              (doc) => StudentComplaint.fromFirestore(
                doc.data(),
                doc.id,
              ),
            )
            .toList();
      },
    );
  }

  // ==========================================================
  // JUMLAH NOTIFIKASI
  // ==========================================================

  int _notificationCount(
    List<StudentComplaint> list,
  ) {
    return list.where(
      (item) {
        final status = item.status.toLowerCase().trim();

        return status == 'diproses' ||
            status == 'proses' ||
            status == 'selesai' ||
            status == 'ditanggapi';
      },
    ).length;
  }

  // ==========================================================
  // NAVIGASI
  // ==========================================================

  void _openPengaduan() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PengaduanPage(),
      ),
    );
  }

  void _openHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const HistoryPage(),
      ),
    );
  }

  // ==========================================================
  // HEADER BUTTON
  // ==========================================================

  Widget _headerButton({
    required IconData icon,
    required VoidCallback onTap,
    Color iconColor = Colors.white,
  }) {
    return SizedBox(
      width: 45,
      height: 45,
      child: Material(
        color: appNavyDark,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          splashColor: appTealLight.withOpacity(0.20),
          highlightColor: appTeal.withOpacity(0.15),
          child: Ink(
            decoration: BoxDecoration(
              color: appNavyDark,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: appTealLight,
                width: 1.5,
              ),
            ),
            child: Center(
              child: Icon(
                icon,
                color: iconColor,
                size: 23,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // HEADER
  // ==========================================================

  Widget _buildHeader(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        18,
        10,
        12,
        10,
      ),
      decoration: BoxDecoration(
        color: appNavy,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              'assets/logosmp3.jpg',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) {
                return const Icon(
                  Icons.school_rounded,
                  color: appNavy,
                );
              },
            ),
          ),
          const SizedBox(width: 9),
          const Expanded(
            child: Text(
              'SMP N 3 BANTUL',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),

          // NOTIFIKASI
          StreamBuilder<List<StudentComplaint>>(
            stream: _getComplaintsStream(),
            builder: (context, snapshot) {
              final count =
                  snapshot.hasData ? _notificationCount(snapshot.data!) : 0;

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  _headerButton(
                    icon: Icons.notifications_none_rounded,
                    onTap: _showNotifications,
                  ),
                  if (count > 0)
                    Positioned(
                      right: -2,
                      top: -3,
                      child: Container(
                        width: 22,
                        height: 22,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          count > 9 ? '9+' : '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),

          const SizedBox(width: 5),

          // RATING
          _headerButton(
            icon: Icons.star_rounded,
            iconColor: appGold,
            onTap: _showRatingDialog,
          ),

          const SizedBox(width: 5),

          // PANDUAN
          _headerButton(
            icon: Icons.help_outline_rounded,
            onTap: _showPanduan,
          ),

          const SizedBox(width: 5),

          // TEMA
          _headerButton(
            icon: isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            iconColor: appGold,
            onTap: _showThemeSettings,
          ),

          const SizedBox(width: 5),

          // LOGOUT
          _headerButton(
            icon: Icons.logout_rounded,
            iconColor: Colors.redAccent,
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // WELCOME
  // ==========================================================

  Widget _buildWelcome(bool isDark) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _currentUserDocumentStream(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data();

        final nama = (data?['nama'] ?? 'Siswa').toString();
        final kelas = (data?['kelas'] ?? '').toString();

        final photoFromFirestore = (data?['photoUrl'] ?? '').toString();

        final photo = photoFromFirestore.isNotEmpty
            ? photoFromFirestore
            : _profilePhotoUrl;

        return Column(
          children: [
            GestureDetector(
              onTap: _uploadingProfilePhoto ? null : _pickProfilePhoto,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 102,
                    height: 102,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: appGold,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: photo != null && photo.isNotEmpty
                          ? Image.network(
                              photo,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) {
                                return const Icon(
                                  Icons.person_rounded,
                                  color: appNavy,
                                  size: 55,
                                );
                              },
                            )
                          : const Icon(
                              Icons.person_rounded,
                              color: appNavy,
                              size: 55,
                            ),
                    ),
                  ),
                  if (_uploadingProfilePhoto)
                    Container(
                      width: 102,
                      height: 102,
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: appGold,
                          strokeWidth: 3,
                        ),
                      ),
                    ),
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Container(
                      width: 29,
                      height: 29,
                      decoration: BoxDecoration(
                        color: appGold,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: appNavy,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: appNavy,
                        size: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'SELAMAT DATANG',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.3,
                shadows: [
                  Shadow(
                    color: Colors.black54,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'APLIKASI PENGADUAN SARANA\nSEKOLAH',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                height: 1.35,
                fontWeight: FontWeight.w900,
                shadows: [
                  Shadow(
                    color: Colors.black54,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: appGold,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                const SizedBox(width: 25),
                const SizedBox(width: 14),
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: appGold,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 17),
            const Text(
              'Laporkan masalah fasilitas sekolah dengan\nmudah.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                height: 1.45,
                fontWeight: FontWeight.w600,
                shadows: [
                  Shadow(
                    color: Colors.black54,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
            if (kelas.isNotEmpty) ...[
              const SizedBox(height: 7),
              Text(
                '$nama • Kelas $kelas',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  // ==========================================================
  // MENU CARD
  // ==========================================================

  Widget _menuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool primary = false,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: appGold.withOpacity(0.18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 13,
          ),
          decoration: BoxDecoration(
            gradient: primary
                ? const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      appNavyDark,
                      appTeal,
                    ],
                  )
                : null,
            color: primary ? null : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: appGold.withOpacity(
                primary ? 0.8 : 0.45,
              ),
              width: 1.3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: primary
                      ? Colors.white.withOpacity(0.10)
                      : appTeal.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(17),
                  border: primary
                      ? Border.all(
                          color: appGold.withOpacity(0.45),
                        )
                      : null,
                ),
                child: Icon(
                  icon,
                  color: primary ? appGold : appTeal,
                  size: 29,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: primary ? Colors.white : appNavy,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: primary ? Colors.white70 : Colors.grey.shade600,
                        fontSize: 12,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: primary
                      ? Colors.white.withOpacity(0.13)
                      : appTeal.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: primary ? Colors.white : appTeal,
                  size: 30,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // PANDUAN
  // ==========================================================

  void _showPanduan() {
    final isDark = localThemeNotifier.value == ThemeMode.dark;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: isDark ? appNavyDark : appCream,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      appNavy,
                      appTeal,
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.help_outline_rounded,
                  color: appGold,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Panduan',
                  style: TextStyle(
                    color: isDark ? Colors.white : appNavy,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _guideItem(
                  '1',
                  'Tekan Buat Pengaduan untuk melaporkan masalah sarana sekolah.',
                  isDark,
                ),
                _guideItem(
                  '2',
                  'Isi judul, kategori, dan deskripsi pengaduan dengan jelas.',
                  isDark,
                ),
                _guideItem(
                  '3',
                  'Tambahkan foto jika diperlukan sebagai bukti.',
                  isDark,
                ),
                _guideItem(
                  '4',
                  'Cek perkembangan laporan melalui Riwayat Pengaduan.',
                  isDark,
                ),
                _guideItem(
                  '5',
                  'Tekan foto profil untuk mengganti foto profil.',
                  isDark,
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: appNavy,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text('TUTUP'),
            ),
          ],
        );
      },
    );
  }

  Widget _guideItem(
    String number,
    String text,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 27,
            height: 27,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: appGold,
              shape: BoxShape.circle,
            ),
            child: Text(
              number,
              style: const TextStyle(
                color: appNavy,
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.grey.shade700,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // RATING
  // ==========================================================

  void _showRatingDialog() {
    int selectedStars = 5;

    final controller = TextEditingController();

    final isDark = localThemeNotifier.value == ThemeMode.dark;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              backgroundColor: isDark ? appNavyDark : appCream,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              title: Text(
                'Beri Penilaian',
                style: TextStyle(
                  color: isDark ? Colors.white : appNavy,
                  fontWeight: FontWeight.w900,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      'Bagaimana pengalamanmu menggunakan aplikasi ini?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.grey.shade700,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        5,
                        (index) {
                          final star = index + 1;

                          return IconButton(
                            onPressed: () {
                              setDialogState(() {
                                selectedStars = star;
                              });
                            },
                            icon: Icon(
                              star <= selectedStars
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              color: appGold,
                              size: 32,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: controller,
                      maxLines: 4,
                      style: TextStyle(
                        color: isDark ? Colors.white : appNavy,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Tulis saran atau ulasan...',
                        filled: true,
                        fillColor: isDark
                            ? Colors.white.withOpacity(0.06)
                            : Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('BATAL'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final user = FirebaseAuth.instance.currentUser;

                    if (user == null) return;

                    try {
                      await FirebaseFirestore.instance
                          .collection('ratings')
                          .add({
                        'uid': user.uid,
                        'email': user.email,
                        'stars': selectedStars,
                        'review': controller.text.trim(),
                        'createdAt': FieldValue.serverTimestamp(),
                      });

                      if (!dialogContext.mounted) return;

                      Navigator.pop(dialogContext);

                      _showMessage(
                        'Penilaian berhasil dikirim.',
                      );
                    } catch (e) {
                      if (!dialogContext.mounted) return;

                      _showMessage(
                        'Gagal mengirim penilaian.',
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appNavy,
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                  child: const Text('KIRIM'),
                ),
              ],
            );
          },
        );
      },
    ).then(
      (_) => controller.dispose(),
    );
  }

  // ==========================================================
  // THEME
  // ==========================================================

  void _showThemeSettings() {
    final isDark = localThemeNotifier.value == ThemeMode.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? appNavyDark : appCream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Tampilan Aplikasi',
                  style: TextStyle(
                    color: isDark ? Colors.white : appNavy,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 15),
                ListTile(
                  leading: const Icon(
                    Icons.light_mode_rounded,
                    color: appGold,
                  ),
                  title: Text(
                    'Mode Terang',
                    style: TextStyle(
                      color: isDark ? Colors.white : appNavy,
                    ),
                  ),
                  onTap: () {
                    localThemeNotifier.value = ThemeMode.light;

                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.dark_mode_rounded,
                    color: appTealLight,
                  ),
                  title: Text(
                    'Mode Gelap',
                    style: TextStyle(
                      color: isDark ? Colors.white : appNavy,
                    ),
                  ),
                  onTap: () {
                    localThemeNotifier.value = ThemeMode.dark;

                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================================
  // NOTIFIKASI
  // ==========================================================

  void _showNotifications() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final isDark = localThemeNotifier.value == ThemeMode.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? appNavyDark : appCream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.65,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Notifikasi',
                          style: TextStyle(
                            color: isDark ? Colors.white : appNavy,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          await NotificationService.instance
                              .markAllAsRead(user.uid);

                          if (!context.mounted) return;

                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Tandai semua dibaca',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Expanded(
                    child: StreamBuilder<
                        List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
                      stream: NotificationService.instance.studentNotifications(
                        user.uid,
                      ),
                      builder: (
                        context,
                        snapshot,
                      ) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: appTeal,
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Gagal mengambil notifikasi.',
                              style: TextStyle(
                                color: isDark ? Colors.white : appNavy,
                              ),
                            ),
                          );
                        }

                        final list = snapshot.data ?? [];

                        if (list.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.notifications_none_rounded,
                                  size: 55,
                                  color: isDark
                                      ? Colors.white38
                                      : Colors.grey.shade400,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Belum ada notifikasi.',
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.separated(
                          itemCount: list.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (
                            context,
                            index,
                          ) {
                            final doc = list[index];
                            final data = doc.data();

                            final title =
                                (data['title'] ?? 'Pengaduan diperbarui')
                                    .toString();

                            final body = (data['body'] ?? '').toString();

                            final status = (data['status'] ?? '').toString();

                            final read = data['read'] == true;

                            return InkWell(
                              borderRadius: BorderRadius.circular(15),
                              onTap: () async {
                                if (!read) {
                                  await NotificationService.instance.markAsRead(
                                    doc.id,
                                  );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withOpacity(0.06)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  border: !read
                                      ? Border.all(
                                          color: appTeal.withOpacity(
                                            0.35,
                                          ),
                                        )
                                      : null,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      read
                                          ? Icons.notifications_none_rounded
                                          : Icons.notifications_active_rounded,
                                      color: read ? Colors.grey : appTeal,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  title,
                                                  style: TextStyle(
                                                    color: isDark
                                                        ? Colors.white
                                                        : appNavy,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                              ),
                                              if (!read)
                                                Container(
                                                  width: 8,
                                                  height: 8,
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Colors.redAccent,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            body,
                                            style: TextStyle(
                                              color: isDark
                                                  ? Colors.white70
                                                  : Colors.grey.shade700,
                                              fontSize: 12,
                                            ),
                                          ),
                                          if (status.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 5,
                                              ),
                                              child: Text(
                                                'Status: $status',
                                                style: const TextStyle(
                                                  color: appTeal,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    unawaited(
      NotificationService.instance.stopStudentNotificationListener(),
    );

    _videoController?.dispose();

    super.dispose();
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: localThemeNotifier,
      builder: (
        context,
        mode,
        child,
      ) {
        final isDark = mode == ThemeMode.dark;

        return Scaffold(
          backgroundColor: appNavyDark,
          body: Stack(
            children: [
              // ==================================================
              // VIDEO
              // ==================================================

              if (_videoReady &&
                  _videoController != null &&
                  _videoController!.value.isInitialized)
                Positioned.fill(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _videoController!.value.size.width,
                      height: _videoController!.value.size.height,
                      child: VideoPlayer(
                        _videoController!,
                      ),
                    ),
                  ),
                )
              else
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          appNavy,
                          appTeal,
                          appNavyDark,
                        ],
                      ),
                    ),
                  ),
                ),

              // ==================================================
              // OVERLAY NAVY SOLID
              // ==================================================

              Positioned.fill(
                child: Container(
                  color: appNavy,
                ),
              ),

              // ==================================================
              // CONTENT
              // ==================================================

              SafeArea(
                child: Column(
                  children: [
                    _buildHeader(isDark),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(
                          18,
                          28,
                          18,
                          30,
                        ),
                        child: Column(
                          children: [
                            _buildWelcome(isDark),

                            const SizedBox(
                              height: 40,
                            ),

                            // ==================================================
                            // MENU UTAMA - NAVY SOLID
                            // ==================================================

                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.fromLTRB(
                                26,
                                28,
                                26,
                                25,
                              ),
                              decoration: BoxDecoration(
                                color: appNavy,
                                borderRadius: BorderRadius.circular(
                                  27,
                                ),
                                border: Border.all(
                                  color: appGold,
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(
                                      0.18,
                                    ),
                                    blurRadius: 20,
                                    offset: const Offset(
                                      0,
                                      8,
                                    ),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    'MENU UTAMA',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 19,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  _menuCard(
                                    icon: Icons.campaign_rounded,
                                    title: 'Buat Pengaduan',
                                    subtitle:
                                        'Laporkan kerusakan atau masalah sarana sekolah',
                                    primary: true,
                                    onTap: _openPengaduan,
                                  ),
                                  const SizedBox(height: 12),
                                  _menuCard(
                                    icon: Icons.history_rounded,
                                    title: 'Riwayat Pengaduan',
                                    subtitle:
                                        'Lihat pengaduan yang pernah kamu kirim dan statusnya',
                                    onTap: _openHistory,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 25),

                            // ==================================================
                            // INFO - NAVY SOLID
                            // ==================================================

                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 17,
                                vertical: 17,
                              ),
                              decoration: BoxDecoration(
                                color: appNavy,
                                borderRadius: BorderRadius.circular(
                                  18,
                                ),
                                border: Border.all(
                                  color: appGold,
                                  width: 1.0,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: appGold.withOpacity(
                                        0.13,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.info_outline_rounded,
                                      color: appGold,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Text(
                                      'Laporkan kerusakan sarana sekolah agar dapat segera ditindaklanjuti.',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            const Text(
                              'SMP NEGERI 3 BANTUL',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: appGold,
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                              ),
                            ),

                            const SizedBox(height: 7),

                            const Text(
                              'Sistem Pengaduan Sarana Sekolah',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
