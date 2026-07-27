<div align="center">

  # 📥 AnySave — Modern Media Downloader App

  **Unduh Video TikTok & Instagram Tanpa Watermark Secara Gratis, Instan, dan Tanpa Ribet.**

  [![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
  [![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
  [![Riverpod](https://img.shields.io/badge/State-Riverpod-blueviolet?style=for-the-badge)](https://riverpod.dev)
  [![Supabase](https://img.shields.io/badge/Backend-Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)](https://supabase.com)
  [![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

</div>

---

## 🌟 Tentang AnySave

**AnySave** adalah aplikasi mobile cross-platform berbasis **Flutter** yang dirancang untuk memberikan pengalaman terbaik dalam menyimpan video dari **TikTok** dan **Instagram** langsung ke galeri HP tanpa watermark.

Aplikasi ini mengusung filosofi **Ultra-Fast & Seamless Onboarding**: tidak ada form pendaftaran panjang atau verifikasi email yang mengganggu. Pengguna cukup memasukkan nama pengguna sekali (1-kolom) untuk langsung menikmati seluruh fitur aplikasi secara instan.

---

## ⚡ Fitur Utama

- 🚀 **Tanpa Watermark**: Hasil unduhan video bersih dari watermark TikTok/Instagram.
- 📋 **Auto-Paste Link**: Membaca link video secara otomatis dari clipboard saat ditempel.
- 👤 **1-Column Fast Login**: Masuk aplikasi cukup mengetik nama pengguna tanpa password rumit.
- 🛡️ **Proteksi Rate Limiting**: Membatasi pendaftaran maksimal 3 akun baru per 10 menit untuk keamanan server.
- 📊 **Database Cloud Supabase**: Terhubung langsung dengan tabel Supabase `users_list` untuk pemantauan pengguna *real-time*.
- 📂 **Riwayat & Galeri**: Pengelolaan daftar riwayat unduhan lokal dengan thumbnail & detail media.
- 🎨 **Multi-Theme Support**: Dukungan Mode Terang (Light Mode) dan Mode Gelap (Dark Mode).
- 🌐 **Multi-Language**: Pilihan Bahasa Indonesia dan Bahasa Inggris.

---

## 🛠️ Tech Stack

| Kategori | Teknologi | Deskripsi |
|---|---|---|
| **Framework** | [Flutter](https://flutter.dev) | Framework UI Cross-Platform (Android & iOS) |
| **Bahasa** | [Dart](https://dart.dev) | Bahasa Pemrograman Utama |
| **State Management** | [Flutter Riverpod](https://riverpod.dev) | Manajemen Status Reaktif & Terpusat |
| **Backend & Database** | [Supabase](https://supabase.com) | Database Cloud Real-time & API Client |
| **Downloader** | `flutter_downloader` | Service Unduhan Latar Belakang & Notifikasi |
| **Local Persistence** | `shared_preferences` | Penyimpanan Preferensi & Session Pengguna |
| **Networking** | `dio` & `http` | HTTP Client untuk Ekstraksi Media & API |

---

## 🏗️ Arsitektur Aplikasi

```mermaid
graph TD
    UI[Presentation Layer: Screens & Widgets] -->|Watch State| Riverpod[State Management: Riverpod Providers]
    Riverpod -->|Persist Local| Prefs[SharedPreferences]
    Riverpod -->|API Requests| Api[ApiService / Media Extractor]
    Riverpod -->|Sync User Data| Supabase[Supabase DB: public.users_list]
    Api -->|Download Task| Downloader[FlutterDownloader Background Service]
    Downloader -->|Save Video| Storage[Device Storage & Gallery]
```

---

## 📁 Struktur Folder Proyek

```
AnySave/
├── anydesk-fe/                         # Proyek Utama Flutter App
│   ├── lib/
│   │   ├── main.dart                  # Entry Point & Setup Supabase/Riverpod
│   │   ├── data/
│   │   │   └── services/
│   │   │       └── api_service.dart   # Ekstraktor Link & Scraping Engine
│   │   ├── providers/
│   │   │   └── app_settings_provider.dart # State Providers (Auth, Theme, Lang)
│   │   ├── screens/
│   │   │   ├── main_navigation_wrapper.dart # Bottom Navigation Handler
│   │   │   ├── home_screen.dart       # Layar Utama Input Link
│   │   │   ├── history_screen.dart    # Layar Riwayat Unduhan
│   │   │   ├── settings_screen.dart   # Layar Pengaturan & Edit Profil
│   │   │   ├── sign_in_screen.dart    # Layar Log In 1-Kolom Nama
│   │   │   ├── downloading_screen.dart# Layar Status Progress Unduhan
│   │   │   └── video_preview_screen.dart # Layar Preview Video
│   │   ├── theme/
│   │   │   ├── app_colors.dart        # Palette Warna Aplikasi
│   │   │   └── app_theme.dart         # Konfigurasi Light & Dark Theme
│   │   └── widgets/
│   │       ├── platform_toggle.dart   # Toggle Platform TikTok / Instagram
│   │       ├── storage_banner.dart    # Banner Izin Storage
│   │       └── recent_download_card.dart # Preview Unduhan Terakhir
│   └── pubspec.yaml                   # File Manifest Package & Asset
└── README.md                          # Dokumentasi Utama Proyek
```

---

## 🗄️ Skema Database Supabase

Untuk menyiapkan database di Supabase SQL Editor, jalankan query berikut:

```sql
-- Membuat Tabel Pengguna
CREATE TABLE IF NOT EXISTS public.users_list (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Mengaktifkan Row Level Security (RLS) & Akses Publik
ALTER TABLE public.users_list ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow public insert" ON public.users_list FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public select" ON public.users_list FOR SELECT USING (true);
```

---

## 📱 Build Release APK

Untuk memproduksi file instalasi APK rilis Android:

```bash
cd anydesk-fe
flutter build apk --release
```
File APK akan secara otomatis tersimpan di: `build/app/outputs/flutter-apk/app-release.apk`

---

## 🤝 Kontribusi & Git Workflow

Proyek ini menggunakan standar **Semantic Commits**:
- `feat:` Fitur baru
- `fix:` Perbaikan bug / error
- `docs:` Pembaruan dokumentasi
- `chore:` Pemeliharaan dependensi / proyek

---

## ⚠️ Disclaimer

**AnySave** dikembangkan untuk keperluan edukasi dan penggunaan pribadi. Aplikasi ini tidak berafiliasi, disponsori, atau didukung oleh TikTok, Instagram, atau Meta Platforms, Inc. Pengguna bertanggung jawab penuh atas penggunaan konten sesuai hukum hak cipta yang berlaku.

---

<div align="center">
  Developed with ❤️ for AnySave App
</div>
