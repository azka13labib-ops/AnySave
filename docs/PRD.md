# Product Requirements Document (PRD)
# AzkaSave — Social Media Downloader

> **Versi:** 1.0.0  
> **Tanggal:** 2026-07-24  
> **Status:** Draft  
> **Author:** Azka

---

## Daftar Isi

1. [Visi & Tujuan](#1-visi--tujuan)
2. [Tech Stack](#2-tech-stack)
3. [Scope / Fitur Utama MVP](#3-scope--fitur-utama-mvp)
4. [Security & Constraints](#4-security--constraints)
5. [User Stories](#5-user-stories)
6. [Non-Functional Requirements](#6-non-functional-requirements)
7. [Out of Scope (v1)](#7-out-of-scope-v1)
8. [Milestone & Timeline](#8-milestone--timeline)

---

## 1. Visi & Tujuan

**AzkaSave** adalah aplikasi mobile yang memungkinkan pengguna mengunduh media (video & gambar) dari platform media sosial populer — **TikTok**, **Instagram**, dan **YouTube** — dengan kualitas **original** dan **tanpa watermark**.

### Permasalahan yang Dipecahkan

| # | Problem | Solution |
|---|---------|----------|
| 1 | Video TikTok yang diunduh via share native mengandung watermark logo TikTok | Ekstrak direct link MP4 original via API tanpa watermark |
| 2 | Instagram tidak menyediakan fitur download bawaan | Parsing URL konten IG dan mengunduh langsung ke storage |
| 3 | YouTube hanya bisa ditonton online (tanpa fitur simpan untuk non-Premium) | Ekstrak stream URL dan simpan ke perangkat |
| 4 | API key sensitif rentan bocor jika di-hardcode di client | Semua API key dikelola di Supabase Secrets (server-side only) |

### Tujuan Utama

- Menyediakan pengalaman download **satu-langkah**: paste URL → tap download → selesai.
- Mendukung **tiga platform** sekaligus dalam satu aplikasi.
- Menjaga **keamanan API Key** dengan arsitektur backend-as-middleware.
- Menghasilkan APK yang dapat didistribusikan secara **mandiri** (side-load) untuk menghindari pembatasan Play Store terkait konten YouTube.

---

## 2. Tech Stack

### Frontend

| Layer | Teknologi | Keterangan |
|-------|-----------|------------|
| Framework | **Flutter** (Dart) | Cross-platform iOS & Android |
| State Management | Riverpod / Bloc | TBD (lihat `state-management.md`) |
| HTTP Client | `dio` / `http` | Request ke Supabase Edge Functions |
| Download Manager | `flutter_downloader` atau implementasi custom | Download file ke local storage |
| File I/O | `path_provider` + `permission_handler` | Akses direktori Download perangkat |

### Backend

| Layer | Teknologi | Keterangan |
|-------|-----------|------------|
| Platform | **Supabase** | Auth, Database, Storage, Edge Functions |
| Serverless Functions | **Supabase Edge Functions** (Deno/TypeScript) | Middleware proxy ke RapidAPI |
| Secret Management | **Supabase Secrets** | Menyimpan API Key RapidAPI secara aman |

### Data Extraction

| Layer | Teknologi | Keterangan |
|-------|-----------|------------|
| API Provider | **RapidAPI** — Social Media Video Downloader | Mendukung TikTok, Instagram, YouTube |
| Protokol | HTTPS REST | JSON response berisi direct download URL |

### Arsitektur Ringkas

```
[Flutter App]
     │
     │  POST /download (URL konten)
     ▼
[Supabase Edge Function]
     │
     │  GET RapidAPI (dengan secret API key)
     ▼
[RapidAPI — Social Media Video Downloader]
     │
     │  JSON { direct_url, quality, ... }
     ▼
[Supabase Edge Function]  ──► return JSON ke Flutter
     │
[Flutter App]  ──► flutter_downloader.enqueue(direct_url)
     │
     ▼
[Local Storage Perangkat]
```

---

## 3. Scope / Fitur Utama MVP

### 3.1 Form Input URL

- Kolom teks untuk paste URL dari TikTok, Instagram, atau YouTube.
- Tombol **"Unduh"** untuk memulai proses.
- Validasi format URL dasar sebelum dikirim ke backend.
- Tombol paste-from-clipboard (optional enhancement).

### 3.2 Deteksi Otomatis Platform

- Aplikasi mendeteksi platform berdasarkan domain URL:
  - `tiktok.com` / `vm.tiktok.com` → TikTok
  - `instagram.com` / `instagr.am` → Instagram
  - `youtube.com` / `youtu.be` → YouTube
- Menampilkan badge/ikon platform yang terdeteksi secara real-time.
- Error handling jika URL tidak dikenali.

### 3.3 Proses Ekstrak Direct Link MP4 via Supabase

- Flutter mengirim POST request ke Supabase Edge Function endpoint.
- Edge Function membaca API Key dari Supabase Secrets (tidak pernah terekspos ke client).
- Edge Function memanggil RapidAPI dengan URL konten.
- Response JSON berisi satu atau lebih opsi kualitas video (URL MP4 direct).
- Edge Function memfilter dan mengembalikan payload bersih ke Flutter.

**Endpoint Edge Function (contoh):**
```
POST /functions/v1/extract-media
Body: { "url": "https://www.tiktok.com/@user/video/123..." }
Response: {
  "platform": "tiktok",
  "title": "...",
  "thumbnail": "...",
  "medias": [
    { "quality": "hd", "url": "https://..." },
    { "quality": "sd", "url": "https://..." }
  ]
}
```

### 3.4 Download Manager Lokal

- Menampilkan progress bar download.
- Menyimpan file ke folder `Downloads/AzkaSave/` di penyimpanan perangkat.
- Notifikasi sistem saat download selesai.
- Riwayat download (list file yang sudah diunduh).
- Mendukung download concurrent (multiple file sekaligus).

---

## 4. Security & Constraints

### 4.1 API Key Management

> **CRITICAL:** API Key RapidAPI **tidak boleh** di-hardcode di kode Flutter (client-side) dalam bentuk apapun — tidak di `dart` file, tidak di `.env` yang di-bundle, tidak di `AndroidManifest.xml`.

| Aturan | Detail |
|--------|--------|
| ✅ API Key disimpan di | **Supabase Secrets** (server environment variable) |
| ✅ API Key diakses oleh | Supabase Edge Function (server-side Deno runtime) |
| ❌ API Key tidak boleh ada di | Kode Flutter, response JSON ke client, log aplikasi |
| ✅ Komunikasi Flutter ↔ Supabase | Menggunakan HTTPS + Supabase Anon Key (public, aman) |

Referensi detail: `docs/backend/api-keys-management.md`

### 4.2 Distribusi Aplikasi

| Platform Target | Distribusi | Alasan |
|----------------|------------|--------|
| Android (TikTok, IG) | Google Play Store | Konten tidak melanggar ToS Play Store |
| Android (YouTube) | **APK Mandiri (Sideload)** | Google Play melarang aplikasi download YouTube |
| iOS | TestFlight / AltStore | TBD — belum menjadi prioritas MVP |

- APK versi YouTube akan dirilis melalui channel distribusi mandiri (GitHub Releases / link langsung).
- Pengguna perlu mengaktifkan "Install from Unknown Sources" di Android.

### 4.3 Ketentuan Penggunaan (Ethical Use)

- Aplikasi dimaksudkan untuk penggunaan pribadi (konten yang user sendiri yang upload, atau konten bebas hak cipta).
- Tidak ada server-side caching konten pihak ketiga.
- Semua download dilakukan langsung dari server CDN platform asal.

---

## 5. User Stories

| ID | As a... | I want to... | So that... |
|----|---------|--------------|------------|
| US-01 | User | Paste URL TikTok dan unduh video tanpa watermark | Saya bisa menyimpan video favorit ke galeri |
| US-02 | User | Unduh foto/video dari Instagram | Saya bisa backup konten IG saya sendiri |
| US-03 | User | Unduh video YouTube dalam kualitas terbaik | Saya bisa menonton offline tanpa kuota |
| US-04 | User | Melihat progress download secara real-time | Saya tahu berapa lama lagi proses selesai |
| US-05 | User | Melihat riwayat file yang sudah diunduh | Saya bisa mengakses ulang file dengan mudah |
| US-06 | Developer | API Key tidak terekspos di kode client | Sistem aman dari penyalahgunaan key |

---

## 6. Non-Functional Requirements

| Kategori | Requirement |
|----------|-------------|
| **Performance** | Respons dari Edge Function < 3 detik untuk URL valid |
| **Availability** | Bergantung pada uptime Supabase (99.9% SLA) dan RapidAPI |
| **Compatibility** | Android 6.0+ (API Level 23+), iOS 13+ |
| **Storage** | Aplikasi itu sendiri < 50 MB; file download ke external storage |
| **Network** | Membutuhkan koneksi internet aktif; tidak ada offline mode |
| **UX** | Dark mode support; animasi loading yang informatif |

---

## 7. Out of Scope (v1)

- ❌ Audio-only download (MP3 extraction)
- ❌ Playlist / batch download dari YouTube
- ❌ User account / login sistem
- ❌ Cloud storage sync (Google Drive, Dropbox)
- ❌ Web version (browser extension)
- ❌ Support platform lain (Twitter/X, Facebook, Pinterest)

---

## 8. Milestone & Timeline

| Milestone | Deskripsi | Target |
|-----------|-----------|--------|
| **M1** | Setup Supabase project + Edge Function boilerplate | Minggu 1 |
| **M2** | Integrasi RapidAPI (TikTok) + pengujian payload | Minggu 1-2 |
| **M3** | Flutter UI: Form input + deteksi platform | Minggu 2 |
| **M4** | Integrasi Flutter ↔ Supabase (end-to-end flow) | Minggu 3 |
| **M5** | Download Manager + local storage | Minggu 3-4 |
| **M6** | Dukungan Instagram & YouTube | Minggu 4-5 |
| **M7** | Testing, bug fixing, UX polish | Minggu 5-6 |
| **M8** | Build APK & distribusi pertama | Minggu 6 |

---

*Dokumen ini adalah living document dan akan diperbarui seiring perkembangan proyek.*
