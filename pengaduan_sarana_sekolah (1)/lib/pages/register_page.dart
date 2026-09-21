import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final namaController = TextEditingController();
  final nisController = TextEditingController();
  final kelasController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  VideoPlayerController? videoController;

  bool videoReady = false;
  bool isLoading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  static const Color navy = Color(0xFF071A33);
  static const Color navyLight = Color(0xFF0B3158);
  static const Color teal = Color(0xFF0F766E);
  static const Color tealBright = Color(0xFF19B8A5);
  static const Color gold = Color(0xFFF4C95D);
  static const Color goldLight = Color(0xFFFFE9A8);

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
      debugPrint('Register background video error: $e');

      if (!mounted) return;

      setState(() {
        videoReady = false;
      });
    }
  }

  Future<void> register() async {
    final nama = namaController.text.trim();
    final nis = nisController.text.trim();
    final kelas = kelasController.text.trim();
    final username = usernameController.text.trim().toLowerCase();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (nama.isEmpty) {
      _showMessage(
        'Nama lengkap wajib diisi.',
        isError: true,
      );
      return;
    }

    if (nis.isEmpty) {
      _showMessage(
        'NIS/NISN wajib diisi.',
        isError: true,
      );
      return;
    }

    if (nis.contains(' ')) {
      _showMessage(
        'NIS/NISN tidak boleh menggunakan spasi.',
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

    if (username.isEmpty) {
      _showMessage(
        'Username wajib diisi.',
        isError: true,
      );
      return;
    }

    if (username.contains(' ')) {
      _showMessage(
        'Username tidak boleh menggunakan spasi.',
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

    if (password.length < 6) {
      _showMessage(
        'Password minimal 6 karakter.',
        isError: true,
      );
      return;
    }

    if (password != confirmPassword) {
      _showMessage(
        'Konfirmasi password tidak sama.',
        isError: true,
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    UserCredential? credential;

    try {
      final email = '$username@smpn3bantul.com';

      credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;

      if (user == null) {
        throw Exception('Akun gagal dibuat.');
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'nama': nama,
        'nis': nis,
        'nisn': nis,
        'kelas': kelas,
        'username': username,
        'role': 'siswa',
        'createdAt': FieldValue.serverTimestamp(),
      });

      debugPrint('========================================');
      debugPrint('REGISTRASI SISWA BERHASIL');
      debugPrint('UID    : ${user.uid}');
      debugPrint('NAMA   : $nama');
      debugPrint('NIS    : $nis');
      debugPrint('KELAS  : $kelas');
      debugPrint('USER   : $username');
      debugPrint('ROLE   : siswa');
      debugPrint('========================================');

      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      _showMessage(
        'Pendaftaran berhasil. Silakan login.',
      );

      await Future.delayed(
        const Duration(milliseconds: 800),
      );

      if (!mounted) return;

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String pesan;

      switch (e.code) {
        case 'email-already-in-use':
          pesan = 'Username sudah digunakan. Silakan pilih username lain.';
          break;

        case 'weak-password':
          pesan = 'Password terlalu lemah. Gunakan minimal 6 karakter.';
          break;

        case 'invalid-email':
          pesan = 'Username tidak valid.';
          break;

        case 'operation-not-allowed':
          pesan = 'Email/Password belum diaktifkan di Firebase Authentication.';
          break;

        case 'network-request-failed':
          pesan = 'Koneksi internet bermasalah.';
          break;

        case 'too-many-requests':
          pesan = 'Terlalu banyak percobaan. Coba lagi beberapa saat.';
          break;

        default:
          pesan = 'Firebase: ${e.code}\n${e.message ?? ''}';
      }

      if (!mounted) return;

      _showMessage(
        pesan,
        isError: true,
      );
    } on FirebaseException catch (e) {
      if (credential?.user != null) {
        try {
          await FirebaseAuth.instance.signOut();
        } catch (_) {}
      }

      if (!mounted) return;

      _showMessage(
        'Gagal menyimpan data siswa ke Firestore.\n'
        '${e.code}: ${e.message ?? ''}',
        isError: true,
      );
    } catch (e) {
      if (credential?.user != null) {
        try {
          await FirebaseAuth.instance.signOut();
        } catch (_) {}
      }

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
              fontWeight: FontWeight.w700,
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
    required String hint,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(
        icon,
        color: gold.withOpacity(0.90),
        size: 21,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white.withOpacity(0.075),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 14,
      ),
      hintStyle: TextStyle(
        color: Colors.white.withOpacity(0.58),
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(
          color: Colors.white.withOpacity(0.15),
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(
          color: Colors.white.withOpacity(0.18),
          width: 1,
        ),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(15),
        ),
        borderSide: BorderSide(
          color: gold,
          width: 1.5,
        ),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(
          color: Colors.white.withOpacity(0.10),
          width: 1,
        ),
      ),
    );
  }

  @override
  void dispose() {
    namaController.dispose();
    nisController.dispose();
    kelasController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: navy,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ================================================================
          // BACKGROUND VIDEO
          // ================================================================

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
            const DecoratedBox(
              decoration: BoxDecoration(
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

          // ================================================================
          // DARK OVERLAY
          // ================================================================

          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    navy.withOpacity(0.48),
                    navy.withOpacity(0.15),
                    navy.withOpacity(0.62),
                  ],
                ),
              ),
            ),
          ),

          // ================================================================
          // TEAL GLOW
          // ================================================================

          Positioned(
            left: -80,
            top: 120,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: teal.withOpacity(0.12),
                boxShadow: [
                  BoxShadow(
                    color: teal.withOpacity(0.18),
                    blurRadius: 100,
                    spreadRadius: 30,
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            right: -90,
            bottom: 100,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: gold.withOpacity(0.07),
                boxShadow: [
                  BoxShadow(
                    color: gold.withOpacity(0.12),
                    blurRadius: 110,
                    spreadRadius: 25,
                  ),
                ],
              ),
            ),
          ),

          // ================================================================
          // CONTENT
          // ================================================================

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  17,
                  8,
                  17,
                  14,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 470,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ====================================================
                      // TOP BAR
                      // ====================================================

                      Row(
                        children: [
                          Material(
                            color: Colors.black.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(13),
                            child: InkWell(
                              onTap: isLoading
                                  ? null
                                  : () => Navigator.pop(context),
                              borderRadius: BorderRadius.circular(13),
                              child: const Padding(
                                padding: EdgeInsets.all(9),
                                child: Icon(
                                  Icons.arrow_back_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 11,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: navy.withOpacity(0.55),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: gold.withOpacity(0.45),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.school_rounded,
                                  color: gold,
                                  size: 14,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'SISWA',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // ====================================================
                      // LOGO
                      // ====================================================

                      Container(
                        width: 70,
                        height: 70,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFDF7),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: gold,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: gold.withOpacity(0.40),
                              blurRadius: 22,
                              spreadRadius: 2,
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.40),
                              blurRadius: 18,
                              offset: const Offset(0, 7),
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

                      const SizedBox(height: 7),

                      const Text(
                        'SMP NEGERI 3 BANTUL',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                          shadows: [
                            Shadow(
                              color: Colors.black87,
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 3),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 25,
                            height: 2,
                            decoration: BoxDecoration(
                              color: gold,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          const SizedBox(width: 7),
                          const Text(
                            'PENGADUAN SARANA SEKOLAH',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(width: 7),
                          Container(
                            width: 25,
                            height: 2,
                            decoration: BoxDecoration(
                              color: gold,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 11),

                      // ====================================================
                      // REGISTER CARD
                      // ====================================================

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(
                          18,
                          16,
                          18,
                          14,
                        ),
                        decoration: BoxDecoration(
                          color: navy.withOpacity(0.80),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: gold.withOpacity(0.38),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.35),
                              blurRadius: 30,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // ==================================================
                            // ICON
                            // ==================================================

                            Container(
                              width: 43,
                              height: 43,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    gold,
                                    Color(0xFFE8A928),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: gold.withOpacity(0.25),
                                    blurRadius: 15,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.person_add_alt_1_rounded,
                                color: navy,
                                size: 23,
                              ),
                            ),

                            const SizedBox(height: 7),

                            const Text(
                              'BUAT AKUN SISWA',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.4,
                              ),
                            ),

                            const SizedBox(height: 2),

                            Text(
                              'Daftarkan akun untuk membuat pengaduan',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.62),
                                fontSize: 10.5,
                              ),
                            ),

                            const SizedBox(height: 13),

                            // ==================================================
                            // NAMA
                            // ==================================================

                            _buildField(
                              child: TextField(
                                controller: namaController,
                                enabled: !isLoading,
                                textInputAction: TextInputAction.next,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: _inputDecoration(
                                  icon: Icons.person_outline_rounded,
                                  hint: 'Nama lengkap',
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),

                            // ==================================================
                            // NIS / NISN
                            // ==================================================

                            _buildField(
                              child: TextField(
                                controller: nisController,
                                enabled: !isLoading,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: _inputDecoration(
                                  icon: Icons.badge_outlined,
                                  hint: 'NIS / NISN',
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),

                            // ==================================================
                            // KELAS
                            // ==================================================

                            _buildField(
                              child: TextField(
                                controller: kelasController,
                                enabled: !isLoading,
                                textCapitalization:
                                    TextCapitalization.characters,
                                textInputAction: TextInputAction.next,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: _inputDecoration(
                                  icon: Icons.class_outlined,
                                  hint: 'Kelas, contoh: VII,VIII,IX A-G',
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),

                            // ==================================================
                            // USERNAME
                            // ==================================================

                            _buildField(
                              child: TextField(
                                controller: usernameController,
                                enabled: !isLoading,
                                autocorrect: false,
                                textCapitalization: TextCapitalization.none,
                                textInputAction: TextInputAction.next,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: _inputDecoration(
                                  icon: Icons.account_circle_outlined,
                                  hint: 'Username',
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),

                            // ==================================================
                            // PASSWORD
                            // ==================================================

                            _buildField(
                              child: TextField(
                                controller: passwordController,
                                enabled: !isLoading,
                                obscureText: obscurePassword,
                                textInputAction: TextInputAction.next,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: _inputDecoration(
                                  icon: Icons.lock_outline_rounded,
                                  hint: 'Password minimal 6 karakter',
                                  suffixIcon: IconButton(
                                    tooltip: obscurePassword
                                        ? 'Tampilkan password'
                                        : 'Sembunyikan password',
                                    icon: Icon(
                                      obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: Colors.white.withOpacity(0.70),
                                      size: 20,
                                    ),
                                    onPressed: isLoading
                                        ? null
                                        : () {
                                            setState(() {
                                              obscurePassword =
                                                  !obscurePassword;
                                            });
                                          },
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),

                            // ==================================================
                            // KONFIRMASI PASSWORD
                            // ==================================================

                            _buildField(
                              child: TextField(
                                controller: confirmPasswordController,
                                enabled: !isLoading,
                                obscureText: obscureConfirmPassword,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) {
                                  if (!isLoading) {
                                    register();
                                  }
                                },
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: _inputDecoration(
                                  icon: Icons.lock_reset_outlined,
                                  hint: 'Konfirmasi password',
                                  suffixIcon: IconButton(
                                    tooltip: obscureConfirmPassword
                                        ? 'Tampilkan password'
                                        : 'Sembunyikan password',
                                    icon: Icon(
                                      obscureConfirmPassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: Colors.white.withOpacity(0.70),
                                      size: 20,
                                    ),
                                    onPressed: isLoading
                                        ? null
                                        : () {
                                            setState(() {
                                              obscureConfirmPassword =
                                                  !obscureConfirmPassword;
                                            });
                                          },
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // ==================================================
                            // BUTTON DAFTAR
                            // ==================================================

                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      gold,
                                      Color(0xFFFFD978),
                                      tealBright,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: gold.withOpacity(0.22),
                                      blurRadius: 14,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: isLoading ? null : register,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    foregroundColor: navy,
                                    disabledBackgroundColor: Colors.transparent,
                                    disabledForegroundColor: Colors.white70,
                                    elevation: 0,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  child: isLoading
                                      ? const SizedBox(
                                          width: 21,
                                          height: 21,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.3,
                                            color: navy,
                                          ),
                                        )
                                      : const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.person_add_alt_1_rounded,
                                              size: 20,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              'BUAT AKUN',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w900,
                                                letterSpacing: 0.7,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),

                            // ==================================================
                            // BUTTON LOGIN
                            // ==================================================

                            SizedBox(
                              width: double.infinity,
                              height: 40,
                              child: OutlinedButton(
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        Navigator.pop(context);
                                      },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor:
                                      Colors.white.withOpacity(0.035),
                                  side: BorderSide(
                                    color: gold.withOpacity(0.45),
                                    width: 1,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(13),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.login_rounded,
                                      color: gold,
                                      size: 17,
                                    ),
                                    SizedBox(width: 7),
                                    Text(
                                      'SUDAH PUNYA AKUN? LOGIN',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.25,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      // ====================================================
                      // FOOTER
                      // ====================================================

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.verified_user_outlined,
                            color: gold.withOpacity(0.85),
                            size: 13,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Akun khusus siswa SMP Negeri 3 Bantul',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.72),
                              fontSize: 9.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
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

  Widget _buildField({
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}
