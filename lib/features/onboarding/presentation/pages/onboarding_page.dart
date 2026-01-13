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
import 'package:gastronomic_os/core/enums/diet_enums.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gastronomic_os/l10n/generated/app_localizations.dart';
import 'package:gastronomic_os/core/util/localized_enums.dart';

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

class OnboardingView extends StatelessWidget {
  final bool isEditing;

  const OnboardingView({super.key, required this.isEditing});

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
              if (isEditing) {
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
                    l10n.onboardingTitle,
                    style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, curve: Curves.easeOut),
                  
                  const SizedBox(height: 8),
                  Text(
                    l10n.onboardingSubtitle,
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
                            childAspectRatio: 0.75,
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
                    label: isEditing ? l10n.onboardingSaveChanges : l10n.onboardingFinish,
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
            AppLocalizations.of(context)!.onboardingAddMember,
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
    final l10n = AppLocalizations.of(context)!;
    
    // Initialize Enums
    DietLifestyle selectedPrimaryDiet = member?.primaryDiet ?? DietLifestyle.omnivore;
    List<MedicalCondition> selectedConditions = List.from(member?.medicalConditions ?? []);
    
    final roles = ['Dad', 'Mom', 'Son', 'Daughter', 'Grandparent', 'Roommate', 'Other'];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text(member == null ? l10n.onboardingAddMember : l10n.onboardingEditMember, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Field 1: Name ---
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: l10n.onboardingNameLabel,
                          hintText: l10n.onboardingNameHint,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.person_outline),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // --- Field 2: Role ---
                      DropdownButtonFormField<String>(
                        value: selectedRole,
                        decoration: InputDecoration(
                          labelText: l10n.onboardingRoleLabel,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.badge_outlined),
                        ),
                        items: roles.map((r) => DropdownMenuItem(
                          value: r, 
                          child: Text(_getLocalizedRole(context, r))
                        )).toList(),
                        onChanged: (val) => setState(() => selectedRole = val!),
                      ),
                      const SizedBox(height: 24),

                      // --- Section 3: Lifestyle (Primary Diet) ---
                      Text(l10n.onboardingLifestyleTitle, style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        color: Theme.of(context).colorScheme.primary)
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<DietLifestyle>(
                        value: selectedPrimaryDiet,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.restaurant_menu),
                          helperText: l10n.onboardingLifestyleHint,
                        ),
                        items: DietLifestyle.values.map((d) => DropdownMenuItem(
                          value: d, 
                          child: Text(d.localized(context)),
                        )).toList(),
                        onChanged: (val) => setState(() => selectedPrimaryDiet = val!),
                      ),
                      
                      const SizedBox(height: 24),

                      // --- Section 4: Clinical Overlays (Medical) ---
                      Text(l10n.onboardingMedicalTitle, style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        color: Theme.of(context).colorScheme.error)
                      ),
                      const SizedBox(height: 4),
                      Text(l10n.onboardingMedicalHint, 
                        style: TextStyle(fontSize: 12, color: Colors.grey[600])
                      ),
                      const SizedBox(height: 8),
                      
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: MedicalCondition.values.map((condition) {
                          final isSelected = selectedConditions.contains(condition);
                          return FilterChip(
                            label: Text(condition.localized(context), style: const TextStyle(fontSize: 12)),
                            selected: isSelected,
                            selectedColor: Theme.of(context).colorScheme.errorContainer,
                            checkmarkColor: Theme.of(context).colorScheme.error,
                            onSelected: (bool selected) {
                              setState(() {
                                if (selected) {
                                  selectedConditions.add(condition);
                                } else {
                                  selectedConditions.remove(condition);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
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
                     child: Text(l10n.onboardingDelete),
                   ),
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext), 
                  child: Text(l10n.dialogCancel)
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
                        primaryDiet: selectedPrimaryDiet,
                        medicalConditions: selectedConditions,
                      );
                      
                      if (member != null) {
                        bloc.add(UpdateFamilyMember(newMember));
                      } else {
                        bloc.add(AddFamilyMember(newMember));
                      }
                      Navigator.pop(dialogContext);
                    }
                  },
                  child: Text(l10n.onboardingSave),
                ),
              ],
            ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack);
          },
        );
      },
    );
  }

  String _getLocalizedRole(BuildContext context, String roleKey) {
    final l10n = AppLocalizations.of(context)!;
    switch (roleKey) {
      case 'Dad': return l10n.roleDad;
      case 'Mom': return l10n.roleMom;
      case 'Son': return l10n.roleSon;
      case 'Daughter': return l10n.roleDaughter;
      case 'Grandparent': return l10n.roleGrandparent;
      case 'Roommate': return l10n.roleRoommate;
      case 'Other': return l10n.roleOther;
      default: return roleKey;
    }
  }
}
