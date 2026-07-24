import 'package:flutter/material.dart';
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
        scaffoldBackgroundColor: const Color(0xFF141416), // Dark background from screenshot
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF141416),
          elevation: 0,
        ),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE83569), // Pinkish red
          secondary: Color(0xFF9147FF), // Purple for trial card
          surface: Color(0xFF1F1F23), // Dark grey for cards
          onSurface: Colors.white,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
