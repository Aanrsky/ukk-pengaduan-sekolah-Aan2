import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../main.dart';
import 'pengaduan_page.dart';
import 'history_page.dart';
import 'complaint_detail_page.dart';
import 'login_page.dart';
import 'models/complaint_model.dart';
import '../services/firestore_service.dart';
import '../widgets/copyright_watermark.dart';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  VideoPlayerController? _videoController;

  bool _videoReady = false;

  // =========================
  // WARNA UTAMA
  // =========================
  static const Color navy = Color(0xFF0B1F3A);
  static const Color navyDark = Color(0xFF061426);
  static const Color teal = Color(0xFF0F766E);
  static const Color tealLight = Color(0xFF2DD4BF);
  static const Color gold = Color(0xFFF4C95D);
  static const Color cream = Color(0xFFFFFDF7);

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      final controller = VideoPlayerController.asset(
        'assets/background1.mp4',
      );

      _videoController = controller;

      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(0.0);
      await controller.play();

      if (!mounted) return;

      setState(() {
        _videoReady = true;
      });
    } catch (e) {
      debugPrint(
        'Gagal memuat background1.mp4: $e',
      );

      if (!mounted) return;

      setState(() {
        _videoReady = false;
      });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  // ======================================================
  // PENGATURAN TEMA
  // ======================================================

  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: cream,
      colorScheme: ColorScheme.fromSeed(
        seedColor: teal,
        primary: teal,
        secondary: gold,
        surface: cream,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: navy,
        elevation: 0,
      ),
    );
  }

  // ======================================================
  // BUILD
  // ======================================================

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _buildTheme(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          final isMobile = width < 700;
          final isTablet = width >= 700 && width < 1100;

          return Scaffold(
            backgroundColor: cream,
            drawer: isMobile
                ? Drawer(
                    backgroundColor: navy,
                    child: _buildDrawer(context),
                  )
                : null,
            body: Stack(
              children: [
                if (_videoReady &&
                    _videoController != null &&
                    _videoController!.value.isInitialized)
                  Positioned.fill(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _videoController!.value.size.width,
                        height: _videoController!.value.size.height,
                        child: VideoPlayer(_videoController!),
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          navy.withOpacity(0.86),
                          navy.withOpacity(0.70),
                          cream.withOpacity(0.98),
                          cream,
                        ],
                        stops: const [
                          0.0,
                          0.30,
                          0.62,
                          1.0,
                        ],
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: Column(
                    children: [
                      _buildTopBar(
                        context,
                        isMobile: isMobile,
                        isTablet: isTablet,
                      ),
                      Expanded(
                        child: _buildMainContent(
                          context,
                          isMobile: isMobile,
                          isTablet: isTablet,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ======================================================
  // TOP BAR
  // ======================================================

  Widget _buildTopBar(
    BuildContext context, {
    required bool isMobile,
    required bool isTablet,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 14 : 24,
        10,
        isMobile ? 14 : 24,
        8,
      ),
      child: Row(
        children: [
          if (isMobile)
            Builder(
              builder: (drawerContext) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.15),
                    ),
                  ),
                  child: IconButton(
                    tooltip: 'Menu',
                    onPressed: () {
                      Scaffold.of(drawerContext).openDrawer();
                    },
                    icon: const Icon(
                      Icons.menu_rounded,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
          if (isMobile) const SizedBox(width: 10),
          Expanded(
            child: Row(
              children: [
                Container(
                  width: isMobile ? 42 : 48,
                  height: isMobile ? 42 : 48,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 18,
                        offset: const Offset(0, 7),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/logosmp3.jpg',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) {
                      return const Icon(
                        Icons.school_rounded,
                        color: navy,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 11),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SMP NEGERI 3 BANTUL',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isMobile ? 12 : 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.4,
                        ),
                      ),
                      if (!isMobile)
                        const Text(
                          'Sistem Pengaduan Sarana Sekolah',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (!isMobile)
            _buildTopProfile(
              context,
              compact: isTablet,
            ),
        ],
      ),
    );
  }

  Widget _buildTopProfile(
    BuildContext context, {
    required bool compact,
  }) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 10 : 13,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.13),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.16),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: gold,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: navy,
                  size: 18,
                ),
              ),
              if (!compact) ...[
                const SizedBox(width: 9),
                Text(
                  user?.email?.split('@').first ?? 'Siswa',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  // ======================================================
  // DRAWER
  // ======================================================

  Widget _buildDrawer(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              18,
              20,
              18,
              18,
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Image.asset(
                    'assets/logosmp3.jpg',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) {
                      return const Icon(
                        Icons.school_rounded,
                        color: navy,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SMP NEGERI 3 BANTUL',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Pengaduan Sarana',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(
            color: Colors.white.withOpacity(0.12),
            height: 1,
          ),
          const SizedBox(height: 10),
          _buildDrawerItem(
            context,
            icon: Icons.home_rounded,
            title: 'Beranda',
            onTap: () {
              Navigator.pop(context);
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.add_circle_outline_rounded,
            title: 'Buat Pengaduan',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PengaduanPage(),
                ),
              );
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.history_rounded,
            title: 'Riwayat Pengaduan',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const HistoryPage(),
                ),
              );
            },
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(18),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _logout();
                },
                icon: const Icon(
                  Icons.logout_rounded,
                  color: Colors.white,
                ),
                label: const Text(
                  'Keluar',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 13,
                  ),
                  side: BorderSide(
                    color: Colors.white.withOpacity(0.25),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 3,
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(13),
        ),
        leading: Icon(
          icon,
          color: Colors.white70,
          size: 21,
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: Colors.white38,
          size: 18,
        ),
      ),
    );
  }

  // ======================================================
  // MAIN CONTENT
  // ======================================================

  Widget _buildMainContent(
    BuildContext context, {
    required bool isMobile,
    required bool isTablet,
  }) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        isMobile ? 14 : 24,
        isMobile ? 10 : 18,
        isMobile ? 14 : 24,
        30,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeCard(
            context,
            isMobile: isMobile,
          ),
          const SizedBox(height: 18),
          _buildActionSection(
            context,
            isMobile: isMobile,
          ),
          const SizedBox(height: 20),
          _buildStatisticsSection(
            context,
            isMobile: isMobile,
          ),
          const SizedBox(height: 22),
          _buildRecentComplaintsSection(
            context,
            isMobile: isMobile,
          ),
        ],
      ),
    );
  }

  // ======================================================
  // WELCOME CARD
  // ======================================================

  Widget _buildWelcomeCard(
    BuildContext context, {
    required bool isMobile,
  }) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _currentUserDocumentStream(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data();

        final nama = (data?['nama'] ?? 'Siswa').toString();
        final kelas = (data?['kelas'] ?? '').toString();

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(
            isMobile ? 18 : 25,
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                navy,
                Color(0xFF12345B),
                teal,
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: navy.withOpacity(0.22),
                blurRadius: 25,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -35,
                top: -45,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    color: gold.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                right: 45,
                bottom: -65,
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: tealLight.withOpacity(0.09),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: gold.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: gold.withOpacity(0.25),
                      ),
                    ),
                    child: const Text(
                      'SELAMAT DATANG 👋',
                      style: TextStyle(
                        color: gold,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  Text(
                    'Halo, $nama',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 22 : 28,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                  if (kelas.isNotEmpty) ...[
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        const Icon(
                          Icons.school_outlined,
                          color: Colors.white70,
                          size: 15,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Kelas $kelas',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 10),
                  const Text(
                    'Sampaikan masalah sarana sekolah dengan mudah. '
                    'Laporanmu akan ditangani oleh pihak sekolah.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 17),
                  SizedBox(
                    width: isMobile ? double.infinity : 210,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PengaduanPage(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.add_rounded,
                        size: 19,
                      ),
                      label: const Text(
                        'Buat Pengaduan',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: gold,
                        foregroundColor: navy,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          vertical: 13,
                          horizontal: 17,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ======================================================
  // ACTION SECTION
  // ======================================================

  Widget _buildActionSection(
    BuildContext context, {
    required bool isMobile,
  }) {
    if (isMobile) {
      return Column(
        children: [
          _buildActionCard(
            context,
            icon: Icons.add_circle_rounded,
            title: 'Buat Pengaduan',
            subtitle: 'Laporkan fasilitas bermasalah',
            color: teal,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PengaduanPage(),
                ),
              );
            },
          ),
          const SizedBox(height: 11),
          _buildActionCard(
            context,
            icon: Icons.history_rounded,
            title: 'Riwayat',
            subtitle: 'Lihat semua pengaduanmu',
            color: navy,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const HistoryPage(),
                ),
              );
            },
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            context,
            icon: Icons.add_circle_rounded,
            title: 'Buat Pengaduan',
            subtitle: 'Laporkan fasilitas bermasalah',
            color: teal,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PengaduanPage(),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: _buildActionCard(
            context,
            icon: Icons.history_rounded,
            title: 'Riwayat',
            subtitle: 'Lihat semua pengaduanmu',
            color: navy,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const HistoryPage(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFE7E2D9),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.035),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: navy,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 9,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 13,
                color: Color(0xFF94A3B8),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ======================================================
  // STATISTICS
  // ======================================================

  Widget _buildStatisticsSection(
    BuildContext context, {
    required bool isMobile,
  }) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('pengaduan')
          .where('userId', isEqualTo: uid)
          .snapshots(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];

        int total = docs.length;
        int menunggu = 0;
        int diproses = 0;
        int selesai = 0;

        for (final doc in docs) {
          final status = (doc.data()['status'] ?? 'Menunggu')
              .toString()
              .toLowerCase()
              .trim();

          if (status == 'menunggu') {
            menunggu++;
          } else if (status == 'diproses') {
            diproses++;
          } else if (status == 'selesai') {
            selesai++;
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(
              title: 'Ringkasan Pengaduan',
              subtitle: 'Pantau perkembangan laporanmu',
              icon: Icons.analytics_rounded,
            ),
            const SizedBox(height: 11),
            if (isMobile)
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          title: 'Total',
                          value: total,
                          icon: Icons.description_rounded,
                          color: navy,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildStatCard(
                          title: 'Menunggu',
                          value: menunggu,
                          icon: Icons.schedule_rounded,
                          color: gold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          title: 'Diproses',
                          value: diproses,
                          icon: Icons.sync_rounded,
                          color: teal,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildStatCard(
                          title: 'Selesai',
                          value: selesai,
                          icon: Icons.check_circle_rounded,
                          color: const Color(0xFF15803D),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'Total',
                      value: total,
                      icon: Icons.description_rounded,
                      color: navy,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Menunggu',
                      value: menunggu,
                      icon: Icons.schedule_rounded,
                      color: gold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Diproses',
                      value: diproses,
                      icon: Icons.sync_rounded,
                      color: teal,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Selesai',
                      value: selesai,
                      icon: Icons.check_circle_rounded,
                      color: const Color(0xFF15803D),
                    ),
                  ),
                ],
              ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required int value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0xFFE7E2D9),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 13,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$value',
                  style: const TextStyle(
                    color: navy,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ======================================================
  // RECENT COMPLAINTS
  // ======================================================

  Widget _buildRecentComplaintsSection(
    BuildContext context, {
    required bool isMobile,
  }) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('pengaduan')
          .where('userId', isEqualTo: uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildError(
            'Gagal memuat pengaduan.',
          );
        }

        final docs = [...(snapshot.data?.docs ?? [])];

        docs.sort((a, b) {
          final aDate = _getDateValue(
            a.data()['tanggal'],
          );
          final bDate = _getDateValue(
            b.data()['tanggal'],
          );

          return bDate.compareTo(aDate);
        });

        final recent = docs.take(5).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildSectionTitle(
                    title: 'Pengaduan Terbaru',
                    subtitle: 'Laporan yang baru kamu kirim',
                    icon: Icons.receipt_long_rounded,
                  ),
                ),
                if (docs.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HistoryPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'Lihat semua',
                      style: TextStyle(
                        color: teal,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 11),
            if (recent.isEmpty)
              _buildEmptyComplaint()
            else
              Column(
                children: recent.map((doc) {
                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: 10,
                    ),
                    child: _buildComplaintCard(
                      context,
                      doc,
                      isMobile: isMobile,
                    ),
                  );
                }).toList(),
              ),
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            color: teal.withOpacity(0.10),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            icon,
            color: teal,
            size: 18,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: navy,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 8,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyComplaint() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 30,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE7E2D9),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: teal.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.inbox_rounded,
              color: teal,
              size: 27,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Belum ada pengaduan',
            style: TextStyle(
              color: navy,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Kamu belum mengirim laporan sarana sekolah.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  // ======================================================
  // COMPLAINT CARD
  // ======================================================

  Widget _buildComplaintCard(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>> doc, {
    required bool isMobile,
  }) {
    final data = doc.data();

    final title = (data['judul'] ?? 'Tanpa judul').toString();

    final category = (data['kategori'] ?? '-').toString();

    final description = (data['deskripsi'] ?? '-').toString();

    final status = (data['status'] ?? 'Menunggu').toString();

    final feedback = (data['feedback'] ?? '').toString();

    final tanggal = data['tanggal'];

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(17),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(17),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ComplaintDetailPage(
                complaint: ComplaintModel.fromFirestore(doc),
              ),
            ),
          );
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(
            isMobile ? 14 : 16,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: const Color(0xFFE7E2D9),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCategoryIcon(category),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: navy,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        height: 1.25,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusBadge(status),
                ],
              ),
              const SizedBox(height: 9),
              Text(
                description,
                maxLines: isMobile ? 2 : 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 9,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                runSpacing: 5,
                children: [
                  _buildMetaText(
                    Icons.category_outlined,
                    category,
                  ),
                  _buildMetaText(
                    Icons.schedule_rounded,
                    _formatDate(tanggal),
                  ),
                ],
              ),
              if (feedback.trim().isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: gold.withOpacity(0.09),
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(
                      color: gold.withOpacity(0.22),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.chat_bubble_outline_rounded,
                        color: navy,
                        size: 15,
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          feedback,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: navy,
                            fontSize: 9,
                            height: 1.4,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(String category) {
    final normalized = category.toLowerCase();

    IconData icon;

    if (normalized.contains('kelas') || normalized.contains('ruang')) {
      icon = Icons.meeting_room_rounded;
    } else if (normalized.contains('toilet') ||
        normalized.contains('kamar mandi')) {
      icon = Icons.wc_rounded;
    } else if (normalized.contains('lapangan') ||
        normalized.contains('olahraga')) {
      icon = Icons.sports_soccer_rounded;
    } else if (normalized.contains('komputer') ||
        normalized.contains('internet')) {
      icon = Icons.computer_rounded;
    } else if (normalized.contains('perpustakaan')) {
      icon = Icons.menu_book_rounded;
    } else if (normalized.contains('meja') || normalized.contains('kursi')) {
      icon = Icons.chair_rounded;
    } else if (normalized.contains('listrik') || normalized.contains('lampu')) {
      icon = Icons.lightbulb_rounded;
    } else {
      icon = Icons.build_rounded;
    }

    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: teal.withOpacity(0.10),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Icon(
        icon,
        color: teal,
        size: 20,
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final normalized = status.toLowerCase().trim();

    Color color;
    IconData icon;

    if (normalized == 'selesai') {
      color = const Color(0xFF15803D);
      icon = Icons.check_circle_rounded;
    } else if (normalized == 'diproses') {
      color = teal;
      icon = Icons.sync_rounded;
    } else if (normalized == 'ditolak') {
      color = const Color(0xFFB91C1C);
      icon = Icons.cancel_rounded;
    } else {
      color = const Color(0xFFB7791F);
      icon = Icons.schedule_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.09),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: color.withOpacity(0.17),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 11,
          ),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: 8,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaText(
    IconData icon,
    String text,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: const Color(0xFF94A3B8),
          size: 12,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 8,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ======================================================
  // FIREBASE
  // ======================================================

  Stream<DocumentSnapshot<Map<String, dynamic>>> _currentUserDocumentStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Stream<DocumentSnapshot<Map<String, dynamic>>>.empty();
    }

    return FirebaseFirestore.instance.collection('users').doc(uid).snapshots();
  }

  DateTime _getDateValue(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }

    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  String _formatDate(dynamic value) {
    final date = _getDateValue(value);

    if (date.millisecondsSinceEpoch == 0) {
      return '-';
    }

    final day = date.day.toString().padLeft(2, '0');

    final month = date.month.toString().padLeft(2, '0');

    final year = date.year.toString();

    final hour = date.hour.toString().padLeft(2, '0');

    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/$year $hour:$minute';
  }

  // ======================================================
  // ERROR
  // ======================================================

  Widget _buildError(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0xFFE7E2D9),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFB91C1C),
            size: 35,
          ),
          const SizedBox(height: 9),
          const Text(
            'Terjadi kesalahan',
            style: TextStyle(
              color: navy,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  // ======================================================
  // LOGOUT
  // ======================================================

  Future<void> _logout() async {
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal keluar: $e',
          ),
        ),
      );
    }
  }
}
