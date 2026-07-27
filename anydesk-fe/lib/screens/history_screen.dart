import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../theme/app_constants.dart';
import '../providers/app_settings_provider.dart';

class HistoryItem {
  final String taskId;
  final String title;
  final String platform;
  final String size;
  final String thumbnail;
  final String filePath;

  HistoryItem({
    required this.taskId,
    required this.title,
    required this.platform,
    required this.size,
    required this.thumbnail,
    required this.filePath,
  });
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

class HistoryScreenState extends ConsumerState<HistoryScreen> {
  List<HistoryItem> _historyItems = [];
  bool _isLoading = true;
  String _userName = 'User';

  @override
  void initState() {
    super.initState();
    _loadUserName();
    loadHistory();
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
            final fileName = task.filename ?? 'Video_${task.taskId.substring(0, 5)}.mp4';
            final filePath = '${task.savedDir}/${task.filename}';

            String platform = 'AnySave';
            if (fileName.toLowerCase().contains('tiktok')) {
              platform = 'TikTok';
            } else if (fileName.toLowerCase().contains('instagram') || fileName.toLowerCase().contains('ig')) {
              platform = 'Instagram';
            } else if (fileName.toLowerCase().contains('youtube') || fileName.toLowerCase().contains('yt')) {
              platform = 'YouTube';
            }

            items.add(
              HistoryItem(
                taskId: task.taskId,
                title: fileName,
                platform: platform,
                size: 'Video MP4',
                thumbnail: thumb,
                filePath: filePath,
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                  color: isDark ? AppColors.primaryAccent : AppColors.primary,
                  size: 26,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'AnySave',
              style: TextStyle(
                color: isDark ? AppColors.primaryAccent : AppColors.primary,
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
              backgroundColor: (isDark ? AppColors.primaryAccent : AppColors.primary).withValues(alpha: 0.15),
              child: Text(
                _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.primaryAccent : AppColors.primary,
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: isDark ? AppColors.borderDark : const Color(0xFFE9E7ED),
            height: 1,
          ),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : _historyItems.isEmpty
                ? _buildEmptyState(isDark, currentLanguage)
                : _buildHistoryContent(isDark, currentLanguage),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, String currentLanguage) {
    final isId = currentLanguage == 'Bahasa Indonesia';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.containerMargin),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceSecondary : AppColors.lightSurfaceSecondary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.folder_open_rounded,
                size: 64,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isId ? 'Belum Ada Unduhan' : 'No Downloads Yet',
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimaryLight,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isId ? 'Video dan audio yang kamu download akan muncul di sini.' : 'Videos and audio clips you download will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryContent(bool isDark, String currentLanguage) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.containerMargin),
      child: Column(
        children: [
          // Section Header Row: Recent Downloads & Clear All
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.tr('recent_downloads', currentLanguage),
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
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

          const SizedBox(height: 16),

          // Cards List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _historyItems.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = _historyItems[index];
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
                    // Thumbnail with play overlay
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurfaceSecondary : AppColors.lightSurfaceSecondary,
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
                                    color: isDark ? AppColors.darkSurfaceSecondary : AppColors.lightSurfaceSecondary,
                                    child: const Icon(Icons.movie_outlined, color: Colors.grey, size: 28),
                                  ),
                                )
                              : Container(
                                  color: isDark ? AppColors.darkSurfaceSecondary : AppColors.lightSurfaceSecondary,
                                  child: const Icon(Icons.movie_outlined, color: Colors.grey, size: 28),
                                ),
                          Container(color: Colors.black26),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.4),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
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
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.darkSurfaceSecondary : const Color(0xFFF2F2F7),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  item.platform,
                                  style: TextStyle(
                                    color: isDark ? AppColors.textSecondaryDark : const Color(0xFF666666),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '•  ${item.size}',
                                style: TextStyle(
                                  color: isDark ? AppColors.textSecondaryDark : const Color(0xFF666666),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Trailing 3 dots action menu
                    IconButton(
                      onPressed: () {
                        _showItemMenu(context, item);
                      },
                      icon: Icon(
                        Icons.more_vert_rounded,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showItemMenu(BuildContext context, HistoryItem item) {
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
              leading: const Icon(Icons.play_circle_outline),
              title: const Text('Play Video'),
              onTap: () {
                Navigator.pop(context);
                if (!item.taskId.startsWith('mock_')) {
                  FlutterDownloader.open(taskId: item.taskId);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: const Text('Delete from History', style: TextStyle(color: AppColors.error)),
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
