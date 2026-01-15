class MLLabelMapper {
  /// Maps detailed ML Kit labels to cleaner, generic inventory names.
  /// This prevents inventory clutter (e.g., "Granny Smith" -> "Apple").
  static String mapLabelToInventoryName(String originalLabel) {
    final lower = originalLabel.toLowerCase();
    
    // Fruits
    if (lower.contains('apple')) return 'Apple';
    if (lower.contains('banana')) return 'Banana';
    if (lower.contains('orange') || lower.contains('citrus')) return 'Orange';
    if (lower.contains('lemon')) return 'Lemon';
    if (lower.contains('strawberry')) return 'Strawberry';
    if (lower.contains('grape')) return 'Grape';
    
    // Vegetables
    if (lower.contains('tomato')) return 'Tomato';
    if (lower.contains('potato')) return 'Potato';
    if (lower.contains('carrot')) return 'Carrot';
    if (lower.contains('onion')) return 'Onion';
    if (lower.contains('garlic')) return 'Garlic';
    if (lower.contains('cucumber')) return 'Cucumber';
    if (lower.contains('pepper') || lower.contains('capsicum')) return 'Bell Pepper';
    if (lower.contains('broccoli')) return 'Broccoli';
    
    // Dairy & Eggs
    if (lower.contains('milk')) return 'Milk';
    if (lower.contains('cheese')) return 'Cheese';
    if (lower.contains('egg')) return 'Egg';
    if (lower.contains('yogurt')) return 'Yogurt';
    
    // Pantry
    if (lower.contains('bread') || lower.contains('bagel') || lower.contains('toast')) return 'Bread';
    if (lower.contains('pasta') || lower.contains('spaghetti')) return 'Pasta';
    if (lower.contains('rice')) return 'Rice';
    if (lower.contains('cereal')) return 'Cereal';
    if (lower.contains('coffee')) return 'Coffee';
    if (lower.contains('tea')) return 'Tea';
    
    // Drinks
    if (lower.contains('wine')) return 'Wine';
    if (lower.contains('beer')) return 'Beer';
    if (lower.contains('juice')) return 'Juice';
    if (lower.contains('soda') || lower.contains('soft drink')) return 'Soda';
    if (lower.contains('water')) return 'Water';

    // Default: Capitalize first letter
    if (originalLabel.length > 1) {
      return originalLabel[0].toUpperCase() + originalLabel.substring(1);
    }
    return originalLabel;
  }
}
