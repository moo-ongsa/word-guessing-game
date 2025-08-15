import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/game_provider.dart';
import 'screens/setup_screen.dart';
import 'screens/game_screen.dart';
import 'screens/stats_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GameProvider(),
      child: MaterialApp(
        title: 'เกมถามตอบ',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFE8B4B8), // Soft dusty rose
            brightness: Brightness.light,
            background: const Color(0xFFFDF6F0), // Warm cream
            surface: const Color(0xFFFDF6F0),
            primary: const Color(0xFFE8B4B8), // Soft dusty rose
            secondary: const Color(0xFFD4A5A5), // Muted rose
            tertiary: const Color(0xFFE6D3A3), // Warm beige
            onBackground: const Color(0xFF8B7D7B), // Warm gray
            onSurface: const Color(0xFF8B7D7B),
          ),
          useMaterial3: true,
          textTheme: GoogleFonts.interTextTheme().copyWith(
            displayLarge: GoogleFonts.inter(
              fontSize: 32,
              fontWeight: FontWeight.w300,
              color: const Color(0xFF8B7D7B),
            ),
            displayMedium: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w300,
              color: const Color(0xFF8B7D7B),
            ),
            displaySmall: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF8B7D7B),
            ),
            bodyLarge: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w300,
              color: const Color(0xFF8B7D7B),
            ),
            bodyMedium: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w300,
              color: const Color(0xFF8B7D7B),
            ),
          ),
          scaffoldBackgroundColor: const Color(0xFFFDF6F0),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFFDF6F0),
            foregroundColor: Color(0xFF8B7D7B),
            elevation: 0,
            centerTitle: true,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE8B4B8).withOpacity(0.8),
              foregroundColor: const Color(0xFF8B7D7B),
              elevation: 0,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white.withOpacity(0.6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: const Color(0xFFE8B4B8).withOpacity(0.5),
                width: 1,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            hintStyle: GoogleFonts.inter(
              color: const Color(0xFFB8A9A7),
              fontWeight: FontWeight.w300,
            ),
          ),
          cardTheme: CardThemeData(
            color: Colors.white.withOpacity(0.7),
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const SetupScreen(),
          '/setup': (context) => const SetupScreen(),
          '/game': (context) => const GameScreen(),
          '/stats': (context) => const StatsScreen(),
        },
      ),
    );
  }
}
