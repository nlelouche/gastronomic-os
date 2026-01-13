import 'package:flutter/widgets.dart';
import 'package:gastronomic_os/core/enums/diet_enums.dart';
import 'package:gastronomic_os/core/enums/family_role.dart';
import 'package:gastronomic_os/l10n/generated/app_localizations.dart';

extension LocalizedDiet on DietLifestyle {
  String localized(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case DietLifestyle.omnivore: return l10n.dietOmnivore;
      case DietLifestyle.vegetarian: return l10n.dietVegetarian;
      case DietLifestyle.vegan: return l10n.dietVegan;
      case DietLifestyle.pescatarian: return l10n.dietPescatarian;
      case DietLifestyle.keto: return l10n.dietKeto;
      case DietLifestyle.paleo: return l10n.dietPaleo;
      case DietLifestyle.whole30: return l10n.dietWhole30;
      case DietLifestyle.mediterranean: return l10n.dietMediterranean;
      case DietLifestyle.highPerformance: return l10n.dietHighPerformance;
      case DietLifestyle.lowCarb: return l10n.dietLowCarb;
    }
  }
}

extension LocalizedMedicalCondition on MedicalCondition {
  String localized(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case MedicalCondition.aplv: return l10n.conditionAplv;
      case MedicalCondition.eggAllergy: return l10n.conditionEggAllergy;
      case MedicalCondition.soyAllergy: return l10n.conditionSoyAllergy;
      case MedicalCondition.nutAllergy: return l10n.conditionNutAllergy;
      case MedicalCondition.shellfishAllergy: return l10n.conditionShellfishAllergy;
      case MedicalCondition.celiac: return l10n.conditionCeliac;
      case MedicalCondition.lowFodmap: return l10n.conditionLowFodmap;
      case MedicalCondition.histamine: return l10n.conditionHistamine;
      case MedicalCondition.diabetes: return l10n.conditionDiabetes;
      case MedicalCondition.renal: return l10n.conditionRenal;
    }
  }
}

extension LocalizedFamilyRole on FamilyRole {
  String localized(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case FamilyRole.dad: return l10n.roleDad;
      case FamilyRole.mom: return l10n.roleMom;
      case FamilyRole.son: return l10n.roleSon;
      case FamilyRole.daughter: return l10n.roleDaughter;
      case FamilyRole.grandparent: return l10n.roleGrandparent;
      case FamilyRole.roommate: return l10n.roleRoommate;
      case FamilyRole.other: return l10n.roleOther;
    }
  }
}
