import 'package:flutter/material.dart';

// ─── Playlist prefix ───────────────────────────────────────────────────────────
const String kPlaylistPrefix = 'tubeorbit_';

// ─── OAuth scopes ──────────────────────────────────────────────────────────────
const List<String> kScopes = [
  'https://www.googleapis.com/auth/youtube',
  'https://www.googleapis.com/auth/youtube.readonly',
];

// ─── Categories ────────────────────────────────────────────────────────────────
enum TubeCategory {
  geopolitica,
  scienze,
  ai,
  stem,
  tecnologia;

  String get displayName => switch (this) {
        TubeCategory.geopolitica => 'Geopolitica',
        TubeCategory.scienze => 'Scienze',
        TubeCategory.ai => 'AI',
        TubeCategory.stem => 'STEM',
        TubeCategory.tecnologia => 'Tecnologia',
      };

  String get searchKeyword => switch (this) {
        TubeCategory.geopolitica => 'geopolitics',
        TubeCategory.scienze => 'science',
        TubeCategory.ai => 'artificial intelligence',
        TubeCategory.stem => 'stem education',
        TubeCategory.tecnologia => 'technology',
      };

  String get playlistName => '$kPlaylistPrefix$name';

  IconData get icon => switch (this) {
        TubeCategory.geopolitica => Icons.public,
        TubeCategory.scienze => Icons.science,
        TubeCategory.ai => Icons.auto_awesome,
        TubeCategory.stem => Icons.calculate,
        TubeCategory.tecnologia => Icons.memory,
      };

  List<Color> get gradient => switch (this) {
        TubeCategory.geopolitica => [
            const Color(0xFF1E1E1E),
            const Color(0xFF2A2A2A),
          ],
        TubeCategory.scienze => [
            const Color(0xFF202020),
            const Color(0xFF2E2E2E),
          ],
        TubeCategory.ai => [
            const Color(0xFF1A1A1A),
            const Color(0xFF282828),
          ],
        TubeCategory.stem => [
            const Color(0xFF242424),
            const Color(0xFF303030),
          ],
        TubeCategory.tecnologia => [
            const Color(0xFF1C1C1C),
            const Color(0xFF2C2C2C),
          ],
      };
}
