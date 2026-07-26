import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

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
                      return _buildDownloadCard(task);
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

  Widget _buildDownloadCard(DownloadTask task) {
    final isComplete = task.status == DownloadTaskStatus.complete;
    final isRunning = task.status == DownloadTaskStatus.running;

    return GestureDetector(
      onTap: () {
        if (isComplete) {
          FlutterDownloader.open(taskId: task.taskId);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            // Thumbnail placeholder
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF111112),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white.withValues(alpha: 0.4),
                    size: 30,
                  ),
                  if (isRunning)
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        value: task.progress > 0 ? task.progress / 100 : null,
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
                    task.filename ?? 'Unknown file',
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
                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _getStatusColor(task.status).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getStatusIcon(task.status),
                              size: 12,
                              color: _getStatusColor(task.status),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _getStatusText(task.status),
                              style: TextStyle(
                                color: _getStatusColor(task.status),
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
                          '${task.progress}%',
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
            Icon(
              isComplete ? Icons.folder_open_rounded : Icons.more_vert,
              color: Colors.grey.shade600,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
