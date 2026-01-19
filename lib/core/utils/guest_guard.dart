import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gastronomic_os/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gastronomic_os/features/auth/presentation/bloc/auth_state.dart';
import 'package:google_fonts/google_fonts.dart';

class GuestGuard {
  /// Checks if the current user is a guest.
  /// If Guest: Shows a dialog prompting upgrade (or login).
  /// If Authenticated: Executes [onAuthorized].
  static void check({
    required BuildContext context,
    required VoidCallback onAuthorized,
    String featureName = 'this feature',
  }) {
    final state = context.read<AuthBloc>().state;
    
    if (state is AuthGuest) {
      _showUpgradeDialog(context, featureName);
    } else if (state is AuthAuthenticated) {
      onAuthorized();
    } else {
      // Unauthenticated - shouldn't happen deep in app, but handle gracefully
      // Maybe redirect to login? For now show dialog.
      _showUpgradeDialog(context, featureName);
    }
  }

  static void _showUpgradeDialog(BuildContext context, String featureName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Account Required', style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold)),
        content: Text('You need to sign in with a full account to $featureName. Guest accounts are read-only for community features.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to Upgrade/Link Account Page
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account Upgrading coming soon!')),
              );
            },
            child: const Text('Sign In / Upgrade'),
          ),
        ],
      ),
    );
  }
}
