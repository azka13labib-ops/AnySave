# State Management

> Dokumentasi pilihan dan implementasi state management di aplikasi Flutter AzkaSave.

---

## Daftar Isi

1. [Pilihan State Management](#1-pilihan-state-management)
2. [State yang Dikelola](#2-state-yang-dikelola)
3. [Diagram Alur State](#3-diagram-alur-state)
4. [Implementasi: Extraction State](#4-implementasi-extraction-state)
5. [Implementasi: Download State](#5-implementasi-download-state)
6. [Error State & Recovery](#6-error-state--recovery)

---

## 1. Pilihan State Management

> **Keputusan:** <!-- TODO: Pilih antara Riverpod atau Bloc dan dokumentasikan alasannya -->

| Opsi | Pros | Cons |
|------|------|------|
| **Riverpod** | Compile-safe, tidak butuh BuildContext, mudah di-test | Kurva belajar bagi yang baru |
| **Bloc** | Pattern jelas (Event → State), community besar | Boilerplate lebih banyak |
| **Provider** | Familiar, sederhana | Kurang powerful untuk app kompleks |

---

## 2. State yang Dikelola

| State | Deskripsi |
|-------|-----------|
| `UrlInputState` | Nilai URL, validasi, platform yang terdeteksi |
| `ExtractionState` | Loading / success / error saat memanggil Edge Function |
| `DownloadQueueState` | Daftar download aktif, progress masing-masing |
| `HistoryState` | Daftar file yang sudah berhasil diunduh |

---

## 3. Diagram Alur State

```
User paste URL
      │
      ▼
[UrlInputState: url updated]
      │
User tap "Unduh"
      │
      ▼
[ExtractionState: loading]
      │
      ├─ Sukses ──► [ExtractionState: success(medias)]
      │                    │
      │             User pilih kualitas
      │                    │
      │                    ▼
      │             [DownloadQueueState: enqueued]
      │                    │
      │             [DownloadQueueState: downloading(progress)]
      │                    │
      │             [DownloadQueueState: completed]
      │                    │
      │             [HistoryState: item added]
      │
      └─ Gagal ──► [ExtractionState: error(message)]
```

---

## 4. Implementasi: Extraction State

<!-- TODO: Tempel kode Provider/Notifier/Bloc setelah implementasi selesai -->

---

## 5. Implementasi: Download State

<!-- TODO: Dokumentasikan integrasi flutter_downloader dengan state management -->

---

## 6. Error State & Recovery

<!-- TODO: Dokumentasikan strategi error handling dan retry mechanism -->
