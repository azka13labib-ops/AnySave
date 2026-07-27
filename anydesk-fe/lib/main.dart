import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme/app_theme.dart';
import 'screens/main_navigation_wrapper.dart';
import 'screens/sign_in_screen.dart';
import 'providers/app_settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize env & Supabase
  try {
    await dotenv.load(fileName: ".env");
    final supabaseUrl = dotenv.env['SUPABASE_FUNCTIONS_URL']?.replaceAll('/functions/v1', '') ?? 'https://kmzwrypgdlxzzsubmepc.supabase.co';
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: 'dummy-anon-key',
    );
  } catch (_) {}

  // Initialize downloader
  try {
    await FlutterDownloader.initialize(
      debug: true, 
      ignoreSsl: true,
    );
  } catch (_) {}

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
  ));

  runApp(
    const ProviderScope(
      child: AnySaveApp(),
    ),
  );
}

class AnySaveApp extends ConsumerWidget {
  const AnySaveApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isSignedIn = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'AnySave',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: isSignedIn
          ? const MainNavigationWrapper()
          : SignInScreen(
              showGuestButton: false,
              onBackPressed: () {},
              onSignInSuccess: () {
                ref.read(authStateProvider.notifier).signIn('User');
              },
            ),
    );
  }
}
