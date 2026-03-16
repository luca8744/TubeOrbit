import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tubeorbit/core/theme.dart';
import 'auth_provider.dart';

class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo icon — minimal greyscale circle
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.surfaceVariant,
                  border: Border.all(color: AppTheme.surfaceHigh, width: 1.5),
                ),
                child: const Icon(
                  Icons.play_circle_outline,
                  size: 44,
                  color: AppTheme.textPrimary,
                ),
              ),

              const SizedBox(height: 28),

              Text(
                'TubeOrbit',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'YouTube curato per categoria',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 56),

              authAsync.when(
                loading: () => const CircularProgressIndicator(
                  color: AppTheme.accent,
                  strokeWidth: 1.5,
                ),
                error: (e, _) => Text(
                  'Errore: $e',
                  style: const TextStyle(color: AppTheme.error),
                ),
                data: (_) => _SignInButton(ref: ref),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SignInButton extends StatefulWidget {
  final WidgetRef ref;
  const _SignInButton({required this.ref});

  @override
  State<_SignInButton> createState() => _SignInButtonState();
}

class _SignInButtonState extends State<_SignInButton> {
  bool _loading = false;

  Future<void> _handleSignIn() async {
    setState(() => _loading = true);
    await widget.ref.read(authServiceProvider).signIn();
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: _loading ? null : _handleSignIn,
      icon: _loading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: AppTheme.onAccent,
              ),
            )
          : const Icon(Icons.account_circle_outlined, size: 18),
      label: Text(_loading ? 'Accesso in corso...' : 'Accedi con Google'),
    );
  }
}
