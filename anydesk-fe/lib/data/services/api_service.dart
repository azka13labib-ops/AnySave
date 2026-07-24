import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/media_item.dart';

class ApiService {
  final Dio _dio = Dio();

  String _detectPlatform(String url) {
    if (url.contains('tiktok.com') || url.contains('vt.tiktok.com')) {
      return 'tiktok';
    } else if (url.contains('instagram.com')) {
      return 'instagram';
    } else if (url.contains('youtube.com') || url.contains('youtu.be')) {
      return 'youtube';
    }
    return '';
  }

  Future<MediaItem> fetchMediaDetails(String url) async {
    final platform = _detectPlatform(url);
    if (platform.isEmpty) {
      throw Exception('Platform dari URL tidak didukung.');
    }

    final baseUrl = dotenv.env['SUPABASE_FUNCTIONS_URL'] ?? 'http://127.0.0.1:54321/functions/v1';
    final endpoint = '$baseUrl/video-downloader';

    try {
      final response = await _dio.post(
        endpoint,
        data: {
          'platform': platform,
          'url': url,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
          sendTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );

      if (response.statusCode == 200) {
        // Cek jika API mereturn error object (bisa terjadi jika URL salah tapi 200 OK)
        if (response.data['error'] != null) {
            throw Exception(response.data['error']);
        }
        if (response.data['success'] == false && response.data['message'] != null) {
            throw Exception(response.data['message']);
        }
        
        return MediaItem.fromJson(response.data);
      } else {
        throw Exception('Gagal menghubungi server (Status: ${response.statusCode})');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        String msg = e.response?.data['error'] ?? e.response?.data['message'] ?? e.message;
        throw Exception('Error dari server: $msg');
      }
      throw Exception('Gagal menghubungi server: ${e.message}');
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
