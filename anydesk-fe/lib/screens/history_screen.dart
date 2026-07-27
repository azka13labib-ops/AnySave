import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_constants.dart';

class HistoryScreen extends StatefulWidget {
  final VoidCallback onClearHistoryTap;

  const HistoryScreen({
    super.key,
    required this.onClearHistoryTap,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final List<Map<String, String>> _mockHistory = [
    {
      'title': 'Epic Skate Session V...',
      'platform': 'TikTok',
      'size': '14.2 MB',
      'thumbnail': 'https://images.unsplash.com/photo-1547447134-cd3f5c716030?w=200',
    },
    {
      'title': 'Truffle Pasta Recipe',
      'platform': 'Instagram',
      'size': '28.5 MB',
      'thumbnail': 'https://images.unsplash.com/photo-1551183053-bf91a1d81141?w=200',
    },
    {
      'title': 'Dog Reaction',
      'platform': 'TikTok',
      'size': '5.1 MB',
      'thumbnail': 'https://images.unsplash.com/photo-1543466835-00a7907e9de1?w=200',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'AnySave',
          style: TextStyle(
            color: isDark ? AppColors.primaryAccent : AppColors.primary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
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
        child: _mockHistory.isEmpty
            ? _buildEmptyState(isDark)
            : _buildHistoryContent(isDark),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.containerMargin),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceSecondary : AppColors.lightSurfaceSecondary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.folder_open_rounded,
                size: 64,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Downloads Yet',
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimaryLight,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Videos and audio clips you download will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryContent(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.containerMargin),
      child: Column(
        children: [
          // Section Header Row: Recent Downloads & Clear All
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Downloads',
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() => _mockHistory.clear());
                  widget.onClearHistoryTap();
                },
                child: Text(
                  'Clear All',
                  style: TextStyle(
                    color: isDark ? AppColors.primaryAccent : AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Cards List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _mockHistory.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = _mockHistory[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : const Color(0xFFE9E7ED),
                  ),
                  boxShadow: isDark
                      ? []
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Row(
                  children: [
                    // Thumbnail with play overlay
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurfaceSecondary : AppColors.lightSurfaceSecondary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.network(
                            item['thumbnail']!,
                            width: 72,
                            height: 72,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: isDark ? AppColors.darkSurfaceSecondary : AppColors.lightSurfaceSecondary,
                              child: const Icon(Icons.movie_outlined, color: Colors.grey, size: 28),
                            ),
                          ),
                          Container(color: Colors.black26),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.4),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Info Column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title']!,
                            style: TextStyle(
                              color: isDark ? Colors.white : AppColors.textPrimaryLight,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.darkSurfaceSecondary : const Color(0xFFF2F2F7),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  item['platform']!,
                                  style: TextStyle(
                                    color: isDark ? AppColors.textSecondaryDark : const Color(0xFF666666),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '•  ${item['size']}',
                                style: TextStyle(
                                  color: isDark ? AppColors.textSecondaryDark : const Color(0xFF666666),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Trailing 3 dots action menu
                    IconButton(
                      onPressed: () {
                        _showItemMenu(context, item['title']!);
                      },
                      icon: Icon(
                        Icons.more_vert_rounded,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showItemMenu(BuildContext context, String title) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkSurfaceContainer
          : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.play_circle_outline),
              title: const Text('Play Video'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('Share Video Link'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: const Text('Delete from History', style: TextStyle(color: AppColors.error)),
              onTap: () {
                setState(() {
                  _mockHistory.removeWhere((h) => h['title'] == title);
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
