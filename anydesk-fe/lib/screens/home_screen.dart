import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';
import '../theme/app_constants.dart';
import '../widgets/storage_banner.dart';
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
  bool _showStorageBanner = false;
  List<DownloadTask> _recentTasks = [];
  Map<String, String> _recentThumbs = {};
  String _userName = 'User';

  @override
  void initState() {
    super.initState();
    _checkPermissionStatus();
    _loadRecentTasks();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name') ?? 'User';
    if (mounted) setState(() => _userName = name);
  }

  Future<void> _loadRecentTasks() async {
    try {
      final tasks = await FlutterDownloader.loadTasks();
      if (tasks != null && tasks.isNotEmpty) {
        final completed = tasks.where((t) => t.status == DownloadTaskStatus.complete).toList();
        if (completed.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          // Ambil maksimal 3 download terbaru (limit 3)
          final latestThree = completed.reversed.take(3).toList();
          final Map<String, String> thumbs = {};
          for (final t in latestThree) {
            thumbs[t.taskId] = prefs.getString('thumb_${t.taskId}') ?? '';
          }
          if (mounted) {
            setState(() {
              _recentTasks = latestThree;
              _recentThumbs = thumbs;
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: isDark ? AppColors.borderDark : const Color(0xFFE9E7ED),
            height: 1,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.containerMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Storage Access Needed Banner
              if (_showStorageBanner) ...[
                StorageBanner(
                  onEnableAccess: _requestStorageAccess,
                ),
                const SizedBox(height: AppConstants.sectionGap),
              ],

              // 2. Search Input Section
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

              const SizedBox(height: AppConstants.sectionGap),

              // 4. Social App Shortcuts Section
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: isDark ? AppColors.borderDark : const Color(0xFFE9E7ED),
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'Open Social App to Copy Link',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: isDark ? AppColors.borderDark : const Color(0xFFE9E7ED),
                      thickness: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSocialShortcut(
                    name: 'TikTok',
                    iconPath: 'assets/icons/tiktok.png',
                    url: 'https://www.tiktok.com/',
                    isDark: isDark,
                  ),
                  _buildSocialShortcut(
                    name: 'Instagram',
                    iconPath: 'assets/icons/instagram.png',
                    url: 'https://www.instagram.com/',
                    isDark: isDark,
                  ),
                  _buildSocialShortcut(
                    name: 'Facebook',
                    iconPath: 'assets/icons/facebook.png',
                    url: 'https://www.facebook.com/',
                    isDark: isDark,
                  ),
                  _buildSocialShortcut(
                    name: 'X',
                    iconPath: 'assets/icons/x.png',
                    url: 'https://x.com/',
                    isDark: isDark,
                  ),
                  _buildSocialShortcut(
                    name: 'Pinterest',
                    iconPath: 'assets/icons/pinterest.png',
                    url: 'https://www.pinterest.com/',
                    isDark: isDark,
                  ),
                ],
              ),

              if (_recentTasks.isNotEmpty) ...[
                const SizedBox(height: AppConstants.sectionGap),

                // 4. Real Recent Download Preview Cards (Limit max 3)
                Text(
                  AppStrings.tr('recent_downloads', currentLanguage),
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                ..._recentTasks.map((task) {
                  final thumb = _recentThumbs[task.taskId] ?? '';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: RecentDownloadCard(
                      title: task.filename ?? 'Video_${task.taskId.substring(0, 5)}.mp4',
                      creator: 'Downloaded Media',
                      views: 'MP4',
                      thumbnailUrl: thumb.isNotEmpty
                          ? thumb
                          : 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=400',
                      onTap: () {
                        FlutterDownloader.open(taskId: task.taskId);
                      },
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialShortcut({
    required String name,
    required String iconPath,
    required String url,
    required bool isDark,
  }) {
    return InkWell(
      onTap: () async {
        final uri = Uri.parse(url);
        try {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } catch (_) {
          // Fallback ke browser biasa jika aplikasi external tidak berhasil dibuka
          await launchUrl(uri);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? const Color(0xFF1E1E24) : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(8),
              child: ClipOval(
                child: Image.asset(
                  iconPath,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.public_rounded,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              name,
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimaryLight,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
