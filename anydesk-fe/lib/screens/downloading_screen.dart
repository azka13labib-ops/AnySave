import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import '../data/models/media_item.dart';
import '../theme/app_colors.dart';
import '../theme/app_constants.dart';

class DownloadingScreen extends StatefulWidget {
  final String? taskId;
  final MediaItem? mediaItem;
  final MediaOption? selectedOption;
  final VoidCallback onCancel;
  final VoidCallback onComplete;

  const DownloadingScreen({
    super.key,
    this.taskId,
    this.mediaItem,
    this.selectedOption,
    required this.onCancel,
    required this.onComplete,
  });

  @override
  State<DownloadingScreen> createState() => _DownloadingScreenState();
}

class _DownloadingScreenState extends State<DownloadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _spinController;
  Timer? _pollingTimer;
  int _progress = 0;
  String _phaseLabel = 'Mengunduh file...';

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _startProgressPolling();
  }

  void _startProgressPolling() {
    if (widget.taskId == null) return;
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(milliseconds: 500), (_) async {
      try {
        final tasks = await FlutterDownloader.loadTasksWithRawQuery(
          query: "SELECT * FROM task WHERE task_id='${widget.taskId}'",
        );
        if (tasks != null && tasks.isNotEmpty && mounted) {
          final task = tasks.first;
          setState(() {
            _progress = task.progress;
            _phaseLabel = task.status == DownloadTaskStatus.complete
                ? 'Selesai disimpan ke Galeri ✅'
                : 'Mengunduh file...';
          });

          if (task.status == DownloadTaskStatus.complete) {
            _pollingTimer?.cancel();
            widget.onComplete();
          } else if (task.status == DownloadTaskStatus.failed ||
              task.status == DownloadTaskStatus.canceled) {
            _pollingTimer?.cancel();
          }
        }
      } catch (e) {
        debugPrint('Polling download task error: $e');
      }
    });
  }

  @override
  void dispose() {
    _spinController.dispose();
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _handleCancel() async {
    if (widget.taskId != null) {
      try {
        await FlutterDownloader.cancel(taskId: widget.taskId!);
      } catch (_) {}
    }
    widget.onCancel();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryAccent : AppColors.primary;

    final item = widget.mediaItem;
    final option = widget.selectedOption;

    final title = item?.title ?? 'Mengunduh video...';
    final thumbnail = item?.thumbnail.isNotEmpty == true
        ? item!.thumbnail
        : 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=600';
    final qualityLabel = option?.renderTitle ?? '720p HD';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Downloading'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.containerMargin),
          child: Center(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : const Color(0xFFE9E7ED),
                ),
                boxShadow: isDark
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. Thumbnail + animasi berputar
                  SizedBox(
                    height: 160,
                    width: double.infinity,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            thumbnail,
                            width: double.infinity,
                            height: 160,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: isDark ? AppColors.darkSurfaceSecondary : AppColors.lightSurfaceSecondary,
                              child: const Icon(Icons.movie_outlined, size: 48, color: Colors.grey),
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black38,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        RotationTransition(
                          turns: _spinController,
                          child: const Icon(
                            Icons.sync_rounded,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 2. Judul + progress
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                color: isDark ? Colors.white : AppColors.textPrimaryLight,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Kualitas: $qualityLabel',
                              style: TextStyle(
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$_progress%',
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: _progress / 100.0,
                      minHeight: 8,
                      backgroundColor: isDark ? AppColors.darkSurfaceSecondary : const Color(0xFFE3E2E7),
                      color: primaryColor,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _phaseLabel,
                        style: TextStyle(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '$_progress%',
                        style: TextStyle(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Tombol cancel
                  OutlinedButton.icon(
                    onPressed: _handleCancel,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    icon: const Icon(Icons.close_rounded, size: 20),
                    label: const Text(
                      'Batal',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
