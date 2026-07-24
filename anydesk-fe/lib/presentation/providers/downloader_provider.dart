import 'package:flutter_riverpod/flutter_riverpod.dart';
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
