import 'dart:io';
import 'package:supabase/supabase.dart';

// --- LOCAL DATA DEFINITIONS (Flutter-Free) ---

class TestRecipe {
  final String id;
  final String title;
  final List<TestStep> steps;

  TestRecipe({required this.id, required this.title, required this.steps});

  factory TestRecipe.fromJson(Map<String, dynamic> json) {
    return TestRecipe(
      id: json['id'],
      title: json['title'],
      steps: (json['steps'] as List).map((e) => TestStep.fromJson(e)).toList(),
    );
  }
}

class TestStep {
  final String instruction;
  final bool isBranchPoint;
  final Map<String, String>? variantLogic;

  TestStep({required this.instruction, this.isBranchPoint = false, this.variantLogic});

  factory TestStep.fromJson(Map<String, dynamic> json) {
    return TestStep(
      instruction: json['instruction'],
      isBranchPoint: json['is_branch_point'] ?? false,
      variantLogic: json['variant_logic'] != null 
          ? Map<String, String>.from(json['variant_logic']) 
          : null,
    );
  }
}

class TestMember {
  final String name;
  final String diet;
  final List<String> conditions;

  TestMember({required this.name, required this.diet, required this.conditions});
}

class TestResolver {
  List<String> resolve(TestRecipe recipe, TestMember member) {
    return recipe.steps.map((step) {
      if (!step.isBranchPoint || step.variantLogic == null) return step.instruction;
      
      // 1. Check Conditions
      for (final condition in member.conditions) {
        // Case-insensitive check against keys
        for (final key in step.variantLogic!.keys) {
          if (key.toLowerCase() == condition.toLowerCase()) {
            return step.variantLogic![key]!; // Found match
          }
        }
      }
      
      // 2. Check Diet
      for (final key in step.variantLogic!.keys) {
        if (key.toLowerCase() == member.diet.toLowerCase()) {
          return step.variantLogic![key]!;
        }
      }
      
      return step.instruction; // Fallback
    }).toList();
  }
}

// --- MAIN SCRIPT ---

