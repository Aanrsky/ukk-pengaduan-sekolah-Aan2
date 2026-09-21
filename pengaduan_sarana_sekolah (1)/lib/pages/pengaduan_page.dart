import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:video_player/video_player.dart';
import '../widgets/copyright_watermark.dart';
import '../services/firestore_service.dart';

class PengaduanPage extends StatefulWidget {
  const PengaduanPage({super.key});

  @override
  State<PengaduanPage> createState() => _PengaduanPageState();
}

class _PengaduanPageState extends State<PengaduanPage> {
  final _formKey = GlobalKey<FormState>();

  final namaController = TextEditingController();
  final judulController = TextEditingController();
  final deskripsiController = TextEditingController();

  String kategori = 'Sarana Rusak';

  bool loading = false;
  String loadingText = 'MENGIRIM...';

  Uint8List? selectedImage;
  String? imageName;

  final FirestoreService firestoreService = FirestoreService();
  final ImagePicker picker = ImagePicker();

  late VideoPlayerController _videoController;
  bool _videoReady = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  // =========================================================
  // BACKGROUND VIDEO
  // =========================================================

  Future<void> _initializeVideo() async {
    _videoController = VideoPlayerController.asset(
      'assets/background1.mp4',
    );

    try {
      await _videoController.initialize();

      if (!mounted) return;

      await _videoController.setLooping(true);
      await _videoController.setVolume(0);
      await _videoController.play();

      if (!mounted) return;

      setState(() {
        _videoReady = true;
      });
    } catch (e) {
      debugPrint('Gagal memuat background1.mp4: $e');

      if (mounted) {
        setState(() {
          _videoReady = false;
        });
      }
    }
  }

  @override
  void dispose() {
    namaController.dispose();
    judulController.dispose();
    deskripsiController.dispose();
    _videoController.dispose();

    super.dispose();
  }

  // =========================================================
  // PILIH FOTO
  // =========================================================

  Future<void> pilihFoto() async {
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,

        // FOTO DIPERKECIL SEBELUM MASUK KE FIREBASE
        imageQuality: 55,
        maxWidth: 960,
        maxHeight: 960,
      );

      if (image == null) return;

      final bytes = await image.readAsBytes();

      if (!mounted) return;

      setState(() {
        selectedImage = bytes;
        imageName = image.name;
      });

