import 'package:inflection3/inflection3.dart';

class IngredientNormalizer {
  /// Normalizes an ingredient string (e.g. "2 chopped Tomatoes") into a standardized format.
  /// Returns a tuple of (Quantity, Unit, Name).
  (double, String, String) normalize(String raw) {
    if (raw.isEmpty) return (0.0, '', '');

    final clean = raw.trim().toLowerCase();
    
    // 1. Extract Quantity (Simple Heuristic: First word is number?)
    final parts = clean.split(' ');
    double qty = 1.0; // Default
    String unit = '';
    String name = clean;
    
    // Check if first part is a number
    final numberRegex = RegExp(r'^[0-9]+(\.[0-9]+)?$');
    if (parts.isNotEmpty && numberRegex.hasMatch(parts.first)) {
       qty = double.tryParse(parts.first) ?? 1.0;
       // Remove quantity from name
       parts.removeAt(0); 
    } else {
      // Logic for "1/2" or fractions here (MVP: ignore complex fractions)
      if (parts.isNotEmpty && parts.first.contains('/')) {
         // handle fraction ?
         // MVP: Keep as 1.0, just remove it from name
         // Actually, let's keep it simple.
      }
    }
    
    // 2. Extract Unit (Heuristic: Check against known units)
    final knownUnits = ['cup', 'cups', 'tbsp', 'tsp', 'oz', 'lb', 'g', 'kg', 'ml', 'l', 'slice', 'slices', 'piece', 'pieces'];
    if (parts.isNotEmpty && knownUnits.contains(parts.first)) {
      unit = convertToSingular(parts.first); // cup, not cups
      parts.removeAt(0);
    }
    
    // 3. Clean Name (Remove adjectives)
    // List of common adjectives/prep to remove
    final stopWords = ['chopped', 'diced', 'sliced', 'minced', 'fresh', 'large', 'small', 'of', 'bag', 'can'];
    parts.removeWhere((word) => stopWords.contains(word));
    
    // Reconstruct name
    String baseName = parts.join(' ');
    
    // 4. Singularize Noun
    // "Tomatoes" -> "Tomato"
    try {
      baseName = convertToSingular(baseName);
    } catch (e) {
      // Fallback if inflection fails on strange word
    }

    // Capitalize first letter
    if (baseName.isNotEmpty) {
      baseName = baseName[0].toUpperCase() + baseName.substring(1);
    }

    return (qty, unit, baseName);
  }
}
