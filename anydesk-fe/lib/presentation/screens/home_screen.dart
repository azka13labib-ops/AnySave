import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/downloader_provider.dart';
import '../../utils/download_helper.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _urlController = TextEditingController();

  void _fetchMedia() {
    final url = _urlController.text.trim();
    if (url.isNotEmpty) {
      ref.read(downloaderProvider.notifier).fetchMedia(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan masukkan link terlebih dahulu')),
      );
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final downloaderState = ref.watch(downloaderProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AnySave Downloader'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                hintText: 'Paste link TikTok, IG, atau YouTube di sini',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
              onSubmitted: (_) => _fetchMedia(),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: downloaderState.isLoading ? null : _fetchMedia,
              icon: downloaderState.isLoading 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.search),
              label: Text(downloaderState.isLoading ? 'Mencari...' : 'Get Video'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
            const SizedBox(height: 24),
            
            // Tampilan Hasil
            downloaderState.when(
              data: (mediaItem) {
                if (mediaItem == null) return const SizedBox.shrink();
                
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (mediaItem.thumbnail.isNotEmpty)
                        Image.network(
                          mediaItem.thumbnail,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => 
                              Container(height: 200, color: Colors.grey, child: const Icon(Icons.broken_image, size: 50)),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mediaItem.title,
                              style: Theme.of(context).textTheme.titleMedium,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 16),
                            if (mediaItem.links.isEmpty)
                                const Text('Tidak ada link download yang tersedia'),
                            ...mediaItem.links.map((link) => Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Memulai download ${link.renderTitle}...'))
                                  );
                                  try {
                                    await DownloadHelper.downloadFile(
                                      link.url, 
                                      'AnySave_${DateTime.now().millisecondsSinceEpoch}'
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error: $e'))
                                    );
                                  }
                                },
                                icon: const Icon(Icons.download),
                                label: Text(link.renderTitle),
                              ),
                            )),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
              error: (err, stack) => Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Error: $err', style: const TextStyle(color: Colors.red)),
              ),
              loading: () => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
