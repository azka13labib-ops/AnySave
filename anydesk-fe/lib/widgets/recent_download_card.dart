import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_constants.dart';

class RecentDownloadCard extends StatelessWidget {
  final String title;
  final String creator;
  final String views;
  final String thumbnailUrl;
  final VoidCallback? onTap;
  final VoidCallback? onShare;

  const RecentDownloadCard({
    super.key,
    required this.title,
    required this.creator,
    required this.views,
    required this.thumbnailUrl,
    this.onTap,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: AppConstants.borderRadiusLarge,
        border: Border.all(
          color: isDark ? AppColors.borderDark : const Color(0xFFE9E7ED),
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        children: [
          // Thumbnail with Play Icon
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceSecondary : AppColors.lightSurfaceSecondary,
                borderRadius: AppConstants.borderRadiusMedium,
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  thumbnailUrl.isNotEmpty
                      ? Image.network(
                          thumbnailUrl,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => _buildFallback(isDark),
                        )
                      : _buildFallback(isDark),
                  Container(
                    color: Colors.black26,
                  ),
                  Icon(
                    Icons.play_circle_fill_rounded,
                    color: isDark ? AppColors.primaryAccent : AppColors.primary,
                    size: 32,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '$creator • $views',
                  style: TextStyle(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Share Action Button
          IconButton(
            onPressed: onShare,
            icon: Icon(
              Icons.share_outlined,
              color: isDark ? AppColors.primaryAccent : AppColors.primary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallback(bool isDark) {
    return Container(
      color: isDark ? AppColors.darkSurfaceSecondary : AppColors.lightSurfaceSecondary,
      child: const Center(
        child: Icon(Icons.movie_outlined, color: Colors.grey, size: 28),
      ),
    );
  }
}
