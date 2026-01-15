import 'package:flutter/material.dart';
import 'package:gastronomic_os/core/services/ad_service.dart';
import 'package:gastronomic_os/core/services/iap_service.dart';
import 'package:gastronomic_os/init/injection_container.dart';
import 'package:gastronomic_os/l10n/generated/app_localizations.dart';

class ActionGuard {
  /// Guards an action with Rewarded Ad for non-premium users.
  /// 
  /// Flow:
  /// 1. Check isPremium.
  /// 2. If Premium -> Run [onAction].
  /// 3. If Free -> Show Dialog "Watch Ad to Continue?".
  /// 4. If User Agrees -> Show Ad -> Run [onAction].
  /// 5. If User Cancels -> Do nothing.
  static Future<void> guard(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onAction,
  }) async {
    final iapService = sl<IAPService>();
    final isPremium = await iapService.isUserPremium();

    if (isPremium) {
      onAction();
      return;
    }

    if (!context.mounted) return;

    // Show Dialog
    final l10n = AppLocalizations.of(context)!;
    final shouldWatch = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.play_circle_filled, color: Colors.amber),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message), // Message often passed contextually, but default prompt exists in l10n if needed by caller
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(ctx).pop(true),
            icon: const Icon(Icons.play_arrow),
            label: Text(l10n.actionWatchAd),
          ),
        ],
      ),
    );

    if (shouldWatch == true) {
      if (!context.mounted) return;
      
      // Show loading overlay if needed, or just trigger ad
      sl<AdService>().showRewardedAd(
        onReward: onAction,
        onDismiss: () {
          // Optional: Handle dismiss without reward if critical, 
          // but AdService logic triggers onReward only if earned.
        },
      );
    }
  }
}
