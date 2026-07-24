# Edge Functions

> Dokumentasi Supabase Edge Functions yang digunakan sebagai middleware antara Flutter dan RapidAPI.

---

## Daftar Isi

1. [Arsitektur Edge Function](#1-arsitektur-edge-function)
2. [Function: `extract-media`](#2-function-extract-media)
   - [Request Schema](#21-request-schema)
   - [Response Schema](#22-response-schema)
   - [Kode Implementasi](#23-kode-implementasi)
3. [Deployment](#3-deployment)
4. [Testing Lokal](#4-testing-lokal)
5. [Error Handling & Status Code](#5-error-handling--status-code)
6. [CORS Configuration](#6-cors-configuration)

---

## 1. Arsitektur Edge Function

Edge Functions berjalan di Deno runtime di sisi server Supabase. Fungsinya adalah:
- Menerima request dari Flutter client
- Membaca `RAPIDAPI_KEY` dari Supabase Secrets (tidak pernah dikirim ke client)
- Meneruskan request ke RapidAPI
- Memproses dan mengembalikan response yang sudah dibersihkan ke client

```
Flutter → [HTTPS POST] → Supabase Edge Function → [HTTPS GET] → RapidAPI
                                    ↑
                          Membaca secret dari
                          Supabase Secrets (aman)
```

---

## 2. Function: `extract-media`

### 2.1 Request Schema

```json
POST /functions/v1/extract-media
Authorization: Bearer <SUPABASE_ANON_KEY>
Content-Type: application/json

{
  "url": "https://www.tiktok.com/@username/video/7123456789"
}
```

### 2.2 Response Schema

```json
{
  "platform": "tiktok",
  "title": "Judul konten",
  "thumbnail": "https://cdn.example.com/thumb.jpg",
  "duration": 30,
  "medias": [
    {
      "quality": "hd",
      "extension": "mp4",
      "url": "https://direct-cdn-link.com/video.mp4",
      "size": 15728640
    },
    {
      "quality": "sd",
      "extension": "mp4",
      "url": "https://direct-cdn-link.com/video_sd.mp4",
      "size": 8388608
    }
  ]
}
```

### 2.3 Kode Implementasi

<!-- TODO: Tempel kode TypeScript/Deno Edge Function di sini setelah implementasi -->

---

## 3. Deployment

```bash
# Deploy function ke Supabase
supabase functions deploy extract-media

# Set secret API key (jangan simpan key di sini, gunakan env variable)
supabase secrets set RAPIDAPI_KEY=<your-key>
```

---

## 4. Testing Lokal

```bash
# Serve functions secara lokal
supabase functions serve extract-media --env-file .env.local

# Test dengan curl
curl -i --location --request POST 'http://localhost:54321/functions/v1/extract-media' \
  --header 'Authorization: Bearer <ANON_KEY>' \
  --header 'Content-Type: application/json' \
  --data '{"url":"https://www.tiktok.com/@user/video/123"}'
```

---

## 5. Error Handling & Status Code

| Status Code | Kondisi |
|-------------|---------|
| `200 OK` | Berhasil mengekstrak media |
| `400 Bad Request` | URL tidak valid atau platform tidak didukung |
| `422 Unprocessable Entity` | RapidAPI gagal memproses URL |
| `500 Internal Server Error` | Error di sisi Edge Function |
| `429 Too Many Requests` | Rate limit RapidAPI terlampaui |

---

## 6. CORS Configuration

<!-- TODO: Dokumentasikan konfigurasi CORS header yang dibutuhkan untuk Flutter Web (jika ada) -->
