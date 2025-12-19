import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lvoapp/features/auth/data/auth_repository.dart';
import '../../../../core/config/theme.dart';

class VerifiedSuccessScreen extends ConsumerStatefulWidget {
  const VerifiedSuccessScreen({super.key});

  @override
  ConsumerState<VerifiedSuccessScreen> createState() =>
      _VerifiedSuccessScreenState();
}

class _VerifiedSuccessScreenState extends ConsumerState<VerifiedSuccessScreen> {
  @override
  void initState() {
    super.initState();
    // Ensure profile is created as soon as verification is confirmed (session is active from deep link)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authRepositoryProvider).ensureProfileExists();
    });
  }

  Future<void> _handleContinue() async {
    // Determine if we are logged in (Supabase auto-login from deep link)
    // We want to force manual login as per user request.
    // So we sign out first.
    await ref.read(authRepositoryProvider).signOut();
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.backgroundColor, Color(0xFF1A1A2E)],
              ),
            ),
          ),

          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_outline_rounded,
                      color: Colors.green,
                      size: 80,
                    ),
                  ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),

                  const SizedBox(height: 32),

                  Text(
                    'Email Terverifikasi!',
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn().slideY(begin: 0.3, end: 0),

                  const SizedBox(height: 16),

                  Text(
                    'Akun Anda telah aktif. Silakan masuk untuk melanjutkan.',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: 48),

                  ElevatedButton(
                    onPressed: _handleContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Masuk ke Aplikasi'),
                  ).animate().fadeIn(delay: 400.ms).scale(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
