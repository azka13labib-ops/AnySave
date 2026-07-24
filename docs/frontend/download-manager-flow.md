# Download Manager Flow

> Dokumentasi alur kerja download manager di Flutter AzkaSave — dari antrian hingga file tersimpan di perangkat.

---

## Daftar Isi

1. [Overview Alur Download](#1-overview-alur-download)
2. [Package yang Digunakan](#2-package-yang-digunakan)
3. [Permissions yang Dibutuhkan](#3-permissions-yang-dibutuhkan)
4. [Implementasi Download Task](#4-implementasi-download-task)
5. [Progress Tracking](#5-progress-tracking)
6. [Lokasi File Tersimpan](#6-lokasi-file-tersimpan)
7. [Notifikasi Sistem](#7-notifikasi-sistem)
8. [Handling Kegagalan Download](#8-handling-kegagalan-download)

---

## 1. Overview Alur Download

```
[User pilih kualitas video]
        │
        ▼
[Validasi URL masih valid (TTL check)]
        │
        ▼
[Enqueue task ke flutter_downloader]
        │
        ▼
[Background isolate menjalankan download]
        │
        ├──► Progress callback → Update UI progress bar
        │
        ├──► Selesai → Simpan ke DownloadHistory, kirim notifikasi
        │
        └──► Gagal → Tampilkan error, opsi retry
```

---

## 2. Package yang Digunakan

| Package | Versi | Fungsi |
|---------|-------|--------|
| `flutter_downloader` | TBD | Download file di background (native) |
| `path_provider` | TBD | Mendapatkan path direktori Download |
| `permission_handler` | TBD | Request izin storage & notifikasi |

---

## 3. Permissions yang Dibutuhkan

### Android

```xml
<!-- AndroidManifest.xml -->
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
    android:maxSdkVersion="28"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
    android:maxSdkVersion="32"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

### iOS

```xml
<!-- Info.plist -->
<key>NSPhotoLibraryAddUsageDescription</key>
<string>AzkaSave membutuhkan akses untuk menyimpan video ke Photos</string>
```

---

## 4. Implementasi Download Task

<!-- TODO: Tempel kode implementasi flutter_downloader.enqueue() setelah selesai -->

```dart
// Contoh skeleton
Future<void> startDownload({
  required String url,
  required String filename,
  required String savedDir,
}) async {
  final taskId = await FlutterDownloader.enqueue(
    url: url,
    savedDir: savedDir,
    fileName: filename,
    showNotification: true,
    openFileFromNotification: true,
  );
  // Simpan taskId untuk tracking progress
}
```

---

## 5. Progress Tracking

<!-- TODO: Dokumentasikan listener/callback untuk update progress -->

---

## 6. Lokasi File Tersimpan

| Platform | Path |
|----------|------|
| Android | `/storage/emulated/0/Download/AzkaSave/` |
| iOS | Direktori Documents app (sandboxed) |

---

## 7. Notifikasi Sistem

- Notifikasi progress muncul saat download berjalan (via `flutter_downloader`)
- Notifikasi "Download selesai" dengan tap-to-open file
- Notifikasi error jika download gagal

---

## 8. Handling Kegagalan Download

| Skenario | Handling |
|----------|---------|
| Koneksi terputus | Retry otomatis (max 3x) |
| URL expired (CDN TTL) | Re-request ke Edge Function, dapat URL baru |
| Storage penuh | Tampilkan dialog error dengan info storage |
| Izin ditolak | Arahkan ke Settings untuk grant permission |
