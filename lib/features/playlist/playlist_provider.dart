import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tubeorbit/core/constants.dart';
import 'package:tubeorbit/features/feed/feed_provider.dart';
import 'package:tubeorbit/shared/api/youtube_api_client.dart';
import 'package:tubeorbit/shared/models/video_model.dart';

// ─── Saved videos per category: { videoId → playlistItemId } ──────────────────
final savedVideosProvider =
    StateNotifierProvider.family<SavedVideosNotifier, Map<String, String>, TubeCategory>(
  (ref, _) => SavedVideosNotifier(),
);

class SavedVideosNotifier extends StateNotifier<Map<String, String>> {
  SavedVideosNotifier() : super({});

  void markSaved(String videoId, String playlistItemId) {
    state = {...state, videoId: playlistItemId};
  }

  void markRemoved(String videoId) {
    final copy = Map<String, String>.from(state);
    copy.remove(videoId);
    state = copy;
  }

  bool isSaved(String videoId) => state.containsKey(videoId);
  String? playlistItemId(String videoId) => state[videoId];
}

// ─── Playlist cache: { TubeCategory → playlistId } ────────────────────────────
final playlistCacheProvider =
    StateNotifierProvider<PlaylistCacheNotifier, Map<TubeCategory, String>>(
  (ref) => PlaylistCacheNotifier(),
);

class PlaylistCacheNotifier
    extends StateNotifier<Map<TubeCategory, String>> {
  PlaylistCacheNotifier() : super({});

  void setPlaylistId(TubeCategory category, String playlistId) {
    state = {...state, category: playlistId};
  }

  String? getPlaylistId(TubeCategory category) => state[category];
}

// ─── Playlist service actions ─────────────────────────────────────────────────
class PlaylistService {
  final Ref ref;
  PlaylistService(this.ref);

  Future<YouTubeApiClient?> _client() async {
    return ref.read(youTubeClientProvider.future);
  }

  /// Loads all tubeorbit_* playlists and populates the cache.
  Future<void> loadUserPlaylists() async {
    final client = await _client();
    if (client == null) return;

    final playlists = await client.getUserPlaylists();
    for (final p in playlists) {
      final title = p['snippet']['title'] as String;
      if (title.startsWith(kPlaylistPrefix)) {
        final suffix = title.substring(kPlaylistPrefix.length);
        try {
          final category = TubeCategory.values.firstWhere(
            (c) => c.name == suffix,
          );
          ref
              .read(playlistCacheProvider.notifier)
              .setPlaylistId(category, p['id'] as String);
        } catch (_) {
          // unknown suffix, skip
        }
      }
    }
  }

  /// Gets or creates the tubeorbit_{category} playlist.
  Future<String> getOrCreatePlaylist(TubeCategory category) async {
    final cached =
        ref.read(playlistCacheProvider).containsKey(category)
            ? ref.read(playlistCacheProvider)[category]!
            : null;
    if (cached != null) return cached;

    final client = await _client();
    if (client == null) throw Exception('Not authenticated');

    final id = await client.createPlaylist(
      category.playlistName,
      'Playlist gestita da TubeOrbit – ${category.displayName}',
    );
    ref.read(playlistCacheProvider.notifier).setPlaylistId(category, id);
    return id;
  }

  /// Saves a video to the category playlist (user confirmed).
  Future<void> saveVideo(TubeCategory category, VideoModel video) async {
    final playlistId = await getOrCreatePlaylist(category);
    final client = await _client();
    if (client == null) return;

    final itemId = await client.addVideoToPlaylist(playlistId, video.videoId);
    ref
        .read(savedVideosProvider(category).notifier)
        .markSaved(video.videoId, itemId);
  }

  /// Removes a video from the category playlist.
  Future<void> removeVideo(TubeCategory category, VideoModel video) async {
    final notifier = ref.read(savedVideosProvider(category).notifier);
    final itemId = notifier.playlistItemId(video.videoId);
    if (itemId == null) return;

    final client = await _client();
    if (client == null) return;

    await client.removePlaylistItem(itemId);
    notifier.markRemoved(video.videoId);
  }
}

final playlistServiceProvider = Provider<PlaylistService>(
  (ref) => PlaylistService(ref),
);
