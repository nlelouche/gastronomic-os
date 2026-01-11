import 'package:json_annotation/json_annotation.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe_step.dart';

part 'recipe_step_model.g.dart';

@JsonSerializable()
class RecipeStepModel extends RecipeStep {
  @JsonKey(name: 'is_branch_point')
  final bool isBranchPoint;
  @JsonKey(name: 'variant_logic')
  final Map<String, String>? variantLogic;
  @JsonKey(name: 'cross_contamination_alert')
  final String? crossContaminationAlert;
  @JsonKey(name: 'skipped_for_diets')
  final List<String>? skippedForDiets;

  const RecipeStepModel({
    required String instruction,
    this.isBranchPoint = false,
    this.variantLogic,
    this.crossContaminationAlert,
    this.skippedForDiets,
  }) : super(
          instruction: instruction,
          isBranchPoint: isBranchPoint,
          variantLogic: variantLogic,
          crossContaminationAlert: crossContaminationAlert,
          skippedForDiets: skippedForDiets,
        );

  factory RecipeStepModel.fromJson(Map<String, dynamic> json) => _$RecipeStepModelFromJson(json);
  Map<String, dynamic> toJson() => _$RecipeStepModelToJson(this);
}
