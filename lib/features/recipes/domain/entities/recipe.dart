import 'dart:ui';
import 'package:equatable/equatable.dart';
import 'recipe_step.dart';

class Recipe extends Equatable {
  final String id;
  final String authorId;
  final String? createdByMemberId; // The Family Chef
  final String? originId;
  final bool isFork;
  final String title;
  final String? description;
  final String? coverPhotoUrl;
  final bool isPublic;
  final DateTime createdAt;
  final List<String> ingredients;
  final List<RecipeStep> steps;
  final List<String> tags; // e.g. ['Vegan', 'Keto', 'Gluten-Free']
  final List<String> dietTags; // System calculated diets
  
  // Translations (Optional)
  final String? titleEn;
  final String? descriptionEn;
  final List<String>? ingredientsEn;
  final List<RecipeStep>? stepsEn;
  
  // Transient/Calculated Fields
  final double? matchScore; 

  const Recipe({
    required this.id,
    required this.authorId,
    this.createdByMemberId,
    this.originId,
    this.isFork = false,
    required this.title,
    this.description,
    this.coverPhotoUrl,
    this.isPublic = true,
    required this.createdAt,
    this.ingredients = const [],
    this.steps = const [],
    this.tags = const [],
    this.dietTags = const [],
    this.titleEn,
    this.descriptionEn,
    this.ingredientsEn,
    this.stepsEn,
    this.matchScore,
  });

  /// Returns a new Recipe with content swapped to the target [locale].
  /// Currently supports 'en' by swapping properties if translation exists.
  Recipe localize(Locale locale) {
    if (locale.languageCode == 'en') {
      return copyWith(
        title: titleEn ?? title,
        description: descriptionEn ?? description,
        ingredients: ingredientsEn ?? ingredients,
        steps: stepsEn ?? steps,
      );
    }
    // Default is just return self (Spanish/Original)
    return this;
  }

  /// Filters ingredients based on user profile tags.
  /// Used for the "Master Recipe" adaptive system.
  /// 
  /// **Filtering Logic:**
  /// 1. Direct Match: If ingredient has a tag matching user -> KEEP
  /// 2. Base Tag: If ingredient has [Base] -> KEEP (it's a safe default)
  /// 3. Universal/No Tags: Always KEEP
  /// 4. Otherwise -> HIDE
  /// 
  /// **Why Base items always show:**
  /// Base ingredients are referenced in default recipe steps. Even if a user
  /// has a specific diet (Keto), they might see base instructions like
  /// "Cocer arroz integral" if no variant applies to them specifically.
  /// It's better to show the item and let the user decide than to hide it
  /// and create confusion between ingredients and steps.
  List<String> getIngredientsForProfile(List<String> userTags) {
    if (ingredients.isEmpty) return [];
    
    // Normalize user tags
    final normalizedUserTags = userTags.map((t) => t.toLowerCase()).toSet();
    
    return ingredients.where((ingredient) {
      final match = RegExp(r'\[(.*?)\]').firstMatch(ingredient);
      if (match == null) return true; // No tags = Universal
      
      final tagsStr = match.group(1)!;
      final ingTags = tagsStr.split(',').map((t) => t.trim().toLowerCase()).toSet();
      
      // 1. Universal
      if (ingTags.contains('universal')) return true;
      
      // 2. Direct Match - ingredient matches user's diet/condition
      if (ingTags.any((t) => normalizedUserTags.contains(t))) return true;
      
      // 3. Base - ALWAYS show (safe default, will be in recipe steps)
      if (ingTags.contains('base')) return true;
      
      // 4. No match -> HIDE
      return false;
    }).toList();
  }

  Recipe copyWith({
    String? id,
    String? authorId,
    String? createdByMemberId,
    String? originId,
    bool? isFork,
    String? title,
    String? description,
    String? coverPhotoUrl,
    bool? isPublic,
    DateTime? createdAt,
    List<String>? ingredients,
    List<RecipeStep>? steps,
    List<String>? tags,
    List<String>? dietTags,
    String? titleEn,
    String? descriptionEn,
    List<String>? ingredientsEn,
    List<RecipeStep>? stepsEn,
    double? matchScore,
  }) {
    return Recipe(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      createdByMemberId: createdByMemberId ?? this.createdByMemberId,
      originId: originId ?? this.originId,
      isFork: isFork ?? this.isFork,
      title: title ?? this.title,
      description: description ?? this.description,
      coverPhotoUrl: coverPhotoUrl ?? this.coverPhotoUrl,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      tags: tags ?? this.tags,
      dietTags: dietTags ?? this.dietTags,
      titleEn: titleEn ?? this.titleEn,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      ingredientsEn: ingredientsEn ?? this.ingredientsEn,
      stepsEn: stepsEn ?? this.stepsEn,
      matchScore: matchScore ?? this.matchScore,
    );
  }

  @override
  List<Object?> get props => [
    id, authorId, createdByMemberId, originId, isFork, title, description, coverPhotoUrl, isPublic, createdAt, 
    ingredients, steps, tags, dietTags, titleEn, descriptionEn, ingredientsEn, stepsEn
  ];
}
