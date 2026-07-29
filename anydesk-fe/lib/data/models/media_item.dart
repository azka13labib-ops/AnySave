class MediaOption {
  final String url;
  final String quality;
  final String extension;
  final String renderTitle;

  /// Khusus YouTube HD: URL stream audio terpisah yang harus di-merge dengan FFmpeg.
  /// Null berarti video sudah muxed (ada audionya) dan tidak perlu merge.
  final String? audioUrl;

  /// True jika opsi ini berasal dari YouTube (native youtube_explode_dart)
  final bool isYouTube;

  MediaOption({
    required this.url,
    required this.quality,
    required this.extension,
    required this.renderTitle,
    this.audioUrl,
    this.isYouTube = false,
  });

  /// Returns true jika opsi ini butuh FFmpeg merge (YouTube HD)
  bool get needsMerge => isYouTube && audioUrl != null && audioUrl!.isNotEmpty;

  static String formatQualityLabel(String rawQuality, String type) {
    if (rawQuality.isEmpty) return type == 'video' ? 'HD Video' : 'Audio MP3';

    final lower = rawQuality.toLowerCase();

    if (lower.contains('4k') || lower.contains('2160')) return '4K Ultra HD';
    if (lower.contains('2k') || lower.contains('1440')) return '2K Quad HD';
    if (lower.contains('1080')) return '1080p Full HD';
    if (lower.contains('720')) return '720p HD';
    if (lower.contains('540')) return '540p SD';
    if (lower.contains('480')) return '480p SD';
    if (lower.contains('360')) return '360p SD';
    if (lower.contains('240')) return '240p';

    if (lower.contains('no_watermark') || lower.contains('nowatermark') || lower.contains('nwm')) {
      return 'No Watermark (HD)';
    }
    if (lower.contains('watermark') || lower.contains('wm')) {
      return 'Watermarked Video';
    }
    if (lower == 'hd' || lower == 'highest') {
      return '1080p Full HD';
    }
    if (lower == 'sd' || lower == 'lowest') {
      return '360p SD';
    }

    // FIX: Gunakan lowercase biasa, bukan flag (?i) yang tidak didukung di Dart
    String clean = rawQuality.replaceAll(RegExp(r'[_-]'), ' ').trim();
    final cleanLower = clean.toLowerCase();
    if (cleanLower.contains('medium360')) return '360p SD';
    if (cleanLower.contains('high720')) return '720p HD';
    if (cleanLower.contains('high1080')) return '1080p Full HD';
    return 'Download $clean';
  }

  factory MediaOption.fromJson(Map<String, dynamic> json, String type) {
    String mime = (json['metadata']?['mime_type'] as String?) ?? '';
    String ext = mime.split('/').last;
    if (ext.isEmpty) {
      ext = type == 'video' ? 'mp4' : (type == 'image' ? 'jpg' : 'mp3');
    }

    String rawQuality = json['label'] ?? json['quality'] ?? '';
    String formattedLabel = formatQualityLabel(rawQuality, type);

    return MediaOption(
      url: json['url'] ?? '',
      quality: rawQuality,
      extension: ext,
      renderTitle: 'Download $type $formattedLabel'.replaceAll('  ', ' ').trim(),
    );
  }
}

class MediaItem {
  final String title;
  final String thumbnail;
  final String uploader;
  final String? uploaderAvatar;
  final List<MediaOption> links;

  MediaItem({
    required this.title,
    required this.thumbnail,
    required this.uploader,
    this.uploaderAvatar,
    required this.links,
  });

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    final title = json['title'] ?? json['metadata']?['title'] ?? 'Unknown Title';
    
    // Parse author/uploader (dari backend/RapidAPI)
    final authorInfo = json['author'] ?? json['metadata']?['author'] ?? {};
    final String uploader = authorInfo['name'] ?? authorInfo['username'] ?? json['uploader'] ?? 'AnySave Downloader';
    final String? uploaderAvatar = authorInfo['avatar'] ?? authorInfo['profile_pic'] ?? json['uploaderAvatar'];
    
    final dynamic contentsData = json['contents'];

    List<MediaOption> parsedLinks = [];
    const String proxyBase = 'https://kmzwrypgdlxzzsubmepc.supabase.co/functions/v1/image-proxy?url=';
    
    String rawThumbnail = json['thumbnail'] ??
                          json['metadata']?['thumbnailUrl'] ?? 
                          json['metadata']?['thumbnail'] ?? 
                          json['metadata']?['cover'] ?? '';
    String thumbnail = rawThumbnail.isNotEmpty 
        ? (rawThumbnail.startsWith('http') ? '$proxyBase${Uri.encodeComponent(rawThumbnail)}' : rawThumbnail)
        : '';

    void parseContentNode(Map<String, dynamic> node) {
      if (node['videos'] != null) {
        for (var v in node['videos']) {
          parsedLinks.add(MediaOption.fromJson(v, 'video'));
        }
      }
      if (node['images'] != null) {
        for (var img in node['images']) {
          parsedLinks.add(MediaOption.fromJson(img, 'image'));
          if (thumbnail.isEmpty) {
            thumbnail = img['url'] ?? '';
          }
        }
      }
      if (node['audios'] != null) {
        for (var a in node['audios']) {
          parsedLinks.add(MediaOption.fromJson(a, 'audio'));
        }
      }
    }

    if (contentsData is List) {
      for (var item in contentsData) {
        if (item is Map<String, dynamic>) {
          parseContentNode(item);
        }
      }
    } else if (contentsData is Map<String, dynamic>) {
      parseContentNode(contentsData);
    }
    
    // Support new ExtractedMedia structure
    final dynamic mediasData = json['medias'];
    if (mediasData is List) {
      for (var m in mediasData) {
        String type = (m['extension'] == 'mp3' ? 'audio' : 'video');
        String rawQuality = m['quality'] ?? '';
        String formattedLabel = MediaOption.formatQualityLabel(rawQuality, type);
        parsedLinks.add(MediaOption(
          url: m['url'] ?? '',
          quality: rawQuality,
          extension: m['extension'] ?? '',
          renderTitle: 'Download $type $formattedLabel'.replaceAll('  ', ' ').trim(),
        ));
      }
    }

    // Sort parsedLinks by highest quality first
    int getQualityScore(MediaOption option) {
      final q = '${option.quality} ${option.renderTitle}'.toLowerCase();
      if (q.contains('1080') || q.contains('full hd') || q.contains('highest')) return 100;
      if (q.contains('720') || q.contains('hd')) return 80;
      if (q.contains('540')) return 60;
      if (q.contains('480')) return 40;
      if (q.contains('360')) return 30;
      if (q.contains('240')) return 20;
      return 10;
    }

    parsedLinks.sort((a, b) => getQualityScore(b).compareTo(getQualityScore(a)));

    // Deduplicate options by renderTitle
    final Map<String, MediaOption> uniqueMap = {};
    for (var option in parsedLinks) {
      if (!uniqueMap.containsKey(option.renderTitle)) {
        uniqueMap[option.renderTitle] = option;
      }
    }
    final List<MediaOption> uniqueLinks = uniqueMap.values.toList();

    return MediaItem(
      title: title,
      thumbnail: thumbnail,
      uploader: uploader,
      uploaderAvatar: uploaderAvatar,
      links: uniqueLinks,
    );
  }
}
