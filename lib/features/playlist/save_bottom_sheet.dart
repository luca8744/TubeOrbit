import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tubeorbit/core/constants.dart';
import 'package:tubeorbit/core/theme.dart';
import 'package:tubeorbit/features/playlist/playlist_provider.dart';
import 'package:tubeorbit/shared/models/video_model.dart';

/// Shows confirm/remove bottom sheet and handles playlist operations.
Future<void> showSaveBottomSheet({
  required BuildContext context,
  required WidgetRef ref,
  required TubeCategory category,
  required VideoModel video,
}) async {
  final isSaved =
      ref.read(savedVideosProvider(category)).containsKey(video.videoId);
  await showModalBottomSheet(
    context: context,
    builder: (_) => _SaveBottomSheet(
      category: category,
      video: video,
      isSaved: isSaved,
      ref: ref,
    ),
  );
}

class _SaveBottomSheet extends StatefulWidget {
  final TubeCategory category;
  final VideoModel video;
  final bool isSaved;
  final WidgetRef ref;

  const _SaveBottomSheet({
    required this.category,
    required this.video,
    required this.isSaved,
    required this.ref,
  });

  @override
  State<_SaveBottomSheet> createState() => _SaveBottomSheetState();
}

class _SaveBottomSheetState extends State<_SaveBottomSheet> {
  bool _loading = false;

  String get _playlistLabel => '$kPlaylistPrefix${widget.category.name}';

  Future<void> _confirm() async {
    setState(() => _loading = true);
    final service = widget.ref.read(playlistServiceProvider);
    try {
      if (widget.isSaved) {
        await service.removeVideo(widget.category, widget.video);
      } else {
        await service.saveVideo(widget.category, widget.video);
      }
    } finally {
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textSecondary.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          Text(
            widget.isSaved ? 'Rimuovi dalla playlist' : 'Salva nella playlist',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
          ),
          const SizedBox(height: 8),

          Text(
            'Playlist: $_playlistLabel',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 6),

          Text(
            widget.video.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _loading ? null : () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textSecondary,
                    side: const BorderSide(color: AppTheme.divider),
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Annulla'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _loading ? null : _confirm,
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        widget.isSaved ? AppTheme.error : AppTheme.accent,
                    foregroundColor: AppTheme.onAccent,
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child:
                              CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(widget.isSaved ? 'Rimuovi' : 'Salva'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
