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
        TubeCategory.geopolitica => 'geopolitica|geopolitics',
        TubeCategory.scienze => 'scienza|science',
        TubeCategory.ai => 'intelligenza artificiale|"artificial intelligence"',
        TubeCategory.stem => 'stem education|divulgazione scientifica',
        TubeCategory.tecnologia => 'tecnologia|technology',
      };

  String get italianSearchKeyword => switch (this) {
        TubeCategory.geopolitica => 'geopolitica',
        TubeCategory.scienze => 'scienza',
        TubeCategory.ai => 'intelligenza artificiale',
        TubeCategory.stem => 'divulgazione scientifica',
        TubeCategory.tecnologia => 'tecnologia',
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

// ─── Content Languages ─────────────────────────────────────────────────────────
enum ContentLanguage {
  all,
  us,
  ita,
  eu;

  String get displayName => switch (this) {
        ContentLanguage.all => '🌍 ALL',
        ContentLanguage.us => '🇺🇸 US',
        ContentLanguage.ita => '🇮🇹 ITA',
        ContentLanguage.eu => '🇪🇺 EU',
      };

  String? get regionCode => switch (this) {
        ContentLanguage.all => null,
        ContentLanguage.us => 'US',
        ContentLanguage.ita => 'IT',
        ContentLanguage.eu => 'GB',
      };

  String? get relevanceLanguage => switch (this) {
        ContentLanguage.all => null,
        ContentLanguage.us => 'en',
        ContentLanguage.ita => 'it',
        ContentLanguage.eu => null,
      };

  List<String>? get allowedCountries => switch (this) {
        ContentLanguage.all => null,
        ContentLanguage.us => const ['US', 'GB', 'CA', 'AU', 'NZ', 'IE'],
        ContentLanguage.ita => const ['IT', 'SM', 'VA', 'CH'],
        ContentLanguage.eu => const [
            'AT', 'BE', 'BG', 'HR', 'CY', 'CZ', 'DK', 'EE', 'FI', 'FR', 'DE', 'GR', 
            'HU', 'IE', 'IT', 'LV', 'LT', 'LU', 'MT', 'NL', 'PL', 'PT', 'RO', 'SK', 
            'SI', 'ES', 'SE', 'GB', 'CH', 'NO'
          ],
      };

  String getSearchKeyword(TubeCategory category) => switch (this) {
        ContentLanguage.ita => category.italianSearchKeyword,
        _ => category.searchKeyword,
      };
}

// ─── Sorting Options ───────────────────────────────────────────────────────────
enum VideoSortOption {
  viewCount,
  date;

  String get displayName => switch (this) {
        VideoSortOption.viewCount => '🔥 Più visti',
        VideoSortOption.date => '⏱️ Più recenti',
      };

  String get apiValue => name;
}
