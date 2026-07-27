import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_constants.dart';

class PlatformToggle extends StatelessWidget {
  final String selectedPlatform; // 'tiktok' or 'instagram'
  final ValueChanged<String> onPlatformChanged;

  const PlatformToggle({
    super.key,
    required this.selectedPlatform,
    required this.onPlatformChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isTikTok = selectedPlatform == 'tiktok';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceSecondary : AppColors.lightSurfaceSecondary,
        borderRadius: AppConstants.borderRadiusFull,
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: AppConstants.animFast,
            curve: Curves.easeInOut,
            alignment: isTikTok ? Alignment.centerLeft : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: AppConstants.borderRadiusFull,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => onPlatformChanged('tiktok'),
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.music_note_rounded,
                          size: 18,
                          color: isTikTok
                              ? (isDark ? Colors.white : AppColors.textPrimaryLight)
                              : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'TikTok',
                          style: TextStyle(
                            color: isTikTok
                                ? (isDark ? Colors.white : AppColors.textPrimaryLight)
                                : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                            fontWeight: isTikTok ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => onPlatformChanged('instagram'),
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt_outlined,
                          size: 18,
                          color: !isTikTok
                              ? (isDark ? Colors.white : AppColors.textPrimaryLight)
                              : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Instagram',
                          style: TextStyle(
                            color: !isTikTok
                                ? (isDark ? Colors.white : AppColors.textPrimaryLight)
                                : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                            fontWeight: !isTikTok ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
