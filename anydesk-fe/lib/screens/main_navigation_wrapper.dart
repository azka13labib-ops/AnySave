import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/media_item.dart';
import '../data/services/api_service.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/clear_cache_dialog.dart';
import 'home_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import 'video_preview_screen.dart';
import 'downloading_screen.dart';
import 'error_state_screen.dart';

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _currentIndex = 0;
  final ApiService _apiService = ApiService();
  final GlobalKey<HistoryScreenState> _historyKey = GlobalKey<HistoryScreenState>();

  void _navigateToScreen(Widget screen) {
    FocusScope.of(context).unfocus();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  Future<void> _handleSearchVideo(String url) async {
    FocusScope.of(context).unfocus();
    if (url.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please paste a video link first')),
      );
      return;
    }

    // Show Loading Modal
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF0058BC)),
      ),
    );

    try {
      final mediaItem = await _apiService.fetchMediaDetails(url.trim());
      if (mounted) Navigator.pop(context); // Close loading dialog

      _navigateToScreen(
        VideoPreviewScreen(
          mediaItem: mediaItem,
          onBackPressed: () => Navigator.pop(context),
          onStartDownload: (selectedOption) => _startActualDownload(mediaItem, selectedOption),
        ),
      );
    } catch (e) {
      if (mounted) Navigator.pop(context); // Close loading dialog

      _navigateToScreen(
        ErrorStateScreen(
          errorMessage: 'Unable to fetch video details. Please ensure link is public.\n($e)',
          onRetry: () {
            Navigator.pop(context);
            _handleSearchVideo(url);
          },
          onBackPressed: () => Navigator.pop(context),
        ),
      );
    }
  }

  Future<void> _startActualDownload(MediaItem mediaItem, MediaOption option) async {
    Navigator.pop(context); // Close preview screen
    FocusScope.of(context).unfocus();

    try {
      await Permission.storage.request();
      await Permission.photos.request();

      const savedDir = '/storage/emulated/0/Download';
      final fileName = 'AnySave_${DateTime.now().millisecondsSinceEpoch}.${option.extension.isNotEmpty ? option.extension : "mp4"}';

      final taskId = await FlutterDownloader.enqueue(
        url: option.url,
        savedDir: savedDir,
        fileName: fileName,
        showNotification: true,
        openFileFromNotification: true,
        saveInPublicStorage: true,
      );

      if (taskId != null) {
        final prefs = await SharedPreferences.getInstance();
        if (mediaItem.thumbnail.isNotEmpty) {
          await prefs.setString('thumb_$taskId', mediaItem.thumbnail);
        }
        await prefs.setBool('history_cleared_permanently', false);
      }

      _navigateToScreen(
        DownloadingScreen(
          taskId: taskId,
          mediaItem: mediaItem,
          selectedOption: option,
          onCancel: () {
            Navigator.pop(context);
            FocusScope.of(context).unfocus();
          },
          onComplete: () {
            Navigator.pop(context); // Close progress
            FocusScope.of(context).unfocus(); // Unfocus keyboard!
            _historyKey.currentState?.loadHistory(); // Real-time sync History tab
            setState(() => _currentIndex = 0); // Return to HOME screen
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Download complete! Saved to gallery.')),
            );
          },
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download failed to start: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(
            onSearchVideo: _handleSearchVideo,
            onSignInTap: () {
              setState(() => _currentIndex = 2);
            },
          ),
          HistoryScreen(
            key: _historyKey,
            onClearHistoryTap: () {
              ClearCacheDialog.show(
                context,
                onConfirm: () {
                  _historyKey.currentState?.clearAllHistory();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('History cleared successfully.')),
                  );
                },
              );
            },
          ),
          SettingsScreen(
            onClearCacheTap: () {
              ClearCacheDialog.show(
                context,
                onConfirm: () {
                  _historyKey.currentState?.clearAllHistory();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cache & history cleared successfully.')),
                  );
                },
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          FocusScope.of(context).unfocus(); // Ensure keyboard is unfocused on tab change
          if (index == 1) {
            _historyKey.currentState?.loadHistory();
          }
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}
