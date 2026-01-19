import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gastronomic_os/core/theme/app_theme.dart';
import 'package:gastronomic_os/core/config/feature_flags.dart';
import 'package:gastronomic_os/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gastronomic_os/features/auth/presentation/bloc/auth_event.dart';
import 'package:gastronomic_os/features/auth/presentation/bloc/auth_state.dart';
// import 'package:sign_in_with_apple/sign_in_with_apple.dart'; // Later

class AuthLandingPage extends StatelessWidget {
  const AuthLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
        // Navigation to Dashboard handled by AuthWrapper in main.dart
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF121212), // Dark fallback background
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image with Gradient Overlay
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const NetworkImage(
                      'https://images.unsplash.com/photo-1547496502-ffa76f35cea5?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.7), // Darker overlay for better text contrast
                    BlendMode.darken,
                  ),
                  onError: (exception, stackTrace) {
                     // Fallback is handled by Scaffold backgroundColor, but we could log here
                  },
                ),
              ),
            ),
            
            // Content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo / Title
                    Spacer(),
                    
                    // Gradient Title
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFA500)], // Gold to Orange
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: Text(
                        'Gastronomic\nOS',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // Required for ShaderMask
                          height: 1.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.3, end: 0),
                    
                    const SizedBox(height: 16),
                    
                    Text(
                      'Manage, Cook, and Master your kitchen.',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        color: Colors.white.withOpacity(0.9),
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 400.ms, duration: 800.ms),
                    
                    Spacer(),

                    // Social Buttons
                    if (FeatureFlags.useGoogleAuth)
                      _SocialLoginButton(
                        label: 'Continue with Google',
                        iconData: Icons.g_mobiledata,
                        isLoading: false,
                        onPressed: () {
                           context.read<AuthBloc>().add(AuthSignInGoogle());
                        },
                      ).animate().fadeIn(delay: 800.ms, duration: 600.ms).slideY(begin: 0.5, end: 0),
                    
                    if (FeatureFlags.useGoogleAuth)
                      const SizedBox(height: 16),

                    // Guest Button (Enhanced Design)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.1),
                            Colors.white.withOpacity(0.05),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        onPressed: () {
                           context.read<AuthBloc>().add(AuthSignInAnonymously());
                        },
                        child: Text(
                          'Continue as Guest',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 1000.ms, duration: 600.ms),
                    
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            
            // Unobtrusive Loading Overlay
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthLoading) {
                  return Container(
                    color: Colors.black54,
                    child: const Center(
                      child: CircularProgressIndicator(color: Color(0xFFFFD700)),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialLoginButton extends StatelessWidget {
  final String label;
  final IconData iconData;
  final VoidCallback onPressed;
  final bool isLoading;

  const _SocialLoginButton({
    required this.label,
    required this.iconData,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      icon: Icon(iconData, size: 28),
      label: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
