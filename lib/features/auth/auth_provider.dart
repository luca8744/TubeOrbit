import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// Holds the currently signed-in user (or null).
/// Emits null immediately so the sign-in screen shows without waiting
/// for silentSignIn (which can hang when Google credentials are missing).
final authStateProvider = StreamProvider<GoogleSignInAccount?>((ref) async* {
  final service = ref.watch(authServiceProvider);

  // Show sign-in screen immediately instead of infinite spinner
  yield null;

  // Attempt silent sign-in in background (succeeds if previously signed in)
  final existing = await service.silentSignIn();
  if (existing != null) yield existing;

  // Continue listening to future auth state changes
  yield* service.onAuthStateChanged;
});