Future<void> main() async {
  const supabaseUrl = 'https://absamxtltbygnadetgex.supabase.co';
  const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFic2FteHRsdGJ5Z25hZGV0Z2V4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjgxMDQyMzEsImV4cCI6MjA4MzY4MDIzMX0.rY4GepPkLSlSeQbDgz7lYUzhZ-lJZT7WZeCFiyPqwEk';

  final supabase = SupabaseClient(supabaseUrl, supabaseKey);
  
  // Authenticate to satisfy RLS
  try {
    await supabase.auth.signInAnonymously();
    print('✅ Validating as Anonymous User: ${supabase.auth.currentUser?.id}');
  } catch (e) {
    print('⚠️ Auth warning: $e');
  }

  final recipeId = '891e1ef8-16ac-4488-94e2-81bd2139e713';

  print('\n🏥 STRICT CLINICAL VALIDATION PROTOCOL (DATA INTEGRITY) 🏥');
  print('Target Recipe: [MASTER] Bol Universal de Alto Rendimiento');
  print('ID: $recipeId\n');

  try {
    // 1. Fetch Recipe Header
    final headerResponse = await supabase
        .from('recipes')
        .select()
        .eq('id', recipeId)
        .single();
    
    print('✅ Loaded Header: ${headerResponse['title']}');

    // 2. Fetch Latest Snapshot
    final snapshotResponse = await supabase
        .from('recipe_snapshots')
        .select()
        .eq('recipe_id', recipeId)
        .order('created_at', ascending: false)
        .limit(1)
        .single();

    final fullStructure = snapshotResponse['full_structure'];
    if (fullStructure == null) throw Exception('Snapshot has no full_structure');
    
    // Merge header + snapshot data for our TestRecipe
    final recipeData = Map<String, dynamic>.from(headerResponse);
    recipeData['steps'] = fullStructure['steps'];
    
    final recipe = TestRecipe.fromJson(recipeData);
    print('✅ Loaded Recipe: ${recipe.title}');
    print('   Steps: ${recipe.steps.length}');
    
    final resolver = TestResolver();
    int passedTests = 0;
    int failedTests = 0;

    // --- TEST CASE 1: CELIAC (Gluten Free) ---
    print('\n🧪 TEST CASE 1: Celiac Disease (Gluten Free)');
    final celiacMember = TestMember(
      name: 'Carla Celiaca',
      diet: 'Omnivore',
      conditions: ['Celiac'], // Matches Enum Key
    );
    
    final celiacSteps = resolver.resolve(recipe, celiacMember);
    
    final tamariStep = celiacSteps.firstWhere(
      (s) => s.toLowerCase().contains('tamari') || s.toLowerCase().contains('coconut aminos'),
      orElse: () => '',
    );
    
    if (tamariStep.isNotEmpty) {
      print('   ✅ PASS: Found Tamari/GF substitution: "${tamariStep}"');
      passedTests++;
    } else {
      print('   ❌ FAIL: Celiac variant missing!');
      failedTests++;
    }

    // --- TEST CASE 2: RENAL (Low Sodium) ---
    print('\n🧪 TEST CASE 2: Renal Diet');
    final renalMember = TestMember(
      name: 'Roberto Renal',
      diet: 'Omnivore',
      conditions: ['Renal'],
    );
    
    final renalSteps = resolver.resolve(recipe, renalMember);
    // Check for low sodium/amino warning
    final renalStep = renalSteps.firstWhere(
      (s) => s.toLowerCase().contains('renal') || 
             s.toLowerCase().contains('sodio') || // Spanish
             s.toLowerCase().contains('potasio') || // Spanish
             s.toLowerCase().contains('omitir'),
      orElse: () => '',
    );
    
     if (renalStep.isNotEmpty) {
      print('   ✅ PASS: Found Renal specific instruction: "${renalStep}"');
      passedTests++;
    } else {
      print('   ❌ FAIL: Renal variant missing!');
      print('   > Debug: Available Variant Keys in Recipe:');
      for(final s in recipe.steps) {
        if(s.variantLogic != null) {
          print('     Step "${s.instruction.substring(0, 10)}...": ${s.variantLogic!.keys.toList()}');
        }
      }
      failedTests++;
    }

    // --- TEST CASE 3: HISTAMINE ---
    print('\n🧪 TEST CASE 3: Histamine Intolerance');
    final histamineMember = TestMember(
      name: 'Hilda Histamine',
      diet: 'Omnivore',
      conditions: ['Histamine'],
    );
    
    final histamineSteps = resolver.resolve(recipe, histamineMember);
    
    final histamineStep = histamineSteps.firstWhere(
      (s) => s.toLowerCase().contains('histamine') || s.toLowerCase().contains('coconut aminos') || s.toLowerCase().contains('fresco'),
      orElse: () => '',
    );
    
    if (histamineStep.isNotEmpty) {
      print('   ✅ PASS: Found Histamine instruction: "${histamineStep}"');
      passedTests++;
    } else {
      print('   ❌ FAIL: Histamine variant missing!');
      failedTests++;
    }
    
    // --- TEST CASE 4: LOW FODMAP ---
    print('\n🧪 TEST CASE 4: Low FODMAP');
    final fodmapMember = TestMember(
      name: 'Fiona Fodmap',
      diet: 'Omnivore',
      conditions: ['Low FODMAP'],
    );
    
    final fodmapSteps = resolver.resolve(recipe, fodmapMember);
    
    final fodmapStep = fodmapSteps.firstWhere(
      (s) => s.toLowerCase().contains('fodmap') || s.toLowerCase().contains('garlic') || s.toLowerCase().contains('ajo'),
      orElse: () => '',
    );

    if (fodmapStep.isNotEmpty) {
      print('   ✅ PASS: Found FODMAP instruction: "${fodmapStep}"');
      passedTests++;
    } else {
      print('   ❌ FAIL: FODMAP variant missing!');
      failedTests++;
    }

    print('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('RESULTS: $passedTests PASSED, $failedTests FAILED');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    
    if (failedTests > 0) exit(1);

  } catch (e, stack) {
    print('❌ CRITICAL ERROR: $e');
    print(stack);
    exit(1);
  }
}
