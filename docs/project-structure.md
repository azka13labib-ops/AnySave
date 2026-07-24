# Struktur Monorepo AzkaSave

> Karena proyek ini memiliki Frontend (Flutter) dan Backend (Supabase Edge Functions), kita akan menggunakan pendekatan **Monorepo** agar semuanya rapi dalam satu tempat.

---

## 📂 Struktur Utama Proyek

```text
AnySave/
│
├── anydesk-fe/                # 📱 FRONTEND (Flutter / Dart)
│   ├── android/             # Konfigurasi native Android
│   ├── ios/                 # Konfigurasi native iOS
│   ├── lib/                 # Kode sumber utama Flutter
│   │   ├── config/          # Konfigurasi env & Supabase
│   │   ├── core/            # Utils, constants, error handling
│   │   ├── data/            # API call, repositories, models
│   │   ├── presentation/    # UI (Pages, Widgets), State Providers
│   │   └── main.dart        # Entry point aplikasi
│   └── pubspec.yaml         # Dependencies Flutter
│
├── anydesk-be/                # ☁️ BACKEND (Supabase / TypeScript)
│   ├── functions/
│   │   ├── _shared/         # Clean Architecture (kode bersama)
│   │   │   ├── exceptions/  # Custom error classes (ApiError, dll)
│   │   │   ├── models/      # Interface & Types (contoh: types.ts)
│   │   │   ├── services/    # 3rd Party API (contoh: rapidapi_client.ts)
│   │   │   └── utils/       # Helper umum (cors.ts, response.ts)
│   │   ├── extract-media/   # Endpoint HTTP
│   │   │   ├── index.ts     # Controller & Routing
│   │   │   └── deno.json    # Konfigurasi module Deno
│   │   └── import_map.json  # Dependency Injection / Module Mapping
│   └── config.toml          # Konfigurasi Supabase project
│
└── docs/                    # 📚 DOKUMENTASI (Markdown)
    ├── api/
    ├── backend/
    ├── frontend/
    ├── PRD.md
    └── project-structure.md
```

## 💡 Penjelasan Layer

1. **`anydesk-fe/` (Flutter)**: Ini adalah aplikasi mobile yang akan di-build menjadi APK. Semua kode UI (Dart) ada di dalam folder ini.
2. **`anydesk-be/` (Backend)**: Folder ini berisi fungsi serverless yang berjalan di awan. Folder ini akan di-deploy menggunakan Supabase CLI. Kode ditulis dalam TypeScript (berjalan di atas Deno).
3. **`docs/`**: Tempat menyimpan seluruh dokumen panduan, spesifikasi, dan arsitektur (tempat file ini berada).
