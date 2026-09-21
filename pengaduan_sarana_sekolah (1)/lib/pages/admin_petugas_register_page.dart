import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class AdminPetugasRegisterPage extends StatefulWidget {
  const AdminPetugasRegisterPage({super.key});

  @override
  State<AdminPetugasRegisterPage> createState() =>
      _AdminPetugasRegisterPageState();
}

class _AdminPetugasRegisterPageState
    extends State<AdminPetugasRegisterPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final namaController = TextEditingController();

  VideoPlayerController? videoController;

  bool videoReady = false;
  bool isLoading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  String selectedRole = 'admin';

  static const Color navy = Color(0xFF19375E);
  static const Color teal = Color(0xFF0F766E);
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
      debugPrint('Register background video error: $e');

      if (!mounted) return;

      setState(() {
        videoReady = false;
      });
    }
  }

  Future<void> _register() async {
    final nama = namaController.text.trim();
    final username =
        usernameController.text.trim().toLowerCase();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (nama.isEmpty) {
      _showMessage(
        'Nama wajib diisi.',
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
        'Username tidak boleh mengandung spasi.',
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

      debugPrint('====================================');
      debugPrint('REGISTRASI ADMIN / PETUGAS');
      debugPrint('NAMA     : $nama');
      debugPrint('USERNAME : $username');
      debugPrint('ROLE     : $selectedRole');
      debugPrint('EMAIL    : $email');
      debugPrint('====================================');

      // ==========================================================
      // CEK USERNAME DI FIRESTORE
      // ==========================================================

      final existingUser = await FirebaseFirestore.instance
          .collection('users')
          .where(
            'username',
            isEqualTo: username,
          )
          .limit(1)
          .get();

      if (existingUser.docs.isNotEmpty) {
        throw Exception(
          'Username "$username" sudah digunakan.',
        );
      }

      // ==========================================================
      // BUAT AKUN FIREBASE AUTH
      // ==========================================================

      credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;

      if (user == null) {
        throw Exception(
          'Akun gagal dibuat.',
        );
      }

      // ==========================================================
      // SIMPAN DATA KE FIRESTORE
      // ==========================================================

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'uid': user.uid,
        'nama': nama,
        'name': nama,
        'username': username,
        'email': email,
        'role': selectedRole,
        'createdAt': FieldValue.serverTimestamp(),
      });

      debugPrint('====================================');
      debugPrint('REGISTRASI BERHASIL');
      debugPrint('UID  : ${user.uid}');
      debugPrint('ROLE : $selectedRole');
      debugPrint('====================================');

      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      _showMessage(
        'Akun ${selectedRole == 'admin' ? 'Admin' : 'Petugas'} berhasil dibuat.',
        isError: false,
      );

      await Future.delayed(
        const Duration(milliseconds: 700),
      );

      if (!mounted) return;

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      // Kalau Firestore gagal setelah Auth berhasil dibuat,
      // akun Auth tetap ada. Kita tidak menghapus otomatis agar
      // tidak terjadi error tambahan.
      
      String message;

      switch (e.code) {
        case 'email-already-in-use':
          message =
              'Username tersebut sudah terdaftar.';
          break;

        case 'weak-password':
          message =
              'Password terlalu lemah. Gunakan minimal 6 karakter.';
          break;

        case 'invalid-email':
          message =
              'Username tidak valid.';
          break;

        case 'operation-not-allowed':
          message =
              'Email/Password belum diaktifkan di Firebase Authentication.';
          break;

        case 'network-request-failed':
          message =
              'Tidak ada koneksi internet.';
          break;

        default:
          message =
              'Registrasi gagal: ${e.message ?? e.code}';
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
          backgroundColor: isError
              ? const Color(0xFFB42318)
              : teal,
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
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(17),
        ),
        borderSide: BorderSide(
          color: teal,
          width: 1.7,
        ),
      ),
    );
  }

  @override
  void dispose() {
    namaController.dispose();
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
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ========================================================
          // BACKGROUND
          // ========================================================

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

          // ========================================================
          // CONTENT
          // ========================================================

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
                      // LOGO
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
                              color:
                                  Colors.black.withOpacity(0.30),
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

                      const Text(
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

                      const SizedBox(height: 15),

                      // =================================================
                      // CARD REGISTER
                      // =================================================

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
                          borderRadius:
                              BorderRadius.circular(27),
                          border: Border.all(
                            color: gold.withOpacity(0.65),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  Colors.black.withOpacity(0.28),
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
                              child: Icon(
                                selectedRole == 'admin'
                                    ? Icons
                                        .admin_panel_settings_rounded
                                    : Icons.support_agent_rounded,
                                color: gold,
                                size: 26,
                              ),
                            ),

                            const SizedBox(height: 8),

                            const Text(
                              'REGISTRASI ADMIN / PETUGAS',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: navy,
                                fontSize: 19,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.3,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              'Buat akun baru untuk Admin atau Petugas',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 11.5,
                              ),
                            ),

                            const SizedBox(height: 17),

                            // ROLE
                            Row(
                              children: [
                                Expanded(
                                  child: _roleButton(
                                    role: 'admin',
                                    icon: Icons
                                        .admin_panel_settings_rounded,
                                    title: 'ADMIN',
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _roleButton(
                                    role: 'petugas',
                                    icon:
                                        Icons.support_agent_rounded,
                                    title: 'PETUGAS',
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 15),

                            // NAMA
                            TextField(
                              controller: namaController,
                              enabled: !isLoading,
                              textCapitalization:
                                  TextCapitalization.words,
                              textInputAction:
                                  TextInputAction.next,
                              decoration: _inputDecoration(
                                icon: Icons.badge_outlined,
                                label: 'Nama',
                                hint: 'Masukkan nama lengkap',
                              ),
                            ),

                            const SizedBox(height: 10),

                            // USERNAME
                            TextField(
                              controller: usernameController,
                              enabled: !isLoading,
                              autocorrect: false,
                              textCapitalization:
                                  TextCapitalization.none,
                              textInputAction:
                                  TextInputAction.next,
                              decoration: _inputDecoration(
                                icon:
                                    Icons.person_outline_rounded,
                                label: 'Username',
                                hint: 'Masukkan username',
                              ),
                            ),

                            const SizedBox(height: 10),

                            // PASSWORD
                            TextField(
                              controller: passwordController,
                              enabled: !isLoading,
                              obscureText: obscurePassword,
                              textInputAction:
                                  TextInputAction.next,
                              decoration: _inputDecoration(
                                icon:
                                    Icons.lock_outline_rounded,
                                label: 'Password',
                                hint: 'Minimal 6 karakter',
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color:
                                        navy.withOpacity(0.75),
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

                            const SizedBox(height: 10),

                            // KONFIRMASI PASSWORD
                            TextField(
                              controller:
                                  confirmPasswordController,
                              enabled: !isLoading,
                              obscureText:
                                  obscureConfirmPassword,
                              textInputAction:
                                  TextInputAction.done,
                              onSubmitted: (_) {
                                if (!isLoading) {
                                  _register();
                                }
                              },
                              decoration: _inputDecoration(
                                icon:
                                    Icons.lock_reset_rounded,
                                label: 'Konfirmasi Password',
                                hint:
                                    'Masukkan ulang password',
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    obscureConfirmPassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color:
                                        navy.withOpacity(0.75),
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

                            const SizedBox(height: 14),

                            // REGISTER BUTTON
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient:
                                      const LinearGradient(
                                    begin:
                                        Alignment.centerLeft,
                                    end:
                                        Alignment.centerRight,
                                    colors: [
                                      navy,
                                      teal,
                                    ],
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(16),
                                ),
                                child: ElevatedButton(
                                  onPressed:
                                      isLoading ? null : _register,
                                  style:
                                      ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Colors.transparent,
                                    foregroundColor:
                                        Colors.white,
                                    disabledBackgroundColor:
                                        Colors.transparent,
                                    elevation: 0,
                                    shadowColor:
                                        Colors.transparent,
                                    shape:
                                        RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: isLoading
                                      ? const SizedBox(
                                          width: 21,
                                          height: 21,
                                          child:
                                              CircularProgressIndicator(
                                            strokeWidth: 2.3,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment
                                                  .center,
                                          children: [
                                            Icon(
                                              Icons
                                                  .person_add_alt_1_rounded,
                                              size: 20,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              'BUAT AKUN',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight:
                                                    FontWeight.w900,
                                                letterSpacing: 0.4,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            // BACK
                            TextButton.icon(
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      Navigator.pop(context);
                                    },
                              icon: const Icon(
                                Icons.arrow_back_rounded,
                                size: 17,
                              ),
                              label: const Text(
                                'KEMBALI KE LOGIN ADMIN / PETUGAS',
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

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: navy.withOpacity(0.38),
                          borderRadius:
                              BorderRadius.circular(30),
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
          foregroundColor:
              isSelected ? Colors.white : navy,
          backgroundColor: isSelected
              ? navy
              : Colors.white.withOpacity(0.55),
          side: BorderSide(
            color: isSelected
                ? gold
                : teal.withOpacity(0.65),
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
            color: isSelected
                ? Colors.white
                : navy,
            fontSize: 11.5,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}