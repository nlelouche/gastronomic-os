import 'package:gastronomic_os/core/util/app_logger.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe_step.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/resolved_step.dart';
import 'package:gastronomic_os/features/onboarding/domain/entities/family_member.dart';

/// Resolves a recipe's DAG structure into linear, personalized instructions.
/// 
/// **Phase 3 Implementation:** This class implements the final phase of the DAG spec:
/// "Substitution/Exclusion Application". It analyzes the family's dietary needs
/// and generates step-by-step instructions customized for each member.
/// 
/// **Example:**
/// Family: Juan (Omnivore), María (Vegetarian)
/// Recipe: "Steak & Eggs" with Vegan variant
/// 
/// Output:
/// - Step 1: "For Everyone: Cook spinach..."
/// - Step 2a: "For Juan: Fry egg..."
/// - Step 2b: "For María: Substitute with Tofu Scramble..."
class RecipeResolver {
  
  /// Resolves a recipe for a specific family.
  /// Returns a flat list of ResolvedStep objects with personalized instructions.
  /// Resolves a recipe for a specific family.
  /// Returns a flat list of ResolvedStep objects with personalized instructions.
  List<ResolvedStep> resolve(Recipe recipe, List<FamilyMember> family) {
    if (family.isEmpty) {
      // No family context: return universal steps
      return _resolveUniversal(recipe);
    }

    List<ResolvedStep> resolvedSteps = [];
    int stepCounter = 1;
    
    for (final step in recipe.steps) {
      AppLogger.d('🔍 Resolver Step: "${step.instruction.length > 30 ? step.instruction.substring(0, 30) : step.instruction}..." - isBranch: ${step.isBranchPoint}, skippedForDiets: ${step.skippedForDiets}');
      
      int originalIndex = recipe.steps.indexOf(step) + 1;

      if (!step.isBranchPoint || step.variantLogic == null || step.variantLogic!.isEmpty) {
        // Universal step: everyone follows the same instruction
        resolvedSteps.add(ResolvedStep(
          index: originalIndex,
          instruction: step.instruction,
          targetMembers: family,
          isUniversal: true,
          crossContaminationAlert: step.crossContaminationAlert,
        ));
      } else {
        // Branch point: resolve for each member individually
        // Map<Instruction, (List<FamilyMember>, Set<Reason>)>
        Map<String, (List<FamilyMember>, Set<String>)> instructionToGroup = {};
        
        for (final member in family) {
          final resolution = _resolveInstructionForMember(step, member);
          final instruction = resolution.$1;
          final reason = resolution.$2;
          
          if (!instructionToGroup.containsKey(instruction)) {
            instructionToGroup[instruction] = ([], {});
          }
          
          instructionToGroup[instruction]!.$1.add(member);
          if (reason != null) {
            instructionToGroup[instruction]!.$2.add(reason);
          }
        }
        
        // Check if everyone converged to same instruction (Functional Universality)
        bool isFunctionallyUniversal = instructionToGroup.length == 1 && 
                                       instructionToGroup.values.first.$1.length == family.length;

        // Create ResolvedSteps
        for (var entry in instructionToGroup.entries) {
          final members = entry.value.$1;
          final reasons = entry.value.$2.toList()..sort();
          final reasonString = reasons.isEmpty ? null : reasons.join(', ');

          resolvedSteps.add(ResolvedStep(
            index: originalIndex,
            instruction: entry.key,
            targetMembers: members,
            isUniversal: isFunctionallyUniversal,
            crossContaminationAlert: step.crossContaminationAlert,
            substitutionReason: reasonString,
          ));
        }
      }
    }
    
    return resolvedSteps;
  }
  
  // ... _groupMembersByDiet ...

  // ... _resolveInstructionForDiet ...
  
  /// Resolves a step's instruction for a SPECIFIC FAMILY MEMBER.
  /// Checks BOTH their primaryDiet AND medicalConditions.
  /// Returns (Instruction, SubstitutionReason?)
  /// 
  /// **Priority:**
  /// 1. Medical Condition variant (highest priority - safety!)
  /// 2. Primary Diet variant
  /// 3. Universal/base instruction
  (String, String?) _resolveInstructionForMember(RecipeStep step, FamilyMember member) {
    if (step.variantLogic == null || step.variantLogic!.isEmpty) {
      return (step.instruction, null);
    }
    
    // 1. Check Medical Conditions FIRST (highest priority for safety)
    for (final condition in member.medicalConditions) {
      final conditionKey = condition.key;
      for (var entry in step.variantLogic!.entries) {
        if (entry.key.toLowerCase() == conditionKey.toLowerCase()) {
          final val = entry.value;
          AppLogger.d('   🚨 MEDICAL MATCH: ${member.name} has $conditionKey → "${val.length > 30 ? val.substring(0, 30) : val}..."');
          return (val, conditionKey);
        }
      }
    }
    
    // 2. Check Primary Diet
    final dietKey = member.primaryDiet.key;
    for (var entry in step.variantLogic!.entries) {
      if (entry.key.toLowerCase() == dietKey.toLowerCase()) {
        final val = entry.value;
        AppLogger.d('   🥗 DIET MATCH: ${member.name} is $dietKey → "${val.length > 30 ? val.substring(0, 30) : val}..."');
        return (val, dietKey);
      }
    }
    
    // 3. Fallback to universal
    AppLogger.d('   ⚪ NO MATCH: ${member.name} gets base instruction');
    return (step.instruction, null);
  }
  
  /// Resolves a recipe without family context (returns universal steps only)
  List<ResolvedStep> _resolveUniversal(Recipe recipe) {
    return recipe.steps.asMap().entries.map((entry) {
      return ResolvedStep(
        index: entry.key + 1,
        instruction: entry.value.instruction,
        targetMembers: const <FamilyMember>[],
        isUniversal: true,
        crossContaminationAlert: entry.value.crossContaminationAlert,
      );
    }).toList();
  }
}
