import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/media_item.dart';
import '../../data/services/api_service.dart';

final apiServiceProvider = Provider((ref) => ApiService());

final downloaderProvider = StateNotifierProvider<DownloaderNotifier, AsyncValue<MediaItem?>>((ref) {
  return DownloaderNotifier(ref.read(apiServiceProvider));
});

class DownloaderNotifier extends StateNotifier<AsyncValue<MediaItem?>> {
  final ApiService _apiService;

  DownloaderNotifier(this._apiService) : super(const AsyncValue.data(null));

  Future<void> fetchMedia(String url) async {
    if (url.isEmpty) return;
    
    state = const AsyncValue.loading();
    try {
      final mediaItem = await _apiService.fetchMediaDetails(url);
      state = AsyncValue.data(mediaItem);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

// ─── Download History Provider ──────────────────────────────────────────────
// FutureProvider untuk memuat semua task download dari FlutterDownloader.
// Saat di-invalidate (ref.invalidate), semua widget yang watch-nya akan rebuild
// secara otomatis dan mendapatkan data terbaru — mewujudkan "realtime refresh".
final downloadHistoryProvider = FutureProvider<List<DownloadTask>>((ref) async {
  final tasks = await FlutterDownloader.loadTasks();
  return tasks?.reversed.toList() ?? [];
});

// Provider terpisah khusus untuk recent (3 terbaru yang completed) + thumbnail map
final recentDownloadsProvider = FutureProvider<({List<DownloadTask> tasks, Map<String, String> thumbs})>((ref) async {
  final allTasks = await FlutterDownloader.loadTasks() ?? [];
  final completed = allTasks.where((t) => t.status == DownloadTaskStatus.complete).toList();
  final latest3 = completed.reversed.take(3).toList();

  final prefs = await SharedPreferences.getInstance();
  final thumbs = <String, String>{};
  for (final t in latest3) {
    thumbs[t.taskId] = prefs.getString('thumb_${t.filename}') ??
                        prefs.getString('thumb_${t.taskId}') ?? '';
  }

  return (tasks: latest3, thumbs: thumbs);
});
