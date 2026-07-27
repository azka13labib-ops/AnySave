import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_constants.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceContainer : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderDark : const Color(0xFFE3E2E7),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(context, 0, Icons.home_rounded, 'Home'),
          _buildNavItem(context, 1, Icons.history_rounded, 'History'),
          _buildNavItem(context, 2, Icons.settings_rounded, 'Settings'),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, IconData icon, String label) {
    final isSelected = currentIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final activeColor = isDark ? AppColors.primaryAccent : AppColors.primary;
    final activeBgColor = isDark
        ? AppColors.primaryAccent
        : AppColors.primary.withValues(alpha: 0.1);
    final activeIconColor = isDark ? AppColors.darkBackground : AppColors.primary;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: AppConstants.animFast,
            width: 56,
            height: 32,
            decoration: BoxDecoration(
              color: isSelected ? activeBgColor : Colors.transparent,
              borderRadius: AppConstants.borderRadiusFull,
            ),
            child: Icon(
              icon,
              size: 22,
              color: isSelected
                  ? activeIconColor
                  : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? activeColor
                  : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
