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

  /// No description provided for @chefsSuggestionsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No suggestions right now'**
  String get chefsSuggestionsEmpty;

  /// No description provided for @chefsSuggestionsEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Add ingredients to your fridge or update your family profile'**
  String get chefsSuggestionsEmptyHint;

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

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Who eats here?'**
  String get onboardingTitle;

  /// No description provided for @onboardingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Build your household profile for personalized diet advice.'**
  String get onboardingSubtitle;

  /// No description provided for @onboardingAddMember.
  ///
  /// In en, this message translates to:
  /// **'Add Member'**
  String get onboardingAddMember;

  /// No description provided for @onboardingEditMember.
  ///
  /// In en, this message translates to:
  /// **'Edit Member'**
  String get onboardingEditMember;

  /// No description provided for @onboardingAvatarTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose Avatar'**
  String get onboardingAvatarTitle;

  /// No description provided for @onboardingNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get onboardingNameLabel;

  /// No description provided for @onboardingNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., John'**
  String get onboardingNameHint;

  /// No description provided for @onboardingRoleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get onboardingRoleLabel;

  /// No description provided for @onboardingLifestyleTitle.
  ///
  /// In en, this message translates to:
  /// **'Lifestyle (Base Diet)'**
  String get onboardingLifestyleTitle;

  /// No description provided for @onboardingLifestyleHint.
  ///
  /// In en, this message translates to:
  /// **'Select the main eating pattern.'**
  String get onboardingLifestyleHint;

  /// No description provided for @onboardingMedicalTitle.
  ///
  /// In en, this message translates to:
  /// **'Clinical Profile'**
  String get onboardingMedicalTitle;

  /// No description provided for @onboardingMedicalHint.
  ///
  /// In en, this message translates to:
  /// **'Select all that apply. These rules override lifestyle.'**
  String get onboardingMedicalHint;

  /// No description provided for @onboardingSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get onboardingSave;

  /// No description provided for @onboardingFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish Setup'**
  String get onboardingFinish;

  /// No description provided for @onboardingSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get onboardingSaveChanges;

  /// No description provided for @onboardingSuccess.
  ///
  /// In en, this message translates to:
  /// **'Family profile updated!'**
  String get onboardingSuccess;

  /// No description provided for @onboardingDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get onboardingDelete;

  /// No description provided for @roleDad.
  ///
  /// In en, this message translates to:
  /// **'Dad'**
  String get roleDad;

  /// No description provided for @roleMom.
  ///
  /// In en, this message translates to:
  /// **'Mom'**
  String get roleMom;

  /// No description provided for @roleSon.
  ///
  /// In en, this message translates to:
  /// **'Son'**
  String get roleSon;

  /// No description provided for @roleDaughter.
  ///
  /// In en, this message translates to:
  /// **'Daughter'**
  String get roleDaughter;

  /// No description provided for @roleGrandparent.
  ///
  /// In en, this message translates to:
  /// **'Grandparent'**
  String get roleGrandparent;

  /// No description provided for @roleRoommate.
  ///
  /// In en, this message translates to:
  /// **'Roommate'**
  String get roleRoommate;

  /// No description provided for @roleOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get roleOther;

  /// No description provided for @dietOmnivore.
  ///
  /// In en, this message translates to:
  /// **'Omnivore'**
  String get dietOmnivore;

  /// No description provided for @dietVegetarian.
  ///
  /// In en, this message translates to:
  /// **'Vegetarian'**
  String get dietVegetarian;

  /// No description provided for @dietVegan.
  ///
  /// In en, this message translates to:
  /// **'Vegan'**
  String get dietVegan;

  /// No description provided for @dietPescatarian.
  ///
  /// In en, this message translates to:
  /// **'Pescatarian'**
  String get dietPescatarian;

  /// No description provided for @dietKeto.
  ///
  /// In en, this message translates to:
  /// **'Keto'**
  String get dietKeto;

  /// No description provided for @dietPaleo.
  ///
  /// In en, this message translates to:
  /// **'Paleo'**
  String get dietPaleo;

  /// No description provided for @dietWhole30.
  ///
  /// In en, this message translates to:
  /// **'Whole30'**
  String get dietWhole30;

  /// No description provided for @dietMediterranean.
  ///
  /// In en, this message translates to:
  /// **'Mediterranean'**
  String get dietMediterranean;

  /// No description provided for @dietHighPerformance.
  ///
  /// In en, this message translates to:
  /// **'High Performance'**
  String get dietHighPerformance;

  /// No description provided for @dietLowCarb.
  ///
  /// In en, this message translates to:
  /// **'Low Carb'**
  String get dietLowCarb;

  /// No description provided for @conditionAplv.
  ///
  /// In en, this message translates to:
  /// **'APLV (Milk Allergy)'**
  String get conditionAplv;

  /// No description provided for @conditionEggAllergy.
  ///
  /// In en, this message translates to:
  /// **'Egg Allergy'**
  String get conditionEggAllergy;

  /// No description provided for @conditionSoyAllergy.
  ///
  /// In en, this message translates to:
  /// **'Soy Allergy'**
  String get conditionSoyAllergy;

  /// No description provided for @conditionNutAllergy.
  ///
  /// In en, this message translates to:
  /// **'Nut/Peanut Allergy'**
  String get conditionNutAllergy;

  /// No description provided for @conditionShellfishAllergy.
  ///
  /// In en, this message translates to:
  /// **'Shellfish Allergy'**
  String get conditionShellfishAllergy;

  /// No description provided for @conditionCeliac.
  ///
  /// In en, this message translates to:
  /// **'Celiac (Gluten Free)'**
  String get conditionCeliac;

  /// No description provided for @conditionLowFodmap.
  ///
  /// In en, this message translates to:
  /// **'Low FODMAP (IBS)'**
  String get conditionLowFodmap;

  /// No description provided for @conditionHistamine.
  ///
  /// In en, this message translates to:
  /// **'Histamine Intolerance'**
  String get conditionHistamine;

  /// No description provided for @conditionDiabetes.
  ///
  /// In en, this message translates to:
  /// **'Diabetes'**
  String get conditionDiabetes;

  /// No description provided for @conditionRenal.
  ///
  /// In en, this message translates to:
  /// **'Renal (Kidney Safe)'**
  String get conditionRenal;

  /// No description provided for @medicalTags.
  ///
  /// In en, this message translates to:
  /// **'Medical Tags'**
  String get medicalTags;

  /// No description provided for @recipeIngredientsTitle.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get recipeIngredientsTitle;

  /// No description provided for @recipeIngredientsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String recipeIngredientsCount(Object count);

  /// No description provided for @recipeIngredientsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No ingredients listed.'**
  String get recipeIngredientsEmpty;

  /// No description provided for @recipeInstructionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get recipeInstructionsTitle;

  /// No description provided for @recipeInstructionsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} steps'**
  String recipeInstructionsCount(Object count);

  /// No description provided for @recipeInstructionsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No instructions listed.'**
  String get recipeInstructionsEmpty;

  /// No description provided for @recipeIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Recipe ID: {id}'**
  String recipeIdLabel(Object id);

  /// No description provided for @recipeForking.
  ///
  /// In en, this message translates to:
  /// **'Forking Recipe...'**
  String get recipeForking;

  /// No description provided for @recipeAddToPlanTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add to Plan'**
  String get recipeAddToPlanTooltip;

  /// No description provided for @recipeForkTooltip.
  ///
  /// In en, this message translates to:
  /// **'Fork Recipe'**
  String get recipeForkTooltip;

  /// No description provided for @recipeLoginRequired.
  ///
  /// In en, this message translates to:
  /// **'Please log in to plan meals.'**
  String get recipeLoginRequired;

  /// No description provided for @recipeAddedToPlan.
  ///
  /// In en, this message translates to:
  /// **'Added \"{title}\" to {date}'**
  String recipeAddedToPlan(Object date, Object title);

  /// No description provided for @themeModeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeModeSystem;

  /// No description provided for @themeModeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeModeLight;

  /// No description provided for @themeModeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeModeDark;

  /// No description provided for @themeNameEmerald.
  ///
  /// In en, this message translates to:
  /// **'Emerald Tech'**
  String get themeNameEmerald;

  /// No description provided for @themeNameBlue.
  ///
  /// In en, this message translates to:
  /// **'Deep Blue'**
  String get themeNameBlue;

  /// No description provided for @themeNameSunset.
  ///
  /// In en, this message translates to:
  /// **'Sunset Haze'**
  String get themeNameSunset;

  /// No description provided for @themeNameForest.
  ///
  /// In en, this message translates to:
  /// **'Forest Green'**
  String get themeNameForest;

  /// No description provided for @themeNameSlate.
  ///
  /// In en, this message translates to:
  /// **'Elegant Slate'**
  String get themeNameSlate;

  /// No description provided for @appearanceThemeMode.
  ///
  /// In en, this message translates to:
  /// **'Theme Mode'**
  String get appearanceThemeMode;

  /// No description provided for @appearanceColorTheme.
  ///
  /// In en, this message translates to:
  /// **'Color Theme'**
  String get appearanceColorTheme;

  /// No description provided for @settingsDataPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Data & Privacy'**
  String get settingsDataPrivacy;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsApplication.
  ///
  /// In en, this message translates to:
  /// **'Application'**
  String get settingsApplication;

  /// No description provided for @settingsDebugZone.
  ///
  /// In en, this message translates to:
  /// **'Debug Zone'**
  String get settingsDebugZone;

  /// No description provided for @settingsEnableLogs.
  ///
  /// In en, this message translates to:
  /// **'Enable Application Logs'**
  String get settingsEnableLogs;

  /// No description provided for @settingsEnableLogsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Toggle detailed console logging.'**
  String get settingsEnableLogsSubtitle;

  /// No description provided for @settingsSeedTestRecipes.
  ///
  /// In en, this message translates to:
  /// **'Seed Test Recipes'**
  String get settingsSeedTestRecipes;

  /// No description provided for @settingsSeedTestRecipesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Populate Graph DB with Matrix Recipes'**
  String get settingsSeedTestRecipesSubtitle;

  /// No description provided for @settingsResetDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Everything?'**
  String get settingsResetDialogTitle;

  /// No description provided for @settingsResetDialogContent.
  ///
  /// In en, this message translates to:
  /// **'This action is irreversible. It will delete your family members, inventory, recipes, and reset the onboarding flow to the beginning.'**
  String get settingsResetDialogContent;

  /// No description provided for @settingsResetDialogConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete & Reset'**
  String get settingsResetDialogConfirm;

  /// No description provided for @inventoryTitle.
  ///
  /// In en, this message translates to:
  /// **'My Fridge'**
  String get inventoryTitle;

  /// No description provided for @inventoryEmptyState.
  ///
  /// In en, this message translates to:
  /// **'Fridge is empty!'**
  String get inventoryEmptyState;

  /// No description provided for @inventoryAddFirstItem.
  ///
  /// In en, this message translates to:
  /// **'Add First Item'**
  String get inventoryAddFirstItem;

  /// No description provided for @inventoryAddItem.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get inventoryAddItem;

  /// No description provided for @inventoryEditItem.
  ///
  /// In en, this message translates to:
  /// **'Edit Item'**
  String get inventoryEditItem;

  /// No description provided for @inventoryNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get inventoryNameLabel;

  /// No description provided for @inventoryQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get inventoryQuantityLabel;

  /// No description provided for @inventoryDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get inventoryDelete;

  /// No description provided for @inventoryUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get inventoryUpdate;

  /// No description provided for @inventoryAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get inventoryAdd;

  /// No description provided for @inventoryCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get inventoryCancel;

  /// No description provided for @inventoryExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get inventoryExpired;

  /// No description provided for @inventoryExpiringSoon.
  ///
  /// In en, this message translates to:
  /// **'Expiring soon'**
  String get inventoryExpiringSoon;

  /// No description provided for @inventoryDaysLeft.
  ///
  /// In en, this message translates to:
  /// **'{days}d left'**
  String inventoryDaysLeft(int days);

  /// No description provided for @commonError.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String commonError(String message);

  /// No description provided for @citation_1.
  ///
  /// In en, this message translates to:
  /// **'Label reading: processed products can hide dangerous ingredients under technical names.'**
  String get citation_1;

  /// No description provided for @citation_2.
  ///
  /// In en, this message translates to:
  /// **'Milk allergy: severe immunological reaction to proteins, not to be confused with lactose intolerance.'**
  String get citation_2;

  /// No description provided for @citation_3.
  ///
  /// In en, this message translates to:
  /// **'Non-dairy substitutes: products labeled as non-dairy often contain sodium caseinate.'**
  String get citation_3;

  /// No description provided for @citation_4.
  ///
  /// In en, this message translates to:
  /// **'Risk in cold cuts: shared slicing machines and use of casein contaminate meats with dairy proteins.'**
  String get citation_4;

  /// No description provided for @citation_5.
  ///
  /// In en, this message translates to:
  /// **'Hidden sources: canned tuna and processed snacks may use whey or casein as enhancers.'**
  String get citation_5;

  /// No description provided for @citation_6.
  ///
  /// In en, this message translates to:
  /// **'Functional substitution: soy and oat milk are the best replacements to maintain structure.'**
  String get citation_6;

  /// No description provided for @citation_7.
  ///
  /// In en, this message translates to:
  /// **'Food allergy: basic guide to replacing dairy ingredients without compromising safety.'**
  String get citation_7;

  /// No description provided for @citation_8.
  ///
  /// In en, this message translates to:
  /// **'Safe baking: plant-based alternatives exist that replicate the texture of cream and cream cheese.'**
  String get citation_8;

  /// No description provided for @citation_9.
  ///
  /// In en, this message translates to:
  /// **'Egg allergy: total exclusion required due to the impossibility of separating white and yolk without contamination.'**
  String get citation_9;

  /// No description provided for @citation_10.
  ///
  /// In en, this message translates to:
  /// **'Egg identifiers: albumin and lysozyme are egg proteins that appear under technical names.'**
  String get citation_10;

  /// No description provided for @citation_11.
  ///
  /// In en, this message translates to:
  /// **'Hidden binders: shiny breads and industrial meatballs often use egg for color.'**
  String get citation_11;

  /// No description provided for @citation_12.
  ///
  /// In en, this message translates to:
  /// **'Lecithin risk: if the origin is not specified, it should be avoided due to risk of being egg-derived.'**
  String get citation_12;

  /// No description provided for @citation_14.
  ///
  /// In en, this message translates to:
  /// **'Substitution limits: recipes requiring more than 3 eggs are difficult to adapt without losing structure.'**
  String get citation_14;

  /// No description provided for @citation_15.
  ///
  /// In en, this message translates to:
  /// **'Aquafaba: chickpea cooking water is the substitute capable of creating stable meringue-like foams.'**
  String get citation_15;

  /// No description provided for @citation_17.
  ///
  /// In en, this message translates to:
  /// **'Soy derivatives: miso, tofu, and soy sauce must be strictly excluded in allergic profiles.'**
  String get citation_17;

  /// No description provided for @citation_19.
  ///
  /// In en, this message translates to:
  /// **'Soy and wheat vectors: industrial vitamin E and Asian sauces often contain undeclared traces.'**
  String get citation_19;

  /// No description provided for @citation_20.
  ///
  /// In en, this message translates to:
  /// **'Shellfish allergy: tropomyosin protein generates strong cross-reactivity between crustaceans and mollusks.'**
  String get citation_20;

  /// No description provided for @citation_21.
  ///
  /// In en, this message translates to:
  /// **'Nuts: total exclusion of walnuts and almonds due to high risk of anaphylaxis.'**
  String get citation_21;

  /// No description provided for @citation_22.
  ///
  /// In en, this message translates to:
  /// **'Risky sauces: pesto and Mexican moles are common sources of hidden nuts.'**
  String get citation_22;

  /// No description provided for @citation_23.
  ///
  /// In en, this message translates to:
  /// **'Walnut oils: are often cold-pressed and retain proteins that cause allergy.'**
  String get citation_23;

  /// No description provided for @citation_24.
  ///
  /// In en, this message translates to:
  /// **'Inorganic phosphorus PHOS: additives absorbed at 100 percent damaging blood vessels in renal patients.'**
  String get citation_24;

  /// No description provided for @citation_25.
  ///
  /// In en, this message translates to:
  /// **'Salt risk: low sodium salts with potassium chloride KCl are lethal for renal patients.'**
  String get citation_25;

  /// No description provided for @citation_26.
  ///
  /// In en, this message translates to:
  /// **'Shellfish contamination: surimi and fish sauces contain real shellfish extracts.'**
  String get citation_26;

  /// No description provided for @citation_27.
  ///
  /// In en, this message translates to:
  /// **'Risky supplements: glucosamine is usually derived from crustacean shells.'**
  String get citation_27;

  /// No description provided for @citation_28.
  ///
  /// In en, this message translates to:
  /// **'Celiac disease: autoimmune disease where the damage threshold demands zero detectable gluten.'**
  String get citation_28;

  /// No description provided for @citation_161.
  ///
  /// In en, this message translates to:
  /// **'FODMAP vegetables: onion and garlic concentrate fructans that trigger intestinal inflammation.'**
  String get citation_161;

  /// No description provided for @citation_169.
  ///
  /// In en, this message translates to:
  /// **'Polyols: avocado and mushrooms contain sugars that cause bloating in sensitive people.'**
  String get citation_169;

  /// No description provided for @citation_173.
  ///
  /// In en, this message translates to:
  /// **'Safe grams: rice and quinoa are low fermentation carbohydrates ideal for irritable bowel.'**
  String get citation_173;

  /// No description provided for @citation_174.
  ///
  /// In en, this message translates to:
  /// **'Safe proteins: fresh meats and fish are naturally free of FODMAPs.'**
  String get citation_174;

  /// No description provided for @citation_368.
  ///
  /// In en, this message translates to:
  /// **'Histamine guide: Johns Hopkins principles for amine reduction using fresh foods.'**
  String get citation_368;

  /// No description provided for @citation_424.
  ///
  /// In en, this message translates to:
  /// **'Omnivore: base profile without animal origin restrictions.'**
  String get citation_424;

  /// No description provided for @citation_426.
  ///
  /// In en, this message translates to:
  /// **'Veganism: total exclusion of animal products; requires watching for hidden colorants.'**
  String get citation_426;

  /// No description provided for @citation_428.
  ///
  /// In en, this message translates to:
  /// **'Keto: metabolic goal of ketosis through severe restriction of net carbohydrates.'**
  String get citation_428;

  /// No description provided for @citation_429.
  ///
  /// In en, this message translates to:
  /// **'Grain exclusion: elimination of grains in ketogenic diets to force fat usage.'**
  String get citation_429;

  /// No description provided for @citation_430.
  ///
  /// In en, this message translates to:
  /// **'Paleo: diet based on pre-agricultural products eliminating grains and legumes.'**
  String get citation_430;

  /// No description provided for @citation_431.
  ///
  /// In en, this message translates to:
  /// **'Whole30: strict 30-day elimination protocol to identify inflammatory foods.'**
  String get citation_431;

  /// No description provided for @citation_432.
  ///
  /// In en, this message translates to:
  /// **'Mediterranean Diet: pattern based on PREDIMED study prioritizing olive oil and fiber.'**
  String get citation_432;

  /// No description provided for @citation_433.
  ///
  /// In en, this message translates to:
  /// **'Mediterranean restriction: limitation of red meats and refined sugars for cardiovascular health.'**
  String get citation_433;

  /// No description provided for @citation_434.
  ///
  /// In en, this message translates to:
  /// **'Athletes: focus on complex carbohydrates and high muscle bioavailability proteins.'**
  String get citation_434;

  /// No description provided for @citation_437.
  ///
  /// In en, this message translates to:
  /// **'CMPA Milk Allergy: reaction to casein strictly prohibiting the use of lactose-free products.'**
  String get citation_437;

  /// No description provided for @citation_438.
  ///
  /// In en, this message translates to:
  /// **'False security: lactose-free products keep allergenic proteins intact.'**
  String get citation_438;

  /// No description provided for @citation_439.
  ///
  /// In en, this message translates to:
  /// **'Egg Filter: blocking whole egg and its technical derivatives throughout the system matrix.'**
  String get citation_439;

  /// No description provided for @citation_441.
  ///
  /// In en, this message translates to:
  /// **'Soy Allergy: exclusion of soy isolates and industrial textured vegetable protein.'**
  String get citation_441;

  /// No description provided for @citation_443.
  ///
  /// In en, this message translates to:
  /// **'Liquor risk: drinks that may contain hidden nut proteins.'**
  String get citation_443;

  /// No description provided for @citation_444.
  ///
  /// In en, this message translates to:
  /// **'Tropomyosin: protein responsible for severe cross-allergies in shellfish consumption.'**
  String get citation_444;

  /// No description provided for @citation_445.
  ///
  /// In en, this message translates to:
  /// **'Strict Celiac: zero tolerance to wheat variants and grains like barley and rye.'**
  String get citation_445;

  /// No description provided for @citation_446.
  ///
  /// In en, this message translates to:
  /// **'FODMAP Protocol: management of fermentable sugars to reduce intestinal osmotic pressure.'**
  String get citation_446;

  /// No description provided for @citation_447.
  ///
  /// In en, this message translates to:
  /// **'SIGHI Histamine: extreme freshness rule excluding matured or fermented foods.'**
  String get citation_447;

  /// No description provided for @citation_448.
  ///
  /// In en, this message translates to:
  /// **'DAO Liberators: foods that, although fresh, trigger internal histamine release.'**
  String get citation_448;

  /// No description provided for @citation_449.
  ///
  /// In en, this message translates to:
  /// **'Diabetes: glycemic control through non-starchy vegetables and structural fiber.'**
  String get citation_449;

  /// No description provided for @citation_450.
  ///
  /// In en, this message translates to:
  /// **'Sugar Control: minimization of added sweeteners to stabilize blood glucose.'**
  String get citation_450;

  /// No description provided for @citation_451.
  ///
  /// In en, this message translates to:
  /// **'Nephropathy: potassium restriction and mandatory use of tuber leaching techniques.'**
  String get citation_451;

  /// No description provided for @citation_467.
  ///
  /// In en, this message translates to:
  /// **'CMPA Pathophysiology: clinical distinction between reaction to milk sugar and protein.'**
  String get citation_467;

  /// No description provided for @citation_468.
  ///
  /// In en, this message translates to:
  /// **'Medical differentiation: the algorithm separates metabolic intolerances from immunological allergies.'**
  String get citation_468;

  /// No description provided for @citation_469.
  ///
  /// In en, this message translates to:
  /// **'Lactose-free danger: critical warning about the presence of proteins in processed dairy.'**
  String get citation_469;

  /// No description provided for @citation_470.
  ///
  /// In en, this message translates to:
  /// **'Dairy reactivity: high probability of reaction to goat and sheep milk in patients allergic to cow.'**
  String get citation_470;

  /// No description provided for @citation_471.
  ///
  /// In en, this message translates to:
  /// **'Dairy Binders: use of caseinates to texture low-quality processed meats.'**
  String get citation_471;

  /// No description provided for @citation_472.
  ///
  /// In en, this message translates to:
  /// **'Hydrolysates: fragmented proteins that can still be recognized by the immune system.'**
  String get citation_472;

  /// No description provided for @citation_474.
  ///
  /// In en, this message translates to:
  /// **'Dairy additives: the preservative nisin and flavoring diacetyl are hidden dairy derivatives.'**
  String get citation_474;

  /// No description provided for @citation_475.
  ///
  /// In en, this message translates to:
  /// **'Deli hygiene: slicing machines are vectors of dairy cross-contamination.'**
  String get citation_475;

  /// No description provided for @citation_476.
  ///
  /// In en, this message translates to:
  /// **'Milk chemistry: soy is the closest substitute to animal milk due to its protein content.'**
  String get citation_476;

  /// No description provided for @citation_477.
  ///
  /// In en, this message translates to:
  /// **'Domestic contamination: it is impossible to separate white from yolk without transferring allergens.'**
  String get citation_477;

  /// No description provided for @citation_480.
  ///
  /// In en, this message translates to:
  /// **'Safe pasta: Italian durum wheat semolina dry pastas are usually egg-free.'**
  String get citation_480;

  /// No description provided for @citation_481.
  ///
  /// In en, this message translates to:
  /// **'Egg substitution: mashed banana or hydrated flax substitute binding function.'**
  String get citation_481;

  /// No description provided for @citation_485.
  ///
  /// In en, this message translates to:
  /// **'Refined Oils: refining eliminates allergenic protein making soy oil tolerable.'**
  String get citation_485;

  /// No description provided for @citation_486.
  ///
  /// In en, this message translates to:
  /// **'Cold pressed: virgin soy oils are unsafe because they retain proteins.'**
  String get citation_486;

  /// No description provided for @citation_488.
  ///
  /// In en, this message translates to:
  /// **'Lecithin caution: common additive requiring vegetable origin validation.'**
  String get citation_488;

  /// No description provided for @citation_489.
  ///
  /// In en, this message translates to:
  /// **'Industrial soy: soy protein isolate is a base ingredient in ultra-processed products.'**
  String get citation_489;

  /// No description provided for @citation_490.
  ///
  /// In en, this message translates to:
  /// **'Vegetable broths: often hide soy extracts or gluten as flavor enhancers.'**
  String get citation_490;

  /// No description provided for @citation_491.
  ///
  /// In en, this message translates to:
  /// **'Nut manufacturing: extreme risk of cross-contamination in shared plants.'**
  String get citation_491;

  /// No description provided for @citation_492.
  ///
  /// In en, this message translates to:
  /// **'Baking extracts: natural almond aromas often contain real proteins.'**
  String get citation_492;

  /// No description provided for @citation_494.
  ///
  /// In en, this message translates to:
  /// **'Cold cuts with nuts: meats like mortadella use pistachios, representing a hidden risk.'**
  String get citation_494;

  /// No description provided for @citation_495.
  ///
  /// In en, this message translates to:
  /// **'IgE Mechanism: shellfish allergy is a rapid response that can lead to anaphylaxis.'**
  String get citation_495;

  /// No description provided for @citation_496.
  ///
  /// In en, this message translates to:
  /// **'Environmental reactivity: allergic patients may react to shellfish cooking steam.'**
  String get citation_496;

  /// No description provided for @citation_497.
  ///
  /// In en, this message translates to:
  /// **'Fish Sauces: Asian condiments usually derived from anchovies or matured shellfish.'**
  String get citation_497;

  /// No description provided for @citation_498.
  ///
  /// In en, this message translates to:
  /// **'Shared frying: oil used to fry fish irretrievably contaminates other foods.'**
  String get citation_498;

  /// No description provided for @citation_500.
  ///
  /// In en, this message translates to:
  /// **'Celiac Standard: exclusion of any trace; low gluten diets are not suitable.'**
  String get citation_500;

  /// No description provided for @citation_501.
  ///
  /// In en, this message translates to:
  /// **'Forbidden grains: barley and rye contain gluten and must be blocked.'**
  String get citation_501;

  /// No description provided for @citation_502.
  ///
  /// In en, this message translates to:
  /// **'Generic Oats: risk of cross-contamination in mill; requires Gluten Free certification.'**
  String get citation_502;

  /// No description provided for @citation_503.
  ///
  /// In en, this message translates to:
  /// **'Tamari: fermented soy sauce variety without wheat, indispensable for celiacs.'**
  String get citation_503;

  /// No description provided for @citation_505.
  ///
  /// In en, this message translates to:
  /// **'Blue cheeses: risk of microscopic gluten traces from molds cultivated on bread.'**
  String get citation_505;

  /// No description provided for @citation_506.
  ///
  /// In en, this message translates to:
  /// **'Licorice: traditional licorice candy uses wheat flour as a structural base.'**
  String get citation_506;

  /// No description provided for @citation_507.
  ///
  /// In en, this message translates to:
  /// **'Airborne flour: suspended wheat dust can contaminate dishes up to hours later.'**
  String get citation_507;

  /// No description provided for @citation_508.
  ///
  /// In en, this message translates to:
  /// **'Porous utensils: wood retains gluten; steel is required for clinical safety.'**
  String get citation_508;

  /// No description provided for @citation_509.
  ///
  /// In en, this message translates to:
  /// **'Intestinal Fermentation: FODMAPs attract water and produce gas when consumed by bacteria.'**
  String get citation_509;

  /// No description provided for @citation_510.
  ///
  /// In en, this message translates to:
  /// **'Stacking Effect: accumulation of FODMAP doses can exceed tolerance threshold.'**
  String get citation_510;

  /// No description provided for @citation_511.
  ///
  /// In en, this message translates to:
  /// **'Infusion Logic: garlic fructans are water soluble but do not pass into hot oil.'**
  String get citation_511;

  /// No description provided for @citation_512.
  ///
  /// In en, this message translates to:
  /// **'Whole legumes: rich in GOS, cause strong bloating in irritable bowel.'**
  String get citation_512;

  /// No description provided for @citation_513.
  ///
  /// In en, this message translates to:
  /// **'Legume rinsing: washing canned lentils eliminates soluble fermentable sugars.'**
  String get citation_513;

  /// No description provided for @citation_514.
  ///
  /// In en, this message translates to:
  /// **'\'-ol\' sweeteners: xylitol and sorbitol act as osmotic laxatives in digestive diets.'**
  String get citation_514;

  /// No description provided for @citation_515.
  ///
  /// In en, this message translates to:
  /// **'DAO Deficit: enzymatic insufficiency preventing histamine degradation.'**
  String get citation_515;

  /// No description provided for @citation_516.
  ///
  /// In en, this message translates to:
  /// **'Time factor: in histamine intolerance, food age is critical.'**
  String get citation_516;

  /// No description provided for @citation_517.
  ///
  /// In en, this message translates to:
  /// **'Bacterial action: microorganisms transform histidine into histamine upon contact.'**
  String get citation_517;

  /// No description provided for @citation_518.
  ///
  /// In en, this message translates to:
  /// **'Leftover Risk: stored food accumulates amines rapidly that heat does not eliminate.'**
  String get citation_518;

  /// No description provided for @citation_519.
  ///
  /// In en, this message translates to:
  /// **'Old fish: canned goods are the biggest triggers of histamine crises.'**
  String get citation_519;

  /// No description provided for @citation_520.
  ///
  /// In en, this message translates to:
  /// **'Marine safety: fish frozen at sea stops histamine production.'**
  String get citation_520;

  /// No description provided for @citation_521.
  ///
  /// In en, this message translates to:
  /// **'SIGHI Safe List: freshly slaughtered white meats have the lowest amine levels.'**
  String get citation_521;

  /// No description provided for @citation_522.
  ///
  /// In en, this message translates to:
  /// **'Hyperkalemia: potassium excess due to kidney failure can cause cardiac arrhythmias.'**
  String get citation_522;

  /// No description provided for @citation_523.
  ///
  /// In en, this message translates to:
  /// **'Potassium Trap: salt substitutes with potassium chloride dangerous for renal filtration.'**
  String get citation_523;

  /// No description provided for @citation_524.
  ///
  /// In en, this message translates to:
  /// **'Technical leaching: peeling and soaking tubers 4h reduces potassium by half.'**
  String get citation_524;

  /// No description provided for @citation_525.
  ///
  /// In en, this message translates to:
  /// **'Natural phosphorus: present in meats, absorbed only partially (40-60%).'**
  String get citation_525;

  /// No description provided for @citation_526.
  ///
  /// In en, this message translates to:
  /// **'Chemical Phosphorus: processed additives absorbed at 100 percent representing renal risk.'**
  String get citation_526;

  /// No description provided for @citation_527.
  ///
  /// In en, this message translates to:
  /// **'PHOS Filter: label scanning looking for polyphosphates in meats and sodas.'**
  String get citation_527;

  /// No description provided for @citation_528.
  ///
  /// In en, this message translates to:
  /// **'Structural fiber: raw vegetables slow sugar entry into bloodstream.'**
  String get citation_528;

  /// No description provided for @citation_529.
  ///
  /// In en, this message translates to:
  /// **'Keto Restriction: elimination of sugar and flours to maintain fat burning.'**
  String get citation_529;

  /// No description provided for @citation_530.
  ///
  /// In en, this message translates to:
  /// **'Hidden spices: garlic and onion powder concentrate net carbs in Keto diets.'**
  String get citation_530;

  /// No description provided for @citation_531.
  ///
  /// In en, this message translates to:
  /// **'Keto Fillers: maltodextrin and dextrose in sweeteners that trigger insulin and break ketosis.'**
  String get citation_531;

  /// No description provided for @citation_532.
  ///
  /// In en, this message translates to:
  /// **'Whole30 SWPO: rule prohibiting recreating junk food with healthy ingredients.'**
  String get citation_532;

  /// No description provided for @citation_533.
  ///
  /// In en, this message translates to:
  /// **'Alcohol elimination: prohibited in Whole30 protocols due to inflammatory effect.'**
  String get citation_533;

  /// No description provided for @citation_534.
  ///
  /// In en, this message translates to:
  /// **'Inflammatory additives: carrageenan and MSG are prohibited due to intestinal irritation.'**
  String get citation_534;

  /// No description provided for @citation_535.
  ///
  /// In en, this message translates to:
  /// **'Animal Colorant E120: derived from crushed insects not suitable for strict vegan profile.'**
  String get citation_535;

  /// No description provided for @citation_536.
  ///
  /// In en, this message translates to:
  /// **'Vitamin Origin: D3 usually comes from lanolin; vegans require lichen sources.'**
  String get citation_536;

  /// No description provided for @citation_537.
  ///
  /// In en, this message translates to:
  /// **'PREDIMED Structure: olive oil base as shield against diseases.'**
  String get citation_537;

  /// No description provided for @citation_538.
  ///
  /// In en, this message translates to:
  /// **'Pro-inflammatory reduction: limitation of processed meats in Mediterranean pattern.'**
  String get citation_538;

  /// No description provided for @citation_540.
  ///
  /// In en, this message translates to:
  /// **'Cross frying: oil becomes toxic if it has previously processed gluten or shellfish.'**
  String get citation_540;

  /// No description provided for @citation_541.
  ///
  /// In en, this message translates to:
  /// **'Trace Management: warning labels treated as absolute prohibition in anaphylaxis.'**
  String get citation_541;

  /// No description provided for @citation_545.
  ///
  /// In en, this message translates to:
  /// **'Molecular precision: system distinguishes between white and yolk to maximize safety.'**
  String get citation_545;

  /// No description provided for @citation_550.
  ///
  /// In en, this message translates to:
  /// **'Soy avoidance: therapeutic protocol to eliminate all soy sources.'**
  String get citation_550;

  /// No description provided for @citation_552.
  ///
  /// In en, this message translates to:
  /// **'Surimi risk: shellfish imitation using real extracts, allergy vector.'**
  String get citation_552;

  /// No description provided for @citation_561.
  ///
  /// In en, this message translates to:
  /// **'Non-vegan additives: surveillance of hidden animal ingredients in processed foods.'**
  String get citation_561;

  /// No description provided for @citation_562.
  ///
  /// In en, this message translates to:
  /// **'Hidden ingredients: gelatin is a frequent animal derivative in sweets and snacks.'**
  String get citation_562;

  /// No description provided for @citation_566.
  ///
  /// In en, this message translates to:
  /// **'Integrity maintenance: matrix ensures dish maintains texture without risks.'**
  String get citation_566;

  /// No description provided for @citation_567.
  ///
  /// In en, this message translates to:
  /// **'Fruit binder: mashed banana binds ingredients but adds glycemic load.'**
  String get citation_567;

  /// No description provided for @citation_568.
  ///
  /// In en, this message translates to:
  /// **'Flax Egg: hydrated seeds to bind doughs in vegan or egg-free diets.'**
  String get citation_568;

  /// No description provided for @citation_570.
  ///
  /// In en, this message translates to:
  /// **'Technical foams: aquafaba allows making vegan mousses by trapping air.'**
  String get citation_570;

  /// No description provided for @citation_571.
  ///
  /// In en, this message translates to:
  /// **'Maillard Reaction: soy allows browning of doughs thanks to its vegetable protein.'**
  String get citation_571;

  /// No description provided for @citation_572.
  ///
  /// In en, this message translates to:
  /// **'Dense textures: silken tofu replicates the sensation of dairy creams.'**
  String get citation_572;

  /// No description provided for @citation_575.
  ///
  /// In en, this message translates to:
  /// **'Sodium substitution: use of fresh herbs and spices eliminates need for salt.'**
  String get citation_575;

  /// No description provided for @citation_576.
  ///
  /// In en, this message translates to:
  /// **'Wheat-free Umami: Tamari Sauce as safe substitute for traditional soy sauce with wheat.'**
  String get citation_576;

  /// No description provided for @citation_577.
  ///
  /// In en, this message translates to:
  /// **'Whole30 Sweetness: natural fruit juice is the only allowed way to sweeten.'**
  String get citation_577;

  /// No description provided for @citation_578.
  ///
  /// In en, this message translates to:
  /// **'Recovery optimization: choosing soy for complete amino acid profile.'**
  String get citation_578;

  /// No description provided for @citation_582.
  ///
  /// In en, this message translates to:
  /// **'Standard soy mode: allows use of refined oils where protein was eliminated.'**
  String get citation_582;

  /// No description provided for @citation_583.
  ///
  /// In en, this message translates to:
  /// **'Method substitution: leaching allows consuming tubers previously prohibited.'**
  String get citation_583;

  /// No description provided for @citation_584.
  ///
  /// In en, this message translates to:
  /// **'Rule automation: clinical logic integration to prevent human errors.'**
  String get citation_584;

  /// No description provided for @citation_587.
  ///
  /// In en, this message translates to:
  /// **'Absolute safety: allergy domain where traces can cause severe reactions.'**
  String get citation_587;

  /// No description provided for @citation_588.
  ///
  /// In en, this message translates to:
  /// **'Dairy exclusion: total prohibition of mammary secretions and their fats.'**
  String get citation_588;

  /// No description provided for @citation_589.
  ///
  /// In en, this message translates to:
  /// **'Dairy additives: surveillance of nisin, dairy derivative used as preservative.'**
  String get citation_589;

  /// No description provided for @citation_590.
  ///
  /// In en, this message translates to:
  /// **'Labeling traps: Non-dairy products can contain dairy proteins.'**
  String get citation_590;

  /// No description provided for @citation_591.
  ///
  /// In en, this message translates to:
  /// **'Egg Proteins: exclusion of ovalbumin responsible for most IgE reactions.'**
  String get citation_591;

  /// No description provided for @citation_593.
  ///
  /// In en, this message translates to:
  /// **'Egg sources: pastry shine is an undeclared egg vector.'**
  String get citation_593;

  /// No description provided for @citation_594.
  ///
  /// In en, this message translates to:
  /// **'Soy derivatives: blocking miso and tempeh in profiles with sensitivity.'**
  String get citation_594;

  /// No description provided for @citation_595.
  ///
  /// In en, this message translates to:
  /// **'Industrial texturized: soy frequently hides in meat fillers.'**
  String get citation_595;

  /// No description provided for @citation_596.
  ///
  /// In en, this message translates to:
  /// **'Broth contamination: flavorings are often soy or wheat derivatives.'**
  String get citation_596;

  /// No description provided for @citation_597.
  ///
  /// In en, this message translates to:
  /// **'Nut Check: exclusion of cashews due to heat-stable allergens.'**
  String get citation_597;

  /// No description provided for @citation_598.
  ///
  /// In en, this message translates to:
  /// **'Mortadella and Pesto: dishes hiding nuts requiring automatic alert.'**
  String get citation_598;

  /// No description provided for @citation_599.
  ///
  /// In en, this message translates to:
  /// **'Shellfish Identification: management of reactivity to tropomyosin.'**
  String get citation_599;

  /// No description provided for @citation_600.
  ///
  /// In en, this message translates to:
  /// **'Dangerous meat substitutes: seitan is pure gluten and risk for celiacs.'**
  String get citation_600;

  /// No description provided for @citation_601.
  ///
  /// In en, this message translates to:
  /// **'Barley yeast: brewer\'s yeast is often contaminated with gluten.'**
  String get citation_601;

  /// No description provided for @citation_602.
  ///
  /// In en, this message translates to:
  /// **'GF Certification: indispensable requirement for safe oat consumption.'**
  String get citation_602;

  /// No description provided for @citation_603.
  ///
  /// In en, this message translates to:
  /// **'Free Fructose: excess fructose in honey causes pain in FODMAP diets.'**
  String get citation_603;

  /// No description provided for @citation_604.
  ///
  /// In en, this message translates to:
  /// **'Polyol control: limited rations of mushrooms to avoid bloating.'**
  String get citation_604;

  /// No description provided for @citation_605.
  ///
  /// In en, this message translates to:
  /// **'Matured foods: ham and old cheeses concentrate prohibited histamine.'**
  String get citation_605;

  /// No description provided for @citation_606.
  ///
  /// In en, this message translates to:
  /// **'Mast cell degranulation: foods forcing release of own histamine.'**
  String get citation_606;

  /// No description provided for @citation_608.
  ///
  /// In en, this message translates to:
  /// **'Potassium density: banana is risky for kidneys with compromised filtration.'**
  String get citation_608;

  /// No description provided for @citation_609.
  ///
  /// In en, this message translates to:
  /// **'KCl Block: exclusion of salts using potassium due to cardiac risk.'**
  String get citation_609;

  /// No description provided for @citation_610.
  ///
  /// In en, this message translates to:
  /// **'PHOS Additives: inorganic phosphorus calcifies arteries in patients with chronic renal failure.'**
  String get citation_610;

  /// No description provided for @citation_611.
  ///
  /// In en, this message translates to:
  /// **'Glycemic load: elimination of flours to avoid insulin spikes and damage.'**
  String get citation_611;

  /// No description provided for @citation_613.
  ///
  /// In en, this message translates to:
  /// **'Diacetyl: butter flavoring with dairy traces, prohibited in strict CMPA.'**
  String get citation_613;

  /// No description provided for @citation_625.
  ///
  /// In en, this message translates to:
  /// **'Injected proteins: industrial poultry treated with dairy whey for texture.'**
  String get citation_625;

  /// No description provided for @citation_630.
  ///
  /// In en, this message translates to:
  /// **'Anti-AGEs techniques: poached egg is preferable to fried in diabetics.'**
  String get citation_630;

  /// No description provided for @citation_634.
  ///
  /// In en, this message translates to:
  /// **'Soluble oligosaccharides: legume washing eliminates gas-producing sugars.'**
  String get citation_634;

  /// No description provided for @citation_635.
  ///
  /// In en, this message translates to:
  /// **'Coconut traps: processed plant milks often use milk caseinates.'**
  String get citation_635;

  /// No description provided for @citation_636.
  ///
  /// In en, this message translates to:
  /// **'Cochineal: animal red dye that must be avoided in vegan profile.'**
  String get citation_636;

  /// No description provided for @citation_638.
  ///
  /// In en, this message translates to:
  /// **'Clinical Personalization: allows omitting leaching if user has no active renal pathology.'**
  String get citation_638;

  /// No description provided for @citation_640.
  ///
  /// In en, this message translates to:
  /// **'Dairy isolation: prohibition of using cheese to bind meats in CMPA.'**
  String get citation_640;

  /// No description provided for @citation_641.
  ///
  /// In en, this message translates to:
  /// **'Bioavailability: egg whites provide higher quality protein for athletes.'**
  String get citation_641;

  /// No description provided for @citation_1062.
  ///
  /// In en, this message translates to:
  /// **'Safe Maillard: intense browning of meat adds umami flavor allowing sodium elimination.'**
  String get citation_1062;

  /// No description provided for @citation_1065.
  ///
  /// In en, this message translates to:
  /// **'CMPA Validation: inspection of meats and additives to ensure total absence of caseinates.'**
  String get citation_1065;

  /// No description provided for @citation_1066.
  ///
  /// In en, this message translates to:
  /// **'Renal protein: restriction of animal portion to 100g to protect kidney filtration.'**
  String get citation_1066;

  /// No description provided for @citation_1067.
  ///
  /// In en, this message translates to:
  /// **'GF Airborne safety: prevention of contamination avoiding volatile flours or porous wood.'**
  String get citation_1067;

  /// No description provided for @citation_1068.
  ///
  /// In en, this message translates to:
  /// **'Quick Sauté: technique minimizing thermal exposure reducing histamine load.'**
  String get citation_1068;

  /// No description provided for @citation_1069.
  ///
  /// In en, this message translates to:
  /// **'Performance Load: Caloric and mineral density optimized for post-exercise recovery.'**
  String get citation_1069;

  /// No description provided for @citation_1070.
  ///
  /// In en, this message translates to:
  /// **'IBS Safe Broth: homemade liquid base without garlic or onion solids to avoid fructans.'**
  String get citation_1070;

  /// No description provided for @citation_1071.
  ///
  /// In en, this message translates to:
  /// **'Lipid Purity: Guarantee of virgin oils without hidden industrial soy mixtures.'**
  String get citation_1071;

  /// No description provided for @citation_1072.
  ///
  /// In en, this message translates to:
  /// **'Tenderizer scrutiny: Surveillance of processes injecting dairy or gluten to retain moisture.'**
  String get citation_1072;

  /// No description provided for @citation_1073.
  ///
  /// In en, this message translates to:
  /// **'Pasture fats: use of lard or tallow to align lipid profile with Paleo framework.'**
  String get citation_1073;

  /// No description provided for @citation_1074.
  ///
  /// In en, this message translates to:
  /// **'Nitrogen management: animal protein control to slow nephrotic damage progression.'**
  String get citation_1074;

  /// No description provided for @citation_1075.
  ///
  /// In en, this message translates to:
  /// **'Surface hygiene: deep cleaning protocol to avoid cross allergen traces.'**
  String get citation_1075;

  /// No description provided for @citation_1077.
  ///
  /// In en, this message translates to:
  /// **'Saturated Balance: Reduction of animal fats in favor of lean poultry for heart health.'**
  String get citation_1077;

  /// No description provided for @citation_1080.
  ///
  /// In en, this message translates to:
  /// **'Safe flavoring: use of controlled ferments like Tamari without wheat to provide umami.'**
  String get citation_1080;

  /// No description provided for @citation_1081.
  ///
  /// In en, this message translates to:
  /// **'PHOS Extraction: Bone risk due to release of inorganic phosphorus when boiling bones for broth.'**
  String get citation_1081;

  /// No description provided for @citation_1082.
  ///
  /// In en, this message translates to:
  /// **'Broth scanning: fish injected with covering broths is lethal source of phosphates.'**
  String get citation_1082;

  /// No description provided for @citation_1083.
  ///
  /// In en, this message translates to:
  /// **'SIGHI Quick Broth: in low histamine diets meat cooking must not exceed 60 minutes.'**
  String get citation_1083;

  /// No description provided for @citation_1084.
  ///
  /// In en, this message translates to:
  /// **'Glycemic stability: use of soluble fiber and fats to slow sugar absorption.'**
  String get citation_1084;

  /// No description provided for @citation_1085.
  ///
  /// In en, this message translates to:
  /// **'Hidden phosphorus: surveillance of PHOS additives frequently used in pork processing.'**
  String get citation_1085;

  /// No description provided for @citation_1086.
  ///
  /// In en, this message translates to:
  /// **'SIGHI Hake: high freshness white fish as marine protein of lowest reactive potential.'**
  String get citation_1086;

  /// No description provided for @citation_1087.
  ///
  /// In en, this message translates to:
  /// **'Post-leaching wash: forced draining of vegetables to eliminate potassium passed to water.'**
  String get citation_1087;

  /// No description provided for @citation_1088.
  ///
  /// In en, this message translates to:
  /// **'Binder Certification: Exclusive use of certified flours to guarantee safety in batters.'**
  String get citation_1088;

  /// No description provided for @legalTermsTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get legalTermsTitle;

  /// No description provided for @legalPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get legalPrivacyTitle;

  /// No description provided for @legalAccept.
  ///
  /// In en, this message translates to:
  /// **'I Accept'**
  String get legalAccept;

  /// No description provided for @legalWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Gastronomic OS'**
  String get legalWelcome;

  /// No description provided for @legalSummary.
  ///
  /// In en, this message translates to:
  /// **'To continue, please review and accept our Terms and Privacy Policy. Your trust and safety are our priority.'**
  String get legalSummary;

  /// No description provided for @legalDisclaimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Medical Disclaimer'**
  String get legalDisclaimerTitle;

  /// No description provided for @legalDisclaimerContent.
  ///
  /// In en, this message translates to:
  /// **'Gastronomic OS provides nutritional suggestions but is NOT a substitute for professional medical advice. Always consult your physician or Dietitian before making significant changes to your diet, especially if you have a medical condition.'**
  String get legalDisclaimerContent;
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
