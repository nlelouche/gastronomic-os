
class UnitConverter {
  // Base Units:
  // Weight -> grams (g)
  // Volume -> milliliters (ml)
  
  static const Map<String, double> _weightToGrams = {
    'g': 1.0,
    'kg': 1000.0,
    'mg': 0.001,
    'oz': 28.3495,
    'lb': 453.592,
    'pound': 453.592,
    'pounds': 453.592,
    'ounce': 28.3495,
    'ounces': 28.3495,
  };

  static const Map<String, double> _volumeToMl = {
    'ml': 1.0,
    'l': 1000.0,
    'liter': 1000.0,
    'liters': 1000.0,
    'dl': 100.0,
    'cl': 10.0,
    'tsp': 4.92892,
    'teasp': 4.92892,
    'teaspoon': 4.92892,
    'tbsp': 14.7868,
    'tablesp': 14.7868,
    'tablespoon': 14.7868,
    'cup': 236.588, // US Cup
    'cups': 236.588,
    'pint': 473.176,
    'quart': 946.353,
    'gallon': 3785.41,
    'gal': 3785.41,
    'fl oz': 29.5735,
  };

  /// Returns (normalizedQty, normalizedUnit, type)
  /// type: 'weight', 'volume', or 'count'
  (double, String, String) normalizeToBasics(double qty, String unit) {
    final u = unit.toLowerCase().trim();
    if (u.isEmpty) return (qty, '', 'count'); // "2 Apples"

    // Check Weight
    if (_weightToGrams.containsKey(u)) {
      return (qty * _weightToGrams[u]!, 'g', 'weight');
    }

    // Check Volume
    if (_volumeToMl.containsKey(u)) {
      return (qty * _volumeToMl[u]!, 'ml', 'volume');
    }

    // Default to count/unknown
    return (qty, u, 'count');
  }

  /// Tries to subtract [deductQty] (in [deductUnit]) from [sourceQty] (in [sourceUnit]).
  /// Returns the remaining quantity in [sourceUnit].
  /// If incompatible, returns [sourceQty] (no deduction).
  // Density Map (g/ml) - Approximate values for common staples
  static const Map<String, double> _densities = {
    'water': 1.0,
    'milk': 1.03,
    'oil': 0.92,
    'olive oil': 0.92,
    'vegetable oil': 0.92,
    'flour': 0.53, // unpacked
    'sugar': 0.85,
    'salt': 1.2, // granular
    'rice': 0.85, // uncooked white
    'butter': 0.96,
    'honey': 1.42,
  };

  double _getDensity(String name) {
    final n = name.toLowerCase().trim();
    // Exact match
    if (_densities.containsKey(n)) return _densities[n]!;
    // Partial match (e.g. "brown rice" matches "rice")
    for (final key in _densities.keys) {
      if (n.contains(key)) return _densities[key]!;
    }
    // Default to Water (1.0) if strictly forced, or null?
    // Let's safe-fail to 1.0 for "wet" sounding things, but for dry things this is dangerous.
    // Return 0.0 to verify "unknown".
    return 0.0;
  }

  /// Tries to subtract [deductQty] (in [deductUnit]) from [sourceQty] (in [sourceUnit]).
  /// Returns the remaining quantity in [sourceUnit].
  double deduct(double sourceQty, String sourceUnit, double deductQty, String deductUnit, {String ingredientName = ''}) {
    if (sourceQty <= 0) return 0.0;

    final (srcBase, _, srcType) = normalizeToBasics(sourceQty, sourceUnit);
    final (deductBase, _, deductType) = normalizeToBasics(deductQty, deductUnit);

    // 1. Exact Type Match
    if (srcType == deductType && srcType != 'count') {
      final remainingBase = srcBase - deductBase;
      if (srcBase <= 0) return 0.0;
      final factor = srcBase / sourceQty;
      return remainingBase / factor;
    }

    // 2. Density Conversion (Weight <-> Volume)
    if (ingredientName.isNotEmpty && (srcType == 'weight' && deductType == 'volume' || srcType == 'volume' && deductType == 'weight')) {
       final density = _getDensity(ingredientName);
       if (density > 0) {
         // Convert Deduct to Source Type
         double deductBaseConverted = 0.0;
         
         if (srcType == 'weight') {
           // Deduct is Volume (ml). Weight (g) = Volume (ml) * Density
           deductBaseConverted = deductBase * density;
         } else {
           // Src is Volume (ml). Deduct is Weight (g). Volume = Weight / Density
           deductBaseConverted = deductBase / density;
         }

         final remainingBase = srcBase - deductBaseConverted;
         final factor = srcBase / sourceQty;
         return remainingBase / factor;
       }
    }
    
    // 3. Count vs Count... (Existing Logic)
    if (srcType == 'count' && deductType == 'count') {
      if (normalizeUnitName(sourceUnit) == normalizeUnitName(deductUnit)) {
         return sourceQty - deductQty;
      }
    }

    return sourceQty; // Incompatible
  }

