import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_constants.dart';

class StorageBanner extends StatelessWidget {
  final VoidCallback onEnableAccess;

  const StorageBanner({
    super.key,
    required this.onEnableAccess,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.stackGap),
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.primary.withValues(alpha: 0.12)
            : AppColors.primary.withValues(alpha: 0.05),
        borderRadius: AppConstants.borderRadiusMedium,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.folder_open_rounded,
                  color: isDark ? AppColors.primaryAccent : AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Storage Access Needed',
                      style: TextStyle(
                        color: isDark ? Colors.white : AppColors.textPrimaryLight,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Enable storage access to save downloaded videos directly to your gallery.',
                      style: TextStyle(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: onEnableAccess,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? AppColors.primaryAccent : AppColors.primary,
                foregroundColor: isDark ? AppColors.darkBackground : Colors.white,
                minimumSize: const Size(0, 36),
                padding: const EdgeInsets.symmetric(horizontal: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: AppConstants.borderRadiusFull,
                ),
                elevation: 0,
              ),
              child: const Text(
                'Enable Access',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
