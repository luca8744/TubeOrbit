# TubeOrbit

A Flutter mobile application (iOS & Android) that wraps YouTube content by curated categories. Browse Videos and Shorts, authenticate with your Google account, and save your favourite content to automatically managed YouTube playlists.

---

## Features

- **Category Selection** — choose from 5 curated topics: Geopolitics, Science, AI, STEM, Technology
- **Video & Shorts Tabs** — switch between regular videos and Shorts, all filtered by the active category
- **Google Sign-In** — authenticate with your YouTube account via OAuth 2.0
- **Smart Playlists** — playlists named `tubeorbit_<category>` are auto-created on your YouTube account on first save
- **User-initiated Saves** — tap the bookmark icon → confirm in a bottom sheet → video is added to the playlist. Nothing is saved without explicit user confirmation
- **Remove from Playlist** — tap a filled bookmark to remove the video
- **Infinite Scroll** — paginated loading via YouTube Data API v3 `nextPageToken`
- **Dark AMOLED Theme** — violet accent, Inter typography, Hero transitions between screens

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter (Dart) |
| State Management | Riverpod 2 |
| Navigation | GoRouter |
| HTTP | Dio |
| Auth | `google_sign_in` + `googleapis_auth` |
| YouTube API | YouTube Data API v3 via `googleapis` |
| Video Open | `url_launcher` → external YouTube app |
| Image Cache | `cached_network_image` |
| Fonts | Google Fonts – Inter |

---

## Project Structure

```
lib/
├── main.dart                        # ProviderScope entrypoint
├── app.dart                         # MaterialApp.router + theme
├── core/
│   ├── constants.dart               # TubeCategory enum, kPlaylistPrefix, kScopes
│   ├── theme.dart                   # AMOLED dark theme
│   └── router.dart                  # GoRouter with auth guard
├── features/
│   ├── auth/
│   │   ├── auth_service.dart        # GoogleSignIn wrapper
│   │   ├── auth_provider.dart       # Riverpod auth state stream
│   │   └── sign_in_screen.dart      # Sign-in UI
│   ├── category/
│   │   └── category_screen.dart     # Category grid with Hero cards
│   ├── feed/
│   │   ├── feed_provider.dart       # Video list + pagination
│   │   ├── feed_screen.dart         # SliverAppBar + TabBar + list
│   │   └── video_card.dart          # Thumbnail, title, bookmark button
│   └── playlist/
│       ├── playlist_provider.dart   # Playlist cache + saved video state
│       └── save_bottom_sheet.dart   # Save/remove confirmation sheet
└── shared/
    ├── models/video_model.dart      # VideoModel data class
    └── api/youtube_api_client.dart  # YouTube Data API v3 Dio client
```

---

## Categories

| Name | Search Query | Playlist |
|------|-------------|---------|
| Geopolitica | geopolitics | `tubeorbit_geopolitica` |
| Scienze | science | `tubeorbit_scienze` |
| AI | artificial intelligence | `tubeorbit_ai` |
| STEM | stem education | `tubeorbit_stem` |
| Tecnologia | technology | `tubeorbit_tecnologia` |

---

## Getting Started

### Prerequisites

- Flutter SDK `>=3.12`
- A Google Cloud project with **YouTube Data API v3** enabled
- OAuth 2.0 Client IDs for iOS and Android

### 1. Clone & install dependencies

```bash
git clone <repo-url>
cd TubeOrbit
flutter pub get
```

### 2. Google Cloud setup

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Enable **YouTube Data API v3**
3. Create **OAuth 2.0 Client IDs**:
   - iOS — bundle ID: `com.tubeorbit.tubeorbit`
   - Android — SHA-1 fingerprint of your keystore
4. Download `GoogleService-Info.plist` → place in `ios/Runner/`
5. Download `google-services.json` → place in `android/app/`

### 3. iOS URL scheme

Open `ios/Runner/Info.plist` and replace the placeholder:

```xml
<string>com.googleusercontent.apps.YOUR_REVERSED_CLIENT_ID</string>
```

Use the `REVERSED_CLIENT_ID` value from your `GoogleService-Info.plist`.

### 4. Run

```bash
flutter run
```

> ⚠️ **Google Sign-In requires a physical device on iOS.** It does not work on the iOS Simulator.

---

## API Quota

| Operation | Cost (units) |
|-----------|-------------|
| Search | 100 |
| Playlists insert | 50 |
| PlaylistItems insert | 50 |

Default daily quota: **10,000 units**. Results are cached per session to minimise usage.

---

## Security

The credential files `GoogleService-Info.plist` and `google-services.json` are listed in `.gitignore` and are **never committed** to version control.

> ℹ️ **Public Git Repository Notice**
> If you are compiling this project from a cloned public repository, the authentication will fail by default since those files are missing. You must create your own Google Cloud Project, enable the YouTube Data API v3, create your own OAuth 2.0 Client IDs, and download your personal configuration files as explained in the [Google Cloud Setup](#2-google-cloud-setup) section.
---

## Out of Scope (v1)

- Push notifications
- Offline video download
- Comments / likes sync
- Multi-account support

---

*Built with Flutter · March 2026*
