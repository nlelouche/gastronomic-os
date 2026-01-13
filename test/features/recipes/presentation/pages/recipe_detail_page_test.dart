import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gastronomic_os/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gastronomic_os/core/enums/diet_enums.dart';
import 'package:gastronomic_os/core/enums/family_role.dart';
import 'package:gastronomic_os/features/onboarding/domain/entities/family_member.dart';
import 'package:gastronomic_os/features/onboarding/domain/repositories/i_onboarding_repository.dart';
import 'package:gastronomic_os/features/planner/presentation/bloc/planner_bloc.dart';
import 'package:gastronomic_os/features/planner/presentation/bloc/planner_event.dart';
import 'package:gastronomic_os/features/planner/presentation/bloc/planner_state.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe_step.dart';
import 'package:gastronomic_os/features/recipes/presentation/bloc/recipe_bloc.dart';
import 'package:gastronomic_os/features/recipes/presentation/bloc/recipe_event.dart';
import 'package:gastronomic_os/features/recipes/presentation/bloc/recipe_state.dart';
import 'package:gastronomic_os/features/recipes/presentation/pages/recipe_detail_page.dart';

// --- Mocks ---
class MockRecipeBloc extends MockBloc<RecipeEvent, RecipeState> implements RecipeBloc {}
class MockPlannerBloc extends MockBloc<PlannerEvent, PlannerState> implements PlannerBloc {}
class MockOnboardingRepository extends Mock implements IOnboardingRepository {}

// --- Fakes ---
class FakeRecipeEvent extends Fake implements RecipeEvent {}
class FakeRecipeState extends Fake implements RecipeState {}

void main() {
  final sl = GetIt.instance;
  late MockRecipeBloc mockRecipeBloc;
  late MockPlannerBloc mockPlannerBloc;
  late MockOnboardingRepository mockOnboardingRepo;

  setUpAll(() {
    registerFallbackValue(FakeRecipeEvent());
    registerFallbackValue(FakeRecipeState());
  });

  setUp(() {
    mockRecipeBloc = MockRecipeBloc();
    mockPlannerBloc = MockPlannerBloc();
    mockOnboardingRepo = MockOnboardingRepository();

    // Register mocks in GetIt (needed for _resolveSteps in View)
    sl.registerSingleton<IOnboardingRepository>(mockOnboardingRepo);

    // Stubs
    when(() => mockRecipeBloc.close()).thenAnswer((_) async {});
    when(() => mockPlannerBloc.close()).thenAnswer((_) async {});
  });

  tearDown(() {
    sl.reset();
  });

  // --- Helpers ---
  Recipe createTestRecipe() {
    return Recipe(
      id: 'test-recipe',
      authorId: 'auth',
      title: 'Steak with Vegan Option',
      description: 'A test recipe',
      createdAt: DateTime.now(),
      ingredients: ['Beef', 'Tofu'],
      tags: [],
      dietTags: [],
      steps: [
        RecipeStep(
          instruction: 'Prepare Base',
          isBranchPoint: false,
        ),
        RecipeStep(
          instruction: 'Cook Protein',
          isBranchPoint: true,
          variantLogic: {
            'Vegan': 'Grill Tofu',
            'Omnivore': 'Grill Steak',
          },
        ),
      ],
    );
  }

  FamilyMember createMember(String name, DietLifestyle diet) {
    return FamilyMember(
      id: name,
      name: name,
      role: FamilyRole.other,
      primaryDiet: diet,
      medicalConditions: [],
    );
  }

  Widget createWidgetUnderTest(Recipe recipe) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<RecipeBloc>.value(value: mockRecipeBloc),
        BlocProvider<PlannerBloc>.value(value: mockPlannerBloc),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en')],
        home: RecipeDetailView(recipe: recipe),
      ),
    );
  }

  group('RecipeDetailView UI Tests', () {
    testWidgets('Should display different instructions for mixed-diet family', (tester) async {
      final recipe = createTestRecipe();
      final dad = createMember('Dad', DietLifestyle.omnivore);
      final mom = createMember('Mom', DietLifestyle.vegan);

      when(() => mockRecipeBloc.state).thenReturn(RecipeDetailLoaded(recipe));
      when(() => mockRecipeBloc.stream).thenAnswer((_) => Stream.value(RecipeDetailLoaded(recipe)));
      
      when(() => mockOnboardingRepo.getFamilyMembers()).thenAnswer(
        (_) async => (null, [dad, mom])
      );

      await tester.pumpWidget(createWidgetUnderTest(recipe));
      await tester.pumpAndSettle(); 

      expect(find.text('Prepare Base'), findsOneWidget);
      expect(find.textContaining('Grill Tofu'), findsOneWidget); 
      expect(find.textContaining('Grill Steak'), findsOneWidget); 

      // Use textContaining because UI might say "For Mom"
      expect(find.descendant(of: find.byType(Column), matching: find.textContaining('Mom')), findsOneWidget); 
      expect(find.descendant(of: find.byType(Column), matching: find.textContaining('Dad')), findsOneWidget);
    });

    testWidgets('Should HIDE meat step for fully Vegan family', (tester) async {
      final recipe = createTestRecipe();
      final user1 = createMember('User1', DietLifestyle.vegan);
      final user2 = createMember('User2', DietLifestyle.vegan);

      when(() => mockRecipeBloc.state).thenReturn(RecipeDetailLoaded(recipe));
      when(() => mockRecipeBloc.stream).thenAnswer((_) => Stream.value(RecipeDetailLoaded(recipe)));

      when(() => mockOnboardingRepo.getFamilyMembers()).thenAnswer(
        (_) async => (null, [user1, user2])
      );

      await tester.pumpWidget(createWidgetUnderTest(recipe));
      await tester.pumpAndSettle();

      expect(find.textContaining('Grill Tofu'), findsOneWidget);
      expect(find.textContaining('Grill Steak'), findsNothing);
      expect(find.text('User1'), findsNothing);
    });
  });
}
