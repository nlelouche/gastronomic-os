import 'package:flutter/material.dart';
import 'package:gastronomic_os/init/supabase_init.dart';
import 'package:gastronomic_os/init/injection_container.dart' as di;
import 'package:gastronomic_os/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:gastronomic_os/features/home/presentation/pages/dashboard_page.dart';
import 'package:gastronomic_os/features/onboarding/domain/repositories/i_onboarding_repository.dart';
import 'package:gastronomic_os/core/theme/app_theme.dart';
import 'package:responsive_framework/responsive_framework.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase and other core services
  await SupabaseInit.init();
  await di.init(); // Initialize Dependency Injection
  
  runApp(const GastronomicOSApp());
}

class GastronomicOSApp extends StatelessWidget {
  const GastronomicOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gastronomic OS',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system, // or User preference later
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
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool? _onboardingCompleted;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    // Wait for Supabase to be ready (just in case)
    // Actually SupabaseInit.init() in main() awaits it.
    
    // Check repository
    final repo = di.sl<IOnboardingRepository>();
    final result = await repo.hasCompletedOnboarding();
    
    // result is (Failure?, bool)
    final isComplete = result.$2; 
    
    if (mounted) {
      setState(() {
        _onboardingCompleted = isComplete;
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
      return const DashboardPage();
    } else {
      return const OnboardingPage();
    }
  }
}
