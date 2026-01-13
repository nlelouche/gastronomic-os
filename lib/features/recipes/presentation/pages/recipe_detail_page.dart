import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gastronomic_os/core/util/app_logger.dart';
import 'package:gastronomic_os/core/widgets/ui_kit.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe_step.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/resolved_step.dart';
import 'package:gastronomic_os/features/recipes/domain/logic/recipe_resolver.dart';
import 'package:gastronomic_os/features/recipes/presentation/bloc/recipe_bloc.dart';
import 'package:gastronomic_os/features/recipes/presentation/bloc/recipe_event.dart';
import 'package:gastronomic_os/features/recipes/presentation/bloc/recipe_state.dart';
import 'package:gastronomic_os/features/onboarding/domain/repositories/i_onboarding_repository.dart';
import 'package:gastronomic_os/init/injection_container.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gastronomic_os/features/planner/presentation/bloc/planner_bloc.dart';
import 'package:gastronomic_os/features/planner/presentation/bloc/planner_event.dart';
import 'package:gastronomic_os/features/planner/domain/entities/meal_plan.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:gastronomic_os/features/recipes/presentation/widgets/formatted_recipe_text.dart';
import 'package:gastronomic_os/l10n/generated/app_localizations.dart';
import 'package:gastronomic_os/core/theme/app_dimens.dart';

class RecipeDetailPage extends StatelessWidget {
  final Recipe recipe;
  final bool isModal;

  const RecipeDetailPage({super.key, required this.recipe, this.isModal = false});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<RecipeBloc>()..add(LoadRecipeDetails(recipe.id)),
      child: RecipeDetailView(recipe: recipe, isModal: isModal),
    );
  }
}

class RecipeDetailView extends StatefulWidget {
  final Recipe recipe;
  final bool isModal;

  const RecipeDetailView({super.key, required this.recipe, this.isModal = false});

  @override
  State<RecipeDetailView> createState() => _RecipeDetailViewState();
}

class _RecipeDetailViewState extends State<RecipeDetailView> {
  List<ResolvedStep>? _resolvedSteps;
  bool _isResolvingSteps = false;

  @override
  void initState() {
    super.initState();
    // Do not call _resolveSteps() here as it depends on InheritedWidgets (Locale)
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Re-resolve steps when dependencies (like Locale) change
    // This ensures that if language switches, we re-run logic on the localized recipe steps
    final blocState = context.read<RecipeBloc>().state;
    if (blocState is RecipeDetailLoaded) {
       _resolveSteps(blocState.recipe);
    } else {
       // If no bloc state yet, use widget.recipe (though it might be minimal)
       _resolveSteps(widget.recipe); 
    }
  }

