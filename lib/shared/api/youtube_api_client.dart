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
    String? order,
    String? publishedAfter,
    String? relevanceLanguage,
    String? regionCode,
    String videoEmbeddable = 'any',
  }) async {
    final response = await _dio.get(
      '/search',
      queryParameters: {
        'part': 'snippet',
        'q': query,
        'type': 'video',
        'videoEmbeddable': videoEmbeddable,
        'videoDuration': duration,
        'maxResults': maxResults,
        'pageToken': pageToken,
        'order': order,
        'publishedAfter': publishedAfter,
        'relevanceLanguage': relevanceLanguage,
        'regionCode': regionCode,
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

  /// Fetch the country origin of a list of channels. Returns a map of channelId -> countryCode.
  Future<Map<String, String?>> getChannelCountries(List<String> channelIds) async {
    if (channelIds.isEmpty) return {};

    final Map<String, String?> result = {};
    // Break into chunks of 50 to respect API limits
    for (var i = 0; i < channelIds.length; i += 50) {
      final chunk = channelIds.sublist(
        i,
        i + 50 > channelIds.length ? channelIds.length : i + 50,
      );

      final response = await _dio.get(
        '/channels',
        queryParameters: {
          'part': 'snippet',
          'id': chunk.join(','),
        },
      );

      final items = (response.data['items'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
      for (final item in items) {
        final id = item['id'] as String;
        final snippet = item['snippet'] as Map<String, dynamic>?;
        result[id] = snippet?['country'] as String?;
      }
    }
    return result;
  }

  /// Returns a list of video IDs that are explicitly marked as `embeddable == false`
  /// or are blocked due to licensing/syndication.
  Future<List<String>> getNonEmbeddableVideos(List<String> videoIds) async {
    if (videoIds.isEmpty) return [];

    final List<String> blockedIds = [];
    // Break into chunks of 50 to respect API limits
    for (var i = 0; i < videoIds.length; i += 50) {
      final chunk = videoIds.sublist(
        i,
        i + 50 > videoIds.length ? videoIds.length : i + 50,
      );

      final response = await _dio.get(
        '/videos',
        queryParameters: {
          'part': 'status,contentDetails',
          'id': chunk.join(','),
        },
      );

      final items = (response.data['items'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
      for (final item in items) {
        final id = item['id'] as String;
        final status = item['status'] as Map<String, dynamic>?;
        final contentDetails = item['contentDetails'] as Map<String, dynamic>?;

        bool isBlocked = false;
        if (status != null && status['embeddable'] == false) {
          isBlocked = true;
        }

        if (contentDetails != null) {
          if (contentDetails['licensedContent'] == true) {
            isBlocked = true;
          }
          
          final regionRestriction = contentDetails['regionRestriction'] as Map<String, dynamic>?;
          if (regionRestriction != null && regionRestriction.containsKey('blocked')) {
            isBlocked = true;
          }
        }

        if (isBlocked) {
          blockedIds.add(id);
        }
      }
    }
    return blockedIds;
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
