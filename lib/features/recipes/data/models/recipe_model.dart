import 'package:gastronomic_os/features/recipes/domain/entities/recipe.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe_step.dart';
import 'package:gastronomic_os/features/recipes/data/models/recipe_step_model.dart';
import 'package:json_annotation/json_annotation.dart';

// part 'recipe_model.g.dart'; // Disabled for manual override

class RecipeModel extends Recipe {
  @override
  final String authorId;
  @override
  final String? createdByMemberId;
  @override
  final String? coverPhotoUrl;
  @override
  final String? originId;
  @override
  final bool isFork;
  @override
  final bool isPublic;
  @override
  final String? prepTime;
  @override
  final DateTime createdAt;
  @override
  final List<String> ingredients;
  @override
  final List<RecipeStep> steps;
  @override
  final List<String> tags;
  @override
  final List<String> dietTags;
  @override
  final String languageCode;
  
  // Translations
  @override
  final String? titleEn;
  @override
  final String? descriptionEn;
  @override
  final List<String>? ingredientsEn;
  @override
  final List<RecipeStep>? stepsEn;

  const RecipeModel({
    required String id,
    required this.authorId,
    this.createdByMemberId,
    this.originId,
    this.isFork = false,
    required String title,
    String? description,
    this.coverPhotoUrl,
    required this.isPublic,
    this.prepTime,
    required this.createdAt,
    this.ingredients = const [],
    this.steps = const [],
    this.tags = const [],
    this.dietTags = const [],
    this.languageCode = 'es',
    this.titleEn,
    this.descriptionEn,
    this.ingredientsEn,
    this.stepsEn,
    double? matchScore,
  }) : super(
          id: id,
          authorId: authorId,
          createdByMemberId: createdByMemberId,
          originId: originId,
          isFork: isFork ?? false,
          title: title,
          description: description,
          coverPhotoUrl: coverPhotoUrl,
          isPublic: isPublic,
          prepTime: prepTime,
          createdAt: createdAt,
          ingredients: ingredients,
          steps: steps,
          tags: tags,
          dietTags: dietTags,
          languageCode: languageCode,
          titleEn: titleEn,
          descriptionEn: descriptionEn,
          ingredientsEn: ingredientsEn,
          stepsEn: stepsEn,
          matchScore: matchScore,
        );

  RecipeModel copyWith({
    String? id,
    String? authorId,
    String? createdByMemberId,
    String? originId,
    bool? isFork,
    String? title,
    String? description,
    String? coverPhotoUrl,
    bool? isPublic,
    String? prepTime,
    DateTime? createdAt,
    List<String>? ingredients,
    List<RecipeStep>? steps,
    List<String>? tags,
    List<String>? dietTags,
    String? languageCode,
    String? titleEn,
    String? descriptionEn,
    List<String>? ingredientsEn,
    List<RecipeStep>? stepsEn,
    double? matchScore,
  }) {
    return RecipeModel(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      createdByMemberId: createdByMemberId ?? this.createdByMemberId,
      originId: originId ?? this.originId,
      isFork: isFork ?? this.isFork,
      title: title ?? this.title,
      description: description ?? this.description,
      coverPhotoUrl: coverPhotoUrl ?? this.coverPhotoUrl,
      isPublic: isPublic ?? this.isPublic,
      prepTime: prepTime ?? this.prepTime,
      createdAt: createdAt ?? this.createdAt,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      tags: tags ?? this.tags,
      dietTags: dietTags ?? this.dietTags,
      languageCode: languageCode ?? this.languageCode,
      titleEn: titleEn ?? this.titleEn,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      ingredientsEn: ingredientsEn ?? this.ingredientsEn,
      stepsEn: stepsEn ?? this.stepsEn,
      matchScore: matchScore ?? this.matchScore,
    );
  }

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    return RecipeModel(
      id: json['id'] as String,
      authorId: json['author_id'] as String,
      createdByMemberId: json['created_by_member_id'] as String?,
      originId: json['origin_id'] as String?,
      isFork: json['is_fork'] as bool? ?? false,
      title: json['title'] as String,
      description: json['description'] as String?,
      coverPhotoUrl: json['cover_photo_url'] as String?,
      isPublic: json['is_public'] as bool? ?? false,
      prepTime: json['prep_time'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      ingredients: (json['ingredients'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      steps: const _RecipeStepListConverter().fromJson(json['steps'] as List<dynamic>? ?? []),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      dietTags: (json['diet_tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      languageCode: json['language_code'] as String? ?? 'es',
      titleEn: json['title_en'] as String?,
      descriptionEn: json['description_en'] as String?,
      ingredientsEn: (json['ingredients_en'] as List<dynamic>?)?.map((e) => e as String).toList(),
      stepsEn: json['steps_en'] != null ? const _RecipeStepListConverter().fromJson(json['steps_en'] as List<dynamic>) : null,
      matchScore: (json['matchScore'] as num?)?.toDouble(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author_id': authorId,
      'created_by_member_id': createdByMemberId,
      'origin_id': originId,
      'is_fork': isFork,
      'title': title,
      'description': description,
      'cover_photo_url': coverPhotoUrl,
      'is_public': isPublic,
      'prep_time': prepTime,
      'created_at': createdAt.toIso8601String(),
      'ingredients': ingredients,
      'steps': const _RecipeStepListConverter().toJson(steps),
      'tags': tags,
      'diet_tags': dietTags,
      'language_code': languageCode,
      'title_en': titleEn,
      'description_en': descriptionEn,
      'ingredients_en': ingredientsEn,
      'steps_en': stepsEn != null ? const _RecipeStepListConverter().toJson(stepsEn!) : null,
      'matchScore': matchScore,
    };
  }
}

class _RecipeStepListConverter implements JsonConverter<List<RecipeStep>, List<dynamic>> {
  const _RecipeStepListConverter();

  @override
  List<RecipeStep> fromJson(List<dynamic> json) {
    return json.map((e) {
      if (e is String) {
        // Backward compatibility for old string-based steps
        return RecipeStepModel(instruction: e);
      }
      return RecipeStepModel.fromJson(e as Map<String, dynamic>);
    }).toList();
  }

  @override
  List<dynamic> toJson(List<RecipeStep> object) {
    return object.map((e) {
       if (e is RecipeStepModel) {
         return e.toJson();
       }
       return RecipeStepModel(
         instruction: e.instruction,
         isBranchPoint: e.isBranchPoint,
         variantLogic: e.variantLogic,
         crossContaminationAlert: e.crossContaminationAlert,
       ).toJson();
    }).toList();
  }
}
