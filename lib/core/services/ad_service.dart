import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  // Test ID for Rewarded Video
  final String rewardedAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/5224354917'
      : 'ca-app-pub-3940256099942544/1712485313';

  RewardedAd? _rewardedAd;

  Future<void> initialize() async {
    if (kIsWeb) return;
    await MobileAds.instance.initialize();
    debugPrint('AdMob initialized');
    _loadRewardedAd();
  }

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('Rewarded Ad Loaded');
          _rewardedAd = ad;
        },
        onAdFailedToLoad: (err) {
          debugPrint('Failed to load Rewarded Ad: $err');
          _rewardedAd = null;
        },
      ),
    );
  }

  void showRewardedAd({required VoidCallback onReward, VoidCallback? onDismiss}) {
    if (_rewardedAd == null) {
      debugPrint('Ad not valid, reloading and bypassing...');
      _loadRewardedAd();
      onReward(); // Fail-open: If ad fails, let user proceed
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadRewardedAd(); // Preload next one
        onDismiss?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        ad.dispose();
        _loadRewardedAd();
        onReward(); // Fail-open
      },
    );

    _rewardedAd!.show(onUserEarnedReward: (ad, reward) {
      debugPrint('User earned reward: ${reward.amount} ${reward.type}');
      onReward();
    });
    _rewardedAd = null; // Clear usage
  }

  // Placeholder App IDs (Test IDs)
  // Replace these with real IDs from AdMob console in production
  String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111'; // Android Test Banner
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716'; // iOS Test Banner
    }
    throw UnsupportedError('Unsupported platform');
  }
}
