import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
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
        // Urutkan dari yang terbaru
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
    if (status == DownloadTaskStatus.complete) return 'Selesai';
    if (status == DownloadTaskStatus.failed) return 'Gagal';
    if (status == DownloadTaskStatus.running) return 'Mengunduh...';
    if (status == DownloadTaskStatus.paused) return 'Jeda';
    if (status == DownloadTaskStatus.canceled) return 'Dibatalkan';
    return 'Menunggu';
  }

  Color _getStatusColor(DownloadTaskStatus status) {
    if (status == DownloadTaskStatus.complete) return Colors.greenAccent;
    if (status == DownloadTaskStatus.failed) return Colors.redAccent;
    if (status == DownloadTaskStatus.running) return Colors.blueAccent;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Background dikendalikan parent (MainScreen)
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Riwayat Unduhan',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTasks,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tasks == null || _tasks!.isEmpty
              ? const Center(
                  child: Text(
                    'Belum ada riwayat unduhan',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadTasks,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _tasks!.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final task = _tasks![index];
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1C1C1E),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _getStatusColor(task.status).withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                task.status == DownloadTaskStatus.complete
                                    ? Icons.check_circle
                                    : task.status == DownloadTaskStatus.failed
                                        ? Icons.error
                                        : Icons.downloading,
                                color: _getStatusColor(task.status),
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task.filename ?? 'Unknown file',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        _getStatusText(task.status),
                                        style: TextStyle(
                                          color: _getStatusColor(task.status),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      if (task.status == DownloadTaskStatus.running) ...[
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: LinearProgressIndicator(
                                            value: task.progress > 0 ? task.progress / 100 : null,
                                            backgroundColor: Colors.white.withValues(alpha: 0.1),
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              _getStatusColor(task.status),
                                            ),
                                          ),
                                        ),
                                      ]
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
