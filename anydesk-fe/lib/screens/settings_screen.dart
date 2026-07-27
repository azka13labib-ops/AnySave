import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../theme/app_constants.dart';
import '../providers/app_settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  final VoidCallback onClearCacheTap;

  const SettingsScreen({
    super.key,
    required this.onClearCacheTap,
  });

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _autoDeleteEnabled = false;
  String _defaultQuality = 'Highest (1080p)';
  String _downloadLocation = 'Photos';
  bool _isSignedIn = false;
  String _userName = 'Guest User';
  String _cacheSizeText = 'Calculating...';

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _calculateCacheSize();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('setting_notifications') ?? true;
      _autoDeleteEnabled = prefs.getBool('setting_autodelete') ?? false;
      _defaultQuality = prefs.getString('setting_quality') ?? 'Highest (1080p)';
      _downloadLocation = prefs.getString('setting_location') ?? 'Photos';
      _isSignedIn = prefs.getBool('is_signed_in') ?? false;
      _userName = prefs.getString('user_name') ?? (_isSignedIn ? 'User Account' : 'Guest User');
    });
  }

  Future<void> _saveBoolSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _saveStringSetting(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<void> _calculateCacheSize() async {
    try {
      final tempDir = await getTemporaryDirectory();
      int totalSize = 0;
      if (tempDir.existsSync()) {
        tempDir.listSync(recursive: true, followLinks: false).forEach((entity) {
          if (entity is File) {
            totalSize += entity.lengthSync();
          }
        });
      }
      final sizeInMb = (totalSize / (1024 * 1024)).toStringAsFixed(1);
      if (mounted) {
        setState(() {
          _cacheSizeText = totalSize > 0 ? '$sizeInMb MB' : '0 MB';
        });
      }
    } catch (_) {
      if (mounted) setState(() => _cacheSizeText = '0 MB');
    }
  }

  Future<void> _clearRealCache() async {
    try {
      final tempDir = await getTemporaryDirectory();
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    } catch (_) {}

    widget.onClearCacheTap();
    await _calculateCacheSize();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cache & temporary files cleared successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentLanguage = ref.watch(languageProvider);
    final currentAppearance = _getAppearanceString(ref.watch(themeModeProvider));

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.download_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'AnySave',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: isDark ? AppColors.borderDark : const Color(0xFFE9E7ED),
            height: 1,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.containerMargin),
          children: [
            // Page Title: Settings
            Text(
              AppStrings.tr('settings', currentLanguage),
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimaryLight,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 16),

            // 1. ACCOUNT SECTION
            _buildSectionHeader(AppStrings.tr('account', currentLanguage), isDark),
            _buildGroupCard(
              isDark: isDark,
              children: [
                ListTile(
                  onTap: () {
                    if (_isSignedIn) {
                      _showEditProfileModal();
                    }
                  },
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurfaceSecondary : const Color(0xFFE9ECEF),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isSignedIn ? Icons.person_rounded : Icons.person_outline_rounded,
                      color: _isSignedIn ? AppColors.primary : (isDark ? AppColors.textSecondaryDark : const Color(0xFF8E8E93)),
                      size: 22,
                    ),
                  ),
                  title: Text(
                    _userName,
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.textPrimaryLight,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    _isSignedIn ? 'Account Active (Synced)' : AppStrings.tr('sign_in_sub', currentLanguage),
                    style: TextStyle(
                      color: isDark ? AppColors.textSecondaryDark : const Color(0xFF8E8E93),
                      fontSize: 12,
                    ),
                  ),
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    color: isDark ? AppColors.textSecondaryDark : const Color(0xFFC7C7CC),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 2. DOWNLOADS SECTION
            _buildSectionHeader(AppStrings.tr('downloads', currentLanguage), isDark),
            _buildGroupCard(
              isDark: isDark,
              children: [
                _buildRowTile(
                  isDark: isDark,
                  iconWidget: _buildIconBox(Icons.high_quality_outlined, AppColors.primary, isDark),
                  title: AppStrings.tr('default_quality', currentLanguage),
                  value: _defaultQuality,
                  onTap: _showQualityPicker,
                ),
                _buildDivider(isDark),
                _buildRowTile(
                  isDark: isDark,
                  iconWidget: _buildIconBox(Icons.folder_outlined, AppColors.primary, isDark),
                  title: AppStrings.tr('save_location', currentLanguage),
                  value: _downloadLocation,
                  onTap: _showLocationPicker,
                ),
                _buildDivider(isDark),
                _buildSwitchTile(
                  isDark: isDark,
                  iconWidget: _buildIconBox(Icons.auto_delete_outlined, AppColors.primary, isDark),
                  title: AppStrings.tr('auto_delete', currentLanguage),
                  value: _autoDeleteEnabled,
                  onChanged: (val) {
                    setState(() => _autoDeleteEnabled = val);
                    _saveBoolSetting('setting_autodelete', val);
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 3. PREFERENCES SECTION
            _buildSectionHeader(AppStrings.tr('preferences', currentLanguage), isDark),
            _buildGroupCard(
              isDark: isDark,
              children: [
                _buildRowTile(
                  isDark: isDark,
                  iconWidget: _buildIconBox(Icons.palette_outlined, AppColors.primary, isDark),
                  title: AppStrings.tr('appearance', currentLanguage),
                  value: currentAppearance,
                  onTap: () => _showAppearancePicker(currentAppearance),
                ),
                _buildDivider(isDark),
                _buildRowTile(
                  isDark: isDark,
                  iconWidget: _buildIconBox(Icons.language_outlined, AppColors.primary, isDark),
                  title: AppStrings.tr('language', currentLanguage),
                  value: currentLanguage,
                  onTap: () => _showLanguagePicker(currentLanguage),
                ),
                _buildDivider(isDark),
                _buildSwitchTile(
                  isDark: isDark,
                  iconWidget: _buildIconBox(Icons.notifications_outlined, AppColors.primary, isDark),
                  title: AppStrings.tr('notifications', currentLanguage),
                  value: _notificationsEnabled,
                  onChanged: (val) {
                    setState(() => _notificationsEnabled = val);
                    _saveBoolSetting('setting_notifications', val);
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 4. STANDALONE CLEAR CACHE BUTTON
            GestureDetector(
              onTap: _clearRealCache,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : const Color(0xFFE9E7ED),
                  ),
                ),
                child: Center(
                  child: Text(
                    '${AppStrings.tr('clear_cache', currentLanguage)} ($_cacheSizeText)',
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 5. ABOUT & LEGAL SECTION
            _buildSectionHeader(AppStrings.tr('about_legal', currentLanguage), isDark),
            _buildGroupCard(
              isDark: isDark,
              children: [
                _buildSimpleLinkTile(
                  isDark: isDark,
                  title: AppStrings.tr('terms_of_service', currentLanguage),
                  onTap: () => _showLegalModal(AppStrings.tr('terms_of_service', currentLanguage), _termsOfServiceText),
                ),
                _buildDivider(isDark),
                _buildSimpleLinkTile(
                  isDark: isDark,
                  title: AppStrings.tr('privacy_policy', currentLanguage),
                  onTap: () => _showLegalModal(AppStrings.tr('privacy_policy', currentLanguage), _privacyPolicyText),
                ),
                _buildDivider(isDark),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  title: Text(
                    AppStrings.tr('version', currentLanguage),
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.textPrimaryLight,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: Text(
                    '1.0.0 (Build 1)',
                    style: TextStyle(
                      color: isDark ? AppColors.textSecondaryDark : const Color(0xFF8E8E93),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _getAppearanceString(ThemeMode mode) {
    if (mode == ThemeMode.dark) return 'Dark Mode';
    if (mode == ThemeMode.light) return 'Light Mode';
    return 'System Default';
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Text(
        title,
        style: TextStyle(
          color: isDark ? AppColors.textSecondaryDark : const Color(0xFF8E8E93),
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildGroupCard({
    required bool isDark,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : const Color(0xFFE9E7ED),
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildIconBox(IconData icon, Color color, bool isDark) {
    return Icon(
      icon,
      color: isDark ? AppColors.primaryAccent : color,
      size: 22,
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: isDark ? AppColors.borderDark : const Color(0xFFE9E7ED),
    );
  }

  Widget _buildRowTile({
    required bool isDark,
    required Widget iconWidget,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      leading: iconWidget,
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white : AppColors.textPrimaryLight,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              color: isDark ? AppColors.textSecondaryDark : const Color(0xFF8E8E93),
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.chevron_right_rounded,
            color: isDark ? AppColors.textSecondaryDark : const Color(0xFFC7C7CC),
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleLinkTile({
    required bool isDark,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white : AppColors.textPrimaryLight,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: isDark ? AppColors.textSecondaryDark : const Color(0xFFC7C7CC),
        size: 20,
      ),
    );
  }

  Widget _buildSwitchTile({
    required bool isDark,
    required Widget iconWidget,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      leading: iconWidget,
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white : AppColors.textPrimaryLight,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Transform.scale(
        scale: 0.85,
        child: CupertinoSwitch(
          value: value,
          activeTrackColor: isDark ? AppColors.primaryAccent : AppColors.primary,
          onChanged: onChanged,
        ),
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
              onTap: () {
                setState(() => _downloadLocation = 'Photos');
                _saveStringSetting('setting_location', 'Photos');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Downloads Folder'),
              subtitle: const Text('/storage/emulated/0/Download'),
              leading: const Icon(Icons.folder_open_outlined, color: AppColors.primary),
              onTap: () {
                setState(() => _downloadLocation = 'Downloads');
                _saveStringSetting('setting_location', 'Downloads');
                Navigator.pop(context);
              },
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
                      _saveStringSetting('setting_quality', val);
                      Navigator.pop(context);
                    }
                  },
                ),
                onTap: () {
                  setState(() => _defaultQuality = q);
                  _saveStringSetting('setting_quality', q);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAppearancePicker(String currentAppearance) {
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
                  groupValue: currentAppearance,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    if (val != null) {
                      ref.read(themeModeProvider.notifier).setTheme(val);
                      Navigator.pop(context);
                    }
                  },
                ),
                onTap: () {
                  ref.read(themeModeProvider.notifier).setTheme(mode);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguagePicker(String currentLanguage) {
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
              'Language',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            ...['English', 'Bahasa Indonesia'].map(
              (lang) => ListTile(
                title: Text(lang),
                leading: Radio<String>(
                  value: lang,
                  groupValue: currentLanguage,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    if (val != null) {
                      ref.read(languageProvider.notifier).setLanguage(val);
                      Navigator.pop(context);
                    }
                  },
                ),
                onTap: () {
                  ref.read(languageProvider.notifier).setLanguage(lang);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLegalModal(String title, String body) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkSurfaceContainer
          : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Text(
                    body,
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmSignOut() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Keluar Akun'),
        content: const Text('Apakah kamu yakin ingin keluar akun? Kamu perlu memasukkan nama lagi saat membuka aplikasi.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              ref.read(authStateProvider.notifier).signOut();
            },
            child: const Text('Keluar', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showEditProfileModal() {
    final TextEditingController nameEditController = TextEditingController(text: _userName);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkSurfaceContainer : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(modalContext).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Edit Profil Pengguna',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(modalContext),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: CircleAvatar(
                radius: 36,
                backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                child: Text(
                  _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'NAMA / USERNAME',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
                color: isDark ? AppColors.textSecondaryDark : const Color(0xFF8E8E93),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: nameEditController,
              textCapitalization: TextCapitalization.words,
              style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimaryLight),
              decoration: const InputDecoration(
                hintText: 'Masukkan nama baru kamu',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final newName = nameEditController.text.trim();
                if (newName.isNotEmpty) {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('user_name', newName);
                  if (mounted) {
                    setState(() => _userName = newName);
                    Navigator.pop(modalContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Nama profil berhasil diperbarui!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              child: const Text('Simpan Perubahan'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                Navigator.pop(modalContext);
                _confirmSignOut();
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                side: const BorderSide(color: AppColors.error),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Keluar Akun', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  static const String _termsOfServiceText = '''
AnySave Terms of Service

1. Acceptance of Terms
By accessing or using AnySave, you agree to be bound by these Terms of Service.

2. Personal Use
AnySave is intended solely for personal, non-commercial media downloading of content you have permission to access.

3. Copyright Compliance
Users are responsible for respecting content creator copyrights and rights of use when saving media files.

4. Disclaimer
AnySave provides download utility services "as is" without warranty of continuous uninterrupted availability.
''';

  static const String _privacyPolicyText = '''
AnySave Privacy Policy

1. Data Collection
AnySave does not collect or sell your personal download history. All media links processed stay localized to your device session.

2. Local Storage
Preferences, settings, and saved thumbnails are stored locally on your mobile device via encrypted Shared Preferences.

3. Third Party Services
No personal user analytics or tracking profiles are uploaded to external tracking servers.
''';
}
