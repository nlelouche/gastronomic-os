import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class RemoteConfigService {
  final FirebaseRemoteConfig _remoteConfig;

  RemoteConfigService({FirebaseRemoteConfig? remoteConfig})
      : _remoteConfig = remoteConfig ?? FirebaseRemoteConfig.instance;

  Future<void> initialize() async {
    try {
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: kDebugMode 
            ? const Duration(minutes: 5) 
            : const Duration(hours: 12),
      ));

      // Default values
      await _remoteConfig.setDefaults({
        'free_family_limit': 2,
        'ad_frequency_feed': 2, // Changed to 2 for easier testing
        'show_interstitial_on_save': true,
        'premium_price_tag_string': '\$4.99/mo',
        'is_paywall_hard_gate': false,
        'welcome_message': 'Welcome to Gastronomic OS!',
      });

      await _remoteConfig.fetchAndActivate();
      debugPrint('Remote Config initialized and fetched');
      debugPrint('RC: free_family_limit = ${_remoteConfig.getInt('free_family_limit')}');
      debugPrint('RC: ad_frequency_feed = ${_remoteConfig.getInt('ad_frequency_feed')}');
      debugPrint('RC: show_interstitial_on_save = ${_remoteConfig.getBool('show_interstitial_on_save')}');
      debugPrint('RC: premium_price_tag_string = ${_remoteConfig.getString('premium_price_tag_string')}');
    } catch (e) {
      debugPrint('Error initializing Remote Config: $e');
    }
  }

  // Getters
  int get freeFamilyLimit => _remoteConfig.getInt('free_family_limit');
  int get adFrequencyFeed => _remoteConfig.getInt('ad_frequency_feed');
  bool get showInterstitialOnSave => _remoteConfig.getBool('show_interstitial_on_save');
  String get premiumPriceTagString => _remoteConfig.getString('premium_price_tag_string');
  bool get isPaywallHardGate => _remoteConfig.getBool('is_paywall_hard_gate');
  String get welcomeMessage => _remoteConfig.getString('welcome_message');
}
