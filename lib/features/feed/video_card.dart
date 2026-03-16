import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tubeorbit/core/constants.dart';
import 'package:tubeorbit/core/theme.dart';
import 'package:tubeorbit/features/playlist/playlist_provider.dart';
import 'package:tubeorbit/features/playlist/save_bottom_sheet.dart';
import 'package:tubeorbit/shared/models/video_model.dart';
import 'package:url_launcher/url_launcher.dart';

class VideoCard extends ConsumerWidget {
  final VideoModel video;
  final TubeCategory category;

  const VideoCard({
    super.key,
    required this.video,
    required this.category,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedMap = ref.watch(savedVideosProvider(category));
    final isSaved = savedMap.containsKey(video.videoId);

    return GestureDetector(
      onTap: () => _openVideo(context),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: video.thumbnailUrl,
                    width: double.infinity,
                    height: 196,
                    fit: BoxFit.cover,
                    placeholder: (_, x) => Container(
                      height: 196,
                      color: AppTheme.surface,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.accent,
                          strokeWidth: 1.5,
                        ),
                      ),
                    ),
                  ),
                  if (video.isShort)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: AppTheme.divider, width: 0.5),
                        ),
                        child: const Text(
                          'SHORTS',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  // Play overlay
                  Positioned.fill(
                    child: Center(
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.play_arrow,
                            color: Colors.white, size: 28),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Info row
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(12, 10, 4, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          video.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          video.channelTitle,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bookmark button
                  IconButton(
                    onPressed: () => showSaveBottomSheet(
                      context: context,
                      ref: ref,
                      category: category,
                      video: video,
                    ),
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        isSaved ? Icons.bookmark : Icons.bookmark_outline,
                        key: ValueKey(isSaved),
                        color: isSaved ? AppTheme.accent : AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openVideo(BuildContext context) async {
    final uri = Uri.parse(video.youtubeUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
