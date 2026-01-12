import 'package:inflection3/inflection3.dart';

class IngredientNormalizer {
  /// Normalizes an ingredient string (e.g. "2 chopped Tomatoes") into a standardized format.
  /// Returns a tuple of (Quantity, Unit, Name).
  (double, String, String) normalize(String raw) {
    if (raw.isEmpty) return (0.0, '', '');

    final clean = raw.trim().toLowerCase();
    
    // 1. Extract Quantity
    final parts = clean.split(' ');
    double qty = 1.0;
    String unit = '';
    String name = clean; // Placeholder, will be rebuilt
    
    // Regex for "1kg", "500g", "1.5L" (Number attached to text)
    final attachedRegex = RegExp(r'^([0-9]+(\.[0-9]+)?)([a-z]+)$');
    final numberRegex = RegExp(r'^[0-9]+(\.[0-9]+)?$');

    if (parts.isNotEmpty) {
      final first = parts.first;
      
      if (numberRegex.hasMatch(first)) {
         // Case: "1 kg"
         qty = double.tryParse(first) ?? 1.0;
         parts.removeAt(0);
      } else if (attachedRegex.hasMatch(first)) {
         // Case: "1kg"
         final match = attachedRegex.firstMatch(first)!;
         qty = double.tryParse(match.group(1)!) ?? 1.0;
         String potentialUnit = match.group(3)!;
         
         // If the suffix is a known unit, treat it as unit.
         // Otherwise, it might be "1st" or "2nd" (ignore for now)
         // We'll let the unit checker below handle the "unit" part if we just split it?
         // Simpler: Just put the unit back into parts[0] to be caught by Step 2.
         parts[0] = potentialUnit; 
         // BUT wait, we removed the number. 
         // So "1kg rice" -> qty=1, parts=["kg", "rice"]
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

  /// Extracts just the normalized name from a raw string, ignoring quantity/unit.
  /// Useful for matching inventory items where qty/unit are separate fields.
  String normalizeNameOnly(String raw) {
    if (raw.isEmpty) return '';
    final (_, _, name) = normalize(raw);
    return name;
  }
}
