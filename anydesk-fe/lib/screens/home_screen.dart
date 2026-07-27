import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../theme/app_constants.dart';
import '../widgets/storage_banner.dart';
import '../widgets/platform_toggle.dart';
import '../widgets/recent_download_card.dart';

class HomeScreen extends StatefulWidget {
  final Function(String url) onSearchVideo;
  final VoidCallback onSignInTap;

  const HomeScreen({
    super.key,
    required this.onSearchVideo,
    required this.onSignInTap,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _urlController = TextEditingController();
  String _selectedPlatform = 'tiktok';
  bool _showStorageBanner = false;

  @override
  void initState() {
    super.initState();
    _checkPermissionStatus();
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('AnySave'),
        actions: [
          IconButton(
            onPressed: widget.onSignInTap,
            icon: Icon(
              Icons.account_circle_outlined,
              color: isDark ? Colors.white : AppColors.primary,
            ),
            tooltip: 'Sign In',
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
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  'SELECT PLATFORM',
                  style: TextStyle(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              PlatformToggle(
                selectedPlatform: _selectedPlatform,
                onPlatformChanged: (platform) {
                  setState(() => _selectedPlatform = platform);
                },
              ),

              const SizedBox(height: AppConstants.sectionGap),

              // 3. Search / URL Input Area
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurfaceSecondary,
                  borderRadius: AppConstants.borderRadiusLarge,
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : const Color(0xFFE9E7ED),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _urlController,
                        style: TextStyle(
                          color: isDark ? Colors.white : AppColors.textPrimaryLight,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Paste ${_selectedPlatform == "tiktok" ? "TikTok" : "Instagram"} link here...',
                          hintStyle: TextStyle(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            fontSize: 13.5,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _pasteFromClipboard,
                      icon: Icon(
                        Icons.content_paste_rounded,
                        color: primaryColor,
                        size: 20,
                      ),
                      tooltip: 'Paste link',
                    ),
                    const SizedBox(width: 4),
                  ],
                ),
              ),

              const SizedBox(height: AppConstants.stackGap),

              // Search Video Primary Button
              ElevatedButton.icon(
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  widget.onSearchVideo(_urlController.text.trim());
                },
                icon: const Icon(Icons.search_rounded, size: 20),
                label: const Text('Search video'),
              ),

              const SizedBox(height: AppConstants.sectionGap),

              // 4. Recent Download Preview Section
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  'RECENT DOWNLOAD',
                  style: TextStyle(
                    color: AppColors.textSecondaryDark,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              RecentDownloadCard(
                title: 'Morning Coffee Routine Aesthetic',
                creator: '@coffeelover',
                views: '2.4M views',
                thumbnailUrl: 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=300',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Playing preview video...')),
                  );
                },
                onShare: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sharing video link...')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
