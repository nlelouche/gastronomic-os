import 'dart:async';
import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gastronomic_os/core/enums/diet_enums.dart';
import 'package:gastronomic_os/core/enums/family_role.dart';
import 'package:gastronomic_os/features/onboarding/domain/entities/family_member.dart';
import 'package:gastronomic_os/features/onboarding/domain/repositories/i_onboarding_repository.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe_step.dart';
import 'package:gastronomic_os/features/recipes/presentation/bloc/recipe_bloc.dart';
import 'package:gastronomic_os/features/recipes/presentation/bloc/recipe_event.dart';
import 'package:gastronomic_os/features/recipes/presentation/bloc/recipe_state.dart';
import 'package:gastronomic_os/features/recipes/presentation/pages/recipe_detail_page.dart';
import 'package:gastronomic_os/l10n/generated/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

// --- MOCKS ---
class MockRecipeBloc extends MockBloc<RecipeEvent, RecipeState> implements RecipeBloc {}
class MockOnboardingRepository extends Mock implements IOnboardingRepository {}

void main() {
  final sl = GetIt.instance;
  late MockRecipeBloc mockRecipeBloc;
  late MockOnboardingRepository mockOnboardingRepo;

  setUp(() async {
    // 1. Disable GoogleFonts network calls
    GoogleFonts.config.allowRuntimeFetching = false;
    
    // 2. Load Mock Font 'Outfit' to prevent asset errors
    final fontLoader = FontLoader('Outfit');
    fontLoader.addFont(Future.value(ByteData(0)));
    await fontLoader.load();
    
    // 3. Initialize Mocks
    mockRecipeBloc = MockRecipeBloc();
    mockOnboardingRepo = MockOnboardingRepository();
    
    // 4. Reset and Register GetIt
    await sl.reset(); 
    sl.registerSingleton<IOnboardingRepository>(mockOnboardingRepo);
  });

  tearDown(() async {
    await sl.reset();
  });

  testWidgets('RecipeDetailView displays Soy Allergy variant correctly', (tester) async {
    // --- DATA SETUP ---
    final family = [
      FamilyMember(
        id: 'user1',
        name: 'Mamá',
        role: FamilyRole.mom,
        primaryDiet: DietLifestyle.keto,
        medicalConditions: [MedicalCondition.soyAllergy],
      ),
      FamilyMember(
        id: 'user2',
        name: 'Fercha',
        role: FamilyRole.daughter,
        primaryDiet: DietLifestyle.highPerformance,
        medicalConditions: [],
      ),
    ];

    final recipe = Recipe(
      id: 'TEST-RECIPE',
      authorId: 'test',
      title: 'Soy Test Recipe',
      createdAt: DateTime.now(),
      ingredients: ['Salsa de Soja [Base]', 'Coconut Aminos [Soy Allergy]'],
      steps: [
        RecipeStep(
          instruction: 'Sazonar: Añadir salsa de soja.',
          isBranchPoint: true,
          variantLogic: {
            'Soy Allergy': '🚫 PROHIBIDO SOJA. Usar Coconut Aminos.',
          },
        ),
      ],
    );

    // --- MOCK BEHAVIOR ---
    // Critical: getFamilyMembers is called by _resolveSteps inside didChangeDependencies
    when(() => mockOnboardingRepo.getFamilyMembers())
      .thenAnswer((_) async => (null, family));
      
    // RecipeBloc state used by BlocConsumer/Listener
    when(() => mockRecipeBloc.state)
      .thenReturn(RecipeDetailLoaded(recipe));

    // --- DEBUG PRINTS ---
    print('🛠️ TEST SETUP: GetIt registered: ${sl.isRegistered<IOnboardingRepository>()}');
    
    // --- WIDGET PUMP ---
    await tester.runAsync(() async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: BlocProvider<RecipeBloc>.value(
            value: mockRecipeBloc,
            child: RecipeDetailView(recipe: recipe),
          ),
        ),
      );
    });
    
    // Allow async _resolveSteps to complete
    await tester.pumpAndSettle();

    // --- ASSERTIONS ---
    // 1. Check Family Member Badges (Variant vs Base)
    // "For Mamá" (Variant)
    expect(find.textContaining('Mamá'), findsOneWidget, reason: 'Should show Mamá badge');
    
    // "For Fercha" (Base/Other) logic in RecipeDetailPage currently hides checks if universal matches? 
    // Wait, the logic is: !isUniversal -> Show Badge.
    // Logic for this step: Base Instruction vs Soy Allergy Variant.
    // Soy Allergy -> Mamá. Base -> Fercha.
    // So both should have badges because neither is universal (applying to everyone).
    
    // 3. Check Ingredients
    // We search for the exact ingredient string to avoid matching the instruction text which also mentions "Coconut Aminos"
    expect(find.text('Coconut Aminos [Soy Allergy]'), findsOneWidget);

    // Verify Ingredients Header (Tab + SectionTitle)
    expect(find.text('Ingredients'), findsWidgets);

    // --- TAB INTERACTION ---
    // Switch to Instructions Tab to verify grouped steps
    await tester.tap(find.text('Instructions'));
    await tester.pumpAndSettle();

    // 4. Check Grouped Instructions
    // Variant Instruction (Mamá)
    expect(find.textContaining('PROHIBIDO SOJA'), findsOneWidget, reason: 'Should show allergy warning');
    // Base Instruction (Fercha)
    expect(find.textContaining('salsa de soja'), findsOneWidget, reason: 'Should show base instruction');
    
    // Check for grouping circle (Master Step 1)
    // In our test data, we only have 1 step, so index must be 1.
    expect(find.text('1'), findsWidgets);
  });
}
