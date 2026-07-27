import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_constants.dart';

class ClearCacheDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const ClearCacheDialog({
    super.key,
    required this.onConfirm,
  });

  static Future<void> show(BuildContext context, {required VoidCallback onConfirm}) {
    return showDialog(
      context: context,
      builder: (context) => ClearCacheDialog(onConfirm: onConfirm),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: AppConstants.borderRadiusLarge,
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.error,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Clear Cache?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
      content: const Text(
        'This will clear temporary files and download history records. Saved media files on your device storage will not be affected.',
        style: TextStyle(
          color: AppColors.textSecondaryDark,
          fontSize: 13.5,
          height: 1.4,
        ),
      ),
      actionsPadding: const EdgeInsets.all(16),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(
              color: AppColors.textSecondaryDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            minimumSize: const Size(100, 42),
            shape: RoundedRectangleBorder(
              borderRadius: AppConstants.borderRadiusMedium,
            ),
            elevation: 0,
          ),
          child: const Text(
            'Clear All',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
