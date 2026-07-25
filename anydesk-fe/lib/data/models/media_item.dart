class MediaOption {
  final String url;
  final String quality; // maps to 'label' in v3
  final String extension; // maps to metadata.mime_type
  final String renderTitle; // custom description based on type

  MediaOption({
    required this.url,
    required this.quality,
    required this.extension,
    required this.renderTitle,
  });

  factory MediaOption.fromJson(Map<String, dynamic> json, String type) {
    String mime = (json['metadata']?['mime_type'] as String?) ?? '';
    String ext = mime.split('/').last;
    if (ext.isEmpty) {
      ext = type == 'video' ? 'mp4' : (type == 'image' ? 'jpg' : 'mp3');
    }

    return MediaOption(
      url: json['url'] ?? '',
      quality: json['label'] ?? '',
      extension: ext,
      renderTitle: 'Download $type ${json['label'] ?? ''}'.trim(),
    );
  }
}

class MediaItem {
  final String title;
  final String thumbnail;
  final List<MediaOption> links;

  MediaItem({
    required this.title,
    required this.thumbnail,
    required this.links,
  });

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    final title = json['title'] ?? json['metadata']?['title'] ?? 'Unknown Title';
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
        // Map new format to our MediaOption model format
        String type = (m['extension'] == 'mp3' ? 'audio' : 'video');
        parsedLinks.add(MediaOption(
          url: m['url'] ?? '',
          quality: m['quality'] ?? '',
          extension: m['extension'] ?? '',
          renderTitle: 'Download $type ${m['quality'] ?? ''}'.trim(),
        ));
      }
    }

    // Use first video frame or image as thumbnail if not set
    if (thumbnail.isEmpty && parsedLinks.isNotEmpty) {
      // RapidAPI doesn't always give a separate 'picture' field in v3,
      // sometimes we just don't have a thumbnail for video unless specified.
      thumbnail = ''; // Will handle empty thumbnail in UI
    }

    return MediaItem(
      title: title,
      thumbnail: thumbnail,
      links: parsedLinks,
    );
  }
}
