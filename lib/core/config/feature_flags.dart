class FeatureFlags {
  static const bool useGoogleAuth = bool.fromEnvironment('USE_GOOGLE_AUTH', defaultValue: false);
}
