import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:tubeorbit/shared/models/video_model.dart';

const String _baseUrl = 'https://www.googleapis.com/youtube/v3';

class YouTubeApiClient {
  final AuthClient _authClient;
  late final Dio _dio;

  YouTubeApiClient(this._authClient) {
    _dio = Dio(BaseOptions(baseUrl: _baseUrl));

    // Inject the Bearer token from the googleapis AuthClient credentials
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = _authClient.credentials.accessToken.data;
          options.headers['Authorization'] = 'Bearer $token';
          handler.next(options);
        },
      ),
    );
  }

  /// Search videos. [duration]: 'short' | 'medium' | 'long'
  Future<({List<VideoModel> videos, String? nextPageToken})> searchVideos({
    required String query,
    required String duration,
    String? pageToken,
    int maxResults = 20,
  }) async {
    final response = await _dio.get(
      '/search',
      queryParameters: {
        'part': 'snippet',
        'q': query,
        'type': 'video',
        'videoDuration': duration,
        'maxResults': maxResults,
        'pageToken': pageToken,
      }..removeWhere((_, v) => v == null),
    );

    final items = (response.data['items'] as List<dynamic>)
        .cast<Map<String, dynamic>>();

    final videos = items
        .where((item) =>
            item['id'] is Map && (item['id'] as Map)['videoId'] != null)
        .map((item) => VideoModel.fromSearchJson(item))
        .toList();

    return (
      videos: videos,
      nextPageToken: response.data['nextPageToken'] as String?,
    );
  }

  /// Fetch all playlists for the authenticated user.
  Future<List<Map<String, dynamic>>> getUserPlaylists() async {
    final response = await _dio.get(
      '/playlists',
      queryParameters: {
        'part': 'snippet',
        'mine': true,
        'maxResults': 50,
      },
    );
    return (response.data['items'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
  }

  /// Create a playlist and return its ID.
  Future<String> createPlaylist(String title, String description) async {
    final response = await _dio.post(
      '/playlists',
      queryParameters: {'part': 'snippet,status'},
      data: jsonEncode({
        'snippet': {'title': title, 'description': description},
        'status': {'privacyStatus': 'private'},
      }),
      options: Options(contentType: 'application/json'),
    );
    return response.data['id'] as String;
  }

  /// Add a video to a playlist. Returns the playlistItem ID.
  Future<String> addVideoToPlaylist(String playlistId, String videoId) async {
    final response = await _dio.post(
      '/playlistItems',
      queryParameters: {'part': 'snippet'},
      data: jsonEncode({
        'snippet': {
          'playlistId': playlistId,
          'resourceId': {'kind': 'youtube#video', 'videoId': videoId},
        },
      }),
      options: Options(contentType: 'application/json'),
    );
    return response.data['id'] as String;
  }

  /// Remove a video from a playlist by its playlistItem ID.
  Future<void> removePlaylistItem(String playlistItemId) async {
    await _dio.delete(
      '/playlistItems',
      queryParameters: {'id': playlistItemId},
    );
  }
}
