import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../services/notification_service.dart';
import 'admin_petugas_login_page.dart';
import '../widgets/copyright_watermark.dart';

// ============================================================
// TEMA — DISAMAKAN DENGAN WEB ADMIN
// ============================================================

const Color navy = Color(0xFF0B1F3A);
const Color navyDark = Color(0xFF061426);
const Color teal = Color(0xFF0F766E);
const Color tealLight = Color(0xFF2DD4BF);
const Color gold = Color(0xFFF4C95D);
const Color goldLight = Color(0xFFFFE9A8);
const Color cream = Color(0xFFFFFDF7);
const Color textMuted = Color(0xFF64748B);
const Color darkCard = Color(0xFF102A43);
const Color lightBorder = Color(0xFFE7E2D9);

// ============================================================
// ADMIN DASHBOARD
// ============================================================

class AdminDashboardPage extends StatefulWidget {
  final String role;
  final String nama;

  const AdminDashboardPage({
    super.key,
    required this.role,
    required this.nama,
  });

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();

  int _selectedMenu = 0;
  bool _sidebarOpen = true;
  bool _darkMode = false;

  String _searchQuery = '';
  String _statusFilter = 'Semua';

  CollectionReference<Map<String, dynamic>> get _complaints =>
      _firestore.collection('pengaduan');

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  final List<String> _menus = const [
    'Dashboard',
    'Pengaduan Siswa',
    'Laporan',
    'Pengguna',
  ];

