import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_constants.dart';

class ErrorStateScreen extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;
  final VoidCallback onBackPressed;

  const ErrorStateScreen({
    super.key,
    this.errorMessage = 'Video Not Found or Link Expired',
    required this.onRetry,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: onBackPressed,
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        ),
        title: const Text('Download Error'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.containerMargin),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  size: 72,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Unable to Fetch Video',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondaryDark,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.darkSurface,
                  borderRadius: AppConstants.borderRadiusMedium,
                  border: Border.all(color: AppColors.borderDark),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lightbulb_outline, color: AppColors.primaryAccent, size: 18),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Ensure the post is public and the link is copied directly from the official app.',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.sectionGap),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: const Text('Try Again'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: onBackPressed,
                child: const Text(
                  'Back to Home',
                  style: TextStyle(color: AppColors.textSecondaryDark),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
