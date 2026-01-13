// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get settingsTitle => 'Settings';

  @override
  String get manageFamilyTitle => 'Manage Family';

  @override
  String get manageFamilySubtitle => 'Add, edit or remove family members.';

  @override
  String get resetDataTitle => 'Reset App Data';

  @override
  String get resetDataSubtitle =>
      'Clear all family profiles and reset onboarding status.';

  @override
  String get glossaryTitle => 'Glossary of Terms';

  @override
  String get glossarySubtitle => 'Learn about APLV, Keto, and other tags.';

  @override
  String get aboutTitle => 'About';

  @override
  String get aboutSubtitle => 'Version 0.5.0 Alpha';

  @override
  String get appearanceTitle => 'Appearance';

  @override
  String get appearanceSubtitle => 'System default';

  @override
  String get weeklyBridgeTitle => 'Weekly Bridge';

  @override
  String get shoppingListButton => 'Shopping List';
}
