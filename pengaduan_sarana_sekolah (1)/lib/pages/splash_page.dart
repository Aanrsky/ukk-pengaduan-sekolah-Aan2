import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'login_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _videoController;

  late AnimationController _animationController;

  late Animation<double> _logoFade;
  late Animation<double> _logoScale;
  late Animation<double> _titleFade;
  late Animation<double> _titleSlide;
  late Animation<double> _sloganFade;
  late Animation<double> _loadingFade;

  bool _videoReady = false;
  bool _isOpeningLogin = false;
  bool _videoFailed = false;

  static const Color navy = Color(0xFF0B1F3A);
  static const Color teal = Color(0xFF0F766E);
  static const Color gold = Color(0xFFF4C95D);
  static const Color cream = Color(0xFFFFFDF7);

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _logoFade = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(
        0.0,
        0.40,
        curve: Curves.easeOut,
      ),
    );

    _logoScale = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(
        0.0,
        0.55,
        curve: Curves.easeOutBack,
      ),
    );

    _titleFade = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(
        0.25,
        0.70,
        curve: Curves.easeOut,
      ),
    );

    _titleSlide = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(
        0.25,
        0.70,
        curve: Curves.easeOutCubic,
      ),
    );

    _sloganFade = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(
        0.45,
        0.85,
        curve: Curves.easeOut,
      ),
    );

    _loadingFade = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(
        0.60,
        1.0,
        curve: Curves.easeOut,
      ),
    );

    _animationController.forward();

    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    VideoPlayerController? controller;

    try {
      controller = VideoPlayerController.asset(
        'assets/animasi.mp4',
      );

      _videoController = controller;

      // Jangan biarkan video membuat aplikasi stuck selamanya.
      await controller.initialize().timeout(
            const Duration(seconds: 6),
          );

      await controller.setLooping(false);
      await controller.setVolume(0.0);

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _videoReady = true;
        _videoFailed = false;
      });

      try {
        await controller.play().timeout(
              const Duration(seconds: 3),
            );
      } catch (e) {
        debugPrint('Splash video play error: $e');
      }

      // Tunggu video selesai, tetapi tetap kasih batas waktu.
      final DateTime maxEndTime = DateTime.now().add(
        const Duration(seconds: 10),
      );

      while (mounted &&
          controller.value.isInitialized &&
          controller.value.isPlaying &&
          DateTime.now().isBefore(maxEndTime)) {
        await Future.delayed(
          const Duration(milliseconds: 100),
        );
      }

      if (!mounted) return;

      _openLogin();
    } on TimeoutException catch (e) {
      debugPrint('Splash video timeout: $e');

      if (!mounted) return;

      setState(() {
        _videoReady = false;
        _videoFailed = true;
      });

      await Future.delayed(
        const Duration(milliseconds: 900),
      );

      if (!mounted) return;

      _openLogin();
    } catch (e) {
      debugPrint('Splash video error: $e');

      if (!mounted) return;

      setState(() {
        _videoReady = false;
        _videoFailed = true;
      });

      await Future.delayed(
        const Duration(milliseconds: 900),
      );

      if (!mounted) return;

      _openLogin();
    }
  }

  void _openLogin() {
    if (!mounted || _isOpeningLogin) return;

    _isOpeningLogin = true;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(
          milliseconds: 650,
        ),
        reverseTransitionDuration: const Duration(
          milliseconds: 350,
        ),
        pageBuilder: (
          context,
          animation,
          secondaryAnimation,
        ) {
          return const LoginPage();
        },
        transitionsBuilder: (
          context,
          animation,
          secondaryAnimation,
          child,
        ) {
          final fade = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          );

          final scale = Tween<double>(
            begin: 1.035,
            end: 1.0,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
          );

          return FadeTransition(
            opacity: fade,
            child: ScaleTransition(
              scale: scale,
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navy,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double width = constraints.maxWidth;
          final double height = constraints.maxHeight;

          return Stack(
            fit: StackFit.expand,
            children: [
              // ============================================================
              // BACKGROUND
              // ============================================================
              if (_videoReady && _videoController != null)
                ClipRect(
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
                // Kalau video belum siap/gagal, tetap tampilkan
                // background yang terlihat, bukan hitam polos.
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF061426),
                        Color(0xFF0B1F3A),
                        Color(0xFF0F766E),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: -width * 0.25,
                        right: -width * 0.25,
                        child: Container(
                          width: width * 0.8,
                          height: width * 0.8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: teal.withOpacity(0.20),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -width * 0.30,
                        left: -width * 0.30,
                        child: Container(
                          width: width * 0.9,
                          height: width * 0.9,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: gold.withOpacity(0.08),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // ============================================================
              // OVERLAY
              // ============================================================
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          navy.withOpacity(0.12),
                          Colors.transparent,
                          navy.withOpacity(0.32),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ============================================================
              // KONTEN SPLASH
              // ============================================================
              SafeArea(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // ======================================================
                    // LOGO
                    // ======================================================
                    Positioned(
                      top: height * 0.255,
                      left: 0,
                      right: 0,
                      child: FadeTransition(
                        opacity: _logoFade,
                        child: AnimatedBuilder(
                          animation: _logoScale,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: 0.72 + (_logoScale.value * 0.28),
                              child: child,
                            );
                          },
                          child: Center(
                            child: Container(
                              width: width * 0.34,
                              height: width * 0.34,
                              constraints: const BoxConstraints(
                                minWidth: 105,
                                minHeight: 105,
                                maxWidth: 150,
                                maxHeight: 150,
                              ),
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: cream,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: gold,
                                  width: 4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: gold.withOpacity(0.62),
                                    blurRadius: 28,
                                    spreadRadius: 4,
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.45),
                                    blurRadius: 24,
                                    offset: const Offset(0, 8),
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
                          ),
                        ),
                      ),
                    ),

                    // ======================================================
                    // NAMA SEKOLAH + SUBTITLE
                    // ======================================================
                    Positioned(
                      top: height * 0.505,
                      left: 18,
                      right: 18,
                      child: FadeTransition(
                        opacity: _titleFade,
                        child: AnimatedBuilder(
                          animation: _titleSlide,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(
                                0,
                                25 * (1 - _titleSlide.value),
                              ),
                              child: child,
                            );
                          },
                          child: Column(
                            children: [
                              const Text(
                                'SMP NEGERI 3 BANTUL',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 27,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.7,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black87,
                                      blurRadius: 10,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Container(
                                    width: 45,
                                    height: 3,
                                    decoration: BoxDecoration(
                                      color: gold,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: gold.withOpacity(0.5),
                                          blurRadius: 7,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Expanded(
                                    child: Text(
                                      'APLIKASI PENGADUAN SARANA SEKOLAH',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.45,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black87,
                                            blurRadius: 6,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    width: 45,
                                    height: 3,
                                    decoration: BoxDecoration(
                                      color: gold,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: gold.withOpacity(0.5),
                                          blurRadius: 7,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ======================================================
                    // SLOGAN
                    // ======================================================
                    Positioned(
                      top: height * 0.635,
                      left: 30,
                      right: 30,
                      child: FadeTransition(
                        opacity: _sloganFade,
                        child: const Text(
                          '“Bersama Membangun\n'
                          'Lingkungan Sekolah yang Lebih Baik”',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                            letterSpacing: 0.2,
                            shadows: [
                              Shadow(
                                color: Colors.black87,
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ======================================================
                    // LOADING
                    // ======================================================
                    Positioned(
                      bottom: height * 0.105,
                      left: 0,
                      right: 0,
                      child: FadeTransition(
                        opacity: _loadingFade,
                        child: Column(
                          children: [
                            Container(
                              width: 168,
                              height: 15,
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white70,
                                  width: 1,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: AnimatedBuilder(
                                  animation: _animationController,
                                  builder: (context, child) {
                                    double progress = _loadingFade.value;

                                    if (_videoFailed) {
                                      progress = 1.0;
                                    } else if (!_videoReady) {
                                      progress = 0.12 * _loadingFade.value;
                                    }

                                    return Align(
                                      alignment: Alignment.centerLeft,
                                      child: FractionallySizedBox(
                                        widthFactor: progress.clamp(0.0, 1.0),
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Color(0xFFF4C95D),
                                                Color(0xFFFFE9A8),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _videoFailed
                                  ? 'M E M U L A I . . .'
                                  : 'M E M U A T . . .',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 3,
                                shadows: [
                                  Shadow(
                                    color: Colors.black87,
                                    blurRadius: 6,
                                  ),
                                ],
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
          );
        },
      ),
    );
  }
}
