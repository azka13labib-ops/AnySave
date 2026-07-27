import 'package:flutter/material.dart';
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

  void _navigateToScreen(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  void _handleSearchVideo(String url) {
    if (url.toLowerCase().contains('error') || url.toLowerCase().contains('invalid')) {
      _navigateToScreen(
        ErrorStateScreen(
          errorMessage: 'The link provided is invalid or the video has been deleted by creator.',
          onRetry: () => Navigator.pop(context),
          onBackPressed: () => Navigator.pop(context),
        ),
      );
    } else {
      _navigateToScreen(
        VideoPreviewScreen(
          onBackPressed: () => Navigator.pop(context),
          onStartDownload: () {
            Navigator.pop(context); // Close preview
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
          },
        ),
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
