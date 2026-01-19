import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:gastronomic_os/init/supabase_init.dart';
import 'package:gastronomic_os/features/planner/presentation/bloc/planner_bloc.dart';
import 'package:gastronomic_os/features/planner/presentation/bloc/planner_event.dart';
import 'package:gastronomic_os/init/injection_container.dart' as di;
import 'package:gastronomic_os/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:gastronomic_os/features/home/presentation/pages/dashboard_page.dart';
import 'package:gastronomic_os/features/onboarding/domain/repositories/i_onboarding_repository.dart';
import 'package:gastronomic_os/core/theme/app_theme.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gastronomic_os/l10n/generated/app_localizations.dart';
import 'package:gastronomic_os/core/bloc/localization_bloc.dart';
import 'package:gastronomic_os/core/bloc/theme_cubit.dart';
import 'package:gastronomic_os/core/bloc/theme_state.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gastronomic_os/core/services/ad_service.dart';
import 'package:gastronomic_os/core/services/remote_config_service.dart';
import 'package:gastronomic_os/core/services/iap_service.dart';
import 'package:gastronomic_os/features/premium/presentation/bloc/subscription_cubit.dart';
import 'package:gastronomic_os/core/widgets/main_shell.dart';

import 'package:gastronomic_os/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gastronomic_os/features/auth/presentation/bloc/auth_event.dart';
import 'package:gastronomic_os/features/auth/presentation/bloc/auth_state.dart';
import 'package:gastronomic_os/features/auth/presentation/pages/auth_landing_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase and other core services
  await Firebase.initializeApp(); // Initialize Firebase
  
  // 🚨 CRASHLYTICS SETUP
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  await SupabaseInit.init();
  await di.init(); // Initialize Dependency Injection
  
  // Initialize Monetization Services
  await di.sl<RemoteConfigService>().initialize();
  await di.sl<AdService>().initialize();
  await di.sl<IAPService>().initialize();
  
  runApp(const GastronomicOSApp());
}


class GastronomicOSApp extends StatelessWidget {
  const GastronomicOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => di.sl<AuthBloc>()..add(AuthCheckRequested()),
        ),
        BlocProvider<PlannerBloc>(
          create: (_) => di.sl<PlannerBloc>()..add(LoadPlannerSuggestions()),
        ),
        BlocProvider<LocalizationBloc>(
          create: (_) => di.sl<LocalizationBloc>(),
        ),
        BlocProvider<ThemeCubit>(
          create: (_) => di.sl<ThemeCubit>(),
        ),
        BlocProvider<SubscriptionCubit>(
          create: (_) => di.sl<SubscriptionCubit>(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return BlocBuilder<LocalizationBloc, LocalizationState>(
            builder: (context, localeState) {
              return MaterialApp(
                title: 'Gastronomic OS',
                theme: themeState.lightTheme,
                darkTheme: themeState.darkTheme,
                themeMode: themeState.themeMode,
                locale: localeState.locale,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [
                  Locale('en'),
                  Locale('es'),
                ],
                builder: (context, child) => ResponsiveBreakpoints.builder(
                  child: child!,
                  breakpoints: [
                    const Breakpoint(start: 0, end: 450, name: MOBILE),
                    const Breakpoint(start: 451, end: 800, name: TABLET),
                    const Breakpoint(start: 801, end: 1920, name: DESKTOP),
                    const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
                  ],
                ),
                home: const AuthWrapper(),
              );
            },
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated || state is AuthGuest) {
          return const OnboardingCheckWrapper();
        } else if (state is AuthUnauthenticated || state is AuthError) {
           // Show landing page if not authenticated (or if error occurred during check)
           return const AuthLandingPage();
        }
        // AuthLoading or AuthInitial
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

class OnboardingCheckWrapper extends StatefulWidget {
  const OnboardingCheckWrapper({super.key});

  @override
  State<OnboardingCheckWrapper> createState() => _OnboardingCheckWrapperState();
}

class _OnboardingCheckWrapperState extends State<OnboardingCheckWrapper> {
  bool? _onboardingCompleted;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final repo = di.sl<IOnboardingRepository>();
    final result = await repo.hasCompletedOnboarding();
    
    if (mounted) {
      setState(() {
        _onboardingCompleted = result.$2;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_onboardingCompleted == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    if (_onboardingCompleted!) {
      return const MainShell();
    } else {
      return const OnboardingPage();
    }
  }
}
