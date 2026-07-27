import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../theme/app_constants.dart';
import '../providers/app_settings_provider.dart';

enum MediaType { video, photo, music }

class HistoryItem {
  final String taskId;
  final String title;
  final String platform;
  final String size;
  final String thumbnail;
  final String filePath;
  final MediaType mediaType;

  HistoryItem({
    required this.taskId,
    required this.title,
    required this.platform,
    required this.size,
    required this.thumbnail,
    required this.filePath,
    required this.mediaType,
  });

  static MediaType detectType(String filename) {
    final ext = filename.toLowerCase().split('.').last;
    const videoExts = {'mp4', 'mov', 'mkv', 'avi', 'webm', 'flv', '3gp', 'm4v'};
    const imageExts = {'jpg', 'jpeg', 'png', 'gif', 'webp', 'heic', 'bmp'};
    const audioExts = {'mp3', 'm4a', 'aac', 'wav', 'ogg', 'flac', 'opus'};

    if (videoExts.contains(ext)) return MediaType.video;
    if (imageExts.contains(ext)) return MediaType.photo;
    if (audioExts.contains(ext)) return MediaType.music;
    // Default: jika tidak dikenal ekstensinya, anggap video (mp4 paling umum)
    return MediaType.video;
  }
}

class HistoryScreen extends ConsumerStatefulWidget {
  final VoidCallback onClearHistoryTap;
  final Key? key;

  const HistoryScreen({
    this.key,
    required this.onClearHistoryTap,
  }) : super(key: key);

  @override
  ConsumerState<HistoryScreen> createState() => HistoryScreenState();
}

