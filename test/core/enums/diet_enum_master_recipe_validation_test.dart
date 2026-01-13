import 'package:flutter_test/flutter_test.dart';
import 'package:gastronomic_os/core/enums/diet_enums.dart';

void main() {
  group('Medical Condition Enum Keys - Master Recipe Compliance', () {
    // This test ensures our enum keys EXACTLY match the Master Recipe variant_logic tags
    // ANY MISMATCH will cause RecipeResolver to fail silently
    
    test('ALL Medical Condition keys must match Master Recipe tags', () {
      final expectedKeys = {
        MedicalCondition.aplv: 'APLV',
        MedicalCondition.eggAllergy: 'Egg Allergy',
        MedicalCondition.soyAllergy: 'Soy Allergy',
        MedicalCondition.nutAllergy: 'Nut Allergy',
        MedicalCondition.shellfishAllergy: 'Shellfish Allergy',
        MedicalCondition.celiac: 'Celiac',
        MedicalCondition.lowFodmap: 'Low FODMAP',
        MedicalCondition.histamine: 'Histamine',
        MedicalCondition.diabetes: 'Diabetes',
        MedicalCondition.renal: 'Renal',
      };

      for (final entry in expectedKeys.entries) {
        expect(
          entry.key.key,
          equals(entry.value),
          reason: '${entry.key.name} enum key must be "${entry.value}" to match Master Recipe',
        );
      }
    });

    test('Soy Allergy key matches Master Recipe (CRITICAL)', () {
      // Master Recipe line 118: "Soy Allergy": "🚫 PROHIBIDO..."
      expect(MedicalCondition.soyAllergy.key, equals('Soy Allergy'),
        reason: 'CRITICAL BUG: Master Recipe uses "Soy Allergy", not "Soy-Free"');
    });

    test('Nut Allergy key matches Master Recipe', () {
      // Master Recipe line 91, 139: "Nut Allergy": "⚠️ Verificar..."
      expect(MedicalCondition.nutAllergy.key, equals('Nut Allergy'),
        reason: 'Master Recipe uses "Nut Allergy", not "Nut-Free"');
    });

    test('Egg Allergy key matches Master Recipe (if present)', () {
      // Master Recipe doesn't have Egg variants yet, but for consistency
      expect(MedicalCondition.eggAllergy.key, equals('Egg Allergy'),
        reason: 'Consistency: use "Egg Allergy", not "Egg-Free"');
    });

    test('Shellfish Allergy key matches Master Recipe (if present)', () {
      expect(MedicalCondition.shellfishAllergy.key, equals('Shellfish Allergy'),
        reason: 'Consistency: use "Shellfish Allergy", not "Shellfish-Free"');
    });

    test('Low FODMAP key matches exactly (case-sensitive)', () {
      // Master Recipe uses "Low FODMAP" with this exact casing
      expect(MedicalCondition.lowFodmap.key, equals('Low FODMAP'),
        reason: 'Case matters! Must be "Low FODMAP", not "low fodmap"');
    });

    test('All other conditions match (Celiac, APLV, Histamine, Diabetes, Renal)', () {
      expect(MedicalCondition.celiac.key, equals('Celiac'));
      expect(MedicalCondition.aplv.key, equals('APLV'));
      expect(MedicalCondition.histamine.key, equals('Histamine'));
      expect(MedicalCondition.diabetes.key, equals('Diabetes'));
      expect(MedicalCondition.renal.key, equals('Renal'));
    });
  });

  group('DietLifestyle Enum Keys - Master Recipe Compliance', () {
    test('ALL DietLifestyle keys must match Master Recipe tags', () {
      final expectedKeys = {
        DietLifestyle.keto: 'Keto',
        DietLifestyle.vegan: 'Vegan',
        DietLifestyle.vegetarian: 'Vegetarian',
        DietLifestyle.pescatarian: 'Pescatarian',
        DietLifestyle.paleo: 'Paleo',
        DietLifestyle.whole30: 'Whole30',
        DietLifestyle.lowCarb: 'Low-Carb', // Note: hyphenated in Master Recipe
        DietLifestyle.highPerformance: 'High-Performance', // Note: hyphenated
      };

      for (final entry in expectedKeys.entries) {
        expect(
          entry.key.key,
          equals(entry.value),
          reason: '${entry.key.name} enum key must be "${entry.value}" to match Master Recipe',
        );
      }
    });

    test('High Performance uses hyphen (CRITICAL)', () {
      // Master Recipe line 15, 132: "High-Performance"
      expect(DietLifestyle.highPerformance.key, equals('High-Performance'),
        reason: 'Master Recipe uses "High-Performance" with hyphen, not "High Performance"');
    });

    test('Low Carb uses hyphen', () {
      // Master Recipe line 19: "Low-Carb"
      expect(DietLifestyle.lowCarb.key, equals('Low-Carb'),
        reason: 'Master Recipe uses "Low-Carb" with hyphen');
    });
  });
}
