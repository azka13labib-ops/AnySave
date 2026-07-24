# API Keys Management

> Panduan pengelolaan API Key secara aman di proyek AzkaSave. Baca ini sebelum menyentuh konfigurasi apapun.

---

## Daftar Isi

1. [Prinsip Zero-Trust Client](#1-prinsip-zero-trust-client)
2. [Keys yang Digunakan](#2-keys-yang-digunakan)
3. [Cara Menyimpan Secret di Supabase](#3-cara-menyimpan-secret-di-supabase)
4. [Cara Mengakses Secret di Edge Function](#4-cara-mengakses-secret-di-edge-function)
5. [Keys yang AMAN di Client (Flutter)](#5-keys-yang-aman-di-client-flutter)
6. [Checklist Security](#6-checklist-security)
7. [Rotasi API Key](#7-rotasi-api-key)

---

## 1. Prinsip Zero-Trust Client

> **Anggap kode Flutter yang berjalan di device pengguna adalah PUBLIC.**

Semua yang ada di APK dapat di-decompile dan dibaca. Oleh karena itu:

- ✅ **API Key HANYA boleh ada di server** (Supabase Edge Function)
- ❌ **API Key TIDAK BOLEH ada di** kode Dart, `pubspec.yaml`, `.env` yang di-bundle ke APK, `AndroidManifest.xml`, `Info.plist`, atau `assets/`

---

## 2. Keys yang Digunakan

| Key | Tingkat Kerahasiaan | Lokasi Penyimpanan | Diakses Oleh |
|-----|--------------------|--------------------|--------------|
| `RAPIDAPI_KEY` | 🔴 **SECRET** | Supabase Secrets | Edge Function only |
| `SUPABASE_URL` | 🟢 Public | Flutter `.env` / hardcode aman | Flutter App |
| `SUPABASE_ANON_KEY` | 🟡 Semi-public | Flutter `.env` / hardcode aman | Flutter App |

### Mengapa `SUPABASE_ANON_KEY` aman di client?

Anon Key adalah public key yang dirancang untuk digunakan di client-side. Akses datanya dikontrol oleh **Row Level Security (RLS)** di database Supabase. Key ini tidak memberikan akses admin.

---

## 3. Cara Menyimpan Secret di Supabase

**Melalui Supabase CLI:**
```bash
supabase secrets set RAPIDAPI_KEY=your_actual_api_key_here
```

**Melalui Supabase Dashboard:**
1. Buka Project → Settings → Edge Functions → Secrets
2. Klik "Add new secret"
3. Nama: `RAPIDAPI_KEY`, Value: `<api key dari RapidAPI>`

> ⚠️ **JANGAN** commit `.env` yang berisi key ini ke Git. Tambahkan ke `.gitignore`.

---

## 4. Cara Mengakses Secret di Edge Function

```typescript
// Di dalam Supabase Edge Function (Deno)
const rapidApiKey = Deno.env.get('RAPIDAPI_KEY');

if (!rapidApiKey) {
  return new Response(
    JSON.stringify({ error: 'API key not configured' }),
    { status: 500 }
  );
}

const response = await fetch('https://social-media-video-downloader.p.rapidapi.com/smvd/get/all', {
  headers: {
    'X-RapidAPI-Key': rapidApiKey,  // Key HANYA ada di sini, di server
    'X-RapidAPI-Host': 'social-media-video-downloader.p.rapidapi.com',
  }
});
```

---

## 5. Keys yang AMAN di Client (Flutter)

File `lib/config/supabase_config.dart` (contoh — aman untuk di-commit):

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'https://xxxxxxxxxxx.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
  // ✅ Kedua nilai ini aman di client-side
  // ❌ JANGAN tambahkan RAPIDAPI_KEY di sini
}
```

---

## 6. Checklist Security

Sebelum push ke Git, pastikan:

- [ ] `RAPIDAPI_KEY` tidak ada di file Dart manapun
- [ ] `RAPIDAPI_KEY` tidak ada di `pubspec.yaml`
- [ ] `.env` lokal yang berisi secret masuk ke `.gitignore`
- [ ] `supabase/functions/.env` (jika ada) masuk ke `.gitignore`
- [ ] Tidak ada secret yang tercetak di log (print/debugPrint)
- [ ] Response Edge Function tidak menyertakan key dalam payload

---

## 7. Rotasi API Key

Jika API Key perlu diganti (misal: bocor atau expired):

1. Generate key baru di dashboard RapidAPI
2. Update Supabase Secret:
   ```bash
   supabase secrets set RAPIDAPI_KEY=new_api_key_here
   ```
3. Re-deploy Edge Function (secret di-load ulang otomatis saat cold start)
4. Revoke key lama di RapidAPI dashboard
5. Verifikasi endpoint Edge Function masih berjalan normal
