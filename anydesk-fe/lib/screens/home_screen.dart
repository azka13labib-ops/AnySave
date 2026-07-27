import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../theme/app_constants.dart';
import '../widgets/storage_banner.dart';
import '../widgets/platform_toggle.dart';
import '../widgets/recent_download_card.dart';
import '../providers/app_settings_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final Function(String url) onSearchVideo;
  final VoidCallback onSignInTap;

  const HomeScreen({
    super.key,
    required this.onSearchVideo,
    required this.onSignInTap,
  });

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _urlController = TextEditingController();
  String _selectedPlatform = 'tiktok';
  bool _showStorageBanner = false;
  DownloadTask? _latestTask;
  String _latestThumb = '';
  String _userName = 'User';

  @override
  void initState() {
    super.initState();
    _checkPermissionStatus();
    _loadLatestTask();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name') ?? 'User';
    if (mounted) setState(() => _userName = name);
  }

  Future<void> _loadLatestTask() async {
    try {
      final tasks = await FlutterDownloader.loadTasks();
      if (tasks != null && tasks.isNotEmpty) {
        final completed = tasks.where((t) => t.status == DownloadTaskStatus.complete).toList();
        if (completed.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          final last = completed.last;
          final thumb = prefs.getString('thumb_${last.taskId}') ?? '';
          if (mounted) {
            setState(() {
              _latestTask = last;
              _latestThumb = thumb;
            });
          }
        }
      }
    } catch (_) {}
  }

  Future<void> _checkPermissionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isSavedGranted = prefs.getBool('storage_access_granted') ?? false;

    if (isSavedGranted) {
      if (mounted) setState(() => _showStorageBanner = false);
      return;
    }

    final isStorageGranted = await Permission.storage.isGranted || await Permission.photos.isGranted;
    if (mounted) {
      setState(() {
        _showStorageBanner = !isStorageGranted;
      });
    }
  }

  Future<void> _requestStorageAccess() async {
    final prefs = await SharedPreferences.getInstance();
    await Permission.storage.request();
    await Permission.photos.request();
    await prefs.setBool('storage_access_granted', true);

    if (mounted) {
      setState(() => _showStorageBanner = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Storage access permission granted!'),
          backgroundColor: AppColors.darkSurfaceSecondary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null && data.text != null) {
      _urlController.text = data.text!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryAccent : AppColors.primary;
    final currentLanguage = ref.watch(languageProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AnySave'),
        actions: [
          GestureDetector(
            onTap: widget.onSignInTap,
            child: Padding(
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
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.containerMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Storage Access Needed Banner
              if (_showStorageBanner)
                StorageBanner(
                  onEnableAccess: _requestStorageAccess,
                ),

              // 2. Select Platform Toggle
              Text(
                AppStrings.tr('select_platform', currentLanguage),
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              PlatformToggle(
                selectedPlatform: _selectedPlatform,
                onPlatformChanged: (platform) {
                  setState(() => _selectedPlatform = platform);
                },
              ),

              const SizedBox(height: AppConstants.sectionGap),

              // 3. Search Input Section
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : const Color(0xFFE9E7ED),
                  ),
                  boxShadow: isDark
                      ? []
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _urlController,
                      style: TextStyle(
                        color: isDark ? Colors.white : AppColors.textPrimaryLight,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: AppStrings.tr('search_placeholder', currentLanguage),
                        prefixIcon: Icon(
                          Icons.link_rounded,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                        suffixIcon: IconButton(
                          onPressed: _pasteFromClipboard,
                          icon: Icon(
                            Icons.content_paste_rounded,
                            color: primaryColor,
                          ),
                          tooltip: 'Paste Link',
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        widget.onSearchVideo(_urlController.text.trim());
                      },
                      icon: const Icon(Icons.search_rounded, size: 20),
                      label: Text(AppStrings.tr('search_button', currentLanguage)),
                    ),
                  ],
                ),
              ),

              if (_latestTask != null) ...[
                const SizedBox(height: AppConstants.sectionGap),

                // 4. Real Recent Download Preview Card
                Text(
                  AppStrings.tr('recent_downloads', currentLanguage),
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                RecentDownloadCard(
                  title: _latestTask!.filename ?? 'Video_${_latestTask!.taskId.substring(0, 5)}.mp4',
                  creator: 'Downloaded Media',
                  views: 'MP4',
                  thumbnailUrl: _latestThumb.isNotEmpty ? _latestThumb : 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=400',
                  onTap: () {
                    FlutterDownloader.open(taskId: _latestTask!.taskId);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