class HistoryScreenState extends ConsumerState<HistoryScreen>
    with SingleTickerProviderStateMixin {
  List<HistoryItem> _historyItems = [];
  bool _isLoading = true;
  String _userName = 'User';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserName();
    loadHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name') ?? 'User';
    if (mounted) setState(() => _userName = name);
  }

  Future<void> loadHistory() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final tasks = await FlutterDownloader.loadTasks();
      final prefs = await SharedPreferences.getInstance();

      List<HistoryItem> items = [];

      if (tasks != null && tasks.isNotEmpty) {
        for (var task in tasks) {
          if (task.status == DownloadTaskStatus.complete) {
            final thumb = prefs.getString('thumb_${task.taskId}') ?? '';
            final fileName = task.filename ?? 'AnySave_${task.taskId.substring(0, 5)}.mp4';
            final filePath = '${task.savedDir}/$fileName';
            final mediaType = HistoryItem.detectType(fileName);

            String platform = 'AnySave';
            if (fileName.toLowerCase().contains('tiktok')) {
              platform = 'TikTok';
            } else if (fileName.toLowerCase().contains('instagram') ||
                fileName.toLowerCase().contains('ig')) {
              platform = 'Instagram';
            } else if (fileName.toLowerCase().contains('youtube') ||
                fileName.toLowerCase().contains('yt')) {
              platform = 'YouTube';
            }

            // Label ukuran berdasarkan tipe media
            String sizeLabel;
            switch (mediaType) {
              case MediaType.video:
                sizeLabel = 'Video MP4';
                break;
              case MediaType.photo:
                sizeLabel = 'Photo';
                break;
              case MediaType.music:
                sizeLabel = 'Audio MP3';
                break;
            }

            items.add(
              HistoryItem(
                taskId: task.taskId,
                title: fileName,
                platform: platform,
                size: sizeLabel,
                thumbnail: thumb,
                filePath: filePath,
                mediaType: mediaType,
              ),
            );
          }
        }
      }

      if (mounted) {
        setState(() {
          _historyItems = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> clearAllHistory() async {
    try {
      final tasks = await FlutterDownloader.loadTasks();
      if (tasks != null) {
        for (var task in tasks) {
          await FlutterDownloader.remove(
            taskId: task.taskId,
            shouldDeleteContent: false,
          );
        }
      }

      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      for (var key in keys) {
        if (key.startsWith('thumb_')) {
          await prefs.remove(key);
        }
      }

      await prefs.setBool('history_cleared_permanently', true);

      if (mounted) {
        setState(() {
          _historyItems.clear();
        });
      }
    } catch (e) {
      debugPrint('Clear history error: $e');
    }
  }

  List<HistoryItem> _filteredItems(MediaType type) =>
      _historyItems.where((item) => item.mediaType == type).toList();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryAccent : AppColors.primary;
    final currentLanguage = ref.watch(languageProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/icons/app_logo.png',
                width: 28,
                height: 28,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.download_rounded,
                  color: primaryColor,
                  size: 26,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'AnySave',
              style: TextStyle(
                color: primaryColor,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: primaryColor.withValues(alpha: 0.15),
              child: Text(
                _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: primaryColor,
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(49),
          child: Column(
            children: [
              Container(
                color: isDark ? AppColors.borderDark : const Color(0xFFE9E7ED),
                height: 1,
              ),
              TabBar(
                controller: _tabController,
                indicatorColor: primaryColor,
                indicatorWeight: 3,
                labelColor: primaryColor,
                unselectedLabelColor:
                    isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                labelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                tabs: const [
                  Tab(text: 'Video'),
                  Tab(text: 'Photo'),
                  Tab(text: 'Music'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildTabContent(
                    isDark: isDark,
                    currentLanguage: currentLanguage,
                    items: _filteredItems(MediaType.video),
                    emptyIcon: Icons.videocam_off_rounded,
                    emptyLabel: 'Belum ada video yang diunduh',
                    emptyLabelEn: 'No videos downloaded yet',
                    actionLabel: 'Putar',
                    actionLabelEn: 'Play',
                    mediaType: MediaType.video,
                  ),
                  _buildTabContent(
                    isDark: isDark,
                    currentLanguage: currentLanguage,
                    items: _filteredItems(MediaType.photo),
                    emptyIcon: Icons.image_not_supported_rounded,
                    emptyLabel: 'Belum ada foto yang diunduh',
                    emptyLabelEn: 'No photos downloaded yet',
                    actionLabel: 'Lihat',
                    actionLabelEn: 'View',
                    mediaType: MediaType.photo,
                  ),
                  _buildTabContent(
                    isDark: isDark,
                    currentLanguage: currentLanguage,
                    items: _filteredItems(MediaType.music),
                    emptyIcon: Icons.music_off_rounded,
                    emptyLabel: 'Belum ada musik yang diunduh',
                    emptyLabelEn: 'No music downloaded yet',
                    actionLabel: 'Putar',
                    actionLabelEn: 'Play',
                    mediaType: MediaType.music,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildTabContent({
    required bool isDark,
    required String currentLanguage,
    required List<HistoryItem> items,
    required IconData emptyIcon,
    required String emptyLabel,
    required String emptyLabelEn,
    required String actionLabel,
    required String actionLabelEn,
    required MediaType mediaType,
  }) {
    final isId = currentLanguage == 'Bahasa Indonesia';

    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.containerMargin),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurfaceSecondary
                      : AppColors.lightSurfaceSecondary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  emptyIcon,
                  size: 56,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isId ? emptyLabel : emptyLabelEn,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.containerMargin),
      child: Column(
        children: [
          // Header Row: jumlah item & Clear All
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${items.length} ${isId ? "file" : "files"}',
                style: TextStyle(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              GestureDetector(
                onTap: widget.onClearHistoryTap,
                child: Text(
                  AppStrings.tr('clear_all', currentLanguage),
                  style: TextStyle(
                    color: isDark ? AppColors.primaryAccent : AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Cards List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              return _buildItemCard(
                isDark: isDark,
                item: item,
                actionLabel: isId ? actionLabel : actionLabelEn,
                mediaType: mediaType,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard({
    required bool isDark,
    required HistoryItem item,
    required String actionLabel,
    required MediaType mediaType,
  }) {
    final Icon typeIcon;
    switch (mediaType) {
      case MediaType.video:
        typeIcon = const Icon(Icons.movie_outlined, color: Colors.grey, size: 28);
        break;
      case MediaType.photo:
        typeIcon = const Icon(Icons.image_outlined, color: Colors.grey, size: 28);
        break;
      case MediaType.music:
        typeIcon = const Icon(Icons.audio_file_outlined, color: Colors.grey, size: 28);
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : const Color(0xFFE9E7ED),
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        children: [
          // Thumbnail / ikon tipe media
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurfaceSecondary
                  : AppColors.lightSurfaceSecondary,
              borderRadius: BorderRadius.circular(14),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              alignment: Alignment.center,
              children: [
                item.thumbnail.isNotEmpty
                    ? Image.network(
                        item.thumbnail,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: isDark
                              ? AppColors.darkSurfaceSecondary
                              : AppColors.lightSurfaceSecondary,
                          child: typeIcon,
                        ),
                      )
                    : Container(
                        color: isDark
                            ? AppColors.darkSurfaceSecondary
                            : AppColors.lightSurfaceSecondary,
                        child: typeIcon,
                      ),
                // Overlay play/view hanya kalau bukan photo (photo tidak perlu play overlay)
                if (mediaType != MediaType.photo) ...[
                  Container(color: Colors.black26),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      mediaType == MediaType.music
                          ? Icons.music_note_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 14),

          // Info Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurfaceSecondary
                            : const Color(0xFFF2F2F7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.platform,
                        style: TextStyle(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : const Color(0xFF666666),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '•  ${item.size}',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : const Color(0xFF666666),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Trailing action menu
          IconButton(
            onPressed: () {
              _showItemMenu(context, item, actionLabel);
            },
            icon: Icon(
              Icons.more_vert_rounded,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  void _showItemMenu(BuildContext context, HistoryItem item, String actionLabel) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkSurfaceContainer
          : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(
                item.mediaType == MediaType.photo
                    ? Icons.open_in_new_rounded
                    : Icons.play_circle_outline,
              ),
              title: Text('$actionLabel file'),
              onTap: () {
                Navigator.pop(context);
                if (!item.taskId.startsWith('mock_')) {
                  FlutterDownloader.open(taskId: item.taskId);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: const Text(
                'Hapus dari Riwayat',
                style: TextStyle(color: AppColors.error),
              ),
              onTap: () async {
                Navigator.pop(context);
                if (!item.taskId.startsWith('mock_')) {
                  await FlutterDownloader.remove(
                    taskId: item.taskId,
                    shouldDeleteContent: false,
                  );
                }
                setState(() {
                  _historyItems.removeWhere((h) => h.taskId == item.taskId);
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
