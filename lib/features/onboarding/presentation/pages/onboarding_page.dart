import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gastronomic_os/core/widgets/ui_kit.dart';
import 'package:gastronomic_os/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:gastronomic_os/features/onboarding/presentation/bloc/onboarding_state_event.dart';
import 'package:gastronomic_os/features/home/presentation/pages/dashboard_page.dart';
import 'package:gastronomic_os/features/onboarding/presentation/widgets/family_member_card.dart';
import 'package:gastronomic_os/features/onboarding/domain/entities/family_member.dart';
import 'package:gastronomic_os/init/injection_container.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<OnboardingBloc>(),
      child: const OnboardingView(),
    );
  }
}

class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // No standard AppBar, usage safe area and custom header
      body: SafeArea(
        child: BlocConsumer<OnboardingBloc, OnboardingState>(
          listener: (context, state) {
            if (state is OnboardingSuccess) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const DashboardPage()),
              );
            } else if (state is OnboardingError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            if (state is OnboardingLoading) {
               return const Center(child: CircularProgressIndicator());
            }

            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  Icon(Icons.family_restroom, size: 48, color: theme.colorScheme.primary).animate().scale(),
                  const SizedBox(height: 16),
                  Text(
                    'Who eats here?',
                    style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, curve: Curves.easeOut),
                  
                  const SizedBox(height: 8),
                  Text(
                    'Build your household profile for personalized diet advice.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 300.ms),
                  
                  const SizedBox(height: 32),
                  
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount = 2;
                        double width = constraints.maxWidth;
                        if (width > 600) crossAxisCount = 3;
                        if (width > 900) crossAxisCount = 4;

                        return GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.85,
                          ),
                          itemCount: state.members.length + 1,
                          itemBuilder: (context, index) {
                            if (index == state.members.length) {
                              return _buildAddCard(context).animate().fadeIn(delay: (100 * index).ms).scale();
                            }
                            final member = state.members[index];
                            return FamilyMemberCard(
                              member: member,
                              onTap: () => _showAddMemberDialog(context, member: member),
                              onLongPress: () => context.read<OnboardingBloc>().add(RemoveFamilyMember(member.id)),
                            ).animate().fadeIn(delay: (100 * index).ms).slideY(begin: 0.1);
                          },
                        );
                      }
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  PrimaryButton(
                    label: 'Finish Setup',
                    icon: Icons.check,
                    onPressed: state.members.isNotEmpty 
                        ? () => context.read<OnboardingBloc>().add(SubmitOnboarding())
                        : null,
                  ).animate().fadeIn(delay: 600.ms).slideY(begin: 1),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAddCard(BuildContext context) {
    return AppCard(
      onTap: () => _showAddMemberDialog(context),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.add, size: 32, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'Add Member',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddMemberDialog(BuildContext context, {FamilyMember? member}) {
    final bloc = context.read<OnboardingBloc>(); // Capture bloc
    final nameController = TextEditingController(text: member?.name ?? '');
    String selectedRole = member?.role ?? 'Dad';
    String selectedDiet = member?.diet ?? 'Omnivore';
    
    final roles = ['Dad', 'Mom', 'Son', 'Daughter', 'Grandparent', 'Roommate', 'Other'];
    final diets = ['Omnivore', 'Vegetarian', 'Vegan', 'Keto', 'Paleo', 'Gluten-Free'];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text(member == null ? 'Add Family Member' : 'Edit Member', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        hintText: 'e.g. John',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      decoration: InputDecoration(
                        labelText: 'Role',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.badge_outlined),
                      ),
                      items: roles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                      onChanged: (val) => setState(() => selectedRole = val!),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedDiet,
                      decoration: InputDecoration(
                        labelText: 'Dietary Preference',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.restaurant_menu),
                      ),
                      items: diets.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                      onChanged: (val) => setState(() => selectedDiet = val!),
                    ),
                  ],
                ),
              ),
              actionsPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              actions: [
                if (member != null)
                   TextButton(
                     style: TextButton.styleFrom(foregroundColor: Colors.red),
                     onPressed: () {
                        bloc.add(RemoveFamilyMember(member.id));
                        Navigator.pop(dialogContext);
                     },
                     child: const Text('Delete'),
                   ),
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext), 
                  child: const Text('Cancel')
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  onPressed: () {
                    if (nameController.text.isNotEmpty) {
                      final newMember = FamilyMember(
                        id: member?.id ?? DateTime.now().toIso8601String(), 
                        name: nameController.text,
                        role: selectedRole,
                        diet: selectedDiet,
                      );
                      
                      if (member != null) {
                        bloc.add(UpdateFamilyMember(newMember));
                      } else {
                        bloc.add(AddFamilyMember(newMember));
                      }
                      Navigator.pop(dialogContext);
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack);
          },
        );
      },
    );
  }
}
