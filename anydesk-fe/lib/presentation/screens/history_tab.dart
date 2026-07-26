import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DownloadsTab extends StatefulWidget {
  const DownloadsTab({super.key});

  @override
  State<DownloadsTab> createState() => _DownloadsTabState();
}

class _DownloadsTabState extends State<DownloadsTab> {
  List<DownloadTask>? _tasks;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    try {
      final tasks = await FlutterDownloader.loadTasks();
      setState(() {
        _tasks = tasks?.reversed.toList() ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _tasks = [];
        _isLoading = false;
      });
    }
  }

  String _getStatusText(DownloadTaskStatus status) {
    if (status == DownloadTaskStatus.complete) return 'COMPLETED';
    if (status == DownloadTaskStatus.failed) return 'FAILED';
    if (status == DownloadTaskStatus.running) return 'DOWNLOADING';
    if (status == DownloadTaskStatus.paused) return 'PAUSED';
    if (status == DownloadTaskStatus.canceled) return 'CANCELED';
    return 'PENDING';
  }

  Color _getStatusColor(DownloadTaskStatus status) {
    if (status == DownloadTaskStatus.complete) return const Color(0xFFC8FF00);
    if (status == DownloadTaskStatus.failed) return Colors.redAccent;
    if (status == DownloadTaskStatus.running) return Colors.blueAccent;
    return Colors.grey;
  }

  IconData _getStatusIcon(DownloadTaskStatus status) {
    if (status == DownloadTaskStatus.complete) return Icons.check_circle;
    if (status == DownloadTaskStatus.failed) return Icons.error_outline;
    if (status == DownloadTaskStatus.running) return Icons.downloading;
    return Icons.schedule;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Downloads',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 22),
            onPressed: _loadTasks,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tasks == null || _tasks!.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadTasks,
                  color: const Color(0xFFC8FF00),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _tasks!.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final task = _tasks![index];
                      return DownloadTabItemWidget(
                        task: task,
                        getStatusText: _getStatusText,
                        getStatusColor: _getStatusColor,
                        getStatusIcon: _getStatusIcon,
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1E),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Icon(
              Icons.download_rounded,
              color: Colors.grey.shade600,
              size: 48,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No downloads yet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your downloaded files will appear here',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class DownloadTabItemWidget extends StatefulWidget {
  final DownloadTask task;
  final String Function(DownloadTaskStatus) getStatusText;
  final Color Function(DownloadTaskStatus) getStatusColor;
  final IconData Function(DownloadTaskStatus) getStatusIcon;

  const DownloadTabItemWidget({
    super.key,
    required this.task,
    required this.getStatusText,
    required this.getStatusColor,
    required this.getStatusIcon,
  });

  @override
  State<DownloadTabItemWidget> createState() => _DownloadTabItemWidgetState();
}

class _DownloadTabItemWidgetState extends State<DownloadTabItemWidget> {
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

  @override
  Widget build(BuildContext context) {
    final isComplete = widget.task.status == DownloadTaskStatus.complete;
    final isRunning = widget.task.status == DownloadTaskStatus.running;

    return GestureDetector(
      onTap: () async {
        if (isComplete) {
          final messenger = ScaffoldMessenger.of(context);
          final success = await FlutterDownloader.open(taskId: widget.task.taskId);
          if (!success && mounted) {
            messenger.showSnackBar(
              SnackBar(
                content: Text('Opening ${widget.task.filename}...'),
                backgroundColor: const Color(0xFF1C1C1E),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } else if (isRunning) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Download is still in progress...'),
              backgroundColor: Color(0xFF1C1C1E),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isComplete ? const Color(0xFFC8FF00).withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.05),
          ),
        ),
        child: Row(
          children: [
            // Thumbnail Container with Dynamic Image / Fallback
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF111112),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isComplete ? const Color(0xFFC8FF00).withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.08),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_thumbnailUrl != null && _thumbnailUrl!.isNotEmpty)
                    Image.network(
                      _thumbnailUrl!,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildFallbackThumbnail(),
                    )
                  else
                    _buildFallbackThumbnail(),
                  if (_thumbnailUrl != null)
                    Container(color: Colors.black.withValues(alpha: 0.3)),
                  Icon(
                    isComplete ? Icons.play_circle_fill_rounded : Icons.movie_outlined,
                    color: isComplete ? const Color(0xFFC8FF00) : Colors.grey.shade600,
                    size: 34,
                  ),
                  if (isRunning)
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: CircularProgressIndicator(
                        value: widget.task.progress > 0 ? widget.task.progress / 100 : null,
                        strokeWidth: 3,
                        color: const Color(0xFFC8FF00),
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.task.filename ?? 'Unknown file',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: widget.getStatusColor(widget.task.status).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              widget.getStatusIcon(widget.task.status),
                              size: 12,
                              color: widget.getStatusColor(widget.task.status),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.getStatusText(widget.task.status),
                              style: TextStyle(
                                color: widget.getStatusColor(widget.task.status),
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isRunning) ...[
                        const SizedBox(width: 10),
                        Text(
                          '${widget.task.progress}%',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Action icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isComplete ? const Color(0xFFC8FF00).withValues(alpha: 0.1) : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isComplete ? Icons.play_arrow_rounded : Icons.more_vert,
                color: isComplete ? const Color(0xFFC8FF00) : Colors.grey.shade600,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackThumbnail() {
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

