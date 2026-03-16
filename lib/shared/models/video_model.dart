class VideoModel {
  final String videoId;
  final String title;
  final String channelTitle;
  final String thumbnailUrl;
  final String? duration; // ISO 8601 duration string
  final bool isShort;

  const VideoModel({
    required this.videoId,
    required this.title,
    required this.channelTitle,
    required this.thumbnailUrl,
    this.duration,
    this.isShort = false,
  });

  String get youtubeUrl => 'https://www.youtube.com/watch?v=$videoId';

  factory VideoModel.fromSearchJson(Map<String, dynamic> json) {
    final snippet = json['snippet'] as Map<String, dynamic>;
    final thumbnails = snippet['thumbnails'] as Map<String, dynamic>;
    final thumbUrl = (thumbnails['high'] ?? thumbnails['medium'] ??
            thumbnails['default']) as Map<String, dynamic>;

    return VideoModel(
      videoId: (json['id'] as Map<String, dynamic>)['videoId'] as String,
      title: snippet['title'] as String,
      channelTitle: snippet['channelTitle'] as String,
      thumbnailUrl: thumbUrl['url'] as String,
    );
  }
}
