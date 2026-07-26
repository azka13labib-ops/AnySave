import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import '../providers/downloader_provider.dart';
import '../../utils/download_helper.dart';
import 'history_tab.dart';
import 'settings_tab.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';
import 'dart:isolate';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _urlController = TextEditingController();
  int _currentIndex = 0;

  // Active Download Progress State
  final ReceivePort _port = ReceivePort();
  int _activeProgress = 0;
  DownloadTaskStatus? _activeStatus;
  String? _activeTaskId;
  String? _activeFileName;
  String? _activeQualityLabel;

  // Neon lime green accent
  static const Color _accent = Color(0xFFC8FF00);
  static const Color _bgDark = Color(0xFF0D0D0D);
  static const Color _cardDark = Color(0xFF1C1C1E);

  @pragma('vm:entry-point')
  static void _downloadCallback(String id, int status, int progress) {
    final SendPort? send = IsolateNameServer.lookupPortByName('downloader_send_port');
    send?.send([id, status, progress]);
  }

  @override
  void initState() {
    super.initState();
    IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      int statusVal = data[1];
      int progress = data[2];
      DownloadTaskStatus status = DownloadTaskStatus.values[statusVal];

      if (mounted) {
        setState(() {
          _activeTaskId = id;
          _activeProgress = progress;
          _activeStatus = status;
        });
      }
    });

    FlutterDownloader.registerCallback(_downloadCallback);
  }

  void _fetchMedia() {
    final url = _urlController.text.trim();
    if (url.isNotEmpty) {
      ref.read(downloaderProvider.notifier).fetchMedia(url);
      FocusScope.of(context).unfocus();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please paste a video link first'),
          backgroundColor: _cardDark,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }


  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    _urlController.dispose();
    super.dispose();
  }

  bool _isMoreAppsExpanded = true;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      drawer: _buildDrawer(context),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildLibraryTab(context),
          const DownloadsTab(),
          const SettingsTab(),
        ],
      ),
      bottomNavigationBar: _buildCustomBottomNav(),
    );
  }


  Widget _buildCustomBottomNav() {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.home_rounded, 'Home'),
          _buildNavItem(1, Icons.arrow_circle_down_outlined, 'Downloads'),
          _buildNavItem(2, Icons.settings_outlined, 'Settings'),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 60,
            height: 32,
            decoration: BoxDecoration(
              color: isSelected ? _accent : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 22,
              color: isSelected ? Colors.black : Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? _accent : Colors.grey.shade400,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF141416),
      child: Column(
        children: [
          // Header (Solid Vibrant Neon Lime Green)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 24),
            color: _accent,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ANYSAVE',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'V1.0.0 BETA',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          
          // Drawer Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Item 1: How it Works
                _buildDrawerCardItem(
                  icon: Icons.help_outline_rounded,
                  title: 'How it Works',
                  onTap: () {
                    Navigator.pop(context);
                    _showHowItWorksModal();
                  },
                ),
                const SizedBox(height: 10),

                // Item 2: Storage Settings (Active with Green Border)
                _buildDrawerCardItem(
                  icon: Icons.folder_open_rounded,
                  title: 'Storage Settings',
                  isHighlighted: true,
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _currentIndex = 2);
                  },
                ),
                const SizedBox(height: 10),

                // Item 3: More Apps by Developer (Expandable)
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E20),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            _isMoreAppsExpanded = !_isMoreAppsExpanded;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          child: Row(
                            children: [
                              const Icon(Icons.apps_rounded, color: Colors.white, size: 20),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'More Apps by\nDeveloper',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                              Icon(
                                _isMoreAppsExpanded
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: Colors.white,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_isMoreAppsExpanded) ...[
                        Divider(height: 1, color: Colors.white.withValues(alpha: 0.1)),
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            _showDeveloperAppModal('AZKA TOP UP', 'Gaming voucher & top-up app');
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            child: Row(
                              children: [
                                SizedBox(width: 8),
                                Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 18),
                                SizedBox(width: 12),
                                Text(
                                  'AZKA TOP UP',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Divider(height: 1, color: Colors.white.withValues(alpha: 0.1)),
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            _showDeveloperAppModal('azka_floatee', 'Floating video player utility');
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            child: Row(
                              children: [
                                SizedBox(width: 8),
                                Icon(Icons.widgets_outlined, color: Colors.white, size: 18),
                                SizedBox(width: 12),
                                Text(
                                  'azka_floatee',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom Items (Report an Issue & Privacy Policy)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildDrawerCardItem(
                  icon: Icons.bug_report_outlined,
                  title: 'Report an Issue',
                  textColor: const Color(0xFFFF8A8A),
                  iconColor: const Color(0xFFFF8A8A),
                  onTap: () {
                    Navigator.pop(context);
                    _showReportIssueModal();
                  },
                ),
                const SizedBox(height: 10),
                _buildDrawerCardItem(
                  icon: Icons.shield_outlined,
                  title: 'Privacy Policy',
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _currentIndex = 2); // Go to settings (privacy policy)
                  },
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildDrawerCardItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isHighlighted = false,
    Color? textColor,
    Color? iconColor,
  }) {
    return Material(
      color: const Color(0xFF1E1E20),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: isHighlighted
                ? Border.all(color: _accent, width: 2)
                : Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isHighlighted ? _accent : (iconColor ?? Colors.white),
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: isHighlighted ? _accent : (textColor ?? Colors.white),
                  fontSize: 14,
                  fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHowItWorksModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141416),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.help_outline_rounded, color: _accent, size: 24),
                  SizedBox(width: 12),
                  Text('How it Works', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                ],
              ),
              const SizedBox(height: 20),
              _buildStepItem('1', 'Copy Link', 'Open TikTok, Instagram, or YouTube and copy the video URL.'),
              const SizedBox(height: 12),
              _buildStepItem('2', 'Paste URL', 'Open AnySave and paste the link into the input box or tap a platform filter.'),
              const SizedBox(height: 12),
              _buildStepItem('3', 'Download Video', 'Tap GET VIDEO and select your preferred quality to save directly to storage.'),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Got it!', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStepItem(String step, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(color: _accent, shape: BoxShape.circle),
          child: Center(child: Text(step, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900))),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(desc, style: TextStyle(color: Colors.grey.shade400, fontSize: 13, height: 1.3)),
            ],
          ),
        ),
      ],
    );
  }

  void _showReportIssueModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141416),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.bug_report_outlined, color: Color(0xFFFF8A8A), size: 24),
                  SizedBox(width: 12),
                  Text('Report an Issue', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                ],
              ),
              const SizedBox(height: 12),
              Text('Encountered a bug or download error? Reach out to our developer team directly:', style: TextStyle(color: Colors.grey.shade400, fontSize: 13.5)),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.code, color: _accent, size: 20),
                ),
                title: const Text('GitHub Issue Tracker', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                subtitle: const Text('Submit bug reports & feature requests', style: TextStyle(color: Colors.grey, fontSize: 12)),
                onTap: () async {
                  Navigator.pop(context);
                  final Uri url = Uri.parse('https://github.com/azka13labib-ops/AnySave/issues');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
              ),
              const Divider(color: Colors.white12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.email_outlined, color: _accent, size: 20),
                ),
                title: const Text('Email Developer', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                subtitle: const Text('azka13labib@gmail.com', style: TextStyle(color: Colors.grey, fontSize: 12)),
                onTap: () async {
                  Navigator.pop(context);
                  final Uri emailUri = Uri(
                    scheme: 'mailto',
                    path: 'azka13labib@gmail.com',
                    queryParameters: {'subject': 'AnySave Bug Report'},
                  );
                  if (await canLaunchUrl(emailUri)) {
                    await launchUrl(emailUri);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeveloperAppModal(String appName, String appDesc) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141416),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: _accent.withValues(alpha: 0.15), shape: BoxShape.circle),
                child: const Icon(Icons.apps_rounded, color: _accent, size: 36),
              ),
              const SizedBox(height: 16),
              Text(appName, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              Text(appDesc, style: const TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Close', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  // ──────────────────────────────────────────────
  //  LIBRARY TAB (main home tab)
  // ──────────────────────────────────────────────
  Widget _buildLibraryTab(BuildContext context) {
    final downloaderState = ref.watch(downloaderProvider);

    return SafeArea(
      child: Column(
        children: [
          // Top Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Builder(
                  builder: (scaffoldContext) => GestureDetector(
                    onTap: () {
                      Scaffold.of(scaffoldContext).openDrawer();
                    },
                    child: const Icon(Icons.menu, color: Colors.white, size: 26),
                  ),
                ),

                const Text(
                  'ANYSAVE',
                  style: TextStyle(
                    color: _accent,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _currentIndex = 2),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.settings_outlined, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 32),

                  // ── Hero Section ──
                  const Text(
                    'SAVE IT. KEEP\nIT.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _accent,
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'One link. Any platform. Straight to your\nlocal storage.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── URL Input ──
                  Container(
                    decoration: BoxDecoration(
                      color: _cardDark,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 14),
                          child: Icon(Icons.link, color: Colors.grey.shade500, size: 20),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _urlController,
                            style: const TextStyle(fontSize: 14, color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Paste Video URL Here',
                              hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                            ),
                            onSubmitted: (_) => _fetchMedia(),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        if (_urlController.text.isNotEmpty)
                          GestureDetector(
                            onTap: () => setState(() {
                              _urlController.clear();
                            }),
                            child: Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: Icon(Icons.close, color: Colors.grey.shade500, size: 18),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── GET VIDEO Button ──
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: downloaderState.isLoading ? null : _fetchMedia,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accent,
                        foregroundColor: _bgDark,
                        disabledBackgroundColor: _accent.withValues(alpha: 0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: downloaderState.isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Color(0xFF0D0D0D),
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.download_rounded, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'GET VIDEO',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Social App Logos (YouTube, Instagram, TikTok) ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 1. YouTube Logo
                      _buildSocialAppLogo(
                        targetUrl: 'https://www.youtube.com',
                        platformName: 'YouTube',
                        child: _buildYouTubeBadge(),
                      ),
                      const SizedBox(width: 20),
                      // 2. Instagram Logo
                      _buildSocialAppLogo(
                        targetUrl: 'https://www.instagram.com',
                        platformName: 'Instagram',
                        child: _buildInstagramBadge(),
                      ),
                      const SizedBox(width: 20),
                      // 3. TikTok Logo
                      _buildSocialAppLogo(
                        targetUrl: 'https://www.tiktok.com',
                        platformName: 'TikTok',
                        child: _buildTikTokBadge(),
                      ),
                    ],
                  ),







                  const SizedBox(height: 36),

                  // ── Result Card (when data is loaded) ──
                  downloaderState.when(
                    data: (mediaItem) {
                      if (mediaItem == null) return const SizedBox.shrink();
                      return _buildResultCard(mediaItem);
                    },
                    error: (err, stack) => Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Error: $err',
                              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    loading: () => const SizedBox.shrink(),
                  ),

                  // ── Recent Downloads Section ──
                  _buildRecentDownloadsSection(),

                  const SizedBox(height: 36),

                  // ── Why AnySave Section ──
                  _buildWhySection(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  //  Social App Logo Launcher & Badge Builders
  // ──────────────────────────────────────────────
  Widget _buildSocialAppLogo({
    required Widget child,
    required String targetUrl,
    required String platformName,
  }) {
    return GestureDetector(
      onTap: () async {
        final Uri uri = Uri.parse(targetUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Cannot open $platformName'),
                backgroundColor: _cardDark,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      },
      child: child,
    );
  }

  Widget _buildYouTubeBadge() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFFF0000), // YouTube Red
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 20,
          height: 14,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Center(
            child: Icon(Icons.play_arrow_rounded, color: Color(0xFFFF0000), size: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildInstagramBadge() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const RadialGradient(
          colors: [
            Color(0xFFFFD600),
            Color(0xFFFF7A00),
            Color(0xFFFF0069),
            Color(0xFFD300C5),
            Color(0xFF7638FA),
          ],
          center: Alignment(-0.8, 0.9),
          radius: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF0069).withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Center(
            child: Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.8),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTikTokBadge() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: CustomPaint(
          size: const Size(22, 22),
          painter: TikTokLogoPainter(),
        ),
      ),
    );
  }






  // ──────────────────────────────────────────────
  //  Result Card
  // ──────────────────────────────────────────────
  Widget _buildResultCard(dynamic mediaItem) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Thumbnail
          Stack(
            children: [
              if (mediaItem.thumbnail.isNotEmpty)
                Image.network(
                  mediaItem.thumbnail,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  headers: const {
                    'Referer': 'https://www.tiktok.com/',
                    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
                  },
                  errorBuilder: (context, error, stackTrace) =>
                      Container(height: 200, color: const Color(0xFF111112)),
                )
              else
                Container(
                  height: 200,
                  color: const Color(0xFF111112),
                  child: Center(
                    child: Icon(Icons.videocam_outlined, color: Colors.grey.shade700, size: 48),
                  ),
                ),
              // Gradient overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                ),
              ),
              // Title overlaid
              Positioned(
                bottom: 12,
                left: 14,
                right: 14,
                child: Text(
                  mediaItem.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          // Download buttons
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                ...mediaItem.links.take(5).map<Widget>((link) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final filename = 'AnySave_${DateTime.now().millisecondsSinceEpoch}';
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Starting download ${link.renderTitle}...'),
                              backgroundColor: _cardDark,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                          final taskId = await DownloadHelper.downloadFile(
                            link.url,
                            filename,
                            thumbnailUrl: mediaItem.thumbnail,
                          );
                          if (taskId != null && mounted) {
                            setState(() {
                              _activeTaskId = taskId;
                              _activeFileName = '$filename.mp4';
                              _activeQualityLabel = link.renderTitle;
                              _activeProgress = 0;
                              _activeStatus = DownloadTaskStatus.running;
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accent,
                          foregroundColor: _bgDark,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.download_rounded, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              link.renderTitle,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveDownloadCard() {
    if (_activeTaskId == null || _activeStatus == null) {
      return const SizedBox.shrink();
    }
    final isComplete = _activeStatus == DownloadTaskStatus.complete;
    final isFailed = _activeStatus == DownloadTaskStatus.failed;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isComplete ? _accent : (isFailed ? Colors.redAccent : _accent.withValues(alpha: 0.6)),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isComplete ? _accent : (isFailed ? Colors.redAccent : _accent)).withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      isComplete
                          ? Icons.check_circle_rounded
                          : isFailed
                              ? Icons.error_outline_rounded
                              : Icons.downloading_rounded,
                      color: isComplete ? _accent : (isFailed ? Colors.redAccent : _accent),
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isComplete ? 'Download Complete!' : (isFailed ? 'Download Failed' : 'Downloading Media...'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          if (_activeQualityLabel != null)
                            Text(
                              _activeQualityLabel!,
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          if (_activeFileName != null)
                            Text(
                              _activeFileName!,
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                isComplete ? '100%' : '$_activeProgress%',
                style: TextStyle(
                  color: isComplete ? _accent : (isFailed ? Colors.redAccent : _accent),
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: isComplete ? 1.0 : (_activeProgress > 0 ? _activeProgress / 100 : null),
              backgroundColor: Colors.white10,
              color: isFailed ? Colors.redAccent : _accent,
              minHeight: 8,
            ),
          ),
          if (isComplete) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (_activeTaskId != null) {
                    FlutterDownloader.open(taskId: _activeTaskId!);
                  }
                },
                icon: const Icon(Icons.play_arrow_rounded, size: 20),
                label: const Text('Play Downloaded Video', style: TextStyle(fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  foregroundColor: _bgDark,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  //  Recent Downloads Section
  // ──────────────────────────────────────────────
  Widget _buildRecentDownloadsSection() {
    return FutureBuilder<List<DownloadTask>?>(
      future: FlutterDownloader.loadTasks(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }
        final tasks = snapshot.data?.reversed.toList() ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildActiveDownloadCard(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Downloads',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _currentIndex = 1),
                  child: const Text(
                    'View All >>',
                    style: TextStyle(
                      color: _accent,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (tasks.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _cardDark,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.download_rounded, color: Colors.grey.shade700, size: 36),
                      const SizedBox(height: 10),
                      const Text(
                        'No downloads yet',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...tasks.take(4).map((task) => _buildRecentDownloadCard(task)),
          ],
        );
      },
    );
  }

  Widget _buildRecentDownloadCard(DownloadTask task) {
    return RecentDownloadCardWidget(
      task: task,
      accent: _accent,
      cardDark: _cardDark,
    );
  }


  // ──────────────────────────────────────────────
  //  Why AnySave Section (1:1 Screenshot Match)
  // ──────────────────────────────────────────────
  Widget _buildWhySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Why AnySave?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 16),
        
        // Card 1: LIGHTNING FAST (Dark card with Neon Green Icon & Lightning Watermark)
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E20),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Background Watermark Lightning Bolt
              Positioned(
                right: -15,
                bottom: -20,
                child: Icon(
                  Icons.bolt,
                  size: 160,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Speedometer Badge
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: _accent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.speed_rounded,
                          color: Colors.black,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'LIGHTNING FAST',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Our servers bypass traditional throttles to deliver your media in seconds, not minutes. Built for pure performance.',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 13.5,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Card 2: 4K READY (Cyan Card with Centered HQ Badge)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: const Color(0xFF75F3FF), // Vibrant cyan blue
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF75F3FF).withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // HQ Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'HQ',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                '4K READY',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Lossless extraction for maximum fidelity.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF0F4C5C), // Dark cyan text
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

}

// ──────────────────────────────────────────────
//  Custom Painter for Official TikTok Play Store Logo
// ──────────────────────────────────────────────
class TikTokLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double scale = size.width / 100;

    Path createPath() {
      final path = Path();
      path.moveTo(56 * scale, 18 * scale);
      path.cubicTo(
        60 * scale, 30 * scale,
        70 * scale, 38 * scale,
        82 * scale, 40 * scale,
      );
      path.lineTo(82 * scale, 52 * scale);
      path.cubicTo(
        72 * scale, 50 * scale,
        64 * scale, 44 * scale,
        58 * scale, 36 * scale,
      );
      path.lineTo(58 * scale, 65 * scale);
      path.cubicTo(
        58 * scale, 76 * scale,
        48 * scale, 84 * scale,
        36 * scale, 84 * scale,
      );
      path.cubicTo(
        24 * scale, 84 * scale,
        14 * scale, 74 * scale,
        14 * scale, 62 * scale,
      );
      path.cubicTo(
        14 * scale, 50 * scale,
        24 * scale, 40 * scale,
        36 * scale, 40 * scale,
      );
      path.lineTo(36 * scale, 52 * scale);
      path.cubicTo(
        30 * scale, 52 * scale,
        25 * scale, 57 * scale,
        25 * scale, 62 * scale,
      );
      path.cubicTo(
        25 * scale, 67 * scale,
        30 * scale, 72 * scale,
        36 * scale, 72 * scale,
      );
      path.cubicTo(
        42 * scale, 72 * scale,
        47 * scale, 67 * scale,
        47 * scale, 62 * scale,
      );
      path.lineTo(47 * scale, 18 * scale);
      path.close();
      return path;
    }

    final path = createPath();

    // 1. Cyan offset (left)
    canvas.save();
    canvas.translate(-2.5 * scale, -2.5 * scale);
    canvas.drawPath(path, Paint()..color = const Color(0xFF25F4EE));
    canvas.restore();

    // 2. Magenta offset (right)
    canvas.save();
    canvas.translate(2.5 * scale, 2.5 * scale);
    canvas.drawPath(path, Paint()..color = const Color(0xFFFE2C55));
    canvas.restore();

    // 3. Main white note (center)
    canvas.drawPath(path, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ──────────────────────────────────────────────
//  Recent Download Card Widget with Dynamic Thumbnail
// ──────────────────────────────────────────────
class RecentDownloadCardWidget extends StatefulWidget {
  final DownloadTask task;
  final Color accent;
  final Color cardDark;

  const RecentDownloadCardWidget({
    super.key,
    required this.task,
    required this.accent,
    required this.cardDark,
  });

  @override
  State<RecentDownloadCardWidget> createState() => _RecentDownloadCardWidgetState();
}

class _RecentDownloadCardWidgetState extends State<RecentDownloadCardWidget> {
  String? _thumbnailUrl;

  @override
  void initState() {
    super.initState();
    _loadThumbnail();
  }

  Future<void> _loadThumbnail() async {
    if (widget.task.filename != null) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final thumb = prefs.getString('thumb_${widget.task.filename}');
        if (thumb != null && thumb.isNotEmpty && mounted) {
          setState(() {
            _thumbnailUrl = thumb;
          });
        }
      } catch (e) {
        debugPrint('Error loading thumbnail: $e');
      }
    }
  }

  void _handleCardTap() async {
    final isComplete = widget.task.status == DownloadTaskStatus.complete;
    final isRunning = widget.task.status == DownloadTaskStatus.running;

    if (isComplete) {
      final success = await FlutterDownloader.open(taskId: widget.task.taskId);
      if (!success && mounted) {
        // Fallback info modal
        showModalBottomSheet(
          context: context,
          backgroundColor: widget.cardDark,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) => Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.video_library_rounded, color: widget.accent, size: 48),
                const SizedBox(height: 14),
                Text(
                  widget.task.filename ?? 'Downloaded Video',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  'Saved in: ${widget.task.savedDir}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      FlutterDownloader.open(taskId: widget.task.taskId);
                    },
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Play Video'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.accent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } else if (isRunning) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Download is still in progress...'),
          backgroundColor: widget.cardDark,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isComplete = widget.task.status == DownloadTaskStatus.complete;
    final isRunning = widget.task.status == DownloadTaskStatus.running;

    return GestureDetector(
      onTap: _handleCardTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: widget.cardDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isComplete ? widget.accent.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.04),
          ),
        ),
        child: Row(
          children: [
            // Thumbnail Container with Dynamic Image / Fallback
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF111112),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isComplete ? widget.accent.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.08),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_thumbnailUrl != null && _thumbnailUrl!.isNotEmpty)
                    Image.network(
                      _thumbnailUrl!,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildFallbackThumbnail(isComplete),
                    )
                  else
                    _buildFallbackThumbnail(isComplete),
                  // Dark overlay for contrast
                  if (_thumbnailUrl != null)
                    Container(color: Colors.black.withValues(alpha: 0.3)),
                  // Play Icon Overlay
                  Icon(
                    isComplete ? Icons.play_circle_fill_rounded : Icons.movie_outlined,
                    color: isComplete ? widget.accent : Colors.grey.shade600,
                    size: 30,
                  ),
                  if (isRunning)
                    SizedBox(
                      width: 44,
                      height: 44,
                      child: CircularProgressIndicator(
                        value: widget.task.progress > 0 ? widget.task.progress / 100 : null,
                        strokeWidth: 3,
                        color: widget.accent,
                        backgroundColor: Colors.white10,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.task.filename ?? 'Video Download',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: isComplete
                              ? widget.accent.withValues(alpha: 0.15)
                              : isRunning
                                  ? Colors.blueAccent.withValues(alpha: 0.15)
                                  : Colors.red.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isComplete
                                  ? Icons.check_circle
                                  : isRunning
                                      ? Icons.downloading
                                      : Icons.error_outline,
                              size: 10,
                              color: isComplete ? widget.accent : (isRunning ? Colors.blueAccent : Colors.redAccent),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              isComplete ? 'COMPLETED' : (isRunning ? 'DOWNLOADING' : 'FAILED'),
                              style: TextStyle(
                                color: isComplete ? widget.accent : (isRunning ? Colors.blueAccent : Colors.redAccent),
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isRunning) ...[
                        const SizedBox(width: 8),
                        Text(
                          '${widget.task.progress}%',
                          style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isComplete ? widget.accent.withValues(alpha: 0.1) : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isComplete ? Icons.play_arrow_rounded : Icons.more_vert,
                color: isComplete ? widget.accent : Colors.grey.shade600,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackThumbnail(bool isComplete) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2C2C2E), Color(0xFF111112)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}


