import 'package:flutter/material.dart';
import '../data/models/media_item.dart';
import '../theme/app_colors.dart';
import '../theme/app_constants.dart';

class VideoPreviewScreen extends StatefulWidget {
  final MediaItem? mediaItem;
  final Function(MediaOption selectedOption) onStartDownload;
  final VoidCallback onBackPressed;

  const VideoPreviewScreen({
    super.key,
    this.mediaItem,
    required this.onStartDownload,
    required this.onBackPressed,
  });

  @override
  State<VideoPreviewScreen> createState() => _VideoPreviewScreenState();
}

class _VideoPreviewScreenState extends State<VideoPreviewScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final item = widget.mediaItem;

    final title = item?.title ?? 'Nature Vibes';
    final thumbnail = item?.thumbnail.isNotEmpty == true
        ? item!.thumbnail
        : 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=600';

    final options = (item?.links.isNotEmpty == true)
        ? item!.links
        : [
            MediaOption(
              url: 'https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4',
              quality: '720p',
              extension: 'mp4',
              renderTitle: '720p HD',
            ),
            MediaOption(
              url: 'https://sample-videos.com/video321/mp4/1080/big_buck_bunny_1080p_1mb.mp4',
              quality: '1080p',
              extension: 'mp4',
              renderTitle: '1080p Full HD',
            ),
          ];

    if (_selectedIndex >= options.length) {
      _selectedIndex = 0;
    }

    final selectedOption = options[_selectedIndex];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: widget.onBackPressed,
          icon: Icon(Icons.arrow_back_rounded, color: isDark ? Colors.white : AppColors.primary),
        ),
        title: const Text('Preview'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.containerMargin),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Preview Card Container
                    Container(
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
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Thumbnail with overlay play button
                          SizedBox(
                            height: 220,
                            width: double.infinity,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Image.network(
                                  thumbnail,
                                  width: double.infinity,
                                  height: 220,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    color: isDark ? AppColors.darkSurfaceSecondary : AppColors.lightSurfaceSecondary,
                                    child: const Center(child: Icon(Icons.movie_outlined, size: 48, color: Colors.grey)),
                                  ),
                                ),
                                Container(color: Colors.black26),
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.4),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.play_arrow_rounded,
                                    color: Colors.white,
                                    size: 36,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Metadata Area
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: TextStyle(
                                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    if (item?.uploaderAvatar != null && item!.uploaderAvatar!.isNotEmpty)
                                      CircleAvatar(
                                        radius: 12,
                                        backgroundImage: NetworkImage(item.uploaderAvatar!),
                                      )
                                    else
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.primary,
                                        ),
                                        child: const Icon(Icons.person, size: 16, color: Colors.white),
                                      ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        item?.uploader ?? 'AnySave Downloader',
                                        style: TextStyle(
                                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                          fontSize: 14,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppConstants.sectionGap),

                    // 2. Quality Options Selector
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : const Color(0xFFE9E7ED),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select Download Quality',
                            style: TextStyle(
                              color: isDark ? Colors.white : AppColors.textPrimaryLight,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Column(
                            children: List.generate(options.length, (index) {
                              final opt = options[index];
                              final isSelected = _selectedIndex == index;
                              final label = opt.renderTitle.replaceAll('Download ', '');

                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? (isDark
                                          ? AppColors.primaryAccent.withValues(alpha: 0.15)
                                          : AppColors.primary.withValues(alpha: 0.08))
                                      : (isDark ? AppColors.darkSurfaceSecondary : AppColors.lightSurfaceSecondary),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? (isDark ? AppColors.primaryAccent : AppColors.primary)
                                        : Colors.transparent,
                                  ),
                                ),
                                child: ListTile(
                                  onTap: () => setState(() => _selectedIndex = index),
                                  leading: Icon(
                                    isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                                    color: isSelected
                                        ? (isDark ? AppColors.primaryAccent : AppColors.primary)
                                        : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                                  ),
                                  title: Text(
                                    label,
                                    style: TextStyle(
                                      color: isSelected
                                          ? (isDark ? AppColors.primaryAccent : AppColors.primary)
                                          : (isDark ? Colors.white : AppColors.textPrimaryLight),
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '.${opt.extension.toUpperCase()}',
                                    style: TextStyle(
                                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. Fixed Bottom Action Bar
            Container(
              padding: const EdgeInsets.all(AppConstants.containerMargin),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppColors.borderDark : const Color(0xFFE9E7ED),
                  ),
                ),
              ),
              child: ElevatedButton.icon(
                onPressed: () => widget.onStartDownload(selectedOption),
                icon: const Icon(Icons.download_rounded, size: 20),
                label: Text('Download (${selectedOption.renderTitle.replaceAll('Download ', '').trim()})'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
