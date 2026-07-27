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
import 'sign_in_screen.dart';
import 'error_state_screen.dart';

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _currentIndex = 0;
  final ApiService _apiService = ApiService();

  void _navigateToScreen(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  Future<void> _handleSearchVideo(String url) async {
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
      );

      if (taskId != null) {
        final prefs = await SharedPreferences.getInstance();
        if (mediaItem.thumbnail.isNotEmpty) {
          await prefs.setString('thumb_$taskId', mediaItem.thumbnail);
        }
      }

      _navigateToScreen(
        DownloadingScreen(
          onCancel: () => Navigator.pop(context),
          onComplete: () {
            Navigator.pop(context); // Close progress
            setState(() => _currentIndex = 1); // Switch to History
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
            onSignInTap: () => _navigateToScreen(
              SignInScreen(
                onBackPressed: () => Navigator.pop(context),
                onSignInSuccess: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Signed in successfully!')),
                  );
                },
              ),
            ),
          ),
          HistoryScreen(
            onClearHistoryTap: () {
              ClearCacheDialog.show(
                context,
                onConfirm: () {
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
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}
