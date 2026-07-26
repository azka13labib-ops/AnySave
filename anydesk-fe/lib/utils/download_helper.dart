import 'package:flutter/foundation.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class DownloadHelper {
  static Future<String?> downloadFile(String url, String filename, {String? thumbnailUrl}) async {
    // On Android 13+, storage permission is denied by default, but we don't need it to save in Downloads.
    // However, we DO need notification permission to show the progress!
    if (Platform.isAndroid) {
      await Permission.notification.request();
    }
    
    var storageStatus = await Permission.storage.request();
    if (!storageStatus.isGranted) {
      debugPrint("Warning: Storage permission not granted. Attempting download anyway (might be Android 13+).");
    }

    String dirPath = '';
    if (Platform.isAndroid) {
      // Use standard Downloads directory on Android
      dirPath = '/storage/emulated/0/Download';
      if (!Directory(dirPath).existsSync()) {
        dirPath = (await getExternalStorageDirectory())?.path ?? '';
      }
    } else {
      dirPath = (await getApplicationDocumentsDirectory()).path;
    }

    if (dirPath.isEmpty) throw Exception("Gagal mendapatkan direktori download");

    // Clean up filename
    String safeFilename = '${filename.replaceAll(RegExp(r'[^\w\s\.-]'), '_')}.mp4';

    // Persist thumbnail URL mapping
    if (thumbnailUrl != null && thumbnailUrl.isNotEmpty) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('thumb_$safeFilename', thumbnailUrl);
      } catch (e) {
        debugPrint('Error saving thumbnail preference: $e');
      }
    }

    final taskId = await FlutterDownloader.enqueue(
      url: url,
      savedDir: dirPath,
      fileName: safeFilename,
      showNotification: true, // show download progress in status bar
      openFileFromNotification: true, // click on notification to open
      saveInPublicStorage: true,
    );

    return taskId;
  }
}


