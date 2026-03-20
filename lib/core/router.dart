import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tubeorbit/features/auth/auth_provider.dart';
import 'package:tubeorbit/features/auth/sign_in_screen.dart';
import 'package:tubeorbit/features/category/category_screen.dart';
import 'package:tubeorbit/features/feed/feed_screen.dart';
import 'package:tubeorbit/features/feed/video_player_screen.dart';
import 'package:tubeorbit/core/constants.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isSignedIn = authState.valueOrNull != null;
      if (!isSignedIn && state.matchedLocation != '/signin') {
        return '/signin';
      }
      if (isSignedIn && state.matchedLocation == '/signin') {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/signin',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const CategoryScreen(),
      ),
      GoRoute(
        path: '/feed/:category',
        builder: (context, state) {
          final categoryName = state.pathParameters['category']!;
          final category = TubeCategory.values.firstWhere(
            (c) => c.name == categoryName,
            orElse: () => TubeCategory.tecnologia,
          );
          return FeedScreen(category: category);
        },
      ),
      GoRoute(
        path: '/player/:id',
        builder: (context, state) {
          final videoId = state.pathParameters['id']!;
          return VideoPlayerScreen(videoId: videoId);
        },
      ),
    ],
  );
});
