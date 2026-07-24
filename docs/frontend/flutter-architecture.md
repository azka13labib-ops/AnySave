# Flutter Architecture

> Dokumentasi arsitektur aplikasi Flutter AzkaSave — struktur folder, layer, dan dependency.

---

## Daftar Isi

1. [Struktur Folder](#1-struktur-folder)
2. [Layer Architecture](#2-layer-architecture)
3. [Dependency Utama (pubspec.yaml)](#3-dependency-utama-pubspecyaml)
4. [Navigation & Routing](#4-navigation--routing)
5. [Tema & Design System](#5-tema--design-system)
6. [Konfigurasi Platform (Android & iOS)](#6-konfigurasi-platform-android--ios)

---

## 1. Struktur Folder

```
lib/
├── config/
│   └── supabase_config.dart       # URL & Anon Key Supabase
├── core/
│   ├── constants/
│   ├── exceptions/
│   └── utils/
│       └── platform_detector.dart # Deteksi TikTok/IG/YouTube dari URL
├── data/
│   ├── models/
│   │   ├── media_item.dart        # Model untuk hasil ekstrak
│   │   └── download_task.dart     # Model untuk antrian download
│   └── repositories/
│       ├── media_repository.dart  # Interface
│       └── media_repository_impl.dart
├── presentation/
│   ├── pages/
│   │   ├── home_page.dart         # Halaman utama (form URL)
│   │   └── history_page.dart      # Riwayat download
│   ├── widgets/
│   │   ├── url_input_form.dart
│   │   ├── platform_badge.dart
│   │   ├── media_card.dart
│   │   └── download_progress_tile.dart
│   └── providers/                 # State management (Riverpod/Bloc)
└── main.dart
```

---

## 2. Layer Architecture

```
┌─────────────────────────────────┐
│        Presentation Layer       │  Pages, Widgets, Providers
├─────────────────────────────────┤
│         Domain Layer            │  Use Cases, Repository Interface
├─────────────────────────────────┤
│          Data Layer             │  Repository Impl, API Client, Models
└─────────────────────────────────┘
```

---

## 3. Dependency Utama (pubspec.yaml)

<!-- TODO: Isi versi package setelah `flutter pub add` dilakukan -->

| Package | Fungsi |
|---------|--------|
| `supabase_flutter` | Koneksi ke Supabase |
| `dio` | HTTP client |
| `flutter_downloader` | Download manager background |
| `path_provider` | Akses path storage lokal |
| `permission_handler` | Request izin storage/notification |
| `riverpod` / `flutter_bloc` | State management |
| `go_router` | Navigasi deklaratif |

---

## 4. Navigation & Routing

<!-- TODO: Dokumentasikan route definition setelah routing dipilih -->

---

## 5. Tema & Design System

<!-- TODO: Dokumentasikan color palette, typography, dan dark mode config -->

---

## 6. Konfigurasi Platform (Android & iOS)

### Android (`android/app/src/main/AndroidManifest.xml`)

<!-- TODO: Dokumentasikan permission yang dibutuhkan:
  - INTERNET
  - WRITE_EXTERNAL_STORAGE (Android < 10)
  - READ_EXTERNAL_STORAGE
  - POST_NOTIFICATIONS (Android 13+)
-->

### iOS (`ios/Runner/Info.plist`)

<!-- TODO: Dokumentasikan NSPhotoLibraryAddUsageDescription dan keys lainnya -->
