# AnySave

Aplikasi mobile berbasis Flutter untuk mengunduh video dari TikTok dan Instagram tanpa watermark secara gratis, cepat, dan mudah langsung ke galeri perangkat, dilengkapi dengan integrasi backend Supabase, manajemen status Riverpod, serta perekaman profil pengguna tanpa ribet.

---

## Daftar Isi

- [Tentang Proyek](#tentang-proyek)
- [Masalah yang Diselesaikan](#masalah-yang-diselesaikan)
- [Fitur Utama](#fitur-utama)
- [Tech Stack](#tech-stack)
- [Struktur Proyek](#struktur-proyek)
- [Arsitektur Aplikasi](#arsitektur-aplikasi)
- [Autentikasi & Database Supabase](#autentikasi--database-supabase)
- [Getting Started](#getting-started)
- [Konfigurasi Environment](#konfigurasi-environment)
- [Build & Release](#build--release)
- [Konvensi Kode](#konvensi-kode)
- [Disclaimer](#disclaimer)
- [Lisensi](#lisensi)

---

## Tentang Proyek

**AnySave** dibangun untuk mempermudah pengguna menyimpan video favorit dari platform media sosial populer (TikTok & Instagram) tanpa watermark yang mengganggu. Aplikasi ini dirancang dengan prinsip **Ultra-Fast & Seamless UX**: tanpa perlu memasukkan password atau email rumit, pengguna dapat langsung menggunakan aplikasi hanya dalam 1 detik dengan memasukkan nama pengguna.

Aplikasi dikembangkan menggunakan **Flutter** dan didukung oleh **Supabase** sebagai backend database real-time.

---

## Masalah yang Diselesaikan

- **Watermark Mengganggu**: Menghilangkan watermark bawaan TikTok dan Instagram secara otomatis.
- **Onboarding Super Rumit**: Menghilangkan hambatan form login tradisional yang meminta email, password, dan verifikasi OTP yang membosankan.
- **Sistem Penyimpanan Berantakan**: Menyediakan pengelolaan riwayat unduhan lokal & galeri yang terintegrasi secara *real-time*.

---

## Fitur Utama

### 1. Unduhan Super Cepat
- **Auto-Paste Link**: Otomatis mendeteksi link video TikTok & Instagram dari clipboard.
- **Platform Toggle**: Switch instan antara platform TikTok dan Instagram.
- **No Watermark Output**: Video diunduh dengan kualitas terbaik tanpa logo watermark.
- **Background Downloader**: Menggunakan `flutter_downloader` untuk mengunduh media di latar belakang dengan indikator progress.

### 2. Autentikasi Pengguna Super Simpel (1-Column Fast Login)
- **1-Kolom Input Nama**: Cukup masukkan Nama/Username (tanpa email & password).
- **Auto-Login Persisten**: Status login tersimpan otomatis via Riverpod & SharedPreferences.
- **Pengecekan Duplikat**: Jika nama sudah ada, pengguna langsung masuk tanpa duplikasi data.
- **Proteksi Rate Limiting**: Membatasi pendaftaran maksimal 3 akun baru per 10 menit untuk menjaga stabilitas backend Supabase.

### 3. Riwayat Unduhan & Pemutar Media
- Tampilan daftar riwayat unduhan lengkap dengan thumbnail, ukuran file, dan nama platform.
- Modal preview video bawaan aplikasi.
- Opsi Hapus Riwayat / Bersihkan Cache lokal.

### 4. Pengaturan & Kustomisasi (Settings)
- **Edit Profil Modal**: Ubah nama profil pengguna kapan saja dengan modal gaya iOS yang interaktif.
- **Tema Aplikasi**: Dukungan Mode Terang (Light Mode), Mode Gelap (Dark Mode), dan Mengikuti Sistem.
- **Pengaturan Bahasa**: Dukungan Bahasa Indonesia & Bahasa Inggris.
- **Status Koneksi Server**: Indikator status backend secara real-time.

---

## Tech Stack

| Kategori | Teknologi / Package |
|----------|---------------------|
| **Framework** | Flutter 3.x (Dart 3.x) |
| **State Management** | Riverpod (`flutter_riverpod`) |
| **Backend & DB** | Supabase (`supabase_flutter`) |
| **Downloader** | `flutter_downloader` |
| **Local Storage** | `shared_preferences` |
| **Networking & API** | `dio`, `http`, Supabase REST Client |
| **Environment** | `flutter_dotenv` |
| **Permissions** | `permission_handler` |
| **Sensors & Haptics** | `vibration` |

---

## Struktur Proyek

```
anydesk-fe/
├── lib/
│   ├── main.dart                      # Entry point aplikasi & inisialisasi Supabase/Riverpod
│   ├── data/
│   │   └── services/
│   │       └── api_service.dart       # Service scraping & ekstraksi URL media
│   ├── providers/
│   │   └── app_settings_provider.dart # Provider Riverpod (Auth, Theme, Language)
│   ├── screens/
│   │   ├── main_navigation_wrapper.dart # Navigasi Bottom Bar utama
│   │   ├── home_screen.dart           # Layar Utama (Input Link & Recent Download)
│   │   ├── history_screen.dart        # Layar Riwayat Unduhan
│   │   ├── settings_screen.dart       # Layar Pengaturan & Edit Profil
│   │   ├── sign_in_screen.dart        # Layar Autentikasi 1-Kolom Nama
│   │   ├── downloading_screen.dart    # Layar Progress Unduhan Video
│   │   ├── video_preview_screen.dart  # Layar Progress & Preview Video
│   │   └── error_state_screen.dart    # Layar Penanganan Error
│   ├── theme/
│   │   ├── app_colors.dart            # Palette Warna Aplikasi
│   │   ├── app_constants.dart         # Konstanta Layout & Spacing
│   │   └── app_theme.dart             # Konfigurasi ThemeData (Light & Dark)
│   └── widgets/
│       ├── platform_toggle.dart       # Toggle Platform TikTok / Instagram
│       ├── storage_banner.dart        # Banner Izin Penyimpanan
│       ├── recent_download_card.dart  # Kartu Preview Unduhan Terakhir
│       └── clear_cache_dialog.dart    # Dialog Konfirmasi Hapus Cache
├── android/                           # Proyek Native Android
├── ios/                               # Proyek Native iOS
├── .env                               # File Environment Variables (Supabase Keys)
└── pubspec.yaml                       # Manifest Dependensi Flutter
```

---

## Arsitektur Aplikasi

Aplikasi AnySave mengadopsi pola **Clean Architecture & Reactive State Management**:

1. **Presentation Layer**: Seluruh Widget UI (`screens/` & `widgets/`) mendengarkan perubahan status dari Riverpod Providers secara reaktif.
2. **State Management Layer**: Provider Riverpod (`authStateProvider`, `themeModeProvider`, `languageProvider`) mengelola status aplikasi secara global tanpa memerlukan pembacaan status manual.
3. **Service & Data Layer**: `ApiService` dan `SupabaseClient` menangani komunikasi jaringan ke backend Supabase dan server ekstraksi video.
4. **Persistence Layer**: Menggunakan `SharedPreferences` untuk menyimpan nama pengguna, tema, dan preferensi aplikasi secara lokal.

---

## Autentikasi & Database Supabase

AnySave menggunakan tabel kustom **`users_list`** di Supabase untuk mencatat pengguna yang mendaftar:

### Skema Tabel SQL Supabase:
```sql
CREATE TABLE IF NOT EXISTS public.users_list (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Kebijakan Akses Publik (RLS)
ALTER TABLE public.users_list ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow public insert" ON public.users_list FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public select" ON public.users_list FOR SELECT USING (true);
```

---

## Getting Started

### Prasyarat
- **Flutter SDK**: `>=3.19.0`
- **Dart SDK**: `>=3.3.0`
- **Android Studio** / **VS Code**

### Langkah Instalasi

1. Clone repositori ini:
   ```bash
   git clone https://github.com/azka13labib-ops/AnySave.git
   cd AnySave/anydesk-fe
   ```

2. Install dependensi package:
   ```bash
   flutter pub get
   ```

3. Jalankan aplikasi di perangkat atau emulator:
   ```bash
   flutter run
   ```

---

## Konfigurasi Environment

Buat file `.env` di dalam folder `anydesk-fe/` dengan isi sebagai berikut:

```env
SUPABASE_FUNCTIONS_URL=https://kmzwrypgdlxzzsubmepc.supabase.co/functions/v1
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

---

## Build & Release

### Build APK Release (Android)
```bash
flutter build apk --release
```

---

## Konvensi Kode

- Gunakan **Semantic Commits** (`feat:`, `fix:`, `chore:`, `refactor:`, `docs:`).
- Jalankan analisis statis sebelum commit:
  ```bash
  flutter analyze
  ```
- Format kode secara otomatis:
  ```bash
  dart format .
  ```

---

## Disclaimer

AnySave dikembangkan untuk keperluan penggunaan pribadi. Aplikasi ini tidak berafiliasi, disponsori, atau didukung secara resmi oleh TikTok, Instagram, maupun Meta Platforms, Inc. Pengguna bertanggung jawab penuh untuk mematuhi Ketentuan Layanan (Terms of Service) platform terkait dan hak cipta pemilik konten.

---

## Lisensi

Proyek ini dilisensikan di bawah [MIT License](LICENSE).
