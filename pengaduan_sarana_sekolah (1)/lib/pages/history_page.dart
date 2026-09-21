import 'package:flutter/material.dart';

import 'models/complaint_model.dart';
import '../services/firestore_service.dart';
import 'complaint_detail_page.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  // =========================
  // WARNA TEMA
  // =========================
  static const Color navy = Color(0xFF0B1F3A);
  static const Color navyDark = Color(0xFF061426);
  static const Color teal = Color(0xFF0F766E);
  static const Color tealLight = Color(0xFF2DD4BF);
  static const Color gold = Color(0xFFF4C95D);
  static const Color cream = Color(0xFFFFFDF7);

  @override
  Widget build(BuildContext context) {
    // Tidak lagi menggunakan themeNotifier.
    // Tema diambil langsung dari ThemeData Flutter.
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    final Color background = isDark ? navyDark : cream;
    final Color cardColor = isDark ? const Color(0xFF102A43) : Colors.white;
    final Color titleColor = isDark ? Colors.white : navy;
    final Color subtitleColor = isDark ? Colors.white70 : Colors.grey.shade600;
    final Color borderColor =
        isDark ? teal.withOpacity(0.45) : gold.withOpacity(0.45);

    return Scaffold(
      backgroundColor: background,

      // =========================================================
      // APP BAR
      // =========================================================
      appBar: AppBar(
        backgroundColor: isDark ? navy : Colors.white,
        foregroundColor: isDark ? Colors.white : navy,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    navy,
                    teal,
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: teal.withOpacity(0.25),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Icon(
                Icons.history_rounded,
                color: gold,
                size: 19,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Riwayat Pengaduan',
              style: TextStyle(
                color: isDark ? Colors.white : navy,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),

      // =========================================================
      // DATA PENGADUAN
      // =========================================================
      body: StreamBuilder<List<ComplaintModel>>(
        stream: FirestoreService().getMyComplaints(),
        builder: (context, snapshot) {
          // =====================================================
          // ERROR
          // =====================================================
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.redAccent.withOpacity(0.45),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: Colors.redAccent,
                        size: 42,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Terjadi kesalahan',
                        style: TextStyle(
                          color: titleColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: subtitleColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          // =====================================================
          // LOADING
          // =====================================================
          if (!snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          navy,
                          teal,
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: teal.withOpacity(0.25),
                          blurRadius: 18,
                        ),
                      ],
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(gold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Memuat riwayat...',
                    style: TextStyle(
                      color: titleColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
          }

          final List<ComplaintModel> complaints = snapshot.data!;

          // =====================================================
          // KOSONG
          // =====================================================
          if (complaints.isEmpty) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(25),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: borderColor,
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(
                          isDark ? 0.25 : 0.08,
                        ),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? [
                                    teal.withOpacity(0.25),
                                    navy.withOpacity(0.5),
                                  ]
                                : [
                                    gold.withOpacity(0.20),
                                    teal.withOpacity(0.10),
                                  ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.history_rounded,
                          color: isDark ? tealLight : teal,
                          size: 35,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Belum Ada Pengaduan',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: titleColor,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        'Belum ada pengaduan dari akun ini.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: subtitleColor,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          // =====================================================
          // LIST RIWAYAT
          // =====================================================
          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              14,
              14,
              14,
              25,
            ),
            itemCount: complaints.length,
            itemBuilder: (context, index) {
              final ComplaintModel complaint = complaints[index];

              final String status = complaint.status.trim().toLowerCase();

              Color statusColor;

              if (status.contains('selesai')) {
                statusColor = Colors.green;
              } else if (status.contains('proses')) {
                statusColor = Colors.orange;
              } else if (status.contains('tolak')) {
                statusColor = Colors.redAccent;
              } else {
                statusColor = tealLight;
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 11),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(21),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ComplaintDetailPage(
                            complaint: complaint,
                          ),
                        ),
                      );
                    },
                    child: Ink(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(21),
                        border: Border.all(
                          color: borderColor,
                          width: 1.1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(
                              isDark ? 0.25 : 0.07,
                            ),
                            blurRadius: 16,
                            offset: const Offset(0, 7),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // =================================================
                          // ICON
                          // =================================================
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isDark
                                    ? [
                                        navy,
                                        teal.withOpacity(0.75),
                                      ]
                                    : [
                                        teal.withOpacity(0.12),
                                        gold.withOpacity(0.14),
                                      ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              Icons.report_problem_rounded,
                              color: isDark ? gold : teal,
                              size: 27,
                            ),
                          ),

                          const SizedBox(width: 13),

                          // =================================================
                          // CONTENT
                          // =================================================
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  complaint.judul,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: titleColor,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),

                                const SizedBox(height: 5),

                                Text(
                                  complaint.kategori,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: subtitleColor,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),

                                const SizedBox(height: 7),

                                // =================================================
                                // STATUS
                                // =================================================
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 9,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(
                                      isDark ? 0.18 : 0.10,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: statusColor.withOpacity(0.35),
                                    ),
                                  ),
                                  child: Text(
                                    'Status: ${complaint.status}',
                                    style: TextStyle(
                                      color: statusColor,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 8),

                          // =================================================
                          // ARROW
                          // =================================================
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? teal.withOpacity(0.18)
                                  : teal.withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: isDark ? tealLight : teal,
                              size: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
