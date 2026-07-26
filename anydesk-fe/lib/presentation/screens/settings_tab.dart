import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  String _downloadLocation = '/storage/emulated/0/Download';
  String _defaultQuality = 'Highest Available';
  bool _notificationsEnabled = true;
  bool _isLoading = true;

  static const Color _accent = Color(0xFFC8FF00);
  static const Color _cardDark = Color(0xFF1C1C1E);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _downloadLocation = prefs.getString('download_location') ?? '/storage/emulated/0/Download';
      _defaultQuality = prefs.getString('default_quality') ?? 'Highest Available';
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _isLoading = false;
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is String) {
      await prefs.setString(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: isError ? Colors.redAccent : _cardDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ──────────────────────────────────────────────
  //  1. DOWNLOAD LOCATION DIALOG
  // ──────────────────────────────────────────────
  void _openLocationDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141416),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.folder_outlined, color: _accent, size: 24),
                      const SizedBox(width: 12),
                      const Text(
                        'Download Location',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  RadioListTile<String>(
                    activeColor: _accent,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Public Downloads Directory', style: TextStyle(color: Colors.white, fontSize: 15)),
                    subtitle: const Text('/storage/emulated/0/Download', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    value: '/storage/emulated/0/Download',
                    groupValue: _downloadLocation,
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _downloadLocation = val);
                        _saveSetting('download_location', val);
                        Navigator.pop(context);
                        _showSnackBar('Download location set to Public Downloads');
                      }
                    },
                  ),
                  RadioListTile<String>(
                    activeColor: _accent,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('App Private Storage', style: TextStyle(color: Colors.white, fontSize: 15)),
                    subtitle: const Text('Internal App Documents Folder', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    value: 'App Private Storage',
                    groupValue: _downloadLocation,
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _downloadLocation = val);
                        _saveSetting('download_location', val);
                        Navigator.pop(context);
                        _showSnackBar('Download location set to App Private Storage');
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await Permission.storage.request();
                        if (mounted) Navigator.pop(context);
                        _showSnackBar('Storage permissions updated');
                      },
                      icon: const Icon(Icons.security, size: 18, color: _accent),
                      label: const Text('Manage Permissions', style: TextStyle(color: _accent)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: _accent),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ──────────────────────────────────────────────
  //  2. DEFAULT QUALITY DIALOG
  // ──────────────────────────────────────────────
  void _openQualityDialog() {
    final qualities = [
      {'title': 'Highest Available', 'sub': '4K / 1080p (Best video & audio)'},
      {'title': 'Medium Quality', 'sub': '720p / 480p (Balanced size & quality)'},
      {'title': 'Data Saver', 'sub': '360p / 240p (Fastest download)'},
      {'title': 'Audio Only', 'sub': 'MP3 format (Music extraction)'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141416),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.high_quality_outlined, color: _accent, size: 24),
                  SizedBox(width: 12),
                  Text(
                    'Default Quality',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...qualities.map((item) {
                final isSelected = _defaultQuality == item['title'];
                return RadioListTile<String>(
                  activeColor: _accent,
                  contentPadding: EdgeInsets.zero,
                  title: Text(item['title']!, style: TextStyle(color: isSelected ? _accent : Colors.white, fontSize: 15, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500)),
                  subtitle: Text(item['sub']!, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  value: item['title']!,
                  groupValue: _defaultQuality,
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _defaultQuality = val);
                      _saveSetting('default_quality', val);
                      Navigator.pop(context);
                      _showSnackBar('Default quality set to "$val"');
                    }
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  // ──────────────────────────────────────────────
  //  3. NOTIFICATIONS TOGGLE
  // ──────────────────────────────────────────────
  void _toggleNotifications() async {
    if (!_notificationsEnabled) {
      final status = await Permission.notification.request();
      if (!status.isGranted) {
        _showSnackBar('Notification permission is denied in phone settings', isError: true);
        return;
      }
    }
    final newValue = !_notificationsEnabled;
    setState(() => _notificationsEnabled = newValue);
    _saveSetting('notifications_enabled', newValue);
    _showSnackBar(newValue ? 'Download progress notifications enabled' : 'Notifications disabled');
  }

  // ──────────────────────────────────────────────
  //  4. CLEAR DOWNLOAD HISTORY DIALOG
  // ──────────────────────────────────────────────
  void _confirmClearHistory() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: _cardDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.delete_outline, color: Colors.redAccent, size: 24),
              SizedBox(width: 10),
              Text('Clear History?', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
            ],
          ),
          content: const Text(
            'This will clear all download progress records. Video files saved on your storage will not be deleted.',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await FlutterDownloader.cancelAll();
                } catch (_) {}
                _showSnackBar('Download history successfully cleared!');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Clear All'),
            ),
          ],
        );
      },
    );
  }

  // ──────────────────────────────────────────────
  //  5. ABOUT ANY SAVE MODAL
  // ──────────────────────────────────────────────
  void _showAboutModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141416),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 64,
                width: 64,
                decoration: BoxDecoration(
                  color: _accent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Icon(Icons.download_rounded, color: Colors.black, size: 36),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'AnySave',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1),
              ),
              const SizedBox(height: 4),
              const Text(
                'Version 1.0.0 (Build 1)',
                style: TextStyle(color: _accent, fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              Text(
                'AnySave is an open-source, lightning-fast media downloader. Paste video links from TikTok, Instagram, YouTube, and more to save them directly to your device storage in high quality.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade400, fontSize: 13.5, height: 1.4),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final Uri url = Uri.parse('https://github.com/azka13labib-ops/AnySave');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    }
                  },
                  icon: const Icon(Icons.code, size: 18, color: Colors.black),
                  label: const Text('GitHub Repository', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ──────────────────────────────────────────────
  //  6. PRIVACY POLICY MODAL
  // ──────────────────────────────────────────────
  void _showPrivacyPolicyModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF141416),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.85,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: ListView(
                controller: scrollController,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.privacy_tip_outlined, color: _accent, size: 24),
                      SizedBox(width: 12),
                      Text(
                        'Privacy Policy',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildPrivacyItem(
                    icon: Icons.no_accounts_outlined,
                    title: '1. No User Accounts Required',
                    description: 'AnySave operates completely anonymously. You do not need to register, log in, or provide any personal information.',
                  ),
                  const SizedBox(height: 14),
                  _buildPrivacyItem(
                    icon: Icons.sd_storage_outlined,
                    title: '2. Local Media Storage',
                    description: 'All extracted videos and photos are downloaded directly to your phone storage. We do not store your media history on external cloud servers.',
                  ),
                  const SizedBox(height: 14),
                  _buildPrivacyItem(
                    icon: Icons.security_outlined,
                    title: '3. Zero Tracking & Analytics',
                    description: 'AnySave does not use third-party ad trackers or sell user data. Your download activities stay private to your device.',
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _cardDark,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('I Understand'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPrivacyItem({required IconData icon, required String title, required String description}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _accent, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(description, style: TextStyle(color: Colors.grey.shade400, fontSize: 12.5, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  //  BUILD SCREEN
  // ──────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: CircularProgressIndicator(color: _accent)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 22,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // App Info Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _cardDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Row(
              children: [
                Container(
                  height: 56,
                  width: 56,
                  decoration: BoxDecoration(
                    color: _accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.download_rounded,
                    color: _accent,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AnySave',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // GENERAL SECTION
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'GENERAL',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ),
          _buildSettingsTile(
            icon: Icons.folder_outlined,
            title: 'Download Location',
            subtitle: _downloadLocation,
            onTap: _openLocationDialog,
          ),
          const SizedBox(height: 8),
          _buildSettingsTile(
            icon: Icons.high_quality_outlined,
            title: 'Default Quality',
            subtitle: _defaultQuality,
            onTap: _openQualityDialog,
          ),
          const SizedBox(height: 8),
          _buildSettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: _notificationsEnabled ? 'Show download progress' : 'Notifications disabled',
            trailing: Switch(
              value: _notificationsEnabled,
              activeColor: _accent,
              onChanged: (_) => _toggleNotifications(),
            ),
            onTap: _toggleNotifications,
          ),

          const SizedBox(height: 24),

          // DATA SECTION
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'DATA',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ),
          _buildSettingsTile(
            icon: Icons.delete_outline,
            title: 'Clear Download History',
            subtitle: 'Remove all download records',
            onTap: _confirmClearHistory,
            isDestructive: true,
          ),

          const SizedBox(height: 24),

          // ABOUT SECTION
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'ABOUT',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ),
          _buildSettingsTile(
            icon: Icons.info_outline,
            title: 'About AnySave',
            subtitle: 'Open-source video downloader',
            onTap: _showAboutModal,
          ),
          const SizedBox(height: 8),
          _buildSettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            subtitle: 'How we handle your data',
            onTap: _showPrivacyPolicyModal,
          ),

          const SizedBox(height: 40),

          // Footer
          const Center(
            child: Text(
              'Made with ❤️ by AnySave Team',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
    bool isDestructive = false,
  }) {
    return Material(
      color: _cardDark,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isDestructive ? Colors.redAccent : Colors.white70,
                size: 22,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: isDestructive ? Colors.redAccent : Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              trailing ??
                  Icon(
                    Icons.chevron_right,
                    color: Colors.grey.shade700,
                    size: 20,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