  Future<void> _resolveSteps([Recipe? recipe]) async {
    // If resolving a new recipe (from Bloc), don't show loading if we already have partial data?
    // Actually, resolving is fast, but let's keep the spinner logic for initState.
    if (recipe == null) setState(() => _isResolvingSteps = true); // Only show loading on initial
    
    try {
      final rawRecipe = recipe ?? (context.read<RecipeBloc>().state is RecipeDetailLoaded 
           ? (context.read<RecipeBloc>().state as RecipeDetailLoaded).recipe 
           : widget.recipe);
           
      final currentLocale = Localizations.localeOf(context);
      final targetRecipe = rawRecipe.localize(currentLocale);

      final onboardingRepo = sl<IOnboardingRepository>();
      final familyResult = await onboardingRepo.getFamilyMembers();
      final family = familyResult.$2 ?? [];
      
      final resolver = RecipeResolver();
      final resolved = resolver.resolve(targetRecipe, family);
      
      if (mounted) {
        setState(() {
          _resolvedSteps = resolved;
          _isResolvingSteps = false;
        });
      }
    } catch (e, stack) {
      AppLogger.e('🔥 Error resolving steps', e, stack);
      if (mounted) setState(() => _isResolvingSteps = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: BlocConsumer<RecipeBloc, RecipeState>(
        listener: (context, state) {
          if (state is RecipeDetailLoaded) {
            _resolveSteps(state.recipe);
          }
        },
        builder: (context, state) {
          if (state is RecipeLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is RecipeDetailLoaded) {
            // Apply Localization
            final currentLocale = Localizations.localeOf(context);
            final fullRecipe = state.recipe.localize(currentLocale);
            
            // Re-resolve steps if the language changed or recipe loaded
            // Note: _resolveSteps is usually called in listener, but that's only on state change.
            // If the user switches language in Settings and comes back, `build` runs but state didn't change.
            // A simple check: if fullRecipe steps differ from what we have resolved (conceptually), we assume we need to re-resolve?
            // Actually, `_resolveSteps` updates `_resolvedSteps` state.
            // We should probably call `_resolveSteps` here if needed, or rely on a `key` change?
            // Better: Trigger a re-resolve if we detect a locale mismatch?
            // For now, let's keep it simple: relying on `build` to show the correct Text is easy.
            // But `_resolvedSteps` is stateful.
            // IF we want steps to switch language dynamically without re-fetching, we need to call `_resolveSteps` again.
            // Let's do it in `didChangeDependencies` or just check in build.
            
            return CustomScrollView(
              slivers: [
                // Immersive App Bar with "Header"
                if (!widget.isModal)
                  SliverAppBar(
                  expandedHeight: 200.0,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      fullRecipe.title,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    background: Container(
                      color: colorScheme.primaryContainer,
                      child: Center(
                        child: Icon(
                          Icons.restaurant,
                          size: 80,
                          color: colorScheme.onPrimaryContainer.withOpacity(0.2),
                        ),
                      ),
                    ),
                  ),
                  actions: [
                     IconButton(
                       icon: const Icon(Icons.calendar_today),
                       tooltip: l10n.recipeAddToPlanTooltip,
                       onPressed: () => _showAddToPlanDialog(context, fullRecipe),
                     ),
                     IconButton(
                       icon: const Icon(Icons.fork_right),
                       tooltip: l10n.recipeForkTooltip,
                       onPressed: () {
                         context.read<RecipeBloc>().add(ForkRecipe(
                           originalRecipeId: fullRecipe.id,
                           newTitle: '${fullRecipe.title} (Fork)',
                         ));
                         ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(content: Text(l10n.recipeForking)),
                         );
                       },
                     ),
                  ],
                ),
                
                // Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimens.paddingPage),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Description
                        if (fullRecipe.description != null) ...[
                          FormattedRecipeText(
                            text: fullRecipe.description!,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: AppDimens.space2XL),
                        ],

                        // Clinical Tags
                        if (fullRecipe.tags.isNotEmpty) ...[
                          _buildTagsSection(context, fullRecipe.tags),
                          const SizedBox(height: 32),
                        ],

                        // Ingredients Section
                        SectionHeader(title: l10n.recipeIngredientsTitle, subtitle: l10n.recipeIngredientsCount(fullRecipe.ingredients.length)),
                        const SizedBox(height: AppDimens.spaceL),
                        _buildIngredientsList(context, fullRecipe.ingredients),
                        
                        const SizedBox(height: AppDimens.space2XL),

                        // Steps Section
                        SectionHeader(title: l10n.recipeInstructionsTitle, subtitle: l10n.recipeInstructionsCount(fullRecipe.steps.length)),
                        const SizedBox(height: AppDimens.spaceL),
                        _buildStepsTimeline(context, fullRecipe.steps),
                        
                        const SizedBox(height: AppDimens.space3XL),
                        
                        // Metadata Footer
                        Center(
                          child: Chip(
                            label: Text(l10n.recipeIdLabel(fullRecipe.id.substring(0, 8))),
                            avatar: const Icon(Icons.fingerprint, size: AppDimens.iconSizeS),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, curve: Curves.easeOutQuad),
                ),
              ],
            );
          } else if (state is RecipeError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('Initializing...'));
        },
      ),
    );
  }

  Widget _buildIngredientsList(BuildContext context, List<String> ingredients) {
    if (ingredients.isEmpty) {
      return Text(AppLocalizations.of(context)!.recipeIngredientsEmpty);
    }
    
    return Column(
      children: ingredients.map((ingredient) => 
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Icon(Icons.check_circle_outline, size: 20, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(child: Text(ingredient, style: Theme.of(context).textTheme.bodyMedium)),
            ],
          ),
        )
      ).toList(),
    );
  }

  Widget _buildStepsTimeline(BuildContext context, List<RecipeStep> steps) {
    if (_isResolvingSteps) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_resolvedSteps == null || _resolvedSteps!.isEmpty) {
      return Text(AppLocalizations.of(context)!.recipeInstructionsEmpty);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _resolvedSteps!.asMap().entries.map((entry) {
        final resolvedStep = entry.value;
        final isLast = entry.key == _resolvedSteps!.length - 1;
        
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline Column
              Column(
                children: [
                   Container(
                     width: 28,
                     height: 28,
                     decoration: BoxDecoration(
                       color: resolvedStep.isUniversal 
                           ? Theme.of(context).colorScheme.primaryContainer 
                           : Theme.of(context).colorScheme.tertiaryContainer,
                       shape: BoxShape.circle,
                       border: Border.all(
                           color: resolvedStep.isUniversal 
                               ? Theme.of(context).colorScheme.primary 
                               : Theme.of(context).colorScheme.tertiary
                       )
                     ),
                     child: Center(
                       child: Text(
                         '${resolvedStep.index}',
                         style: TextStyle(
                           fontWeight: FontWeight.bold,
                           color: resolvedStep.isUniversal 
                               ? Theme.of(context).colorScheme.primary 
                               : Theme.of(context).colorScheme.onTertiaryContainer,
                           fontSize: 12,
                         ),
                       ),
                     ),
                   ),
                   if (!isLast)
                     Expanded(
                       child: Container(
                         width: 2,
                         color: Theme.of(context).colorScheme.outlineVariant,
                         margin: const EdgeInsets.symmetric(vertical: 4),
                       ),
                     ),
                ],
              ),
              const SizedBox(width: 16),
              
              // Content Column
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       // Target Group Badge (For Juan, María...)
                       if (!resolvedStep.isUniversal)
                         Container(
                           margin: const EdgeInsets.only(bottom: 8),
                           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                           decoration: BoxDecoration(
                             color: Theme.of(context).colorScheme.tertiaryContainer.withOpacity(0.5),
                             borderRadius: BorderRadius.circular(12),
                             border: Border.all(color: Theme.of(context).colorScheme.tertiary.withOpacity(0.3)),
                           ),
                           child: Row(
                             mainAxisSize: MainAxisSize.min,
                             children: [
                               Icon(Icons.person, size: 14, color: Theme.of(context).colorScheme.tertiary),
                               const SizedBox(width: 4),
                               Text(
                                 resolvedStep.targetGroupLabel,
                                 style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                   color: Theme.of(context).colorScheme.onTertiaryContainer,
                                   fontWeight: FontWeight.bold,
                                 ),
                               ),
                             ],
                           ),
                         ),
                       
                       // Main Instruction
                       FormattedRecipeText(
                         text: resolvedStep.instruction,
                         style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
                       ),

                       // Cross Contamination Alert
                       if (resolvedStep.crossContaminationAlert != null)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Theme.of(context).colorScheme.error.withOpacity(0.5)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.warning_amber, size: 16, color: Theme.of(context).colorScheme.error),
                              const SizedBox(width: 8),
                               Expanded(
                                 child: Text(
                                   resolvedStep.crossContaminationAlert!,
                                   style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                     color: Theme.of(context).colorScheme.onErrorContainer,
                                     fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTagsSection(BuildContext context, List<String> tags) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: tags.map((tag) {
        final isClinical = ['renal', 'keto', 'diabetes', 'celiac', 'aplv', 'histamine', 'low fodmap']
            .contains(tag.toLowerCase());
        final colorScheme = Theme.of(context).colorScheme;
        
        return Chip(
          label: Text(tag),
          labelStyle: TextStyle(
            color: isClinical ? colorScheme.onPrimary : colorScheme.onSecondaryContainer,
            fontWeight: isClinical ? FontWeight.bold : FontWeight.normal,
          ),
          backgroundColor: isClinical ? colorScheme.primary : colorScheme.secondaryContainer,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        );
      }).toList(),
    );
  }

  Future<void> _showAddToPlanDialog(BuildContext context, Recipe recipe) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
    );

    if (date != null && context.mounted) {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.recipeLoginRequired)),
        );
        return;
      }

      final plan = MealPlan(
        id: const Uuid().v4(),
        userId: userId,
        recipeId: recipe.id,
        scheduledDate: date,
        mealType: 'Dinner',
        createdAt: DateTime.now(),
        recipe: recipe,
      );

      context.read<PlannerBloc>().add(AddMealToPlan(plan));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.recipeAddedToPlan('${date.day}/${date.month}', recipe.title))),
      );
    }
  }
}
