import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @manageFamilyTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage Family'**
  String get manageFamilyTitle;

  /// No description provided for @manageFamilySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add, edit or remove family members.'**
  String get manageFamilySubtitle;

  /// No description provided for @resetDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset App Data'**
  String get resetDataTitle;

  /// No description provided for @resetDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Clear all family profiles and reset onboarding status.'**
  String get resetDataSubtitle;

  /// No description provided for @glossaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Glossary of Terms'**
  String get glossaryTitle;

  /// No description provided for @glossarySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Learn about APLV, Keto, and other tags.'**
  String get glossarySubtitle;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// No description provided for @aboutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Version 0.5.0 Alpha'**
  String get aboutSubtitle;

  /// No description provided for @appearanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceTitle;

  /// No description provided for @appearanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get appearanceSubtitle;

  /// No description provided for @weeklyBridgeTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly Bridge'**
  String get weeklyBridgeTitle;

  /// No description provided for @dashboardGreeting.
  ///
  /// In en, this message translates to:
  /// **'Good Morning!'**
  String get dashboardGreeting;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'What are we cooking?'**
  String get dashboardTitle;

  /// No description provided for @dashboardFridgeTitle.
  ///
  /// In en, this message translates to:
  /// **'My Fridge'**
  String get dashboardFridgeTitle;

  /// No description provided for @dashboardFridgeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your supplies'**
  String get dashboardFridgeSubtitle;

  /// No description provided for @dashboardCookbookTitle.
  ///
  /// In en, this message translates to:
  /// **'Cookbook'**
  String get dashboardCookbookTitle;

  /// No description provided for @dashboardCookbookSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Explore recipes'**
  String get dashboardCookbookSubtitle;

  /// No description provided for @dashboardPlannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly Bridge'**
  String get dashboardPlannerTitle;

  /// No description provided for @dashboardPlannerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Plan your meals'**
  String get dashboardPlannerSubtitle;

  /// No description provided for @dashboardSocialTitle.
  ///
  /// In en, this message translates to:
  /// **'Social'**
  String get dashboardSocialTitle;

  /// No description provided for @dashboardSocialSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share & Discover (Coming Soon)'**
  String get dashboardSocialSubtitle;

  /// No description provided for @plannerEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No meals planned yet.'**
  String get plannerEmptyTitle;

  /// No description provided for @plannerEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add recipes from the Cookbook!'**
  String get plannerEmptySubtitle;

  /// No description provided for @shoppingListButton.
  ///
  /// In en, this message translates to:
  /// **'Shopping List'**
  String get shoppingListButton;

  /// No description provided for @shoppingListTitle.
  ///
  /// In en, this message translates to:
  /// **'Shopping List'**
  String get shoppingListTitle;

  /// No description provided for @shoppingListEmpty.
  ///
  /// In en, this message translates to:
  /// **'List is empty. Plan some meals!'**
  String get shoppingListEmpty;

  /// No description provided for @shoppingListVariant.
  ///
  /// In en, this message translates to:
  /// **'Variant'**
  String get shoppingListVariant;

  /// No description provided for @quickReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick Review'**
  String get quickReviewTitle;

  /// No description provided for @socialComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Social features coming soon!'**
  String get socialComingSoon;

  /// No description provided for @mealTypeDinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get mealTypeDinner;

  /// No description provided for @mealTypeLunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get mealTypeLunch;

  /// No description provided for @mealTypeBreakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get mealTypeBreakfast;

  /// No description provided for @mealTypeSnack.
  ///
  /// In en, this message translates to:
  /// **'Snack'**
  String get mealTypeSnack;

  /// No description provided for @chefsSuggestionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Chef\'s Suggestions'**
  String get chefsSuggestionsTitle;

  /// No description provided for @chefsSuggestionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Optimized for your fridge & family'**
  String get chefsSuggestionsSubtitle;

  /// No description provided for @matchGreatValue.
  ///
  /// In en, this message translates to:
  /// **'Great Value'**
  String get matchGreatValue;

  /// No description provided for @matchGoodMatch.
  ///
  /// In en, this message translates to:
  /// **'Good Match'**
  String get matchGoodMatch;

  /// No description provided for @recipesTitle.
  ///
  /// In en, this message translates to:
  /// **'Recipes'**
  String get recipesTitle;

  /// No description provided for @searchRecipesHint.
  ///
  /// In en, this message translates to:
  /// **'Search recipes...'**
  String get searchRecipesHint;

  /// No description provided for @filterFamilySafe.
  ///
  /// In en, this message translates to:
  /// **'Family Safe'**
  String get filterFamilySafe;

  /// No description provided for @filterBestMatch.
  ///
  /// In en, this message translates to:
  /// **'Best Match (Available)'**
  String get filterBestMatch;

  /// No description provided for @filterAddIngredient.
  ///
  /// In en, this message translates to:
  /// **'Add Ingredient'**
  String get filterAddIngredient;

  /// No description provided for @dialogAddIngredientTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Ingredient'**
  String get dialogAddIngredientTitle;

  /// No description provided for @dialogIngredientLabel.
  ///
  /// In en, this message translates to:
  /// **'Ingredient'**
  String get dialogIngredientLabel;

  /// No description provided for @dialogIngredientHint.
  ///
  /// In en, this message translates to:
  /// **'E.g., Chicken'**
  String get dialogIngredientHint;

  /// No description provided for @dialogCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get dialogCancel;

  /// No description provided for @dialogAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get dialogAdd;

  /// No description provided for @recipesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No matching recipes found'**
  String get recipesEmptyTitle;

  /// No description provided for @recipesClearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get recipesClearFilters;

  /// No description provided for @recipesNewRecipeButton.
  ///
  /// In en, this message translates to:
  /// **'New Recipe'**
  String get recipesNewRecipeButton;

  /// No description provided for @editorNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New Recipe'**
  String get editorNewTitle;

  /// No description provided for @editorEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Recipe'**
  String get editorEditTitle;

  /// No description provided for @editorTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get editorTitleLabel;

  /// No description provided for @editorTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get editorTitleRequired;

  /// No description provided for @editorDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get editorDescriptionLabel;

  /// No description provided for @editorIngredientsSection.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get editorIngredientsSection;

  /// No description provided for @editorIngredientsHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., 200g Flour'**
  String get editorIngredientsHint;

  /// No description provided for @editorInstructionsSection.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get editorInstructionsSection;

  /// No description provided for @editorInstructionsHint.
  ///
  /// In en, this message translates to:
  /// **'Describe the step...'**
  String get editorInstructionsHint;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
