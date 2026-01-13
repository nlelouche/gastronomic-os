enum DietLifestyle {
  omnivore,
  vegetarian,
  vegan,
  pescatarian,
  keto,
  paleo,
  whole30,
  mediterranean,
  highPerformance,
  lowCarb; // New addition

  String get displayName {
    switch (this) {
      case DietLifestyle.omnivore: return 'Omnivore';
      case DietLifestyle.vegetarian: return 'Vegetarian';
      case DietLifestyle.vegan: return 'Vegan';
      case DietLifestyle.pescatarian: return 'Pescatarian';
      case DietLifestyle.keto: return 'Keto';
      case DietLifestyle.paleo: return 'Paleo';
      case DietLifestyle.whole30: return 'Whole30';
      case DietLifestyle.mediterranean: return 'Mediterranean';
      case DietLifestyle.highPerformance: return 'High Performance';
      case DietLifestyle.lowCarb: return 'Low Carb';
    }
  }

  /// The strict key used in Recipe JSONs and Logic checks
  String get key {
    switch (this) {
      case DietLifestyle.omnivore: return 'Omnivore';
      case DietLifestyle.vegetarian: return 'Vegetarian';
      case DietLifestyle.vegan: return 'Vegan';
      case DietLifestyle.pescatarian: return 'Pescatarian';
      case DietLifestyle.keto: return 'Keto';
      case DietLifestyle.paleo: return 'Paleo';
      case DietLifestyle.whole30: return 'Whole30';
      case DietLifestyle.mediterranean: return 'Mediterranean';
      case DietLifestyle.highPerformance: return 'High Performance';
      case DietLifestyle.lowCarb: return 'Low Carb';
    }
  }
}

enum MedicalCondition {
  aplv,             // Cow's Milk Protein Allergy
  eggAllergy,       // Maps from 'egg_allergy'
  soyAllergy,       // Maps from 'soy_allergy'
  nutAllergy,       // Maps from 'nut_allergy'
  shellfishAllergy, // Maps from 'shellfish_allergy'
  celiac,
  lowFodmap,        // Maps from 'low_fodmap'
  histamine,
  diabetes,
  renal;

  String get displayName {
    switch (this) {
      case MedicalCondition.aplv: return 'APLV (Milk Allergy)';
      case MedicalCondition.eggAllergy: return 'Egg Allergy';
      case MedicalCondition.soyAllergy: return 'Soy Allergy';
      case MedicalCondition.nutAllergy: return 'Nut/Peanut Allergy';
      case MedicalCondition.shellfishAllergy: return 'Shellfish Allergy';
      case MedicalCondition.celiac: return 'Celiac (Gluten Free)';
      case MedicalCondition.lowFodmap: return 'Low FODMAP (IBS)';
      case MedicalCondition.histamine: return 'Histamine Intolerance';
      case MedicalCondition.diabetes: return 'Diabetes';
      case MedicalCondition.renal: return 'Renal (Kidney Safe)';
    }
  }

  /// The strict key used in Recipe JSONs and Logic checks
  String get key {
    switch (this) {
      case MedicalCondition.aplv: return 'APLV';
      case MedicalCondition.eggAllergy: return 'Egg-Free'; // Matches "Egg-Free" variant tag often used vs "Egg Allergy"
      case MedicalCondition.soyAllergy: return 'Soy-Free';
      case MedicalCondition.nutAllergy: return 'Nut-Free';
      case MedicalCondition.shellfishAllergy: return 'Shellfish-Free';
      case MedicalCondition.celiac: return 'Celiac';
      case MedicalCondition.lowFodmap: return 'Low FODMAP';
      case MedicalCondition.histamine: return 'Histamine';
      case MedicalCondition.diabetes: return 'Diabetes';
      case MedicalCondition.renal: return 'Renal';
    }
  }
}
