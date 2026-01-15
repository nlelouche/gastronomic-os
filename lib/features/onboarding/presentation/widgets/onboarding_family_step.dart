import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gastronomic_os/core/widgets/ui_kit.dart';
import 'package:gastronomic_os/core/theme/app_dimens.dart';
import 'package:gastronomic_os/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:gastronomic_os/features/onboarding/presentation/bloc/onboarding_state_event.dart';
import 'package:gastronomic_os/features/onboarding/presentation/widgets/family_member_card.dart';
import 'package:gastronomic_os/features/onboarding/domain/entities/family_member.dart';
import 'package:gastronomic_os/core/enums/diet_enums.dart';
import 'package:gastronomic_os/core/enums/family_role.dart';
import 'package:gastronomic_os/core/util/localized_enums.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gastronomic_os/l10n/generated/app_localizations.dart';
import 'package:gastronomic_os/features/onboarding/presentation/widgets/avatar_selector.dart';

class OnboardingFamilyStep extends StatelessWidget {
  final bool isEditing;

  const OnboardingFamilyStep({super.key, required this.isEditing});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    // Consuming Bloc State from Parent Page
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, state) {
        if (state is OnboardingLoading) {
           return const Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: const EdgeInsets.all(AppDimens.paddingPage),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppDimens.spaceXL),
              Icon(Icons.family_restroom, size: AppDimens.iconSizeXL, color: theme.colorScheme.primary).animate().scale(),
              const SizedBox(height: AppDimens.spaceL),
              Text(
                l10n.onboardingTitle,
                style: GoogleFonts.outfit(
                  fontSize: AppDimens.fontSizeTitle,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: AppDimens.durationShortMs.ms).slideY(begin: 0.2, curve: Curves.easeOut),
              
              const SizedBox(height: AppDimens.spaceS),
              Text(
                l10n.onboardingSubtitle,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: AppDimens.durationMediumMs.ms),
              
              const SizedBox(height: AppDimens.space2XL),
              
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = 2;
                    double width = constraints.maxWidth;
                    if (width > AppDimens.breakpointTablet) crossAxisCount = 3;
                    if (width > AppDimens.breakpointDesktop) crossAxisCount = 4;

                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: AppDimens.spaceL,
                        mainAxisSpacing: AppDimens.spaceL,
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
              
              const SizedBox(height: AppDimens.spaceXL),
              
              PrimaryButton(
                label: isEditing ? l10n.onboardingSaveChanges : l10n.onboardingFinish,
                icon: Icons.check,
                onPressed: state.members.isNotEmpty 
                    ? () => context.read<OnboardingBloc>().add(SubmitOnboarding())
                    : null,
              ).animate().fadeIn(delay: AppDimens.durationLongMs.ms).slideY(begin: 1),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddCard(BuildContext context) {
    return AppCard(
      onTap: () => _showAddMemberDialog(context),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimens.spaceL),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.add, size: AppDimens.iconSizeL, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(height: AppDimens.spaceL),
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
    final bloc = context.read<OnboardingBloc>(); 
    final nameController = TextEditingController(text: member?.name ?? '');
    FamilyRole selectedRole = member?.role ?? FamilyRole.dad;
    final l10n = AppLocalizations.of(context)!;
    
    // Initialize Enums
    DietLifestyle selectedPrimaryDiet = member?.primaryDiet ?? DietLifestyle.omnivore;
    List<MedicalCondition> selectedConditions = List.from(member?.medicalConditions ?? []);
    String? selectedAvatar = member?.avatarPath;
    
    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusXL)),
              title: Text(member == null ? l10n.onboardingAddMember : l10n.onboardingEditMember, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       _buildPrimaryCookOption(context, member, bloc, dialogContext),
                       
                       // --- Field 0: Avatar ---
                       AvatarSelector(
                         currentAvatarPath: selectedAvatar,
                         onAvatarSelected: (path) => setState(() => selectedAvatar = path),
                       ),
                       const SizedBox(height: AppDimens.spaceL),

                      // --- Field 1: Name ---
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: l10n.onboardingNameLabel,
                          hintText: l10n.onboardingNameHint,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimens.radiusM)),
                          prefixIcon: const Icon(Icons.person_outline),
                        ),
                      ),
                      const SizedBox(height: AppDimens.spaceL),
                      
                      // --- Field 2: Role ---
                      DropdownButtonFormField<FamilyRole>(
                        value: selectedRole,
                        decoration: InputDecoration(
                          labelText: l10n.onboardingRoleLabel,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimens.radiusM)),
                          prefixIcon: const Icon(Icons.badge_outlined),
                        ),
                        items: FamilyRole.values.map((r) => DropdownMenuItem(
                          value: r, 
                          child: Text(r.localized(context))
                        )).toList(),
                        onChanged: (val) => setState(() => selectedRole = val!),
                      ),
                      const SizedBox(height: AppDimens.spaceXL),

                      // --- Section 3: Lifestyle (Primary Diet) ---
                      Text(l10n.onboardingLifestyleTitle, style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        color: Theme.of(context).colorScheme.primary)
                      ),
                      const SizedBox(height: AppDimens.spaceS),
                      DropdownButtonFormField<DietLifestyle>(
                        value: selectedPrimaryDiet,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimens.radiusM)),
                          prefixIcon: const Icon(Icons.restaurant_menu),
                          helperText: l10n.onboardingLifestyleHint,
                        ),
                        items: DietLifestyle.values.map((d) => DropdownMenuItem(
                          value: d, 
                          child: Text(d.localized(context)),
                        )).toList(),
                        onChanged: (val) => setState(() => selectedPrimaryDiet = val!),
                      ),
                      
                      const SizedBox(height: AppDimens.spaceXL),

                      // --- Section 4: Clinical Overlays (Medical) ---
                      Text(l10n.onboardingMedicalTitle, style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        color: Theme.of(context).colorScheme.error)
                      ),
                      const SizedBox(height: AppDimens.spaceXS),
                      Text(l10n.onboardingMedicalHint, 
                        style: TextStyle(fontSize: AppDimens.fontSizeSmall, color: Theme.of(context).colorScheme.onSurfaceVariant)
                      ),
                      const SizedBox(height: AppDimens.spaceS),
                      
                      Wrap(
                        spacing: AppDimens.spaceS,
                        runSpacing: AppDimens.spaceXS,
                        children: MedicalCondition.values.map((condition) {
                          final isSelected = selectedConditions.contains(condition);
                          return FilterChip(
                            label: Text(condition.localized(context), style: const TextStyle(fontSize: AppDimens.fontSizeSmall)),
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
              actionsPadding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingPage, vertical: AppDimens.paddingPage),
              actions: [
                if (member != null)
                   TextButton(
                     style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusM)),
                    padding: const EdgeInsets.symmetric(horizontal: AppDimens.spaceXL, vertical: AppDimens.spaceM),
                  ),
                  onPressed: () {
                    if (nameController.text.isNotEmpty) {
                      final newMember = FamilyMember(
                        id: member?.id ?? DateTime.now().toIso8601String(), 
                        name: nameController.text,
                        role: selectedRole,
                        primaryDiet: selectedPrimaryDiet,
                        medicalConditions: selectedConditions,
                        avatarPath: selectedAvatar,
                        isVerifiedChef: member?.isVerifiedChef ?? false,
                        isPrimaryCook: member?.isPrimaryCook ?? false,
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
            ).animate().scale(duration: AppDimens.durationMediumMs.ms, curve: Curves.easeOutBack);
          },
        );
      },
    );
  }

  Widget _buildPrimaryCookOption(BuildContext context, FamilyMember? member, OnboardingBloc bloc, BuildContext dialogContext) {
    if (member == null) return const SizedBox.shrink();
    if (member.isPrimaryCook) {
      return Container(
        margin: const EdgeInsets.only(bottom: AppDimens.spaceL),
        padding: const EdgeInsets.all(AppDimens.spaceM),
        decoration: BoxDecoration(
          color: Colors.amber.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
          border: Border.all(color: Colors.amber),
        ),
        child: Row(
          children: [
            const Icon(Icons.star, color: Colors.amber),
            const SizedBox(width: AppDimens.spaceM),
            Expanded(child: Text("Primary Chef", style: TextStyle(color: Colors.amber[800], fontWeight: FontWeight.bold))),
          ],
        ),
      );
    }
    
    return Container(
       margin: const EdgeInsets.only(bottom: AppDimens.spaceL),
       child: OutlinedButton.icon(
          onPressed: () {
             bloc.add(SetPrimaryCookEvent(member.id));
             Navigator.pop(dialogContext); // Close dialog to refresh
          },
          icon: const Icon(Icons.star_border, color: Colors.amber),
          label: const Text("Make Primary Chef"),
       ),
    );
  }
}
