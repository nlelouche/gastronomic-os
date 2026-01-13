import 'dart:ui';
import 'package:equatable/equatable.dart';
import 'recipe_step.dart';

class Recipe extends Equatable {
  final String id;
  final String authorId;
  final String? originId;
  final bool isFork;
  final String title;
  final String? description;
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

  const Recipe({
    required this.id,
    required this.authorId,
    this.originId,
    this.isFork = false,
    required this.title,
    this.description,
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

  Recipe copyWith({
    String? id,
    String? authorId,
    String? originId,
    bool? isFork,
    String? title,
    String? description,
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
  }) {
    return Recipe(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      originId: originId ?? this.originId,
      isFork: isFork ?? this.isFork,
      title: title ?? this.title,
      description: description ?? this.description,
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
    );
  }

  @override
  List<Object?> get props => [
    id, authorId, originId, isFork, title, description, isPublic, createdAt, 
    ingredients, steps, tags, dietTags, titleEn, descriptionEn, ingredientsEn, stepsEn
  ];
}