  String normalizeUnitName(String unit) {
    final u = unit.toLowerCase().trim();
    if (u == 'unit' || u == 'piece' || u == 'units' || u == 'pieces') return '';
    return u;
  }

  // Smart Purchase Matrix (Base Units: g / ml)
  // If required qty is BELOW this threshold, we suppress the quantity 
  // and assume the user buys a standard "Unit" (Bottle, Pack, Bag).
  // If ABOVE, we show the specific amount (e.g. for bulk cooking).
  static const Map<String, double> _bulkThresholds = {
    'oil': 3000.0,      // 3L
    'olive oil': 3000.0,
    'vegetable oil': 3000.0,
    'salt': 500.0,      // 500g
    'sugar': 1000.0,    // 1kg
    'flour': 2000.0,    // 2kg
    'pepper': 100.0,    // 100g
    'black pepper': 100.0,
    'vinegar': 1000.0,  // 1L
    'soy sauce': 1000.0,
    'spices': 50.0,
    'cinnamon': 50.0,
    'paprika': 50.0,
    'oregano': 50.0,
    'cumin': 50.0,
    'butter': 250.0, // If need < 250g butter, likely just "Butter". If 500g, show 500g.
                     // Actually butter is crucial for baking, maybe keep precise? 
                     // Let's set low threshold.
  };

  double _getBulkThreshold(String name) {
     final n = name.toLowerCase().trim();
     if (_bulkThresholds.containsKey(n)) return _bulkThresholds[n]!;
     for (final key in _bulkThresholds.keys) {
       if (n.contains(key)) return _bulkThresholds[key]!;
     }
     return 0.0;
  }

  /// Scalable Display Logic
  /// [ingredientName]: Context helps decide Unit Type (e.g. Rice -> show Kg).
  /// Returns (qty, unit). If qty is -1, it implies "Hide Quantity" (Smart Purchase).
  (double, String) formatForDisplay(double qty, String unit, String ingredientName, {String targetSystem = 'metric'}) {
    var (baseQty, baseUnit, type) = normalizeToBasics(qty, unit);
    
    // 0. Smart Purchase Check (Staples)
    final bulkThreshold = _getBulkThreshold(ingredientName);
    if (bulkThreshold > 0 && baseQty < bulkThreshold) {
       // Item is a staple and amount is "normal" (not industrial).
       // Return signal to hide quantity.
       return (-1.0, ''); 
    }

    // 1. Density Logic (Volume -> Weight for dry goods)
    // Intelligence: If it's Volume (ml) but matches a "Density" known item (like Rice),
    // and the user generally prefers Weight (implied by "Kg" request), 
    // let's SWAP to Weight for display.
    if (type == 'volume') {
       final density = _getDensity(ingredientName);
       if (density > 0 && ingredientName.contains('oil') == false && ingredientName.contains('milk') == false && ingredientName.contains('water') == false && ingredientName.contains('vinegar') == false && ingredientName.contains('sauce') == false) {
         // It has density and isn't a liquid? (Rice, Flour, Sugar) -> Show in Weight!
         baseQty = baseQty * density; // ml * g/ml = g
         type = 'weight';
       }
    }

    if (type == 'weight') {
      if (targetSystem == 'metric' || targetSystem == 'auto') {
        if (baseQty >= 1000) {
          return (double.parse((baseQty / 1000).toStringAsFixed(2)), 'kg');
        } else {
          return (double.parse(baseQty.toStringAsFixed(0)), 'g');
        }
      } else {
         // Imperial
         final lbs = baseQty * 0.00220462;
         if (lbs >= 1.0) {
            return (double.parse(lbs.toStringAsFixed(2)), 'lb');
         } else {
            return (double.parse((baseQty * 0.035274).toStringAsFixed(1)), 'oz');
         }
      }
    } 
    else if (type == 'volume') {
      if (baseUnit == 'ml') {
         if (baseQty >= 1000) {
           return (double.parse((baseQty / 1000).toStringAsFixed(2)), 'L');
         } else {
           return (double.parse(baseQty.toStringAsFixed(0)), 'ml');
         }
      }
    }
    
    return (qty, unit);
  }
}
