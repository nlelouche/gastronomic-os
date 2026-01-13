import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gastronomic_os/core/enums/diet_enums.dart';
import 'package:gastronomic_os/core/enums/family_role.dart';
import 'package:gastronomic_os/features/onboarding/domain/entities/family_member.dart';
import 'package:gastronomic_os/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:gastronomic_os/features/onboarding/presentation/bloc/onboarding_state_event.dart';
import 'package:gastronomic_os/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:gastronomic_os/core/widgets/ui_kit.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gastronomic_os/l10n/generated/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

class MockOnboardingBloc extends MockBloc<OnboardingEvent, OnboardingState>
    implements OnboardingBloc {}

class FakeOnboardingEvent extends Fake implements OnboardingEvent {}
class FakeOnboardingState extends Fake implements OnboardingState {}

void main() {
  late MockOnboardingBloc mockBloc;

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false; 
    registerFallbackValue(FakeOnboardingEvent());
    registerFallbackValue(FakeOnboardingState());
  });

  setUp(() {
    mockBloc = MockOnboardingBloc();
    final sl = GetIt.instance;
    sl.reset();
    sl.registerFactory<OnboardingBloc>(() => mockBloc);
  });

  tearDown(() {
    GetIt.instance.reset();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: const OnboardingPage(),
    );
  }

  testWidgets('OnboardingPage renders correctly', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400); // Standard Mobile
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);

    when(() => mockBloc.state).thenReturn(const OnboardingInitial());

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(); // Allow animations to start

    expect(find.text('Welcome to Gastronomic OS'), findsOneWidget); 
    expect(find.byIcon(Icons.family_restroom), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget); 
  });

  testWidgets('Tapping Add Member opens dialog', (tester) async {
    when(() => mockBloc.state).thenReturn(const OnboardingInitial());

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.text('Add Family Member'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget); // Name input
  });

  testWidgets('Filling dialog and saving emits AddFamilyMember', (tester) async {
    when(() => mockBloc.state).thenReturn(const OnboardingInitial());

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Open Dialog
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Fill Name
    await tester.enterText(find.byType(TextField), 'John Doe');
    
    // Save
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Verify Bloc Event
    verify(() => mockBloc.add(any(that: isA<AddFamilyMember>()
      .having((e) => e.member.name, 'name', 'John Doe')
    ))).called(1);
  });

  testWidgets('Finish button is disabled when no members', (tester) async {
    when(() => mockBloc.state).thenReturn(const OnboardingInitial());

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Find PrimaryButton
    final buttonFinder = find.widgetWithText(PrimaryButton, 'Finish Setup');
    final button = tester.widget<PrimaryButton>(buttonFinder);
    expect(button.onPressed, isNull);
  });

  testWidgets('Finish button is enabled with members and emits Submit', (tester) async {
    when(() => mockBloc.state).thenReturn(const OnboardingUpdated(members: [
      FamilyMember(id: '1', name: 'Dad', role: FamilyRole.dad, primaryDiet: DietLifestyle.omnivore, medicalConditions: [])
    ]));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Tap Finish (PrimaryButton)
    final buttonFinder = find.widgetWithText(PrimaryButton, 'Finish Setup');
    await tester.ensureVisible(buttonFinder); 
    await tester.tap(buttonFinder);
    await tester.pump();

    verify(() => mockBloc.add(any(that: isA<SubmitOnboarding>()))).called(1);
  });
}
