# AnySave Frontend (Flutter App)

Dokumentasi teknis untuk aplikasi Flutter AnySave.

## Fitur Utama
- **TikTok & Instagram Media Extractor** (No Watermark)
- **1-Column Fast Login** (Murni Nama Pengguna, Tanpa Password)
- **Supabase Cloud Sync** (`users_list` Table)
- **Riverpod State Management** (`authStateProvider`, `themeModeProvider`)
- **Rate Limit Protection** (Max 3 akun baru per 10 menit)

## Menjalankan Aplikasi
```bash
flutter pub get
flutter run
```

## Konfigurasi Environment (.env)
```env
SUPABASE_FUNCTIONS_URL=https://kmzwrypgdlxzzsubmepc.supabase.co/functions/v1
SUPABASE_ANON_KEY=your_supabase_anon_key
```
