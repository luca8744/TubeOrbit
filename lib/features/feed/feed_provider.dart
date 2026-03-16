import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tubeorbit/core/constants.dart';
import 'package:tubeorbit/features/auth/auth_provider.dart';
import 'package:tubeorbit/shared/api/youtube_api_client.dart';
import 'package:tubeorbit/shared/models/video_model.dart';

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

// ─── Feed provider (per category + isShorts) ──────────────────────────────────
final feedProvider = AsyncNotifierProvider.family<FeedNotifier, FeedState,
    ({TubeCategory category, bool isShorts})>(
  FeedNotifier.new,
);

class FeedNotifier
    extends FamilyAsyncNotifier<FeedState, ({TubeCategory category, bool isShorts})> {
  @override
  Future<FeedState> build(
      ({TubeCategory category, bool isShorts}) arg) async {
    final client = await ref.watch(youTubeClientProvider.future);
    if (client == null) return const FeedState();
    return _fetch(client, arg.category, arg.isShorts, pageToken: null);
  }

  Future<FeedState> _fetch(
    YouTubeApiClient client,
    TubeCategory category,
    bool isShorts, {
    String? pageToken,
    List<VideoModel> existing = const [],
  }) async {
    final duration = isShorts ? 'short' : 'medium';
    final result = await client.searchVideos(
      query: category.searchKeyword,
      duration: duration,
      pageToken: pageToken,
    );
    return FeedState(
      videos: [...existing, ...result.videos],
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
      arg.isShorts,
      pageToken: current.nextPageToken,
      existing: current.videos,
    );
    state = AsyncData(next);
  }
}
