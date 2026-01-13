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
    GoogleFonts.config.allowRuntimeFetching = false;
    final fontLoader = FontLoader('Outfit');
    fontLoader.addFont(Future.value(ByteData(0)));
    await fontLoader.load();
    
    mockRecipeBloc = MockRecipeBloc();
    mockOnboardingRepo = MockOnboardingRepository();
    
    await sl.reset(); 
    sl.registerSingleton<IOnboardingRepository>(mockOnboardingRepo);
  });

  testWidgets('Debug UX Test', (tester) async {
    // SETUP
    final family = [FamilyMember(id: 'u1', name: 'User', role: FamilyRole.mom, primaryDiet: DietLifestyle.omnivore, medicalConditions: [])];
    final recipe = Recipe(id: 'r1', authorId: 'a1', title: 'T', createdAt: DateTime.now(), ingredients: [], steps: [
      RecipeStep(instruction: 'Inst 1', isBranchPoint: false)
    ]);

    when(() => mockOnboardingRepo.getFamilyMembers()).thenAnswer((_) async => (null, family));
    when(() => mockRecipeBloc.state).thenReturn(RecipeDetailLoaded(recipe));

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: BlocProvider<RecipeBloc>.value(value: mockRecipeBloc, child: RecipeDetailView(recipe: recipe)),
      ),
    );
    await tester.pumpAndSettle();

    // CHECK TABS
    print('Found Instructions: ${find.text('Instructions').evaluate().length}');
    print('Found Ingredients: ${find.text('Ingredients').evaluate().length}');
    
    // TAP
    await tester.tap(find.text('Instructions'));
    await tester.pumpAndSettle();
    
    // CHECK CONTENT
    print('Found Group Circle 1: ${find.text('1').evaluate().length}');
    
    expect(find.text('1'), findsWidgets);
  });
}
