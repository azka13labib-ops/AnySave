import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/media_item.dart';

class ApiService {
  final Dio _dio = Dio();

  String _cleanUrl(String input) {
    final regExp = RegExp(r'https?://[^\s]+');
    final match = regExp.firstMatch(input);
    if (match != null) {
      return match.group(0)!;
    }
    return input.trim();
  }

  String _detectPlatform(String url) {
    final lower = url.toLowerCase();
    if (lower.contains('instagram.com') || lower.contains('instagr.am')) {
      return 'instagram';
    } else if (lower.contains('youtube.com') || lower.contains('youtu.be')) {
      return 'youtube';
    }
    // Default to tiktok for all shortlinks and TikTok variants
    return 'tiktok';
  }

  Future<MediaItem> fetchMediaDetails(String rawUrl) async {
    final cleanUrl = _cleanUrl(rawUrl);
    final platform = _detectPlatform(cleanUrl);

    final baseUrl = dotenv.env['SUPABASE_FUNCTIONS_URL'] ?? 'https://kmzwrypgdlxzzsubmepc.supabase.co/functions/v1';
    final endpoint = '$baseUrl/video-downloader';

    try {
      final response = await _dio.post(
        endpoint,
        data: {
          'platform': platform,
          'url': cleanUrl,
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
        String msg = e.response?.data['msg'] ?? e.response?.data['error'] ?? e.response?.data['message'] ?? e.message;
        throw Exception('Error dari server: $msg');
      }
      throw Exception('Gagal menghubungi server: ${e.message}');
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
