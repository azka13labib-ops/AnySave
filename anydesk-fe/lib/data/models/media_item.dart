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
    if (ext.isEmpty) ext = type == 'video' ? 'mp4' : (type == 'image' ? 'jpg' : 'mp3');

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
    final title = json['metadata']?['title'] ?? 'Unknown Title';
    final contents = json['contents'] as Map<String, dynamic>? ?? {};

    List<MediaOption> parsedLinks = [];
    String thumbnail = '';

    // Parse Videos
    if (contents['videos'] != null) {
      for (var v in contents['videos']) {
        parsedLinks.add(MediaOption.fromJson(v, 'video'));
      }
    }

    // Parse Images
    if (contents['images'] != null) {
      for (var img in contents['images']) {
        parsedLinks.add(MediaOption.fromJson(img, 'image'));
        if (thumbnail.isEmpty) {
          thumbnail = img['url'] ?? '';
        }
      }
    }

    // Parse Audios
    if (contents['audios'] != null) {
      for (var a in contents['audios']) {
        parsedLinks.add(MediaOption.fromJson(a, 'audio'));
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
