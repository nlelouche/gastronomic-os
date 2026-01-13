import 'dart:io';
import 'dart:convert';

void main() async {
  final recipesDir = Directory(r'd:\Gastronomic OS\assets\recipes');
  final outputFile = File(r'C:\Users\User\.gemini\antigravity\brain\0a13cee8-3559-4c2a-a780-86d986d96996\recipe_refinement_package.md');
  
  final buffer = StringBuffer();
  
  // 1. Introduction & Context
  buffer.writeln('# Gastronomic OS: Recipe Refinement & Engineering Package');
  buffer.writeln();
  buffer.writeln('> **Objective**: Review, expand, and professionally refine 55 existing JSON recipes to meet "Chef Quality" standards while strictly preserving the "Clinical Safety" logic.');
  buffer.writeln();

  // 2. The Logic System
  buffer.writeln('## 1. The Logic System (Clinical Safety)');
  buffer.writeln('Gastronomic OS is a medical-grade meal planner. We have a "Zero Tolerance" policy for medical conditions. The recipe engine uses a strict branching system.');
  buffer.writeln();
  buffer.writeln('### Core Rules:');
  buffer.writeln('1.  **Branch Points**: Any step that forks based on a condition MUST have `"is_branch_point": true`.');
  buffer.writeln('2.  **Variant Logic**: Uses strictly formatted keys (e.g., `APLV`, `Keto`, `Vegan`, `Low FODMAP`).');
  buffer.writeln('3.  **Text Keys**: Steps typically use reference keys (e.g., `step_1_base`, `step_1_dairy_free`) rather than raw text, though raw text is acceptable if standardized.');
  buffer.writeln();
  buffer.writeln('### The Goal for You (The Agent):');
  buffer.writeln('- **Expand Instructions**: Convert simple steps like "Cook meat" into "Heat pan to medium-high (180°C), sear meat for 4 mins per side until golden brown".');
  buffer.writeln('- **Improve Metadata**: Ensure `prep_time`, `cook_time`, and `servings` are realistic.');
  buffer.writeln('- **Verify Structure**: Ensure every branch point is logically sound (e.g., if you have a variant for `APLV` (No Milk), make sure the ingredient list supports it).');
  buffer.writeln();

  // 3. The Recipe Dump
  buffer.writeln('## 2. Current Recipe Database');
  buffer.writeln('Below are the raw JSON contents of our current recipe database. Please analyze them.');
  buffer.writeln();

  final jsonDir = Directory(r'd:\Gastronomic OS\Documentation\test_recipes\json');
  final Map<String, dynamic> uniqueRecipes = {};

  if (await jsonDir.exists()) {
    final files = await jsonDir.list().toList();
    for (var file in files) {
      if (file is File && file.path.endsWith('.json')) {
        try {
          final content = await file.readAsString();
          // Skip empty or font manifest files
          if (content.trim().isEmpty || file.path.contains('Manifest')) continue;
          
          final dynamic parsed = jsonDecode(content);
          if (parsed is List) {
            for (var item in parsed) {
              final id = item['id'];
              if (id != null) {
                uniqueRecipes[id] = item;
              }
            }
          }
        } catch (e) {
          print('Skipping ${file.path}: Not a valid JSON list of recipes');
        }
      }
    }
  }

  // Sort by ID naturally
  final sortedKeys = uniqueRecipes.keys.toList()..sort((a, b) {
     // rudimentary numeric sort if possible GOS-01 vs GOS-10
     return a.compareTo(b);
  });

  int count = 0;
  for (var key in sortedKeys) {
    count++;
    final recipe = uniqueRecipes[key];
    final title = recipe['title'] ?? 'Unknown Recipe';
    final id = recipe['id'] ?? 'NO-ID';
    const encoder = JsonEncoder.withIndent('  ');
    final prettyJson = encoder.convert(recipe);

    buffer.writeln('### $count. $title ($id)');
    buffer.writeln('```json');
    buffer.writeln(prettyJson);
    buffer.writeln('```');
    buffer.writeln('---');
  }

  await outputFile.writeAsString(buffer.toString());
  print('Successfully exported $count unique recipes to ${outputFile.path}');
}
