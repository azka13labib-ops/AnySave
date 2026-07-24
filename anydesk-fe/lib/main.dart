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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
