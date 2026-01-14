import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gastronomic_os/core/theme/app_dimens.dart';
import 'package:gastronomic_os/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:gastronomic_os/features/onboarding/presentation/bloc/onboarding_state_event.dart';
import 'package:gastronomic_os/features/home/presentation/pages/dashboard_page.dart';
import 'package:gastronomic_os/features/onboarding/presentation/widgets/onboarding_family_step.dart';
import 'package:gastronomic_os/features/onboarding/presentation/widgets/onboarding_legal_step.dart';
import 'package:gastronomic_os/init/injection_container.dart';
import 'package:gastronomic_os/l10n/generated/app_localizations.dart';

class OnboardingPage extends StatelessWidget {
  final bool isEditing;

  const OnboardingPage({super.key, this.isEditing = false});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OnboardingBloc>(
      create: (context) {
        final bloc = sl<OnboardingBloc>();
        if (isEditing) {
          bloc.add(LoadFamilyMembers());
        }
        return bloc;
      },
      child: OnboardingView(isEditing: isEditing),
    );
  }
}

class OnboardingView extends StatefulWidget {
  final bool isEditing;

  const OnboardingView({super.key, required this.isEditing});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    // If editing, start at Family Step (Index 1) to skip Legal
    _pageController = PageController(initialPage: widget.isEditing ? 1 : 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // No standard AppBar, usage safe area and custom header
      body: SafeArea(
        child: BlocConsumer<OnboardingBloc, OnboardingState>(
          listener: (context, state) {
            if (state is OnboardingSuccess) {
              if (widget.isEditing) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.onboardingSuccess)));
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const DashboardPage()),
                );
              }
            } else if (state is OnboardingError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            return PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(), // Force manual navigation
              children: [
                OnboardingLegalStep(
                  onAccepted: () {
                    _pageController.nextPage(
                      duration: 300.ms, 
                      curve: Curves.easeInOut,
                    );
                  },
                ),
                OnboardingFamilyStep(isEditing: widget.isEditing),
              ],
            );
          },
        ),
      ),
    );
  }
}
