# RapidAPI Endpoints — Social Media Video Downloader

> Catatan struktur payload JSON dari hasil pengujian langsung terhadap endpoint RapidAPI.  
> Update dokumen ini setiap kali ada payload baru yang berhasil dites.

---

## Daftar Isi

1. [Info API](#1-info-api)
2. [Base Request Structure](#2-base-request-structure)
3. [Payload TikTok](#3-payload-tiktok)
4. [Payload Instagram](#4-payload-instagram)
5. [Payload YouTube](#5-payload-youtube)
6. [Payload Error](#6-payload-error)
7. [Catatan & Gotchas](#7-catatan--gotchas)

---

## 1. Info API

| Field | Value |
|-------|-------|
| **API Name** | Social Media Video Downloader |
| **RapidAPI Host** | `social-media-video-downloader.p.rapidapi.com` |
| **Base URL** | `https://social-media-video-downloader.p.rapidapi.com` |
| **Auth Header** | `X-RapidAPI-Key: <RAPIDAPI_KEY>` |
| **Dokumentasi RapidAPI** | https://rapidapi.com/search/social-media-video-downloader |

> ⚠️ **PENTING:** Endpoint ini HANYA boleh dipanggil dari Supabase Edge Function. Jangan pernah panggil dari Flutter langsung.

---

## 2. Base Request Structure

```http
GET /smvd/get/all?url=<encoded_url>
Host: social-media-video-downloader.p.rapidapi.com
X-RapidAPI-Key: <RAPIDAPI_KEY>
X-RapidAPI-Host: social-media-video-downloader.p.rapidapi.com
```

---

## 3. Payload TikTok

> **Status:** <!-- TODO: Tandai ✅ Sukses / ❌ Belum dites / ⚠️ Partial -->  
> **URL Contoh yang Dites:** `https://www.tiktok.com/@username/video/7xxxxxxxxxx`  
> **Tanggal Tes:** <!-- TODO: Isi tanggal -->

### Raw Response

```json
{
  "success": true,
  "src_url": "https://www.tiktok.com/@username/video/7xxxxxxxxxx",
  "title": "Judul video TikTok",
  "picture": "https://p16-sign.tiktokcdn-us.com/...",
  "links": [
    {
      "link": "https://v19-webapp.tiktok.com/video/tos/...",
      "type": "mp4",
      "quality": "hd",
      "render": "Download HD (No Watermark)"
    },
    {
      "link": "https://v19-webapp.tiktok.com/video/tos/...",
      "type": "mp4",
      "quality": "sd",
      "render": "Download SD"
    }
  ]
}
```

### Field Mapping ke Model Flutter

| API Field | Flutter Model Field | Keterangan |
|-----------|---------------------|------------|
| `success` | - | Validasi response |
| `title` | `MediaItem.title` | |
| `picture` | `MediaItem.thumbnail` | |
| `links[].link` | `MediaOption.url` | Direct download URL |
| `links[].quality` | `MediaOption.quality` | `"hd"` / `"sd"` |
| `links[].type` | `MediaOption.extension` | `"mp4"` |

---

## 4. Payload Instagram

> **Status:** <!-- TODO: Tandai ✅ Sukses / ❌ Belum dites / ⚠️ Partial -->  
> **URL Contoh yang Dites:** `https://www.instagram.com/reel/Cxxxxxxxxxx/`  
> **Tanggal Tes:** <!-- TODO: Isi tanggal -->

### Raw Response

```json
{
  "success": true,
  "src_url": "https://www.instagram.com/reel/Cxxxxxxxxxx/",
  "title": "Instagram Reel",
  "picture": "https://instagram.com/...",
  "links": [
    {
      "link": "https://cdn-instagram.com/...",
      "type": "mp4",
      "quality": "hd",
      "render": "Download Video"
    }
  ]
}
```

### Catatan Khusus Instagram

<!-- TODO: Dokumentasikan perbedaan payload untuk:
  - Post biasa (single image)
  - Post carousel (multiple images)
  - Reels
  - Stories (jika didukung)
-->

---

## 5. Payload YouTube

> **Status:** <!-- TODO: Tandai ✅ Sukses / ❌ Belum dites / ⚠️ Partial -->  
> **URL Contoh yang Dites:** `https://www.youtube.com/watch?v=xxxxxxxxxxx`  
> **Tanggal Tes:** <!-- TODO: Isi tanggal -->

### Raw Response

```json
{
  "success": true,
  "src_url": "https://www.youtube.com/watch?v=xxxxxxxxxxx",
  "title": "Judul video YouTube",
  "picture": "https://i.ytimg.com/vi/xxxxxxxxxxx/maxresdefault.jpg",
  "links": [
    {
      "link": "https://...",
      "type": "mp4",
      "quality": "1080p",
      "render": "1080p"
    },
    {
      "link": "https://...",
      "type": "mp4",
      "quality": "720p",
      "render": "720p"
    },
    {
      "link": "https://...",
      "type": "mp4",
      "quality": "480p",
      "render": "480p"
    },
    {
      "link": "https://...",
      "type": "mp3",
      "quality": "128kbps",
      "render": "Audio MP3"
    }
  ]
}
```

### Catatan Khusus YouTube

<!-- TODO: Dokumentasikan:
  - Apakah URL YouTube Shorts berbeda handlingnya?
  - TTL (Time-to-Live) dari direct link yang dihasilkan
  - Apakah perlu handle separate audio + video stream?
-->

---

## 6. Payload Error

### URL Tidak Valid

```json
{
  "success": false,
  "message": "Invalid URL or unsupported platform"
}
```

### Rate Limit Tercapai

```json
{
  "message": "You have exceeded the MONTHLY quota for Requests on your current plan"
}
```

---

## 7. Catatan & Gotchas

| # | Catatan | Dampak |
|---|---------|--------|
| 1 | Direct URL dari YouTube memiliki TTL pendek (~6 jam) | Perlu re-fetch jika link expired |
| 2 | TikTok link `vm.tiktok.com` perlu di-resolve redirect-nya dahulu | Handle di Edge Function |
| 3 | Instagram memerlukan URL lengkap (bukan link mobile app share) | Validasi di client |
| 4 | Response `links` array bisa kosong meski `success: true` | Tambahkan null-check di Edge Function |

<!-- TODO: Tambahkan gotcha baru setelah ditemukan saat testing -->
