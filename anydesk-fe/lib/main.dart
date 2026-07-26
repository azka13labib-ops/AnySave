import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize env
  await dotenv.load(fileName: ".env");

  // Initialize downloader
  await FlutterDownloader.initialize(
    debug: true, 
    ignoreSsl: true,
  );

  // Set system UI overlay style for immersive dark theme
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF0D0D0D),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(
    const ProviderScope(
      child: AnySaveApp(),
    ),
  );
}

class AnySaveApp extends StatelessWidget {
  const AnySaveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AnySave',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        fontFamily: 'Inter',
        scaffoldBackgroundColor: const Color(0xFF0D0D0D),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0D0D0D),
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFC8FF00), // Neon lime green
          onPrimary: Color(0xFF0D0D0D), // Dark text on green buttons
          secondary: Color(0xFF1C1C1E),
          surface: Color(0xFF1C1C1E),
          onSurface: Colors.white,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF0D0D0D),
          selectedItemColor: Color(0xFFC8FF00),
          unselectedItemColor: Color(0xFF666666),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
