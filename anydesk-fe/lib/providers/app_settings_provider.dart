import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 1. Theme Mode Provider
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.light) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final appearance = prefs.getString('setting_appearance') ?? 'Light Mode';
    state = _parseTheme(appearance);
  }

  ThemeMode _parseTheme(String appearance) {
    if (appearance == 'Dark Mode') return ThemeMode.dark;
    if (appearance == 'Light Mode') return ThemeMode.light;
    return ThemeMode.light; // System Default defaults to Light Mode
  }

  Future<void> setTheme(String appearance) async {
    state = _parseTheme(appearance);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('setting_appearance', appearance);
  }
}

// 2. Language Provider
final languageProvider = StateNotifierProvider<LanguageNotifier, String>((ref) {
  return LanguageNotifier();
});

class LanguageNotifier extends StateNotifier<String> {
  LanguageNotifier() : super('English') {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString('setting_language') ?? 'English';
  }

  Future<void> setLanguage(String lang) async {
    state = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('setting_language', lang);
  }
}

// 3. Translation Helper
class AppStrings {
  static String tr(String key, String lang) {
    final isId = lang == 'Bahasa Indonesia';
    switch (key) {
      case 'home':
        return isId ? 'Beranda' : 'Home';
      case 'history':
        return isId ? 'Riwayat' : 'History';
      case 'settings':
        return isId ? 'Pengaturan' : 'Settings';
      case 'search_placeholder':
        return isId ? 'Tempel link video di sini...' : 'Paste video link here...';
      case 'search_button':
        return isId ? 'Cari Video' : 'Search Video';
      case 'recent_downloads':
        return isId ? 'Unduhan Terkini' : 'Recent Downloads';
      case 'clear_all':
        return isId ? 'Hapus Semua' : 'Clear All';
      case 'storage_needed':
        return isId ? 'Akses Penyimpanan Dibutuhkan' : 'Storage Access Needed';
      case 'storage_desc':
        return isId
            ? 'Aktifkan akses penyimpanan untuk menyimpan video secara otomatis ke galeri.'
            : 'Enable storage access to save downloaded videos directly to your gallery.';
      case 'enable_access':
        return isId ? 'Aktifkan Akses' : 'Enable Access';
      case 'account':
        return isId ? 'AKUN' : 'ACCOUNT';
      case 'guest_user':
        return isId ? 'Pengguna Tamu' : 'Guest User';
      case 'sign_in_sub':
        return isId ? 'Masuk untuk sinkronisasi riwayat' : 'Sign in to sync history';
      case 'downloads':
        return isId ? 'UNDUHAN' : 'DOWNLOADS';
      case 'default_quality':
        return isId ? 'Kualitas Default' : 'Default Quality';
      case 'save_location':
        return isId ? 'Lokasi Penyimpanan' : 'Save Location';
      case 'auto_delete':
        return isId ? 'Hapus otomatis setelah 30 hari' : 'Auto-delete after 30 days';
      case 'preferences':
        return isId ? 'PREFERENSI' : 'PREFERENCES';
      case 'appearance':
        return isId ? 'Tampilan' : 'Appearance';
      case 'language':
        return isId ? 'Bahasa' : 'Language';
      case 'notifications':
        return isId ? 'Notifikasi' : 'Notifications';
      case 'clear_cache':
        return isId ? 'Hapus Cache' : 'Clear Cache';
      case 'about_legal':
        return isId ? 'TENTANG & HUKUM' : 'ABOUT & LEGAL';
      case 'terms_of_service':
        return isId ? 'Syarat & Ketentuan' : 'Terms of Service';
      case 'privacy_policy':
        return isId ? 'Kebijakan Privasi' : 'Privacy Policy';
      case 'version':
        return isId ? 'Versi' : 'Version';
      case 'select_platform':
        return isId ? 'Pilih Platform' : 'Select Platform';
      default:
        return key;
    }
  }
}
