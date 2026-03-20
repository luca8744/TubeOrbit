import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tubeorbit/core/constants.dart';
import 'package:tubeorbit/features/auth/auth_provider.dart';
import 'package:tubeorbit/shared/api/youtube_api_client.dart';
import 'package:tubeorbit/shared/models/video_model.dart';
import 'package:tubeorbit/shared/services/video_filter_gateway.dart';

enum FeedTabType {
  videos,
  shorts,
  external,
}

// ─── YouTube API client provider ───────────────────────────────────────────────
final youTubeClientProvider = FutureProvider<YouTubeApiClient?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  final authClient = await authService.getAuthClient();
  if (authClient == null) return null;
  return YouTubeApiClient(authClient);
});

// ─── Feed state ────────────────────────────────────────────────────────────────
class FeedState {
  final List<VideoModel> videos;
  final String? nextPageToken;
  final bool isLoadingMore;

  const FeedState({
    this.videos = const [],
    this.nextPageToken,
    this.isLoadingMore = false,
  });

  FeedState copyWith({
    List<VideoModel>? videos,
    String? nextPageToken,
    bool clearNextPageToken = false,
    bool? isLoadingMore,
  }) =>
      FeedState(
        videos: videos ?? this.videos,
        nextPageToken:
            clearNextPageToken ? null : (nextPageToken ?? this.nextPageToken),
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      );
}

// ─── Feed provider (per category + tabType + language) ──────────────────────────────────
final feedProvider = AsyncNotifierProvider.family<FeedNotifier, FeedState,
    ({TubeCategory category, FeedTabType tabType, ContentLanguage language, VideoSortOption sortOption})>(
  FeedNotifier.new,
);

class FeedNotifier
    extends FamilyAsyncNotifier<FeedState, ({TubeCategory category, FeedTabType tabType, ContentLanguage language, VideoSortOption sortOption})> {
  @override
  Future<FeedState> build(
      ({TubeCategory category, FeedTabType tabType, ContentLanguage language, VideoSortOption sortOption}) arg) async {
    final client = await ref.watch(youTubeClientProvider.future);
    if (client == null) return const FeedState();
    return _fetch(client, arg.category, arg.tabType, arg.language, arg.sortOption, pageToken: null);
  }

  Future<FeedState> _fetch(
    YouTubeApiClient client,
    TubeCategory category,
    FeedTabType tabType,
    ContentLanguage language,
    VideoSortOption sortOption, {
    String? pageToken,
    List<VideoModel> existing = const [],
  }) async {
    final duration = tabType == FeedTabType.shorts ? 'short' : 'medium';
    final embeddable = tabType == FeedTabType.external ? 'any' : 'true';
    final publishedAfter =
        DateTime.now().subtract(const Duration(days: 60)).toUtc().toIso8601String();
        
    final query = language.getSearchKeyword(category);

    final result = await client.searchVideos(
      query: query,
      duration: duration,
      pageToken: pageToken,
      order: sortOption.apiValue,
      publishedAfter: publishedAfter,
      relevanceLanguage: language.relevanceLanguage,
      regionCode: language.regionCode,
      videoEmbeddable: embeddable,
    );

    final filterGateway = ref.read(videoFilterGatewayProvider);
    final requireEmbeddable = tabType != FeedTabType.external;
    final filteredVideos = await filterGateway.filterVideos(result.videos, language, client, requireEmbeddable: requireEmbeddable);

    return FeedState(
      videos: [...existing, ...filteredVideos],
      nextPageToken: result.nextPageToken,
    );
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || current.nextPageToken == null) return;
    if (current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));

    final client = await ref.read(youTubeClientProvider.future);
    if (client == null) return;

    final next = await _fetch(
      client,
      arg.category,
      arg.tabType,
      arg.language,
      arg.sortOption,
      pageToken: current.nextPageToken,
      existing: current.videos,
    );
    state = AsyncData(next);
  }
}
