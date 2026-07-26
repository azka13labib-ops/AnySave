import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import '../providers/downloader_provider.dart';
import '../../utils/download_helper.dart';
import 'history_tab.dart';
import 'settings_tab.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _urlController = TextEditingController();
  int _currentIndex = 0;
  String? _selectedPlatform;

  // Neon lime green accent
  static const Color _accent = Color(0xFFC8FF00);
  static const Color _bgDark = Color(0xFF0D0D0D);
  static const Color _cardDark = Color(0xFF1C1C1E);

  void _fetchMedia() {
    final url = _urlController.text.trim();
    if (url.isNotEmpty) {
      ref.read(downloaderProvider.notifier).fetchMedia(url);
      FocusScope.of(context).unfocus();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please paste a video link first'),
          backgroundColor: _cardDark,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _selectPlatform(String platform) {
    setState(() {
      if (_selectedPlatform == platform) {
        _selectedPlatform = null;
        _urlController.clear();
      } else {
        _selectedPlatform = platform;
        switch (platform) {
          case 'YouTube':
            _urlController.text = 'https://www.youtube.com/watch?v=';
            break;
          case 'Instagram':
            _urlController.text = 'https://www.instagram.com/reel/';
            break;
          case 'TikTok':
            _urlController.text = 'https://www.tiktok.com/@/video/';
            break;
        }
      }
    });
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildLibraryTab(context),
          const DownloadsTab(),
          const SettingsTab(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: _bgDark,
          border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_rounded),
              activeIcon: Icon(Icons.grid_view_rounded),
              label: 'Library',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.download_rounded),
              activeIcon: Icon(Icons.download_rounded),
              label: 'Downloads',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings_rounded),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  //  LIBRARY TAB (main home tab)
  // ──────────────────────────────────────────────
  Widget _buildLibraryTab(BuildContext context) {
    final downloaderState = ref.watch(downloaderProvider);

    return SafeArea(
      child: Column(
        children: [
          // Top Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {},
                  child: const Icon(Icons.menu, color: Colors.white, size: 26),
                ),
                const Text(
                  'ANYSAVE',
                  style: TextStyle(
                    color: _accent,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _currentIndex = 2),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.settings_outlined, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 32),

                  // ── Hero Section ──
                  const Text(
                    'SAVE IT. KEEP\nIT.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _accent,
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'One link. Any platform. Straight to your\nlocal storage.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── URL Input ──
                  Container(
                    decoration: BoxDecoration(
                      color: _cardDark,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 14),
                          child: Icon(Icons.link, color: Colors.grey.shade500, size: 20),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _urlController,
                            style: const TextStyle(fontSize: 14, color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Paste Video URL Here',
                              hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                            ),
                            onSubmitted: (_) => _fetchMedia(),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        if (_urlController.text.isNotEmpty)
                          GestureDetector(
                            onTap: () => setState(() {
                              _urlController.clear();
                              _selectedPlatform = null;
                            }),
                            child: Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: Icon(Icons.close, color: Colors.grey.shade500, size: 18),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── GET VIDEO Button ──
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: downloaderState.isLoading ? null : _fetchMedia,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accent,
                        foregroundColor: _bgDark,
                        disabledBackgroundColor: _accent.withValues(alpha: 0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: downloaderState.isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Color(0xFF0D0D0D),
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.download_rounded, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'GET VIDEO',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Platform Filter Chips ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildPlatformChip('YouTube', Icons.play_circle_filled),
                      const SizedBox(width: 10),
                      _buildPlatformChip('Instagram', Icons.camera_alt),
                      const SizedBox(width: 10),
                      _buildPlatformChip('TikTok', Icons.music_note),
                    ],
                  ),

                  const SizedBox(height: 36),

                  // ── Result Card (when data is loaded) ──
                  downloaderState.when(
                    data: (mediaItem) {
                      if (mediaItem == null) return const SizedBox.shrink();
                      return _buildResultCard(mediaItem);
                    },
                    error: (err, stack) => Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Error: $err',
                              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    loading: () => const SizedBox.shrink(),
                  ),

                  // ── Recent Downloads Section ──
                  _buildRecentDownloadsSection(),

                  const SizedBox(height: 36),

                  // ── Why AnySave Section ──
                  _buildWhySection(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  //  Platform Chip
  // ──────────────────────────────────────────────
  Widget _buildPlatformChip(String label, IconData icon) {
    final isSelected = _selectedPlatform == label;
    return GestureDetector(
      onTap: () => _selectPlatform(label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _accent.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? _accent : Colors.grey.shade700,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? _accent : Colors.grey.shade400),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? _accent : Colors.grey.shade400,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  //  Result Card
  // ──────────────────────────────────────────────
  Widget _buildResultCard(dynamic mediaItem) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Thumbnail
          Stack(
            children: [
              if (mediaItem.thumbnail.isNotEmpty)
                Image.network(
                  mediaItem.thumbnail,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  headers: const {
                    'Referer': 'https://www.tiktok.com/',
                    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
                  },
                  errorBuilder: (context, error, stackTrace) =>
                      Container(height: 200, color: const Color(0xFF111112)),
                )
              else
                Container(
                  height: 200,
                  color: const Color(0xFF111112),
                  child: Center(
                    child: Icon(Icons.videocam_outlined, color: Colors.grey.shade700, size: 48),
                  ),
                ),
              // Gradient overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                ),
              ),
              // Title overlaid
              Positioned(
                bottom: 12,
                left: 14,
                right: 14,
                child: Text(
                  mediaItem.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          // Download buttons
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                ...mediaItem.links.take(3).map<Widget>((link) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Starting download...'),
                              backgroundColor: _cardDark,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                          DownloadHelper.downloadFile(
                            link.url,
                            'AnySave_${DateTime.now().millisecondsSinceEpoch}',
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accent,
                          foregroundColor: _bgDark,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.download_rounded, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              link.renderTitle,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  //  Recent Downloads Section
  // ──────────────────────────────────────────────
  Widget _buildRecentDownloadsSection() {
    return FutureBuilder<List<DownloadTask>?>(
      future: FlutterDownloader.loadTasks(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }
        final tasks = snapshot.data?.reversed.toList() ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Downloads',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _currentIndex = 1),
                  child: const Text(
                    'View All >>',
                    style: TextStyle(
                      color: _accent,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (tasks.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _cardDark,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.download_rounded, color: Colors.grey.shade700, size: 36),
                      const SizedBox(height: 10),
                      const Text(
                        'No downloads yet',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...tasks.take(4).map((task) => _buildRecentDownloadCard(task)),
          ],
        );
      },
    );
  }

  Widget _buildRecentDownloadCard(DownloadTask task) {
    final isComplete = task.status == DownloadTaskStatus.complete;
    final isRunning = task.status == DownloadTaskStatus.running;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Row(
        children: [
          // Thumbnail placeholder
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF111112),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(
                Icons.play_arrow_rounded,
                color: Colors.white.withValues(alpha: 0.3),
                size: 26,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.filename ?? 'Video Download',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: isComplete
                            ? _accent.withValues(alpha: 0.15)
                            : isRunning
                                ? Colors.blueAccent.withValues(alpha: 0.15)
                                : Colors.red.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isComplete
                                ? Icons.check_circle
                                : isRunning
                                    ? Icons.downloading
                                    : Icons.error_outline,
                            size: 10,
                            color: isComplete ? _accent : (isRunning ? Colors.blueAccent : Colors.redAccent),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            isComplete ? 'COMPLETED' : (isRunning ? 'DOWNLOADING' : 'FAILED'),
                            style: TextStyle(
                              color: isComplete ? _accent : (isRunning ? Colors.blueAccent : Colors.redAccent),
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isRunning) ...[
                      const SizedBox(width: 8),
                      Text(
                        '${task.progress}%',
                        style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              if (isComplete) {
                FlutterDownloader.open(taskId: task.taskId);
              }
            },
            child: Icon(
              isComplete ? Icons.folder_open_rounded : Icons.more_vert,
              color: Colors.grey.shade600,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  //  Why AnySave Section
  // ──────────────────────────────────────────────
  Widget _buildWhySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Why AnySave?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        _buildFeatureCard(
          icon: Icons.bolt,
          iconColor: _accent,
          title: 'LIGHTNING FAST',
          description: 'Our servers bypass traditional throttles to deliver your media in seconds, not minutes. Built for pure performance.',
        ),
        const SizedBox(height: 10),
        _buildFeatureCard(
          icon: Icons.high_quality,
          iconColor: _accent,
          title: '4K READY',
          description: 'Lossless extraction for maximum fidelity.',
        ),
        const SizedBox(height: 10),
        _buildFeatureCard(
          icon: Icons.security,
          iconColor: _accent,
          title: 'PRIVATE & SECURE',
          description: 'No accounts needed. No tracking. Your downloads stay on your device.',
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
