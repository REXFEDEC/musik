class Song {
  final String title;
  final String artist;
  final String videoId;
  final String thumbnailUrl;
  final String? highResThumbnailUrl;

  // Optional: Retained in case you still use these elsewhere
  final List<ThumbnailFull>? thumbnails;

  Song({
    required this.title,
    required this.artist,
    required this.videoId,
    required this.thumbnailUrl,
    this.highResThumbnailUrl,
    this.thumbnails,
  });

  /// Uses YouTube's public max-res image
  String get bestThumbnailUrl =>
      'https://i.ytimg.com/vi/$videoId/maxresdefault.jpg';

  /// Fallback if maxres doesn't exist (optional)
  String get fallbackThumbnailUrl =>
      'https://i.ytimg.com/vi/$videoId/hqdefault.jpg';

  factory Song.fromMap(Map<String, dynamic> map) {
    return Song(
      title: map['title'],
      artist: map['artist'],
      videoId: map['videoId'],
      thumbnailUrl: map['thumbnailUrl'],
      highResThumbnailUrl: map['highResThumbnailUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'artist': artist,
      'videoId': videoId,
      'thumbnailUrl': thumbnailUrl,
      'highResThumbnailUrl': highResThumbnailUrl,
    };
  }
}

class ThumbnailFull {
  final String url;
  final int width;
  final int height;

  ThumbnailFull({required this.url, required this.width, required this.height});

  factory ThumbnailFull.fromMap(Map<String, dynamic> map) {
    return ThumbnailFull(
      url: map['url'],
      width: map['width'],
      height: map['height'],
    );
  }
}
