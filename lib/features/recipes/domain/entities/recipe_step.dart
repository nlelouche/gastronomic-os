import 'package:equatable/equatable.dart';

class RecipeStep extends Equatable {
  final String instruction;
  final bool isBranchPoint;
  final Map<String, String>? variantLogic;
  final String? crossContaminationAlert;
  final List<String>? skippedForDiets;

  const RecipeStep({
    required this.instruction,
    this.isBranchPoint = false,
    this.variantLogic,
    this.crossContaminationAlert,
    this.skippedForDiets,
  });

  @override
  List<Object?> get props => [
        instruction,
        isBranchPoint,
        variantLogic,
        crossContaminationAlert,
        skippedForDiets,
      ];
}
