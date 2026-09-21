import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'admin_petugas_register_page.dart';
import 'admin_dashboard_page.dart';

class AdminPetugasLoginPage extends StatefulWidget {
  const AdminPetugasLoginPage({super.key});

  @override
  State<AdminPetugasLoginPage> createState() => _AdminPetugasLoginPageState();
}

class _AdminPetugasLoginPageState extends State<AdminPetugasLoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final accessPasswordController = TextEditingController();

  VideoPlayerController? videoController;

  bool videoReady = false;
  bool isLoading = false;
  bool obscurePassword = true;
  bool obscureAccessPassword = true;
  bool accessGranted = false;

  String selectedRole = 'admin';

  static const Color navy = Color(0xff19375e);
  static const Color teal = Color(0xFF0F766E);
  static const Color tealLight = Color(0xFF2DD4BF);
  static const Color gold = Color(0xFFF4C95D);
  static const Color cream = Color(0xFFFFFDF7);

  // ============================================================
  // SANDI AKSES HALAMAN ADMIN / PETUGAS
  // ============================================================
  static const String accessPassword = 'SPEGABA3BANTUL';

  @override
  void initState() {
    super.initState();
    _initVideo();

    // Setelah halaman terbuka, langsung minta sandi akses.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _openAccessPasswordDialog();
      }
    });
  }

  // ============================================================
  // BACKGROUND VIDEO
  // ============================================================
  Future<void> _initVideo() async {
    try {
      final controller = VideoPlayerController.asset(
        'assets/background1.mp4',
      );

      videoController = controller;

      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(0);
      await controller.play();

      if (!mounted) return;

      setState(() {
        videoReady = true;
      });
    } catch (e) {
      debugPrint(
        'Admin/Petugas background video error: $e',
      );

      if (!mounted) return;

      setState(() {
        videoReady = false;
      });
    }
  }

  // ============================================================
  // DIALOG SANDI SAAT MEMBUKA HALAMAN
  // ============================================================
  void _openAccessPasswordDialog() {
    accessPasswordController.clear();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool obscure = true;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: cream,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              titlePadding: const EdgeInsets.fromLTRB(
                22,
                22,
                22,
                8,
              ),
              contentPadding: const EdgeInsets.fromLTRB(
                22,
                8,
                22,
                10,
              ),
              actionsPadding: const EdgeInsets.fromLTRB(
                16,
                0,
                16,
                16,
              ),
              title: Row(
                children: [
                  Container(
                    width: 43,
                    height: 43,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          navy,
                          teal,
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_rounded,
                      color: gold,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'AKSES ADMIN / PETUGAS',
                      style: TextStyle(
                        color: navy,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Masukkan sandi khusus untuk membuka halaman login Admin/Petugas.',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: accessPasswordController,
                    autofocus: true,
                    obscureText: obscure,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) {
                      _checkAccessPassword(dialogContext);
                    },
                    decoration: InputDecoration(
                      labelText: 'Sandi Akses',
                      hintText: 'Masukkan sandi',
                      prefixIcon: const Icon(
                        Icons.vpn_key_rounded,
                        color: navy,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: navy,
                        ),
                        onPressed: () {
                          setDialogState(() {
                            obscure = !obscure;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF5F7F6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(
                          color: Colors.grey.shade200,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(
                          color: teal,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);

                    // Kembali karena belum memasukkan
                    // sandi akses.
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'BATAL',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _checkAccessPassword(dialogContext);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: navy,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 17,
                      vertical: 11,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'BUKA',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ============================================================
  // CEK SANDI AKSES
  // ============================================================
  void _checkAccessPassword(
    BuildContext dialogContext,
  ) {
    final password = accessPasswordController.text.trim();

    if (password.isEmpty) {
      _showMessage(
        'Sandi akses wajib diisi.',
        isError: true,
      );
      return;
    }

    if (password != accessPassword) {
      _showMessage(
        'Sandi akses salah.',
        isError: true,
      );
      return;
    }

    Navigator.pop(dialogContext);

    accessPasswordController.clear();

    if (!mounted) return;

    setState(() {
      accessGranted = true;
    });
  }

  // ============================================================
  // LOGIN ADMIN / PETUGAS
  // ============================================================
  Future<void> _login() async {
    if (!accessGranted) {
      _openAccessPasswordDialog();
      return;
    }

    final username = usernameController.text.trim().toLowerCase();
    final password = passwordController.text.trim();

    if (username.isEmpty) {
      _showMessage(
        'Username wajib diisi.',
        isError: true,
      );
      return;
    }

    if (password.isEmpty) {
      _showMessage(
        'Password wajib diisi.',
        isError: true,
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final email = '$username@smpn3bantul.com';

      debugPrint('========================================');
      debugPrint('LOGIN ADMIN / PETUGAS');
      debugPrint('USERNAME    : $username');
      debugPrint('EMAIL       : $email');
      debugPrint('ROLE PILIHAN: $selectedRole');
      debugPrint('========================================');

      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;

      if (user == null) {
        throw Exception(
          'Akun tidak ditemukan.',
        );
      }

      debugPrint('FIREBASE AUTH BERHASIL');
      debugPrint('UID AUTH : ${user.uid}');
      debugPrint('EMAIL    : ${user.email}');

      // ============================================================
      // CEK users/{uid}
      // ============================================================
      DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(user.uid)
          .get();

      Map<String, dynamic> data = userDoc.data() ?? {};

      // ============================================================
      // FALLBACK CARI BERDASARKAN USERNAME
      // ============================================================
      if (!userDoc.exists) {
        debugPrint(
          'Dokumen users/${user.uid} tidak ditemukan.',
        );

        debugPrint(
          'Mencari user berdasarkan username: $username',
        );

        final usernameQuery = await FirebaseFirestore.instance
            .collection('users')
            .where(
              'username',
              isEqualTo: username,
            )
            .limit(10)
            .get();

        QueryDocumentSnapshot<Map<String, dynamic>>? matchedDoc;

        for (final doc in usernameQuery.docs) {
          final docData = doc.data();

          final docUsername =
              docData['username']?.toString().trim().toLowerCase() ?? '';

          final docRole =
              docData['role']?.toString().trim().toLowerCase() ?? '';

          if (docUsername == username &&
              (docRole == 'admin' || docRole == 'petugas')) {
            matchedDoc = doc;
            break;
          }
        }

        if (matchedDoc != null) {
          userDoc = matchedDoc;
          data = matchedDoc.data();

          debugPrint(
            'FALLBACK USER DITEMUKAN',
          );

          debugPrint(
            'DOCUMENT ID : ${matchedDoc.id}',
          );
        }
      }

      // ============================================================
      // DATA AKUN TIDAK DITEMUKAN
      // ============================================================
      if (!userDoc.exists) {
        await FirebaseAuth.instance.signOut();

        throw Exception(
          'Data akun Admin/Petugas tidak ditemukan untuk username "$username".',
        );
      }

      // ============================================================
      // NORMALISASI DATA
      // ============================================================
      final role = data['role']?.toString().trim().toLowerCase() ?? '';

      final firestoreUsername =
          data['username']?.toString().trim().toLowerCase() ?? '';

      final firestoreUid = data['uid']?.toString().trim() ?? '';

      debugPrint('========================================');
      debugPrint('DATA FIRESTORE');
      debugPrint('DOCUMENT ID   : ${userDoc.id}');
      debugPrint('UID AUTH      : ${user.uid}');
      debugPrint('UID DATA      : $firestoreUid');
      debugPrint('USERNAME DATA : $firestoreUsername');
      debugPrint('ROLE DATA     : $role');
      debugPrint('ROLE PILIHAN  : $selectedRole');
      debugPrint('========================================');

      // ============================================================
      // CEK USERNAME
      // ============================================================
      if (firestoreUsername.isNotEmpty && firestoreUsername != username) {
        await FirebaseAuth.instance.signOut();

        throw Exception(
          'Data akun tidak cocok dengan username yang digunakan.',
        );
      }

      // ============================================================
      // CEK ROLE
      // ============================================================
      if (role != 'admin' && role != 'petugas') {
        await FirebaseAuth.instance.signOut();

        throw Exception(
          'Role akun belum disetel sebagai Admin atau Petugas.',
        );
      }

      // ============================================================
      // ROLE YANG DIPILIH HARUS SESUAI
      // ============================================================
      if (role != selectedRole) {
        await FirebaseAuth.instance.signOut();

        if (selectedRole == 'admin') {
          throw Exception(
            'Akun ini bukan akun admin. Role akun: $role',
          );
        } else {
          throw Exception(
            'Akun ini bukan akun petugas. Role akun: $role',
          );
        }
      }

      if (!mounted) return;

      final nama =
          (data['nama'] ?? data['name'] ?? data['username'] ?? username)
              .toString();

      debugPrint('========================================');
      debugPrint('LOGIN BERHASIL');
      debugPrint('USERNAME : $username');
      debugPrint('ROLE     : $role');
      debugPrint('NAMA     : $nama');
      debugPrint('UID AUTH : ${user.uid}');
      debugPrint('========================================');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AdminDashboardPage(
            role: role,
            nama: nama,
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message;

      switch (e.code) {
        case 'user-not-found':
          message = 'Username belum terdaftar.';
          break;

        case 'wrong-password':
          message = 'Password salah.';
          break;

        case 'invalid-credential':
          message = 'Username atau password salah.';
          break;

        case 'invalid-email':
          message = 'Username tidak valid.';
          break;

        case 'user-disabled':
          message = 'Akun ini telah dinonaktifkan.';
          break;

        case 'too-many-requests':
          message = 'Terlalu banyak percobaan login. Coba lagi nanti.';
          break;

        case 'network-request-failed':
          message = 'Tidak ada koneksi internet.';
          break;

        case 'operation-not-allowed':
          message =
              'Email/Password belum diaktifkan di Firebase Authentication.';
          break;

        default:
          message = 'Login gagal: ${e.message ?? e.code}';
      }

      if (!mounted) return;

      _showMessage(
        message,
        isError: true,
      );
    } on FirebaseException catch (e) {
      if (!mounted) return;

      _showMessage(
        'Firebase/Firestore bermasalah:\n'
        '${e.code}\n'
        '${e.message ?? ''}',
        isError: true,
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // SNACKBAR
  // ============================================================
  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(14),
          backgroundColor: isError ? const Color(0xFFB42318) : teal,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          duration: const Duration(seconds: 4),
        ),
      );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================
  InputDecoration _inputDecoration({
    required IconData icon,
    required String label,
    required String hint,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(
        icon,
        size: 22,
        color: navy.withOpacity(0.78),
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF5F7F6),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 15,
      ),
      labelStyle: const TextStyle(
        color: navy,
        fontWeight: FontWeight.w600,
      ),
      hintStyle: TextStyle(
        color: Colors.grey.shade500,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: BorderSide(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: const BorderSide(
          color: teal,
          width: 1.7,
        ),
      ),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    accessPasswordController.dispose();
    videoController?.dispose();
    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ======================================================
          // BACKGROUND VIDEO
          // ======================================================
          if (videoReady && videoController != null)
            ClipRect(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: videoController!.value.size.width,
                  height: videoController!.value.size.height,
                  child: VideoPlayer(
                    videoController!,
                  ),
                ),
              ),
            )
          else
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    navy,
                    teal,
                  ],
                ),
              ),
            ),

          // ======================================================
          // OVERLAY
          // ======================================================
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x660B1F3A),
                    Color(0x220F766E),
                    Color(0x990B1F3A),
                  ],
                ),
              ),
            ),
          ),

          // ======================================================
          // CONTENT
          // ======================================================
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  18,
                  20,
                  18,
                  20,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 500,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ==================================================
                      // LOGO
                      // ==================================================
                      Container(
                        width: 82,
                        height: 82,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: cream,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: gold,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.30),
                              blurRadius: 18,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/logosmp3.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      const SizedBox(height: 9),

                      const Text(
                        'SMP NEGERI 3 BANTUL',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
                          shadows: [
                            Shadow(
                              color: Colors.black54,
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 4),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 25,
                            height: 2,
                            decoration: BoxDecoration(
                              color: gold,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Flexible(
                            child: Text(
                              'APLIKASI PENGADUAN SARANA SEKOLAH',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.4,
                                shadows: [
                                  Shadow(
                                    color: Colors.black54,
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 25,
                            height: 2,
                            decoration: BoxDecoration(
                              color: gold,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      // ==================================================
                      // LOGIN CARD
                      // ==================================================
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(
                          20,
                          19,
                          20,
                          18,
                        ),
                        decoration: BoxDecoration(
                          color: cream.withOpacity(0.96),
                          borderRadius: BorderRadius.circular(27),
                          border: Border.all(
                            color: gold.withOpacity(0.65),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.28),
                              blurRadius: 26,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // ==========================================
                            // ICON
                            // ==========================================
                            Container(
                              width: 48,
                              height: 48,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    navy,
                                    teal,
                                  ],
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                selectedRole == 'admin'
                                    ? Icons.admin_panel_settings_rounded
                                    : Icons.support_agent_rounded,
                                color: gold,
                                size: 26,
                              ),
                            ),

                            const SizedBox(height: 8),

                            const Text(
                              'LOGIN ADMIN / PETUGAS',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: navy,
                                fontSize: 21,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.4,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              'Masuk menggunakan akun Admin atau Petugas',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 11.5,
                              ),
                            ),

                            const SizedBox(height: 17),

                            // ==========================================
                            // PILIH ROLE
                            // ==========================================
                            Row(
                              children: [
                                Expanded(
                                  child: _roleButton(
                                    role: 'admin',
                                    icon: Icons.admin_panel_settings_rounded,
                                    title: 'ADMIN',
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _roleButton(
                                    role: 'petugas',
                                    icon: Icons.support_agent_rounded,
                                    title: 'PETUGAS',
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 15),

                            // ==========================================
                            // USERNAME
                            // ==========================================
                            TextField(
                              controller: usernameController,
                              enabled: !isLoading && accessGranted,
                              autocorrect: false,
                              textCapitalization: TextCapitalization.none,
                              textInputAction: TextInputAction.next,
                              decoration: _inputDecoration(
                                icon: Icons.person_outline_rounded,
                                label: 'Username',
                                hint: 'Masukkan username',
                              ),
                            ),

                            const SizedBox(height: 10),

                            // ==========================================
                            // PASSWORD
                            // ==========================================
                            TextField(
                              controller: passwordController,
                              enabled: !isLoading && accessGranted,
                              obscureText: obscurePassword,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) {
                                if (!isLoading && accessGranted) {
                                  _login();
                                }
                              },
                              decoration: _inputDecoration(
                                icon: Icons.lock_outline_rounded,
                                label: 'Password',
                                hint: 'Masukkan password',
                                suffixIcon: IconButton(
                                  tooltip: obscurePassword
                                      ? 'Tampilkan password'
                                      : 'Sembunyikan password',
                                  icon: Icon(
                                    obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: navy.withOpacity(0.75),
                                    size: 21,
                                  ),
                                  onPressed: isLoading || !accessGranted
                                      ? null
                                      : () {
                                          setState(() {
                                            obscurePassword = !obscurePassword;
                                          });
                                        },
                                ),
                              ),
                            ),

                            const SizedBox(height: 14),

                            // ==========================================
                            // LOGIN BUTTON
                            // ==========================================
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      navy,
                                      teal,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ElevatedButton(
                                  onPressed: isLoading ? null : _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: Colors.transparent,
                                    elevation: 0,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        16,
                                      ),
                                    ),
                                  ),
                                  child: isLoading
                                      ? const SizedBox(
                                          width: 21,
                                          height: 21,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.3,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              selectedRole == 'admin'
                                                  ? Icons
                                                      .admin_panel_settings_rounded
                                                  : Icons.support_agent_rounded,
                                              size: 20,
                                            ),
                                            const SizedBox(
                                              width: 8,
                                            ),
                                            Text(
                                              selectedRole == 'admin'
                                                  ? 'MASUK SEBAGAI ADMIN'
                                                  : 'MASUK SEBAGAI PETUGAS',
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w900,
                                                letterSpacing: 0.3,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: isLoading || !accessGranted
                                  ? null
                                  : () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const AdminPetugasRegisterPage(),
                                        ),
                                      );
                                    },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 13,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.75),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: teal.withOpacity(0.45),
                                    width: 1.2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: navy.withOpacity(0.08),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            navy,
                                            teal,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.person_add_alt_1_rounded,
                                        color: Colors.white,
                                        size: 21,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Belum punya akun?',
                                            style: TextStyle(
                                              color: Colors.black54,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          const Text(
                                            'Daftar Admin / Petugas',
                                            style: TextStyle(
                                              color: navy,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: teal.withOpacity(0.10),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        color: teal,
                                        size: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // ==========================================
                            // KEMBALI
                            // ==========================================
                            TextButton.icon(
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      Navigator.pop(
                                        context,
                                      );
                                    },
                              icon: const Icon(
                                Icons.arrow_back_rounded,
                                size: 17,
                              ),
                              label: const Text(
                                'KEMBALI KE LOGIN SISWA',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                foregroundColor: navy,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      // ==================================================
                      // FOOTER
                      // ==================================================
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: navy.withOpacity(0.38),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: gold.withOpacity(0.35),
                          ),
                        ),
                        child: const Text(
                          '© SMP Negeri 3 Bantul',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ROLE BUTTON
  // ============================================================
  Widget _roleButton({
    required String role,
    required IconData icon,
    required String title,
  }) {
    final isSelected = selectedRole == role;

    return SizedBox(
      height: 43,
      child: OutlinedButton.icon(
        onPressed: isLoading
            ? null
            : () {
                setState(() {
                  selectedRole = role;
                });
              },
        style: OutlinedButton.styleFrom(
          foregroundColor: isSelected ? Colors.white : navy,
          backgroundColor: isSelected ? navy : Colors.white.withOpacity(0.55),
          side: BorderSide(
            color: isSelected ? gold : teal.withOpacity(0.65),
            width: isSelected ? 1.5 : 1.2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: Icon(
          icon,
          size: 18,
          color: isSelected ? gold : navy,
        ),
        label: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : navy,
            fontSize: 11.5,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
