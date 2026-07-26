import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 22,
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
              color: const Color(0xFF1C1C1E),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  height: 56,
                  width: 56,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.download_rounded,
                    color: theme.colorScheme.primary,
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
                        fontWeight: FontWeight.w700,
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
          
          // General Section
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'GENERAL',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
          ),
          _buildSettingsTile(
            icon: Icons.folder_outlined,
            title: 'Download Location',
            subtitle: '/storage/emulated/0/Download',
            onTap: () {},
          ),
          const SizedBox(height: 8),
          _buildSettingsTile(
            icon: Icons.high_quality_outlined,
            title: 'Default Quality',
            subtitle: 'Highest Available',
            onTap: () {},
          ),
          const SizedBox(height: 8),
          _buildSettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Show download progress',
            onTap: () {},
          ),
          
          const SizedBox(height: 24),
          
          // Data Section
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'DATA',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
          ),
          _buildSettingsTile(
            icon: Icons.delete_outline,
            title: 'Clear Download History',
            subtitle: 'Remove all download records',
            onTap: () async {
              await FlutterDownloader.cancelAll();
            },
            isDestructive: true,
          ),
          
          const SizedBox(height: 24),
          
          // About Section
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'ABOUT',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
          ),
          _buildSettingsTile(
            icon: Icons.info_outline,
            title: 'About AnySave',
            subtitle: 'Open-source video downloader',
            onTap: () {},
          ),
          const SizedBox(height: 8),
          _buildSettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            subtitle: 'How we handle your data',
            onTap: () {},
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
    bool isDestructive = false,
  }) {
    return Material(
      color: const Color(0xFF1C1C1E),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
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
