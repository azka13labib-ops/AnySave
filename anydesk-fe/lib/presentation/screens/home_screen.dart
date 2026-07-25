import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import '../providers/downloader_provider.dart';
import '../../utils/download_helper.dart';
import 'history_tab.dart'; // Import tab riwayat

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _urlController = TextEditingController();
  int _currentIndex = 0; // State untuk navigasi tab

  void _fetchMedia() {
    final url = _urlController.text.trim();
    if (url.isNotEmpty) {
      ref.read(downloaderProvider.notifier).fetchMedia(url);
      FocusScope.of(context).unfocus();
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

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF1C1C1E),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF141416),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.cloud_download, color: Theme.of(context).colorScheme.primary, size: 32),
                ),
                const SizedBox(height: 12),
                const Text('AnySave', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const Text('Versi 1.0.0', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.white),
            title: const Text('Pengaturan', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Menu Pengaturan belum tersedia')));
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.white),
            title: const Text('Tentang Kami', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141416),
      drawer: _buildDrawer(context),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeTab(context),
          const HistoryTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF141416),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.history), // Ubah ikon ke history biar lebih pas
              ],
            ),
            label: 'Riwayat',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab(BuildContext context) {
    final downloaderState = ref.watch(downloaderProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        AppBar(
          leading: Builder(
            builder: (innerContext) => IconButton(
              icon: Stack(
                children: [
                  const Icon(Icons.menu, size: 28),
                  Positioned(
                    right: 0,
                    top: 2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              onPressed: () {
                Scaffold.of(innerContext).openDrawer();
              },
            ),
          ),
          title: const Text(
            'AnySave',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 22,
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Row Input & Button
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1C1C1E),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _urlController,
                                style: const TextStyle(fontSize: 16),
                                decoration: const InputDecoration(
                                  hintText: 'Paste link video...',
                                  hintStyle: TextStyle(color: Colors.grey),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                                ),
                                onSubmitted: (_) => _fetchMedia(),
                              ),
                            ),
                            if (_urlController.text.isNotEmpty)
                              IconButton(
                                icon: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade800,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, size: 14, color: Colors.white),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _urlController.clear();
                                  });
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      height: 56,
                      width: 90,
                      child: ElevatedButton(
                        onPressed: downloaderState.isLoading ? null : _fetchMedia,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: downloaderState.isLoading 
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text(
                              'Unduh',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                const Text(
                  'Pengingat: Hormati karya dan hak kekayaan intelektual kreator.',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                
                const SizedBox(height: 32),
                
                // Divider text
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.withOpacity(0.3))),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Open Social App to Copy Link',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey.withOpacity(0.3))),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Social Icons Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSocialLogoIcon('https://upload.wikimedia.org/wikipedia/en/thumb/a/a9/TikTok_logo.svg/100px-TikTok_logo.svg.png', 'TikTok', const Color(0xFF010101)),
                    _buildSocialLogoIcon('https://upload.wikimedia.org/wikipedia/commons/thumb/a/a5/Instagram_icon.png/120px-Instagram_icon.png', 'Instagram', null, isGradient: true),
                    _buildSocialLogoIcon('https://upload.wikimedia.org/wikipedia/commons/thumb/0/05/Facebook_Logo_%282019%29.png/120px-Facebook_Logo_%282019%29.png', 'Facebook', const Color(0xFF1877F2)),
                    _buildSocialLogoIcon('https://upload.wikimedia.org/wikipedia/commons/thumb/5/53/X_logo_2023_original.svg/120px-X_logo_2023_original.svg.png', 'X', const Color(0xFF000000)),
                    _buildSocialLogoIcon('https://upload.wikimedia.org/wikipedia/commons/thumb/0/08/Pinterest-logo.png/120px-Pinterest-logo.png', 'Pinterest', const Color(0xFFE60023)),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Result Video Card
                downloaderState.when(
                  data: (mediaItem) {
                    if (mediaItem == null) return const SizedBox.shrink();
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C1C1E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Stack(
                            children: [
                              if (mediaItem.thumbnail.isNotEmpty)
                                Image.network(
                                  mediaItem.thumbnail,
                                  height: 250,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  headers: const {
                                    'Referer': 'https://www.tiktok.com/',
                                    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
                                  },
                                  errorBuilder: (context, error, stackTrace) => 
                                      Container(height: 250, color: const Color(0xFF111112)),
                                )
                              else
                                Container(
                                  height: 250,
                                  color: const Color(0xFF111112),
                                ),
                              // Gradient Overlay to make text readable
                              Container(
                                height: 250,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black.withOpacity(0.3),
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.8),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 12,
                                left: 12,
                                child: Icon(Icons.picture_in_picture_alt, color: Colors.white.withOpacity(0.8), size: 20),
                              ),
                              Positioned(
                                top: 12,
                                right: 12,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.volume_off, color: Colors.white, size: 16),
                                ),
                              ),
                              // Title, Duration, Progress Bar OVERLAID
                              Positioned(
                                bottom: 12,
                                left: 12,
                                right: 12,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      mediaItem.title,
                                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('0:03', style: TextStyle(color: Colors.white, fontSize: 11)),
                                        const Text('2:00', style: TextStyle(color: Colors.white, fontSize: 11)),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Stack(
                                      clipBehavior: Clip.none,
                                      alignment: Alignment.centerLeft,
                                      children: [
                                        Container(
                                          height: 3,
                                          width: double.infinity,
                                          color: Colors.white.withOpacity(0.3),
                                        ),
                                        Container(
                                          height: 3,
                                          width: 24,
                                          color: Colors.white,
                                        ),
                                        Positioned(
                                          left: 20,
                                          child: Container(
                                            width: 6,
                                            height: 8,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Container(
                            color: const Color(0xFF1C1C1E),
                            padding: const EdgeInsets.only(right: 12.0, bottom: 12.0, top: 12.0),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: SizedBox(
                                height: 42,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (mediaItem.links.isNotEmpty) {
                                      final link = mediaItem.links.first;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Memulai download...'))
                                      );
                                      DownloadHelper.downloadFile(
                                        link.url, 
                                        'AnySave_${DateTime.now().millisecondsSinceEpoch}'
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colorScheme.primary, // Pinkish Red
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 24),
                                  ),
                                  child: const Text(
                                    'DOWNLOAD',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  error: (err, stack) => Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text('Error: $err', style: const TextStyle(color: Colors.redAccent)),
                  ),
                  loading: () => const SizedBox.shrink(),
                ),

                // Remove subscription banner and replace with History
                const SizedBox(height: 16),
                
                // Riwayat Terakhir
                FutureBuilder<List<DownloadTask>?>(
                  future: FlutterDownloader.loadTasks(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox.shrink();
                    }
                    final tasks = snapshot.data?.reversed.toList() ?? [];
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Riwayat Unduhan',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        if (tasks.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1C1C1E),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Column(
                                children: [
                                  Icon(Icons.history, color: Colors.grey, size: 36),
                                  SizedBox(height: 8),
                                  Text('Belum ada riwayat unduhan', style: TextStyle(color: Colors.grey, fontSize: 14)),
                                ],
                              ),
                            ),
                          )
                        else
                          ...tasks.take(5).map((task) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1C1C1E),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(8),
                            leading: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: const Color(0xFF111112),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.play_arrow, color: Colors.white54, size: 30),
                            ),
                            title: Text(
                              task.filename ?? 'Video Unduhan',
                              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                task.status == DownloadTaskStatus.complete ? 'Disimpan di galeri' : 'Mengunduh...',
                                style: TextStyle(
                                  color: task.status == DownloadTaskStatus.complete ? Colors.greenAccent : Colors.blueAccent,
                                  fontSize: 12
                                ),
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.folder_open, color: Colors.white70),
                              onPressed: () {
                                if (task.status == DownloadTaskStatus.complete) {
                                   FlutterDownloader.open(taskId: task.taskId);
                                }
                              }
                            ),
                          ),
                        )),
                      ],
                    );
                  },
                ),
                
                const SizedBox(height: 40), // spacer for bottom nav
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLogoIcon(String logoUrl, String label, Color? bgColor, {bool isGradient = false}) {
    return Column(
      children: [
        Container(
          height: 54,
          width: 54,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isGradient ? null : (bgColor ?? Colors.black),
            gradient: isGradient
                ? const LinearGradient(
                    colors: [Color(0xFFF58529), Color(0xFFDD2A7B), Color(0xFF8134AF), Color(0xFF515BD4)],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: (bgColor ?? Colors.black).withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Center(
            child: ClipOval(
              child: Image.network(
                logoUrl,
                height: 30,
                width: 30,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.public, color: Colors.white.withOpacity(0.7), size: 28),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }
}
