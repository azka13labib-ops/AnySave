import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_constants.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onClearCacheTap;

  const SettingsScreen({
    super.key,
    required this.onClearCacheTap,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _autoDeleteEnabled = true;
  String _defaultQuality = 'Highest (1080p)';
  final String _downloadLocation = 'Photos';
  String _appearance = 'System Default';
  String _language = 'English';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.containerMargin),
          children: [
            // 1. Account Section Card (Guest User)
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : const Color(0xFFE9E7ED),
                ),
              ),
              child: ListTile(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Opening Sign In screen...')),
                  );
                },
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceSecondary : AppColors.lightSurfaceSecondary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_outline_rounded,
                    color: isDark ? AppColors.primaryAccent : AppColors.primary,
                  ),
                ),
                title: Text(
                  'Guest User',
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  'Sign in to sync history',
                  style: TextStyle(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    fontSize: 13,
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
            ),

            const SizedBox(height: AppConstants.sectionGap),

            // 2. DOWNLOADS SECTION
            _buildSectionHeader('DOWNLOADS', isDark),
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : const Color(0xFFE9E7ED),
                ),
              ),
              child: Column(
                children: [
                  _buildRowTile(
                    isDark: isDark,
                    icon: Icons.high_quality_outlined,
                    title: 'Default Quality',
                    value: _defaultQuality,
                    onTap: _showQualityPicker,
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildRowTile(
                    isDark: isDark,
                    icon: Icons.folder_outlined,
                    title: 'Save Location',
                    value: _downloadLocation,
                    onTap: _showLocationPicker,
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildSwitchTile(
                    isDark: isDark,
                    icon: Icons.auto_delete_outlined,
                    title: 'Auto-delete after 30 days',
                    value: _autoDeleteEnabled,
                    onChanged: (val) => setState(() => _autoDeleteEnabled = val),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.sectionGap),

            // 3. PREFERENCES SECTION
            _buildSectionHeader('PREFERENCES', isDark),
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : const Color(0xFFE9E7ED),
                ),
              ),
              child: Column(
                children: [
                  _buildRowTile(
                    isDark: isDark,
                    icon: Icons.palette_outlined,
                    title: 'Appearance',
                    value: _appearance,
                    onTap: _showAppearancePicker,
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildRowTile(
                    isDark: isDark,
                    icon: Icons.language_outlined,
                    title: 'Language',
                    value: _language,
                    onTap: () {},
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildSwitchTile(
                    isDark: isDark,
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    value: _notificationsEnabled,
                    onChanged: (val) => setState(() => _notificationsEnabled = val),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.sectionGap),

            // 4. STORAGE & ABOUT
            _buildSectionHeader('STORAGE & ABOUT', isDark),
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : const Color(0xFFE9E7ED),
                ),
              ),
              child: Column(
                children: [
                  ListTile(
                    onTap: widget.onClearCacheTap,
                    leading: const Icon(Icons.cleaning_services_rounded, color: AppColors.error),
                    title: const Text(
                      'Clear Cache & History',
                      style: TextStyle(color: AppColors.error, fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.error),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    onTap: _showAboutModal,
                    leading: Icon(Icons.info_outline_rounded, color: isDark ? Colors.white : AppColors.primary),
                    title: Text(
                      'About AnySave',
                      style: TextStyle(
                        color: isDark ? Colors.white : AppColors.textPrimaryLight,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: Icon(
                      Icons.chevron_right_rounded,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildRowTile({
    required bool isDark,
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        color: isDark ? AppColors.primaryAccent : AppColors.primary,
        size: 22,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white : AppColors.textPrimaryLight,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.chevron_right_rounded,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required bool isDark,
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDark ? AppColors.primaryAccent : AppColors.primary,
        size: 22,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white : AppColors.textPrimaryLight,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: Switch(
        value: value,
        activeColor: isDark ? AppColors.primaryAccent : AppColors.primary,
        onChanged: onChanged,
      ),
    );
  }

  void _showLocationPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkSurfaceContainer
          : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Save Location',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Photos / Gallery'),
              subtitle: const Text('/storage/emulated/0/DCIM/AnySave'),
              leading: const Icon(Icons.photo_library_outlined, color: AppColors.primary),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showQualityPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkSurfaceContainer
          : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Default Quality',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            ...['Highest (1080p)', 'Standard (720p)', 'Low (480p)'].map(
              (q) => ListTile(
                title: Text(q),
                leading: Radio<String>(
                  value: q,
                  groupValue: _defaultQuality,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _defaultQuality = val);
                      Navigator.pop(context);
                    }
                  },
                ),
                onTap: () {
                  setState(() => _defaultQuality = q);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAppearancePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkSurfaceContainer
          : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Appearance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            ...['Light Mode', 'Dark Mode', 'System Default'].map(
              (mode) => ListTile(
                title: Text(mode),
                leading: Radio<String>(
                  value: mode,
                  groupValue: _appearance,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _appearance = val);
                      Navigator.pop(context);
                    }
                  },
                ),
                onTap: () {
                  setState(() => _appearance = mode);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkSurfaceContainer
          : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.download_for_offline, color: Colors.white, size: 36),
            ),
            const SizedBox(height: 16),
            const Text(
              'AnySave',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            const Text(
              'Proprietary Video & Audio Downloader',
              style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            const Text(
              'AnySave is a high-speed media downloading suite engineered for smooth video downloads from TikTok and Instagram directly to your mobile gallery.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondaryLight, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Got It'),
            ),
          ],
        ),
      ),
    );
  }
}