  final List<IconData> _menuIcons = const [
    Icons.dashboard_rounded,
    Icons.report_problem_rounded,
    Icons.bar_chart_rounded,
    Icons.people_alt_rounded,
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkMode ? navyDark : cream,
      drawer: MediaQuery.of(context).size.width < 700
          ? Drawer(
              backgroundColor: navy,
              child: _buildMobileDrawer(),
            )
          : null,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final isMobile = width < 700;
          final isTablet = width >= 700 && width < 1100;

          if (isMobile) {
            _sidebarOpen = false;
          } else if (!isTablet) {
            _sidebarOpen = true;
          }

          return Row(
            children: [
              if (!isMobile)
                _buildSidebar(
                  compact: !_sidebarOpen,
                ),
              Expanded(
                child: Column(
                  children: [
                    _buildTopBar(
                      isMobile: isMobile,
                      isTablet: isTablet,
                    ),
                    Expanded(
                      child: _buildContent(
                        isMobile: isMobile,
                        isTablet: isTablet,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ==========================================================
  // SIDEBAR
  // ==========================================================

  Widget _buildSidebar({
    required bool compact,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: compact ? 78 : 250,
      color: navy,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 10 : 18,
              ),
              child: compact ? _buildCompactLogo() : _buildFullLogo(),
            ),
            const SizedBox(height: 28),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 8 : 12,
                ),
                children: [
                  for (int i = 0; i < _menus.length; i++)
                    _buildMenuItem(
                      index: i,
                      compact: compact,
                    ),
                ],
              ),
            ),
            if (!compact)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  14,
                  4,
                  14,
                  10,
                ),
                child: _buildThemeButton(),
              ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                compact ? 8 : 14,
                5,
                compact ? 8 : 14,
                15,
              ),
              child: _buildLogoutButton(compact),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullLogo() {
    return Row(
      children: [
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: teal,
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(
            Icons.school_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 11),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SaranaKu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'ADMIN PANEL',
                style: TextStyle(
                  color: tealLight,
                  fontSize: 9,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompactLogo() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: teal,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(
        Icons.school_rounded,
        color: Colors.white,
        size: 25,
      ),
    );
  }

  Widget _buildMenuItem({
    required int index,
    required bool compact,
  }) {
    final selected = _selectedMenu == index;

    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(13),
          onTap: () {
            setState(() {
              _selectedMenu = index;
            });

            if (MediaQuery.of(context).size.width < 700) {
              Navigator.pop(context);
            }
          },
          child: Container(
            height: 48,
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 12 : 14,
            ),
            decoration: BoxDecoration(
              color: selected ? teal.withOpacity(0.22) : Colors.transparent,
              borderRadius: BorderRadius.circular(13),
              border: selected
                  ? Border.all(
                      color: tealLight.withOpacity(0.25),
                    )
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  _menuIcons[index],
                  color: selected ? tealLight : Colors.white.withOpacity(0.70),
                  size: 20,
                ),
                if (!compact) ...[
                  const SizedBox(width: 13),
                  Expanded(
                    child: Text(
                      _menus[index],
                      style: TextStyle(
                        color: selected
                            ? Colors.white
                            : Colors.white.withOpacity(0.72),
                        fontSize: 12,
                        fontWeight:
                            selected ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeButton() {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        setState(() {
          _darkMode = !_darkMode;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 11,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              _darkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              color: gold,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _darkMode ? 'Mode Gelap' : 'Mode Terang',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              _darkMode ? Icons.toggle_on_rounded : Icons.toggle_off_rounded,
              color: tealLight,
              size: 27,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(bool compact) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: _logout,
      child: Container(
        height: 46,
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 12 : 14,
        ),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.09),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.red.withOpacity(0.16),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.logout_rounded,
              color: Color(0xFFFF8A80),
              size: 19,
            ),
            if (!compact) ...[
              const SizedBox(width: 11),
              const Text(
                'Keluar',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMobileDrawer() {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: _buildFullLogo(),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                for (int i = 0; i < _menus.length; i++)
                  _buildMenuItem(
                    index: i,
                    compact: false,
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: _buildLogoutButton(false),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // TOP BAR
  // ==========================================================

  Widget _buildTopBar({
    required bool isMobile,
    required bool isTablet,
  }) {
    final background = _darkMode ? darkCard : Colors.white;

    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: background,
        border: Border(
          bottom: BorderSide(
            color: _darkMode ? Colors.white.withOpacity(0.06) : lightBorder,
          ),
        ),
      ),
      child: Row(
        children: [
          if (isMobile)
            IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: const Icon(Icons.menu_rounded),
              color: _darkMode ? Colors.white : navy,
            ),
          if (!isMobile && isTablet)
            IconButton(
              onPressed: () {
                setState(() {
                  _sidebarOpen = !_sidebarOpen;
                });
              },
              icon: const Icon(Icons.menu_rounded),
              color: _darkMode ? Colors.white : navy,
            ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _menus[_selectedMenu],
                  style: TextStyle(
                    color: _darkMode ? Colors.white : navy,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (!isMobile)
                  Text(
                    'Sistem Pengaduan Sarana Sekolah',
                    style: TextStyle(
                      color: _darkMode ? Colors.white54 : textMuted,
                      fontSize: 10,
                    ),
                  ),
              ],
            ),
          ),
          if (!isMobile)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: _darkMode ? Colors.white.withOpacity(0.05) : cream,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Row(
                children: [
                  Container(
                    width: 29,
                    height: 29,
                    decoration: const BoxDecoration(
                      color: teal,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.nama.isEmpty ? 'Admin' : widget.nama,
                    style: TextStyle(
                      color: _darkMode ? Colors.white : navy,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ==========================================================
  // CONTENT
  // ==========================================================

  Widget _buildContent({
    required bool isMobile,
    required bool isTablet,
  }) {
    switch (_selectedMenu) {
      case 1:
        return _buildComplaintPage(isMobile: isMobile);
      case 2:
        return _buildReportPage(isMobile: isMobile);
      case 3:
        return _buildUsersPage(isMobile: isMobile);
      default:
        return _buildDashboardPage(
          isMobile: isMobile,
          isTablet: isTablet,
        );
    }
  }

  // ==========================================================
  // DASHBOARD
  // ==========================================================

  Widget _buildDashboardPage({
    required bool isMobile,
    required bool isTablet,
  }) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _complaints.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _errorView(snapshot.error.toString());
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: teal),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        return _scrollContent(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDashboardHero(isMobile),
              const SizedBox(height: 18),
              _buildStats(docs, isMobile),
              const SizedBox(height: 18),
              _buildDashboardGrid(docs, isMobile),
              const SizedBox(height: 18),
              _buildRecentComplaints(docs, isMobile),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDashboardHero(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 18 : 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            navy,
            Color(0xFF09213D),
            teal,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _heroText(),
                const SizedBox(height: 18),
                _printButton(),
              ],
            )
          : Row(
              children: [
                Expanded(child: _heroText()),
                _printButton(),
              ],
            ),
    );
  }

  Widget _heroText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: gold.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'ADMIN DASHBOARD',
            style: TextStyle(
              color: gold,
              fontSize: 9,
              letterSpacing: 1,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 11),
        Text(
          'Halo, ${widget.nama.isEmpty ? 'Admin' : widget.nama}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Pantau dan kelola pengaduan siswa dengan mudah.',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 11,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _printButton() {
    return ElevatedButton.icon(
      onPressed: _printReport,
      style: ElevatedButton.styleFrom(
        backgroundColor: gold,
        foregroundColor: navy,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: 17,
          vertical: 13,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      icon: const Icon(
        Icons.print_rounded,
        size: 18,
      ),
      label: const Text(
        'Cetak Laporan',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  // ==========================================================
  // STATISTICS
  // ==========================================================

  Widget _buildStats(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    bool isMobile,
  ) {
    final counts = _getStatusCounts(docs);

    final stats = [
      _StatItem(
        title: 'Total Pengaduan',
        value: docs.length,
        icon: Icons.assignment_rounded,
        color: navy,
      ),
      _StatItem(
        title: 'Menunggu',
        value: counts['menunggu'] ?? 0,
        icon: Icons.hourglass_top_rounded,
        color: gold,
      ),
      _StatItem(
        title: 'Diproses',
        value: counts['diproses'] ?? 0,
        icon: Icons.sync_rounded,
        color: teal,
      ),
      _StatItem(
        title: 'Selesai',
        value: counts['selesai'] ?? 0,
        icon: Icons.check_circle_rounded,
        color: Colors.green,
      ),
      _StatItem(
        title: 'Ditolak',
        value: counts['ditolak'] ?? 0,
        icon: Icons.cancel_rounded,
        color: Colors.redAccent,
      ),
    ];

    if (isMobile) {
      return Column(
        children: [
          for (final item in stats)
            Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: _statCard(item),
            ),
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 950) {
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: stats.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.7,
            ),
            itemBuilder: (context, index) {
              return _statCard(stats[index]);
            },
          );
        }

        return Row(
          children: [
            for (int i = 0; i < stats.length; i++)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: i == stats.length - 1 ? 0 : 10,
                  ),
                  child: _statCard(stats[i]),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _statCard(_StatItem item) {
    final cardColor = _darkMode ? darkCard : Colors.white;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _darkMode ? Colors.white.withOpacity(0.06) : lightBorder,
        ),
        boxShadow: _darkMode
            ? null
            : [
                BoxShadow(
                  color: navy.withOpacity(0.035),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              item.icon,
              color: item.color,
              size: 21,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _darkMode ? Colors.white54 : textMuted,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.value}',
                  style: TextStyle(
                    color: _darkMode ? Colors.white : navy,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // GRAPH + QUICK ACTION
  // ==========================================================

  Widget _buildDashboardGrid(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    bool isMobile,
  ) {
    final stats = _getStatusCounts(docs);

    if (isMobile) {
      return Column(
        children: [
          _buildGraphCard(stats, true),
          const SizedBox(height: 18),
          _buildQuickActions(),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: _buildGraphCard(stats, false),
        ),
        const SizedBox(width: 18),
        Expanded(
          flex: 1,
          child: _buildQuickActions(),
        ),
      ],
    );
  }

  Widget _buildGraphCard(
    Map<String, int> stats,
    bool mobile,
  ) {
    final values = [
      stats['menunggu'] ?? 0,
      stats['diproses'] ?? 0,
      stats['selesai'] ?? 0,
      stats['ditolak'] ?? 0,
    ];

    final maxValue = values.fold<int>(
      1,
      (a, b) => a > b ? a : b,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _darkMode ? darkCard : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _darkMode ? Colors.white.withOpacity(0.06) : lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            title: 'Grafik Pengaduan Siswa',
            subtitle: 'Jumlah pengaduan berdasarkan status',
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: mobile ? 250 : 280,
            child: CustomPaint(
              painter: _ComplaintChartPainter(
                values: values,
                maxValue: maxValue,
                darkMode: _darkMode,
              ),
              child: const SizedBox.expand(),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 17,
            runSpacing: 9,
            children: [
              _legend('Menunggu', gold),
              _legend('Diproses', teal),
              _legend('Selesai', Colors.green),
              _legend('Ditolak', Colors.redAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legend(String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: _darkMode ? Colors.white60 : textMuted,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _darkMode ? darkCard : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _darkMode ? Colors.white.withOpacity(0.06) : lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            title: 'Menu Cepat',
            subtitle: 'Akses fitur admin',
          ),
          const SizedBox(height: 17),
          _quickAction(
            icon: Icons.report_problem_rounded,
            title: 'Pengaduan Siswa',
            subtitle: 'Lihat semua laporan',
            onTap: () {
              setState(() {
                _selectedMenu = 1;
              });
            },
          ),
          const SizedBox(height: 9),
          _quickAction(
            icon: Icons.print_rounded,
            title: 'Cetak Laporan',
            subtitle: 'Buat laporan cetak',
            onTap: _printReport,
          ),
          const SizedBox(height: 9),
          _quickAction(
            icon: Icons.people_alt_rounded,
            title: 'Pengguna',
            subtitle: 'Lihat data pengguna',
            onTap: () {
              setState(() {
                _selectedMenu = 3;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _quickAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _darkMode
              ? Colors.white.withOpacity(0.04)
              : const Color(0xFFFAF9F5),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: teal.withOpacity(0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: teal,
                size: 19,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: _darkMode ? Colors.white : navy,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: _darkMode ? Colors.white54 : textMuted,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: _darkMode ? Colors.white38 : textMuted,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // RECENT COMPLAINTS
  // ==========================================================

  Widget _buildRecentComplaints(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    bool isMobile,
  ) {
    final sorted = [...docs];

    sorted.sort(
      (a, b) => _dateOf(b.data()).compareTo(_dateOf(a.data())),
    );

    final recent = sorted.take(5).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _darkMode ? darkCard : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _darkMode ? Colors.white.withOpacity(0.06) : lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            title: 'Pengaduan Siswa Terbaru',
            subtitle: 'Laporan yang terakhir masuk',
          ),
          const SizedBox(height: 15),
          if (recent.isEmpty)
            _emptyView('Belum ada pengaduan siswa.')
          else
            for (final doc in recent) _complaintListTile(doc),
        ],
      ),
    );
  }

  Widget _complaintListTile(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();

    return InkWell(
      onTap: () => _showComplaintDetail(doc),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: _darkMode
              ? Colors.white.withOpacity(0.035)
              : const Color(0xFFFAF9F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            _complaintImage(
              _getFotoUrl(data),
              width: 45,
              height: 45,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getTitle(data),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _darkMode ? Colors.white : navy,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${_getName(data)} • ${_getCategory(data)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _darkMode ? Colors.white54 : textMuted,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
            _statusBadge(_status(data)),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // PENGADUAN
  // ==========================================================

  Widget _buildComplaintPage({
    required bool isMobile,
  }) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _complaints.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _errorView(snapshot.error.toString());
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: teal),
          );
        }

        final docs = snapshot.data?.docs ?? [];
        final filtered = _filterComplaints(docs);

        return _scrollContent(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _pageHeader(
                title: 'Pengaduan Siswa',
                subtitle: 'Kelola semua laporan pengaduan yang masuk.',
                icon: Icons.report_problem_rounded,
                action: _printButton(),
              ),
              const SizedBox(height: 18),
              _buildComplaintFilter(isMobile),
              const SizedBox(height: 15),
              Row(
                children: [
                  Text(
                    '${filtered.length} pengaduan',
                    style: TextStyle(
                      color: _darkMode ? Colors.white : navy,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Total: ${docs.length}',
                    style: TextStyle(
                      color: _darkMode ? Colors.white54 : textMuted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (filtered.isEmpty)
                _emptyCard('Tidak ada pengaduan yang sesuai.')
              else
                for (final doc in filtered) _complaintCard(doc),
            ],
          ),
        );
      },
    );
  }

  Widget _buildComplaintFilter(bool isMobile) {
    final boxColor = _darkMode ? darkCard : Colors.white;

    if (isMobile) {
      return Column(
        children: [
          _searchField(boxColor),
          const SizedBox(height: 10),
          _statusDropdown(boxColor),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: _searchField(boxColor),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 200,
          child: _statusDropdown(boxColor),
        ),
      ],
    );
  }

  Widget _searchField(Color boxColor) {
    return TextField(
      controller: _searchController,
      onChanged: (value) {
        setState(() {
          _searchQuery = value.trim().toLowerCase();
        });
      },
      style: TextStyle(
        color: _darkMode ? Colors.white : navy,
        fontSize: 11,
      ),
      decoration: InputDecoration(
        hintText: 'Cari nama, judul, kategori...',
        hintStyle: TextStyle(
          color: _darkMode ? Colors.white38 : textMuted,
          fontSize: 11,
        ),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: teal,
          size: 19,
        ),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                  });
                },
                icon: const Icon(
                  Icons.close_rounded,
                  size: 17,
                ),
              )
            : null,
        filled: true,
        fillColor: boxColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: _darkMode ? Colors.white.withOpacity(0.07) : lightBorder,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: _darkMode ? Colors.white.withOpacity(0.07) : lightBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: teal,
            width: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _statusDropdown(Color boxColor) {
    return DropdownButtonFormField<String>(
      initialValue: _statusFilter,
      style: TextStyle(
        color: _darkMode ? Colors.white : navy,
        fontSize: 11,
      ),
      decoration: InputDecoration(
        labelText: 'Status',
        labelStyle: TextStyle(
          color: _darkMode ? Colors.white54 : textMuted,
          fontSize: 10,
        ),
        filled: true,
        fillColor: boxColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: _darkMode ? Colors.white.withOpacity(0.07) : lightBorder,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: _darkMode ? Colors.white.withOpacity(0.07) : lightBorder,
          ),
        ),
      ),
      dropdownColor: _darkMode ? darkCard : Colors.white,
      items: const [
        DropdownMenuItem(
          value: 'Semua',
          child: Text('Semua'),
        ),
        DropdownMenuItem(
          value: 'Menunggu',
          child: Text('Menunggu'),
        ),
        DropdownMenuItem(
          value: 'Diproses',
          child: Text('Diproses'),
        ),
        DropdownMenuItem(
          value: 'Selesai',
          child: Text('Selesai'),
        ),
        DropdownMenuItem(
          value: 'Ditolak',
          child: Text('Ditolak'),
        ),
      ],
      onChanged: (value) {
        if (value == null) return;

        setState(() {
          _statusFilter = value;
        });
      },
    );
  }

  Widget _complaintCard(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _darkMode ? darkCard : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: _darkMode ? Colors.white.withOpacity(0.06) : lightBorder,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _complaintImage(
            _getFotoUrl(data),
            width: 64,
            height: 64,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        _getTitle(data),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _darkMode ? Colors.white : navy,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _statusBadge(_status(data)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${_getName(data)} • ${_getCategory(data)}',
                  style: TextStyle(
                    color: _darkMode ? Colors.white54 : textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _formatDate(_dateOf(data)),
                  style: TextStyle(
                    color: _darkMode ? Colors.white38 : textMuted,
                    fontSize: 9,
                  ),
                ),
                if (_getDescription(data).isNotEmpty) ...[
                  const SizedBox(height: 7),
                  Text(
                    _getDescription(data),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _darkMode ? Colors.white60 : textMuted,
                      fontSize: 10,
                      height: 1.4,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    _smallButton(
                      icon: Icons.visibility_rounded,
                      text: 'Detail',
                      color: teal,
                      onTap: () => _showComplaintDetail(doc),
                    ),
                    _smallButton(
                      icon: Icons.edit_rounded,
                      text: 'Status',
                      color: navy,
                      onTap: () => _showStatusDialog(doc),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _complaintImage(
    String url, {
    required double width,
    required double height,
  }) {
    if (url.trim().isEmpty) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: teal.withOpacity(0.09),
          borderRadius: BorderRadius.circular(11),
        ),
        child: const Icon(
          Icons.image_not_supported_rounded,
          color: teal,
          size: 21,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(11),
      child: Image.network(
        url,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: teal.withOpacity(0.09),
            child: const Icon(
              Icons.broken_image_rounded,
              color: teal,
              size: 21,
            ),
          );
        },
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color bg;
    Color fg;

    switch (status) {
      case 'menunggu':
        bg = const Color(0xFFFFF4CE);
        fg = const Color(0xFF9A7600);
        break;
      case 'diproses':
        bg = const Color(0xFFDDF7F3);
        fg = teal;
        break;
      case 'selesai':
        bg = const Color(0xFFE0F4E5);
        fg = Colors.green.shade700;
        break;
      case 'ditolak':
        bg = const Color(0xFFFFE4E1);
        fg = Colors.red.shade700;
        break;
      default:
        bg = const Color(0xFFE7E7E7);
        fg = textMuted;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        _capitalize(status),
        style: TextStyle(
          color: fg,
          fontSize: 8,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _smallButton({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return OutlinedButton.icon(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(
          color: color.withOpacity(0.35),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 7,
        ),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9),
        ),
      ),
      icon: Icon(
        icon,
        size: 14,
      ),
      label: Text(
        text,
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ==========================================================
  // DETAIL
  // ==========================================================

  void _showComplaintDetail(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: _darkMode ? darkCard : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(19),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.report_problem_rounded,
                color: teal,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  'Detail Pengaduan',
                  style: TextStyle(
                    color: _darkMode ? Colors.white : navy,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 560,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_getFotoUrl(data).isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(
                          _getFotoUrl(data),
                          width: double.infinity,
                          height: 230,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 150,
                              color: teal.withOpacity(0.08),
                              child: const Center(
                                child: Icon(
                                  Icons.broken_image_rounded,
                                  color: teal,
                                  size: 35,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  _detailRow('Judul', _getTitle(data)),
                  _detailRow('Nama Siswa', _getName(data)),
                  _detailRow('User ID', _getUserId(data)),
                  _detailRow('Kelas', _getKelas(data)),
                  _detailRow('Kategori', _getCategory(data)),
                  _detailRow('Status', _capitalize(_status(data))),
                  _detailRow(
                    'Tanggal',
                    _formatDateTime(_dateOf(data)),
                  ),
                  const SizedBox(height: 10),
                  _detailBox(
                    title: 'Deskripsi',
                    value: _getDescription(data),
                  ),
                  const SizedBox(height: 10),
                  _detailBox(
                    title: 'Feedback Admin',
                    value: _getFeedback(data).isEmpty
                        ? 'Belum ada feedback.'
                        : _getFeedback(data),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Tutup'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(dialogContext);
                _showStatusDialog(doc);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: teal,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(
                Icons.edit_rounded,
                size: 16,
              ),
              label: const Text('Status & Feedback'),
            ),
          ],
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 95,
            child: Text(
              label,
              style: TextStyle(
                color: _darkMode ? Colors.white54 : textMuted,
                fontSize: 10,
              ),
            ),
          ),
          Text(
            ': ',
            style: TextStyle(
              color: _darkMode ? Colors.white38 : textMuted,
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: TextStyle(
                color: _darkMode ? Colors.white : navy,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailBox({
    required String title,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: _darkMode ? Colors.white : navy,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _darkMode
                ? Colors.white.withOpacity(0.04)
                : const Color(0xFFFAF9F5),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Text(
            value.isEmpty ? '-' : value,
            style: TextStyle(
              color: _darkMode ? Colors.white60 : textMuted,
              fontSize: 10,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // STATUS & FEEDBACK
  // ==========================================================

  void _showStatusDialog(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();

    String selectedStatus = _capitalize(_status(data));

    final feedbackController = TextEditingController(
      text: _getFeedback(data),
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: _darkMode ? darkCard : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: Text(
                'Status & Feedback',
                style: TextStyle(
                  color: _darkMode ? Colors.white : navy,
                  fontWeight: FontWeight.w800,
                ),
              ),
              content: SizedBox(
                width: 480,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getTitle(data),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _darkMode ? Colors.white70 : textMuted,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedStatus,
                      decoration: InputDecoration(
                        labelText: 'Status Pengaduan',
                        labelStyle: TextStyle(
                          color: _darkMode ? Colors.white54 : textMuted,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(11),
                        ),
                      ),
                      dropdownColor: _darkMode ? darkCard : Colors.white,
                      items: const [
                        DropdownMenuItem(
                          value: 'Menunggu',
                          child: Text('Menunggu'),
                        ),
                        DropdownMenuItem(
                          value: 'Diproses',
                          child: Text('Diproses'),
                        ),
                        DropdownMenuItem(
                          value: 'Selesai',
                          child: Text('Selesai'),
                        ),
                        DropdownMenuItem(
                          value: 'Ditolak',
                          child: Text('Ditolak'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setDialogState(() {
                          selectedStatus = value;
                        });
                      },
                    ),
                    const SizedBox(height: 13),
                    TextField(
                      controller: feedbackController,
                      minLines: 3,
                      maxLines: 5,
                      style: TextStyle(
                        color: _darkMode ? Colors.white : navy,
                        fontSize: 11,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Feedback Admin',
                        hintText: 'Tulis tanggapan untuk siswa...',
                        labelStyle: TextStyle(
                          color: _darkMode ? Colors.white54 : textMuted,
                        ),
                        hintStyle: TextStyle(
                          color: _darkMode ? Colors.white30 : textMuted,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(11),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    feedbackController.dispose();
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final feedback = feedbackController.text.trim();

                    Navigator.pop(dialogContext);

                    await _updateComplaint(
                      doc.id,
                      selectedStatus,
                      feedback,
                    );

                    feedbackController.dispose();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: teal,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _updateComplaint(
    String id,
    String status,
    String feedback,
  ) async {
    try {
      // ========================================================
      // AMBIL DATA PENGADUAN LAMA
      // ========================================================

      final DocumentSnapshot<Map<String, dynamic>> complaintSnapshot =
          await _complaints.doc(id).get();

      if (!complaintSnapshot.exists) {
        throw Exception(
          'Data pengaduan tidak ditemukan.',
        );
      }

      final Map<String, dynamic> data =
          complaintSnapshot.data() ?? <String, dynamic>{};

      // ========================================================
      // AMBIL USER ID SISWA
      // ========================================================

      final String userId =
          (data['userId'] ?? data['uid'] ?? '').toString().trim();

      // ========================================================
      // AMBIL JUDUL
      // ========================================================

      final String judul = (data['judul'] ??
              data['title'] ??
              data['keluhan'] ??
              data['masalah'] ??
              'Pengaduan')
          .toString();

      // ========================================================
      // STATUS & FEEDBACK SEBELUMNYA
      // ========================================================

      final String oldStatus = (data['status'] ?? '').toString();

      final String oldFeedback =
          (data['feedback'] ?? data['tanggapan'] ?? '').toString();

      // ========================================================
      // UPDATE PENGADUAN
      // ========================================================

      await _complaints.doc(id).update({
        'status': status,
        'feedback': feedback,
      });

      // ========================================================
      // BUAT NOTIFIKASI
      //
      // Hanya dibuat kalau status atau feedback berubah.
      // ========================================================

      final bool adaPerubahan = oldStatus != status || oldFeedback != feedback;

      if (userId.isNotEmpty && adaPerubahan) {
        String body;

        if (feedback.trim().isNotEmpty) {
          body = '$judul telah diperbarui. '
              'Status: $status. '
              'Feedback: $feedback';
        } else {
          body = '$judul telah diperbarui. '
              'Status: $status';
        }

        await NotificationService.instance.createStudentNotification(
          userId: userId,
          title: 'Pengaduan diperbarui',
          body: body,
          complaintId: id,
          status: status,
          feedback: feedback,
        );
      }

      // ========================================================
      // PESAN BERHASIL
      // ========================================================

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Status, feedback, dan notifikasi berhasil diperbarui.',
          ),
          backgroundColor: teal,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal memperbarui data: $e',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // ==========================================================
  // LAPORAN
  // ==========================================================

  Widget _buildReportPage({
    required bool isMobile,
  }) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _complaints.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _errorView(snapshot.error.toString());
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: teal),
          );
        }

        final docs = snapshot.data?.docs ?? [];
        final counts = _getStatusCounts(docs);

        return _scrollContent(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _pageHeader(
                title: 'Laporan',
                subtitle: 'Ringkasan dan cetak laporan pengaduan siswa.',
                icon: Icons.bar_chart_rounded,
                action: _printButton(),
              ),
              const SizedBox(height: 18),
              _buildReportSummary(
                docs,
                counts,
                isMobile,
              ),
              const SizedBox(height: 18),
              _buildReportTable(
                docs,
                isMobile,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReportSummary(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    Map<String, int> counts,
    bool isMobile,
  ) {
    final items = [
      _ReportSummary(
        'Total',
        docs.length,
        navy,
        Icons.assignment_rounded,
      ),
      _ReportSummary(
        'Menunggu',
        counts['menunggu'] ?? 0,
        gold,
        Icons.hourglass_top_rounded,
      ),
      _ReportSummary(
        'Diproses',
        counts['diproses'] ?? 0,
        teal,
        Icons.sync_rounded,
      ),
      _ReportSummary(
        'Selesai',
        counts['selesai'] ?? 0,
        Colors.green,
        Icons.check_circle_rounded,
      ),
      _ReportSummary(
        'Ditolak',
        counts['ditolak'] ?? 0,
        Colors.redAccent,
        Icons.cancel_rounded,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = isMobile
            ? 1
            : constraints.maxWidth < 900
                ? 2
                : 5;

        if (columns == 1) {
          return Column(
            children: [
              for (final item in items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: _reportSummaryCard(item),
                ),
            ],
          );
        }

        if (columns == 2) {
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 3.2,
            ),
            itemBuilder: (context, index) {
              return _reportSummaryCard(items[index]);
            },
          );
        }

        return Row(
          children: [
            for (int i = 0; i < items.length; i++)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: i == items.length - 1 ? 0 : 10,
                  ),
                  child: _reportSummaryCard(items[i]),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _reportSummaryCard(_ReportSummary item) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: _darkMode ? darkCard : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: _darkMode ? Colors.white.withOpacity(0.06) : lightBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              item.icon,
              color: item.color,
              size: 19,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    color: _darkMode ? Colors.white54 : textMuted,
                    fontSize: 9,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${item.value}',
                  style: TextStyle(
                    color: _darkMode ? Colors.white : navy,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportTable(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    bool isMobile,
  ) {
    final sorted = [...docs];

    sorted.sort(
      (a, b) => _dateOf(b.data()).compareTo(_dateOf(a.data())),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _darkMode ? darkCard : Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: _darkMode ? Colors.white.withOpacity(0.06) : lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            title: 'Data Laporan',
            subtitle: 'Data yang akan masuk ke laporan cetak.',
          ),
          const SizedBox(height: 14),
          if (sorted.isEmpty)
            _emptyView('Belum ada data laporan.')
          else if (isMobile)
            for (final doc in sorted) _reportMobileCard(doc)
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                  _darkMode ? navy : const Color(0xFFF4F1E9),
                ),
                columns: const [
                  DataColumn(label: Text('No')),
                  DataColumn(label: Text('Nama')),
                  DataColumn(label: Text('Judul')),
                  DataColumn(label: Text('Kategori')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Tanggal')),
                ],
                rows: [
                  for (int i = 0; i < sorted.length; i++)
                    DataRow(
                      cells: [
                        DataCell(Text('${i + 1}')),
                        DataCell(
                          Text(_getName(sorted[i].data())),
                        ),
                        DataCell(
                          SizedBox(
                            width: 200,
                            child: Text(
                              _getTitle(sorted[i].data()),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(_getCategory(sorted[i].data())),
                        ),
                        DataCell(
                          _statusBadge(
                            _status(sorted[i].data()),
                          ),
                        ),
                        DataCell(
                          Text(
                            _formatDate(
                              _dateOf(sorted[i].data()),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _reportMobileCard(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _darkMode
            ? Colors.white.withOpacity(0.035)
            : const Color(0xFFFAF9F5),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getTitle(data),
                  style: TextStyle(
                    color: _darkMode ? Colors.white : navy,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_getName(data)} • ${_getCategory(data)}',
                  style: TextStyle(
                    color: _darkMode ? Colors.white54 : textMuted,
                    fontSize: 9,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _formatDate(_dateOf(data)),
                  style: TextStyle(
                    color: _darkMode ? Colors.white38 : textMuted,
                    fontSize: 8,
                  ),
                ),
              ],
            ),
          ),
          _statusBadge(_status(data)),
        ],
      ),
    );
  }

  // ==========================================================
  // PENGGUNA
  // ==========================================================

  Widget _buildUsersPage({
    required bool isMobile,
  }) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _users.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _errorView(snapshot.error.toString());
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: teal),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        return _scrollContent(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _pageHeader(
                title: 'Pengguna',
                subtitle: 'Data pengguna yang tersimpan di sistem.',
                icon: Icons.people_alt_rounded,
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: _darkMode ? darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(
                    color: _darkMode
                        ? Colors.white.withOpacity(0.06)
                        : lightBorder,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${docs.length} pengguna',
                      style: TextStyle(
                        color: _darkMode ? Colors.white : navy,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 13),
                    if (docs.isEmpty)
                      _emptyView('Belum ada data pengguna.')
                    else
                      for (final doc in docs) _userCard(doc),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _userCard(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();

    final name =
        (data['nama'] ?? data['name'] ?? data['displayName'] ?? 'Pengguna')
            .toString();

    final email = (data['email'] ?? '').toString();
    final role = (data['role'] ?? 'siswa').toString();

    final isAdmin = role.toLowerCase() == 'admin';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _darkMode
            ? Colors.white.withOpacity(0.035)
            : const Color(0xFFFAF9F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: teal.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: teal,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: _darkMode ? Colors.white : navy,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (email.isNotEmpty)
                  Text(
                    email,
                    style: TextStyle(
                      color: _darkMode ? Colors.white54 : textMuted,
                      fontSize: 9,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: isAdmin ? gold.withOpacity(0.18) : teal.withOpacity(0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _capitalize(role),
              style: TextStyle(
                color: isAdmin ? const Color(0xFF9A7600) : teal,
                fontSize: 8,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // PAGE HEADER
  // ==========================================================

  Widget _pageHeader({
    required String title,
    required String subtitle,
    required IconData icon,
    Widget? action,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: teal.withOpacity(0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: teal,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: _darkMode ? Colors.white : navy,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: _darkMode ? Colors.white54 : textMuted,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
        if (action != null) action,
      ],
    );
  }

  Widget _sectionTitle({
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: _darkMode ? Colors.white : navy,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: TextStyle(
            color: _darkMode ? Colors.white54 : textMuted,
            fontSize: 9,
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // FILTER
  // ==========================================================

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _filterComplaints(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final result = docs.where((doc) {
      final data = doc.data();

      final title = _getTitle(data).toLowerCase();
      final name = _getName(data).toLowerCase();
      final category = _getCategory(data).toLowerCase();
      final status = _status(data);

      final matchesSearch = _searchQuery.isEmpty ||
          title.contains(_searchQuery) ||
          name.contains(_searchQuery) ||
          category.contains(_searchQuery);

      final matchesStatus =
          _statusFilter == 'Semua' || status == _statusFilter.toLowerCase();

      return matchesSearch && matchesStatus;
    }).toList();

    result.sort(
      (a, b) => _dateOf(b.data()).compareTo(_dateOf(a.data())),
    );

    return result;
  }

  // ==========================================================
  // PRINT REPORT
  // ==========================================================

  Future<void> _printReport() async {
    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Menyiapkan laporan...'),
            duration: Duration(seconds: 1),
          ),
        );
      }

      final snapshot = await _complaints.get();
      final docs = [...snapshot.docs];

      docs.sort(
        (a, b) => _dateOf(b.data()).compareTo(_dateOf(a.data())),
      );

      final counts = _getStatusCounts(docs);

      final Map<String, int> categories = {};

      for (final doc in docs) {
        final category = _getCategory(doc.data());
        categories[category] = (categories[category] ?? 0) + 1;
      }

      final sortedCategories = categories.entries.toList()
        ..sort(
          (a, b) => b.value.compareTo(a.value),
        );

      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (context) {
            return [
              pw.Text(
                'SMP NEGERI 3 BANTUL',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Text(
                'Laporan Pengaduan Sarana dan Prasarana Sekolah',
                style: const pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.grey700,
                ),
              ),
              pw.SizedBox(height: 25),
              pw.Table(
                border: pw.TableBorder.all(
                  color: PdfColors.grey400,
                ),
                children: [
                  pw.TableRow(
                    children: [
                      _pdfStatCell(
                        'TOTAL',
                        docs.length.toString(),
                      ),
                      _pdfStatCell(
                        'MENUNGGU',
                        (counts['menunggu'] ?? 0).toString(),
                      ),
                      _pdfStatCell(
                        'DIPROSES',
                        (counts['diproses'] ?? 0).toString(),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _pdfStatCell(
                        'SELESAI',
                        (counts['selesai'] ?? 0).toString(),
                      ),
                      _pdfStatCell(
                        'DITOLAK',
                        (counts['ditolak'] ?? 0).toString(),
                      ),
                      _pdfStatCell(
                        'DITANGANI',
                        ((counts['diproses'] ?? 0) + (counts['selesai'] ?? 0))
                            .toString(),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 28),
              pw.Text(
                'Rekap Status Pengaduan',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.TableHelper.fromTextArray(
                headers: const [
                  'Status',
                  'Jumlah',
                ],
                data: [
                  [
                    'Menunggu',
                    (counts['menunggu'] ?? 0).toString(),
                  ],
                  [
                    'Diproses',
                    (counts['diproses'] ?? 0).toString(),
                  ],
                  [
                    'Selesai',
                    (counts['selesai'] ?? 0).toString(),
                  ],
                  [
                    'Ditolak',
                    (counts['ditolak'] ?? 0).toString(),
                  ],
                ],
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.blueGrey900,
                ),
                cellPadding: const pw.EdgeInsets.all(8),
                border: pw.TableBorder.all(
                  color: PdfColors.grey400,
                ),
              ),
              pw.SizedBox(height: 28),
              pw.Text(
                'Distribusi Kategori',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              if (sortedCategories.isEmpty)
                pw.Text(
                  'Belum ada data kategori.',
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey700,
                  ),
                )
              else
                pw.TableHelper.fromTextArray(
                  headers: const [
                    'Kategori',
                    'Jumlah',
                    'Persentase',
                  ],
                  data: sortedCategories.map((entry) {
                    final percentage =
                        docs.isEmpty ? 0.0 : (entry.value / docs.length) * 100;

                    return [
                      entry.key,
                      entry.value.toString(),
                      '${percentage.toStringAsFixed(1)}%',
                    ];
                  }).toList(),
                  headerStyle: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                  headerDecoration: const pw.BoxDecoration(
                    color: PdfColors.blueGrey900,
                  ),
                  cellPadding: const pw.EdgeInsets.all(8),
                  border: pw.TableBorder.all(
                    color: PdfColors.grey400,
                  ),
                ),
              pw.SizedBox(height: 35),
              pw.Divider(),
              pw.SizedBox(height: 8),
              pw.Text(
                'Dicetak dari Sistem Pengaduan Sarana Sekolah.',
                style: const pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.grey600,
                ),
              ),
            ];
          },
        ),
      );

      final Uint8List bytes = await pdf.save();

      await Printing.layoutPdf(
        onLayout: (format) async => bytes,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mencetak laporan: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  pw.Widget _pdfStatCell(
    String title,
    String value,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(12),
      child: pw.Column(
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // FIRESTORE HELPERS
  // ==========================================================

  String _getUserId(Map<String, dynamic> data) {
    return (data['userId'] ?? data['uid'] ?? '').toString();
  }

  String _getName(Map<String, dynamic> data) {
    return (data['nama'] ??
            data['namaSiswa'] ??
            data['nama_siswa'] ??
            data['userName'] ??
            data['name'] ??
            'Siswa')
        .toString();
  }

  String _getKelas(Map<String, dynamic> data) {
    return (data['kelas'] ?? '').toString();
  }

  String _getCategory(Map<String, dynamic> data) {
    return (data['kategori'] ?? data['category'] ?? 'Tidak berkategori')
        .toString();
  }

  String _getTitle(Map<String, dynamic> data) {
    return (data['judul'] ??
            data['title'] ??
            data['keluhan'] ??
            data['masalah'] ??
            'Pengaduan')
        .toString();
  }

  String _getDescription(Map<String, dynamic> data) {
    return (data['deskripsi'] ??
            data['description'] ??
            data['keluhan'] ??
            data['isi'] ??
            '')
        .toString();
  }

  String _getFeedback(Map<String, dynamic> data) {
    return (data['feedback'] ?? data['tanggapan'] ?? '').toString();
  }

  String _getFotoUrl(Map<String, dynamic> data) {
    return (data['fotoUrl'] ?? data['foto'] ?? data['imageUrl'] ?? '')
        .toString();
  }

  String _status(Map<String, dynamic> data) {
    final value =
        (data['status'] ?? 'Menunggu').toString().trim().toLowerCase();

    switch (value) {
      case 'menunggu':
      case 'pending':
        return 'menunggu';

      case 'diproses':
      case 'process':
      case 'processing':
        return 'diproses';

      case 'selesai':
      case 'done':
      case 'completed':
        return 'selesai';

      case 'ditolak':
      case 'tolak':
      case 'rejected':
        return 'ditolak';

      default:
        return value.isEmpty ? 'menunggu' : value;
    }
  }

  DateTime _dateOf(Map<String, dynamic> data) {
    final value = data['tanggal'] ?? data['createdAt'] ?? data['created_at'];

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime(2000);
    }

    return DateTime(2000);
  }

  String _formatDate(DateTime date) {
    if (date.year == 2000) return '-';

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    if (date.year == 2000) return '-';

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/${date.year} $hour:$minute';
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;

    return value[0].toUpperCase() + value.substring(1);
  }

  Map<String, int> _getStatusCounts(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    int menunggu = 0;
    int diproses = 0;
    int selesai = 0;
    int ditolak = 0;

    for (final doc in docs) {
      switch (_status(doc.data())) {
        case 'menunggu':
          menunggu++;
          break;
        case 'diproses':
          diproses++;
          break;
        case 'selesai':
          selesai++;
          break;
        case 'ditolak':
          ditolak++;
          break;
      }
    }

    return {
      'menunggu': menunggu,
      'diproses': diproses,
      'selesai': selesai,
      'ditolak': ditolak,
    };
  }

  // ==========================================================
  // UI HELPERS
  // ==========================================================

  Widget _scrollContent({
    required Widget child,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(22),
      child: child,
    );
  }

  Widget _emptyView(String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            Icon(
              Icons.inbox_rounded,
              color: _darkMode ? Colors.white30 : textMuted,
              size: 42,
            ),
            const SizedBox(height: 9),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _darkMode ? Colors.white54 : textMuted,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: _darkMode ? darkCard : Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: _darkMode ? Colors.white.withOpacity(0.06) : lightBorder,
        ),
      ),
      child: _emptyView(text),
    );
  }

  Widget _errorView(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.redAccent,
              size: 50,
            ),
            const SizedBox(height: 12),
            Text(
              'Gagal memuat data',
              style: TextStyle(
                color: _darkMode ? Colors.white : navy,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _darkMode ? Colors.white54 : textMuted,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // LOGOUT
  // ==========================================================

  Future<void> _logout() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: _darkMode ? darkCard : Colors.white,
          title: Text(
            'Keluar dari Admin?',
            style: TextStyle(
              color: _darkMode ? Colors.white : navy,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            'Kamu akan keluar dari akun admin.',
            style: TextStyle(
              color: _darkMode ? Colors.white60 : textMuted,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text('Keluar'),
            ),
          ],
        );
      },
    );

    if (result != true) return;

    try {
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const AdminPetugasLoginPage(),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal keluar: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
}

// ============================================================
// STAT ITEM
// ============================================================

class _StatItem {
  final String title;
  final int value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
}

// ============================================================
// REPORT SUMMARY
// ============================================================

class _ReportSummary {
  final String title;
  final int value;
  final Color color;
  final IconData icon;

  const _ReportSummary(
    this.title,
    this.value,
    this.color,
    this.icon,
  );
}

// ============================================================
// GRAPH PAINTER
// ============================================================

class _ComplaintChartPainter extends CustomPainter {
  final List<int> values;
  final int maxValue;
  final bool darkMode;

  _ComplaintChartPainter({
    required this.values,
    required this.maxValue,
    required this.darkMode,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final paint = Paint()..strokeWidth = 1;

    const double left = 45;
    const double right = 18;
    const double top = 18;
    const double bottom = 48;

    final chartWidth = size.width - left - right;
    final chartHeight = size.height - top - bottom;

    final gridColor =
        darkMode ? Colors.white.withOpacity(0.07) : const Color(0xFFE8EDEF);

    final labelColor = darkMode ? Colors.white54 : textMuted;

    // GRID
    for (int i = 0; i <= 4; i++) {
      final y = top + chartHeight - chartHeight * i / 4;

      paint.color = gridColor;

      canvas.drawLine(
        Offset(left, y),
        Offset(size.width - right, y),
        paint,
      );

      final value = (maxValue * i / 4).round();

      final painter = TextPainter(
        text: TextSpan(
          text: '$value',
          style: TextStyle(
            color: labelColor,
            fontSize: 9,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      painter.layout();

      painter.paint(
        canvas,
        Offset(
          left - painter.width - 8,
          y - painter.height / 2,
        ),
      );
    }

    // AXIS
    paint.color = gridColor;

    canvas.drawLine(
      const Offset(left, top),
      Offset(left, top + chartHeight),
      paint,
    );

    // BAR DATA
    const labels = [
      'Menunggu',
      'Diproses',
      'Selesai',
      'Ditolak',
    ];

    const colors = [
      gold,
      teal,
      Colors.green,
      Colors.redAccent,
    ];

    final slotWidth = chartWidth / values.length;
    final barWidth = slotWidth * 0.46;

    for (int i = 0; i < values.length; i++) {
      final centerX = left + slotWidth * (i + 0.5);

      final barHeight =
          maxValue <= 0 ? 0.0 : chartHeight * values[i] / maxValue;

      final rect = Rect.fromLTWH(
        centerX - barWidth / 2,
        top + chartHeight - barHeight,
        barWidth,
        barHeight,
      );

      paint.color = colors[i];

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          rect,
          const Radius.circular(8),
        ),
        paint,
      );

      // VALUE
      final valuePainter = TextPainter(
        text: TextSpan(
          text: '${values[i]}',
          style: TextStyle(
            color: darkMode ? Colors.white : navy,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      valuePainter.layout();

      final valueY = barHeight > 0
          ? top + chartHeight - barHeight - valuePainter.height - 6
          : top + chartHeight - valuePainter.height - 6;

      valuePainter.paint(
        canvas,
        Offset(
          centerX - valuePainter.width / 2,
          valueY,
        ),
      );

      // LABEL
      final labelPainter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: TextStyle(
            color: labelColor,
            fontSize: 8,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );

      labelPainter.layout(
        maxWidth: slotWidth,
      );

      labelPainter.paint(
        canvas,
        Offset(
          centerX - labelPainter.width / 2,
          top + chartHeight + 10,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant _ComplaintChartPainter oldDelegate,
  ) {
    if (oldDelegate.maxValue != maxValue) return true;
    if (oldDelegate.darkMode != darkMode) return true;
    if (oldDelegate.values.length != values.length) return true;

    for (int i = 0; i < values.length; i++) {
      if (oldDelegate.values[i] != values[i]) {
        return true;
      }
    }

    return false;
  }
}
