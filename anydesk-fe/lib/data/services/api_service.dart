import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
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
    return 'tiktok';
  }

  Future<MediaItem> fetchMediaDetails(String rawUrl) async {
    final cleanUrl = _cleanUrl(rawUrl);
    final platform = _detectPlatform(cleanUrl);

    // YouTube: gunakan youtube_explode_dart secara native (bypass RapidAPI)
    if (platform == 'youtube') {
      return await _fetchYoutubeDetails(cleanUrl);
    }

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

  Future<MediaItem> _fetchYoutubeDetails(String url) async {
    final yt = YoutubeExplode();
    try {
      final video = await yt.videos.get(url);
      final manifest = await yt.videos.streamsClient.getManifest(video.id);

      final List<MediaOption> links = [];

      // Ambil semua stream muxed (video+audio sudah tergabung) — tidak perlu merge
      // youtube_explode_dart biasanya menyediakan hingga 720p untuk muxed
      final addedResolutions = <int>{};
      
      // Urutkan dari kualitas tertinggi
      final sortedMuxed = manifest.muxed.toList()
        ..sort((a, b) => b.videoResolution.height.compareTo(a.videoResolution.height));

      for (final muxed in sortedMuxed) {
        final height = muxed.videoResolution.height;
        if (addedResolutions.contains(height)) continue;
        addedResolutions.add(height);

        String label;
        if (height >= 1080) label = '1080p Full HD';
        else if (height >= 720) label = '720p HD';
        else if (height >= 480) label = '480p SD';
        else if (height >= 360) label = '360p SD';
        else label = '${height}p';

        links.add(MediaOption(
          url: muxed.url.toString(),
          quality: '${height}p',
          extension: muxed.container.name,
          renderTitle: label,
          isYouTube: true,
          // audioUrl = null → tidak butuh FFmpeg, sudah muxed
        ));
      }

      final thumbUrl = video.thumbnails.highResUrl;

      return MediaItem(
        title: video.title,
        thumbnail: thumbUrl,
        uploader: video.author,
        uploaderAvatar: null,
        links: links,
      );
    } catch (e) {
      throw Exception('Gagal memproses YouTube: $e');
    } finally {
      yt.close();
    }
  }
}
