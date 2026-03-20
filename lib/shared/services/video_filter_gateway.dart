import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tubeorbit/core/constants.dart';
import 'package:tubeorbit/shared/api/youtube_api_client.dart';
import 'package:tubeorbit/shared/models/video_model.dart';

/// Provider for the VideoFilterGateway
final videoFilterGatewayProvider = Provider<VideoFilterGateway>((ref) {
  return VideoFilterGateway();
});

/// A gateway that acts as a filter between the YouTube API and the UI feed.
class VideoFilterGateway {
  
  /// Filters based on strict channel country matching and embeddable status.
  Future<List<VideoModel>> filterVideos(List<VideoModel> candidates, ContentLanguage language, YouTubeApiClient client, {bool requireEmbeddable = false}) async {
    List<VideoModel> currentCandidates = candidates;

    // Optional: Filter out Non-Embeddable videos directly from the single source of truth (/videos API)
    if (requireEmbeddable) {
      final videoIds = currentCandidates.map((v) => v.videoId).toList();
      if (videoIds.isNotEmpty) {
        try {
          final nonEmbeddableIds = await client.getNonEmbeddableVideos(videoIds);
          if (nonEmbeddableIds.isNotEmpty) {
            currentCandidates = currentCandidates.where((v) => !nonEmbeddableIds.contains(v.videoId)).toList();
          }
        } catch (_) {
          // Ignore failures on this strict check
        }
      }
    }

    final allowedCountries = language.allowedCountries;
    // If 'ALL' is selected, there are no strict country requirements.
    if (allowedCountries == null) return currentCandidates;

    final channelIds = currentCandidates.map((v) => v.channelId).toSet().toList();
    if (channelIds.isEmpty) return [];

    try {
      final countryMap = await client.getChannelCountries(channelIds);
      
      return currentCandidates.where((video) {
        final country = countryMap[video.channelId];
        // Strictly discard videos if country is null or not in the allowed list
        if (country == null) return false;
        return allowedCountries.contains(country);
      }).toList();
    } catch (e) {
      // In case of an API/Network error matching countries, we return the fallback candidates 
      return currentCandidates;
    }
  }
}