      debugPrint(
        'Ukuran foto setelah kompresi: '
        '${(bytes.lengthInBytes / 1024).toStringAsFixed(1)} KB',
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal memilih foto: $e',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // =========================================================
  // UPLOAD FOTO
  // =========================================================

  Future<String> uploadFoto() async {
    if (selectedImage == null) {
      return '';
    }

    final fileName = 'pengaduan_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final ref =
        FirebaseStorage.instance.ref().child('foto_pengaduan').child(fileName);

    final metadata = SettableMetadata(
      contentType: 'image/jpeg',
      cacheControl: 'public,max-age=31536000',
    );

    try {
      final uploadTask = ref.putData(
        selectedImage!,
        metadata,
      );

      final snapshot = await uploadTask;

      if (snapshot.state != TaskState.success) {
        throw Exception(
          'Upload foto gagal: ${snapshot.state}',
        );
      }

      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      debugPrint('Upload foto pengaduan error: $e');
      rethrow;
    }
  }
  // =========================================================
  // KIRIM PENGADUAN
  // =========================================================

  Future<void> kirimPengaduan() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      loading = true;
      loadingText =
          selectedImage != null ? 'MENGUPLOAD FOTO...' : 'MENYIMPAN...';
    });

    try {
      String fotoUrl = '';

      // =====================================================
      // UPLOAD FOTO
      // =====================================================

      if (selectedImage != null) {
        fotoUrl = await uploadFoto();

        if (!mounted) return;

        setState(() {
          loadingText = 'MENYIMPAN PENGADUAN...';
        });
      }

      // =====================================================
      // SIMPAN KE FIRESTORE
      // =====================================================

      await firestoreService.addComplaint(
        nama: namaController.text.trim(),
        kategori: kategori,
        judul: judulController.text.trim(),
        deskripsi: deskripsiController.text.trim(),
        fotoUrl: fotoUrl,
      );

      if (!mounted) return;

      // =====================================================
      // BERHASIL
      // =====================================================

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Pengaduan berhasil dikirim',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      debugPrint('Gagal mengirim pengaduan: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal mengirim pengaduan: $e',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
          loadingText = 'MENGIRIM...';
        });
      }
    }
  }

  // =========================================================
  // INPUT DECORATION
  // =========================================================

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: isDark
          ? const Color(0xFF252C34)
          : Colors.white.withValues(alpha: 0.95),
      labelStyle: TextStyle(
        color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: colorScheme.primary,
          width: 2,
        ),
      ),
    );
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final cardColor = isDark
        ? const Color(0xFF151A20).withValues(alpha: 0.95)
        : Colors.white.withValues(alpha: 0.92);

    final mainTextColor = isDark ? Colors.white : Colors.black87;

    final secondaryTextColor = isDark ? Colors.grey.shade300 : Colors.black54;

    return Scaffold(
      extendBodyBehindAppBar: true,

      // =======================================================
      // APP BAR
      // =======================================================

      appBar: AppBar(
        title: const Text(
          'Buat Pengaduan',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black.withValues(
          alpha: 0.30,
        ),
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      body: Stack(
        fit: StackFit.expand,
        children: [
          // ===================================================
          // BACKGROUND VIDEO
          // ===================================================

          if (_videoReady)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _videoController.value.size.width,
                height: _videoController.value.size.height,
                child: VideoPlayer(
                  _videoController,
                ),
              ),
            )
          else
            Container(
              color: Colors.black,
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),

          // ===================================================
          // OVERLAY
          // ===================================================

          Container(
            color: Colors.black.withValues(
              alpha: isDark ? 0.55 : 0.35,
            ),
          ),

          // ===================================================
          // FORM
          // ===================================================

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                16,
                20,
                16,
                30,
              ),
              child: Form(
                key: _formKey,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: 0.25,
                        ),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // =======================================
                      // JUDUL
                      // =======================================

                      Row(
                        children: [
                          Icon(
                            Icons.report_problem,
                            color: colorScheme.primary,
                            size: 30,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Sampaikan Pengaduan',
                              style: TextStyle(
                                color: mainTextColor,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Silakan isi data pengaduan sarana sekolah '
                        'dengan lengkap.',
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 25),

                      // =======================================
                      // NAMA
                      // =======================================

                      TextFormField(
                        controller: namaController,
                        enabled: !loading,
                        style: TextStyle(
                          color: mainTextColor,
                        ),
                        decoration: _inputDecoration(
                          label: 'Nama',
                          icon: Icons.person,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nama wajib diisi';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 15),

                      // =======================================
                      // KATEGORI
                      // =======================================

                      DropdownButtonFormField<String>(
                        value: kategori,
                        style: TextStyle(
                          color: mainTextColor,
                        ),
                        decoration: _inputDecoration(
                          label: 'Kategori Pengaduan',
                          icon: Icons.category,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Sarana Rusak',
                            child: Text(
                              'Sarana Rusak',
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'Kebersihan',
                            child: Text(
                              'Kebersihan',
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'Keamanan',
                            child: Text(
                              'Keamanan',
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'Lainnya',
                            child: Text(
                              'Lainnya',
                            ),
                          ),
                        ],
                        onChanged: loading
                            ? null
                            : (value) {
                                if (value == null) {
                                  return;
                                }

                                setState(() {
                                  kategori = value;
                                });
                              },
                      ),

                      const SizedBox(height: 15),

                      // =======================================
                      // JUDUL PENGADUAN
                      // =======================================

                      TextFormField(
                        controller: judulController,
                        enabled: !loading,
                        style: TextStyle(
                          color: mainTextColor,
                        ),
                        decoration: _inputDecoration(
                          label: 'Judul Pengaduan',
                          icon: Icons.title,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Judul wajib diisi';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 15),

                      // =======================================
                      // DESKRIPSI
                      // =======================================

                      TextFormField(
                        controller: deskripsiController,
                        enabled: !loading,
                        maxLines: 5,
                        style: TextStyle(
                          color: mainTextColor,
                        ),
                        decoration: _inputDecoration(
                          label: 'Deskripsi Pengaduan',
                          icon: Icons.description,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Deskripsi wajib diisi';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // =======================================
                      // PILIH FOTO
                      // =======================================

                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: loading ? null : pilihFoto,
                          icon: const Icon(
                            Icons.photo_camera,
                          ),
                          label: const Text(
                            'PILIH FOTO KERUSAKAN',
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: 15,
                            ),
                            backgroundColor:
                                isDark ? const Color(0xFF252C34) : Colors.white,
                            foregroundColor: colorScheme.primary,
                            side: BorderSide(
                              color: colorScheme.primary,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // =======================================
                      // PREVIEW FOTO
                      // =======================================

                      if (selectedImage != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.memory(
                            selectedImage!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),

                      if (selectedImage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 20,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Foto berhasil dipilih '
                                  '(sudah dikompresi)',
                                  style: TextStyle(
                                    color: Colors.green.shade600,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 25),

                      // =======================================
                      // KIRIM
                      // =======================================

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: loading ? null : kirimPengaduan,
                          icon: loading
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: colorScheme.onPrimary,
                                  ),
                                )
                              : const Icon(
                                  Icons.send,
                                ),
                          label: Text(
                            loading ? loadingText : 'KIRIM PENGADUAN',
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                            ),
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            disabledBackgroundColor:
                                colorScheme.primary.withValues(alpha: 0.65),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
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
}
