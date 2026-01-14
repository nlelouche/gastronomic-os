import 'package:gastronomic_os/features/recipes/domain/entities/recipe.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe_step.dart';
import 'package:gastronomic_os/features/recipes/data/models/recipe_step_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'recipe_model.g.dart';

@JsonSerializable()
class RecipeModel extends Recipe {
  @override
  @JsonKey(name: 'author_id')
  final String authorId;
  @override
  @JsonKey(name: 'cover_photo_url')
  final String? coverPhotoUrl;
  @override
  @JsonKey(name: 'origin_id')
  final String? originId;
  @override
  @JsonKey(name: 'is_fork')
  final bool isFork;
  @override
  @JsonKey(name: 'is_public')
  final bool isPublic;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  final List<String> ingredients;
  @override
  @JsonKey(name: 'steps')
  @_RecipeStepListConverter()
  final List<RecipeStep> steps;
  @override
  @JsonKey(name: 'tags')
  final List<String> tags;
  @override
  @override
  @JsonKey(name: 'diet_tags')
  final List<String> dietTags;
  
  // Translations
  @override
  @JsonKey(name: 'title_en')
  final String? titleEn;
  @override
  @JsonKey(name: 'description_en')
  final String? descriptionEn;
  @override
  @JsonKey(name: 'ingredients_en')
  final List<String>? ingredientsEn;
  @override
  @JsonKey(name: 'steps_en')
  @_RecipeStepListConverter()
  final List<RecipeStep>? stepsEn;

  const RecipeModel({
    required String id,
    required this.authorId,
    this.originId,
    this.isFork = false,
    required String title,
    String? description,
    this.coverPhotoUrl,
    required this.isPublic,
    required this.createdAt,
    this.ingredients = const [],
    this.steps = const [],
    this.tags = const [],
    this.dietTags = const [],
    this.titleEn,
    this.descriptionEn,
    this.ingredientsEn,
    this.stepsEn,
    double? matchScore,
  }) : super(
          id: id,
          authorId: authorId,
          originId: originId,
          isFork: isFork ?? false,
          title: title,
          description: description,
          coverPhotoUrl: coverPhotoUrl,
          isPublic: isPublic,
          createdAt: createdAt,
          ingredients: ingredients,
          steps: steps,
          tags: tags,
          dietTags: dietTags,
          titleEn: titleEn,
          descriptionEn: descriptionEn,
          ingredientsEn: ingredientsEn,
          stepsEn: stepsEn,
          matchScore: matchScore,
        );

  RecipeModel copyWith({
    String? id,
    String? authorId,
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
    return RecipeModel(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
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

  factory RecipeModel.fromJson(Map<String, dynamic> json) => _$RecipeModelFromJson(json);
  Map<String, dynamic> toJson() => _$RecipeModelToJson(this);
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
