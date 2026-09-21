import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'services/firebase_options.dart';
import 'pages/splash_page.dart';
import 'services/notification_service.dart';

/// ============================================================
/// THEME GLOBAL
/// ============================================================

final ValueNotifier<ThemeMode> themeNotifier =
    ValueNotifier<ThemeMode>(ThemeMode.light);

/// ============================================================
/// MAIN
/// ============================================================

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // ==========================================================
    // FIREBASE
    // ==========================================================

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    debugPrint(
      'Firebase initialization selesai.',
    );

    // ==========================================================
    // LOCAL NOTIFICATION
    // ==========================================================

    await NotificationService.instance.init();

    debugPrint(
      'NotificationService initialization selesai.',
    );
  } catch (e) {
    debugPrint(
      'Firebase / Notification initialization error: $e',
    );
  }

  runApp(const MyApp());
}

/// ============================================================
/// MY APP
/// ============================================================

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (
        context,
        currentTheme,
        child,
      ) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,

          title: 'SMP Negeri 3 Bantul',

          // ====================================================
          // LIGHT THEME
          // ====================================================

          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF0F766E),
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: const Color(0xFFFFFDF7),
            appBarTheme: const AppBarTheme(
              centerTitle: false,
              backgroundColor: Color(0xFFFFFDF7),
              foregroundColor: Color(0xFF0B1F3A),
              elevation: 0,
              surfaceTintColor: Colors.transparent,
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(
                  color: Color(0xFFE5E7EB),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(
                  color: Color(0xFFE5E7EB),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(
                  color: Color(0xFF0F766E),
                  width: 2,
                ),
              ),
            ),
          ),

          // ====================================================
          // DARK THEME
          // ====================================================

          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF0F766E),
              brightness: Brightness.dark,
            ),
            scaffoldBackgroundColor: const Color(0xFF061426),
            appBarTheme: const AppBarTheme(
              centerTitle: false,
              backgroundColor: Color(0xFF0B1F3A),
              foregroundColor: Colors.white,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xFF102A43),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(
                  color: Color(0xFF334155),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(
                  color: Color(0xFF334155),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(
                  color: Color(0xFF2DD4BF),
                  width: 2,
                ),
              ),
            ),
          ),

          // ====================================================
          // THEME MODE
          // ====================================================

          themeMode: currentTheme,

          // ====================================================
          // SPLASH
          // ====================================================

          home: const SplashPage(),
        );
      },
    );
  }
}
