import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'register_page.dart';
import 'student_home_page.dart';
import 'admin_petugas_login_page.dart';
import '../widgets/copyright_watermark.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final nisnController = TextEditingController();
  final kelasController = TextEditingController();
  final passwordController = TextEditingController();

  VideoPlayerController? videoController;

  bool videoReady = false;
  bool isLoading = false;
  bool obscurePassword = true;

  static const Color navy = Color(0xFF0B1F3A);
  static const Color teal = Color(0xFF000000);
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
      debugPrint('Login background video error: $e');

      if (!mounted) return;

      setState(() {
        videoReady = false;
      });
    }
  }

  Future<void> login() async {
    final username = usernameController.text.trim().toLowerCase();
    final nisn = nisnController.text.trim();
    final kelas = kelasController.text.trim().toLowerCase();
    final password = passwordController.text.trim();

    if (username.isEmpty) {
      _showMessage(
        'Username wajib diisi.',
        isError: true,
      );
      return;
    }

    if (nisn.isEmpty) {
      _showMessage(
        'NISN/NIS wajib diisi.',
        isError: true,
      );
      return;
    }

    if (kelas.isEmpty) {
      _showMessage(
        'Kelas wajib diisi.',
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

      // ==========================================================
      // LOGIN FIREBASE AUTH
      // ==========================================================

      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;

      if (user == null) {
        throw Exception('Akun tidak ditemukan.');
      }

      // ==========================================================
      // AMBIL DATA SISWA DARI FIRESTORE
      // ==========================================================

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        await FirebaseAuth.instance.signOut();

        throw Exception(
          'Data siswa tidak ditemukan di database.',
        );
      }

      final data = userDoc.data() ?? {};

      final role = data['role']?.toString().toLowerCase() ?? 'siswa';

      // ==========================================================
      // CEK ROLE
      // ==========================================================

      if (role != 'siswa') {
        await FirebaseAuth.instance.signOut();

        throw Exception(
          'Akun ini bukan akun siswa.',
        );
      }

      // ==========================================================
      // AMBIL DATA NISN/NIS DAN KELAS
      // ==========================================================

      final nisnFirestore = data['nisn']?.toString().trim() ?? '';
      final kelasFirestore =
          data['kelas']?.toString().trim().toLowerCase() ?? '';

      // ==========================================================
      // CEK NISN/NIS
      // ==========================================================

      if (nisnFirestore.isEmpty) {
        await FirebaseAuth.instance.signOut();

        throw Exception(
          'NISN/NIS belum terdaftar pada akun ini.',
        );
      }

      if (nisnFirestore != nisn) {
        await FirebaseAuth.instance.signOut();

        throw Exception(
          'NISN/NIS tidak sesuai dengan akun.',
        );
      }

      // ==========================================================
      // CEK KELAS
      // ==========================================================

      if (kelasFirestore.isEmpty) {
        await FirebaseAuth.instance.signOut();

        throw Exception(
          'Kelas belum terdaftar pada akun ini.',
        );
      }

      if (kelasFirestore != kelas) {
        await FirebaseAuth.instance.signOut();

        throw Exception(
          'Kelas tidak sesuai dengan akun.',
        );
      }

      // ==========================================================
      // LOGIN BERHASIL
      // ==========================================================

      debugPrint('========================================');
      debugPrint('LOGIN SISWA BERHASIL');
      debugPrint('USERNAME : $username');
      debugPrint('NISN/NIS : $nisn');
      debugPrint('KELAS    : $kelasFirestore');
      debugPrint('ROLE     : $role');
      debugPrint('UID      : ${user.uid}');
      debugPrint('========================================');

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const StudentHomePage(),
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
          message = 'Login gagal: ${e.code}\n${e.message ?? ''}';
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

  void _openAdminPetugasLogin() {
    if (isLoading) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminPetugasLoginPage(),
      ),
    );
  }

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
    nisnController.dispose();
    kelasController.dispose();
    passwordController.dispose();
    videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ==========================================================
          // BACKGROUND VIDEO
          // ==========================================================

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

          // ==========================================================
          // OVERLAY
          // ==========================================================

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

          // ==========================================================
          // CONTENT
          // ==========================================================

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  18,
                  9,
                  18,
                  15,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 500,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ====================================================
                      // LOGO
                      // ====================================================

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

                      // ====================================================
                      // LOGIN CARD
                      // ====================================================

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(
                          20,
                          19,
                          20,
                          15,
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
                              child: const Icon(
                                Icons.lock_person_rounded,
                                color: gold,
                                size: 25,
                              ),
                            ),

                            const SizedBox(height: 8),

                            const Text(
                              'LOGIN SISWA',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: navy,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.4,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              'Masuk untuk membuat pengaduan',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 11.5,
                              ),
                            ),

                            const SizedBox(height: 17),

                            // ==================================================
                            // USERNAME
                            // ==================================================

                            TextField(
                              controller: usernameController,
                              enabled: !isLoading,
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

                            // ==================================================
                            // NISN / NIS
                            // ==================================================

                            TextField(
                              controller: nisnController,
                              enabled: !isLoading,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              decoration: _inputDecoration(
                                icon: Icons.badge_outlined,
                                label: 'NISN / NIS',
                                hint: 'Masukkan NISN atau NIS',
                              ),
                            ),

                            const SizedBox(height: 10),

                            // ==================================================
                            // KELAS
                            // ==================================================

                            TextField(
                              controller: kelasController,
                              enabled: !isLoading,
                              textCapitalization: TextCapitalization.characters,
                              textInputAction: TextInputAction.next,
                              decoration: _inputDecoration(
                                icon: Icons.school_outlined,
                                label: 'Kelas',
                                hint: 'Contoh: IX A / IX B',
                              ),
                            ),

                            const SizedBox(height: 10),

                            // ==================================================
                            // PASSWORD
                            // ==================================================

                            TextField(
                              controller: passwordController,
                              enabled: !isLoading,
                              obscureText: obscurePassword,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) {
                                if (!isLoading) {
                                  login();
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
                                  onPressed: isLoading
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

                            // ==================================================
                            // LOGIN BUTTON
                            // ==================================================

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
                                  onPressed: isLoading ? null : login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: Colors.transparent,
                                    elevation: 0,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
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
                                      : const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.login_rounded,
                                              size: 20,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              'MASUK',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w900,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 11),

                            // ==================================================
                            // PEMBATAS
                            // ==================================================

                            Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 9,
                                  ),
                                  child: Text(
                                    'BELUM PUNYA AKUN?',
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            // ==================================================
                            // REGISTER
                            // ==================================================

                            SizedBox(
                              width: double.infinity,
                              height: 43,
                              child: OutlinedButton(
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const RegisterPage(),
                                          ),
                                        );
                                      },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: navy,
                                  side: BorderSide(
                                    color: teal.withOpacity(0.65),
                                    width: 1.3,
                                  ),
                                  backgroundColor:
                                      Colors.white.withOpacity(0.55),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.person_add_alt_1_rounded,
                                      color: teal,
                                      size: 17,
                                    ),
                                    SizedBox(width: 7),
                                    Text(
                                      'BUAT AKUN SISWA',
                                      style: TextStyle(
                                        color: navy,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 11.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      // ====================================================
                      // FOOTER
                      // ====================================================

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

          // ==========================================================
          // ADMIN / PETUGAS
          // ==========================================================

          Positioned(
            top: 10,
            left: 10,
            child: SafeArea(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isLoading ? null : _openAdminPetugasLogin,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: navy.withOpacity(0.78),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: gold.withOpacity(0.65),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.20),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.admin_panel_settings_rounded,
                          color: gold,
                          size: 17,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'ADMIN / PETUGAS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
