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
  List<ResolvedStep> resolve(Recipe recipe, List<FamilyMember> family) {
    if (family.isEmpty) {
      // No family context: return universal steps
      return _resolveUniversal(recipe);
    }

    // Group family members by their effective diet path
    Map<String, List<String>> dietToMembers = _groupMembersByDiet(family);
    
    List<ResolvedStep> resolvedSteps = [];
    int stepCounter = 1;
    
    for (final step in recipe.steps) {
      AppLogger.d('🔍 Resolver Step: "${step.instruction.length > 30 ? step.instruction.substring(0, 30) : step.instruction}..." - isBranch: ${step.isBranchPoint}, skippedForDiets: ${step.skippedForDiets}');
      
      // Check which diet groups should see this step
      Map<String, List<String>> applicableDietToMembers = {};
      
      for (var entry in dietToMembers.entries) {
        final diet = entry.key;
        final members = entry.value;
        
        // Skip this step for diets listed in skippedForDiets
        if (step.skippedForDiets != null && 
            step.skippedForDiets!.any((d) => d.toLowerCase() == diet.toLowerCase())) {
          AppLogger.d('   ⏭️ Skipping for diet: $diet (members: $members)');
          continue; // Skip this diet group
        }
        
        applicableDietToMembers[diet] = members;
      }
      
      AppLogger.d('   ✅ Applicable diets: ${applicableDietToMembers.keys.toList()}');
      
      // If no one should see this step, skip it entirely
      if (applicableDietToMembers.isEmpty) {
        AppLogger.d('   ❌ No one can see this step, skipping entirely');
        continue;
      }
      
      if (!step.isBranchPoint || step.variantLogic == null || step.variantLogic!.isEmpty) {
        // Universal step: everyone (who can see it) follows the same instruction
        final allApplicableMembers = applicableDietToMembers.values
            .expand((members) => members)
            .toList();
        
        AppLogger.d('   📝 Creating universal step for: $allApplicableMembers');
        
        resolvedSteps.add(ResolvedStep(
          index: stepCounter++,
          instruction: step.instruction,
          targetMembers: allApplicableMembers,
          isUniversal: allApplicableMembers.length == family.length, // Universal only if ALL can see it
          crossContaminationAlert: step.crossContaminationAlert,
        ));
      } else {
        // Branch point: resolve for each diet group
        Map<String, List<String>> instructionToMembers = {};
        
        for (var entry in dietToMembers.entries) {
          final diet = entry.key;
          final members = entry.value;
          
          String instruction = _resolveInstructionForDiet(step, diet);
          
          // Group members with same instruction
          if (!instructionToMembers.containsKey(instruction)) {
            instructionToMembers[instruction] = [];
          }
          instructionToMembers[instruction]!.addAll(members);
        }
        
        // Create one ResolvedStep per unique instruction
        // IMPORTANT: None of these are "universal" because they're branch variants
        // Check if all members converged to a single instruction (Functional Universality)
        // This prevents showing "For dad and mom" chips when everyone shares the same step.
        bool isFunctionallyUniversal = instructionToMembers.length == 1 && 
                                       instructionToMembers.values.first.length == family.length;

        // Create ResolvedSteps
        for (var entry in instructionToMembers.entries) {
          resolvedSteps.add(ResolvedStep(
            index: stepCounter++,
            instruction: entry.key,
            targetMembers: entry.value,
            isUniversal: isFunctionallyUniversal, // ✅ Hide chip if everyone sees the same
            crossContaminationAlert: step.crossContaminationAlert,
          ));
        }
      }
    }
    
    return resolvedSteps;
  }
  
  /// Groups family members by their diet, returning a map of diet -> list of member names
  Map<String, List<String>> _groupMembersByDiet(List<FamilyMember> family) {
    Map<String, List<String>> groups = {};
    
    for (final member in family) {
      // Use Primary Diet KEY for grouping (Stable matching with Recipe Logic)
      final diet = member.primaryDiet.key;
      if (!groups.containsKey(diet)) {
        groups[diet] = [];
      }
      groups[diet]!.add(member.name);
    }
    
    return groups;
  }
  
  /// Resolves a step's instruction for a specific diet.
  /// Returns the variant instruction if available, otherwise the universal instruction.
  String _resolveInstructionForDiet(RecipeStep step, String diet) {
    if (step.variantLogic == null) {
      return step.instruction;
    }
    
    // Try exact match first (case-insensitive)
    for (var entry in step.variantLogic!.entries) {
      if (entry.key.toLowerCase() == diet.toLowerCase()) {
        return entry.value;
      }
    }
    
    // Handle diet aliases (e.g., Omnivore can use base instruction)
    if (diet.toLowerCase() == 'omnivore' || diet.toLowerCase() == 'normal') {
      return step.instruction;
    }
    
    // Fallback: use universal instruction
    return step.instruction;
  }
  
  /// Resolves a recipe without family context (returns universal steps only)
  List<ResolvedStep> _resolveUniversal(Recipe recipe) {
    return recipe.steps.asMap().entries.map((entry) {
      return ResolvedStep(
        index: entry.key + 1,
        instruction: entry.value.instruction,
        targetMembers: [],
        isUniversal: true,
        crossContaminationAlert: entry.value.crossContaminationAlert,
      );
    }).toList();
  }
}
