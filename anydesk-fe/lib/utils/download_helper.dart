import 'package:flutter/foundation.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class DownloadHelper {
  static Future<void> downloadFile(String url, String filename) async {
    // On Android 13+, storage permission is denied by default, but we don't need it to save in Downloads.
    // However, we DO need notification permission to show the progress!
    if (Platform.isAndroid) {
      await Permission.notification.request();
    }
    
    var storageStatus = await Permission.storage.request();
    if (!storageStatus.isGranted) {
      // Don't throw an error immediately, because on Android 13+ this is normally denied,
      // but we can still write to the public Downloads folder.
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

    await FlutterDownloader.enqueue(
      url: url,
      savedDir: dirPath,
      fileName: safeFilename,
      showNotification: true, // show download progress in status bar
      openFileFromNotification: true, // click on notification to open
      saveInPublicStorage: true,
    );
  }
}
