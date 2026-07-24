import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class DownloadHelper {
  static Future<void> downloadFile(String url, String filename) async {
    // Request permission for storage
    var status = await Permission.storage.request();
    if (!status.isGranted) {
      if (Platform.isAndroid && await Permission.manageExternalStorage.request().isGranted) {
        // Android 11+
      } else {
        throw Exception("Izin penyimpanan ditolak");
      }
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
    String safeFilename = filename.replaceAll(RegExp(r'[^\w\s\.-]'), '_') + '.mp4';

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
