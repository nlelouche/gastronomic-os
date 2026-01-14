import 'dart:io';
import 'package:gastronomic_os/features/recipes/presentation/widgets/recipe_tree_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart'; // Add SchedulerBinding
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
import 'package:gastronomic_os/features/onboarding/domain/entities/family_member.dart';
import 'package:gastronomic_os/init/injection_container.dart';

import 'package:gastronomic_os/features/planner/presentation/bloc/planner_bloc.dart';
import 'package:gastronomic_os/features/planner/presentation/bloc/planner_event.dart';
import 'package:gastronomic_os/features/planner/domain/entities/meal_plan.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:gastronomic_os/features/recipes/presentation/widgets/formatted_recipe_text.dart';
import 'package:gastronomic_os/features/recipes/presentation/widgets/smart_fork_dialog.dart';
import 'package:gastronomic_os/features/recipes/presentation/pages/recipe_editor_page.dart';
import 'package:gastronomic_os/features/recipes/presentation/widgets/add_to_collection_sheet.dart';
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
  List<FamilyMember> _familyMembers = []; // Store family for ingredient filtering
  bool _isResolvingSteps = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final blocState = context.read<RecipeBloc>().state;
    if (blocState is RecipeDetailLoaded) {
       _resolveSteps(blocState.recipe);
    } else {
       _resolveSteps(widget.recipe); 
    }
  }

  Future<void> _resolveSteps([Recipe? recipe]) async {
    // Safe setState for resolving flag
    if (mounted && SchedulerBinding.instance.schedulerPhase == SchedulerPhase.idle) {
        setState(() => _isResolvingSteps = true);
    } else {
        // If mid-frame, probably skip setting loading true to avoid flicker/error, or use postFrame
    }
    
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
          _familyMembers = family; // Store for ingredients
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
          } else if (state is RecipeDeleted) {
            Navigator.of(context).pop(true); // Exit Detail Page and signal deletion
            ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(content: Text('Recipe deleted successfully')),
            );
          } else if (state is RecipeForked) {
             // Navigate to the newly created recipe
             Navigator.of(context).push(
               MaterialPageRoute(builder: (_) => RecipeDetailPage(recipe: state.newRecipe)),
             );
             ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(content: Text('Recipe forked successfully!')),
             );
          } else if (state is RecipeError) {
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(content: Text('Error: ${state.message}'), backgroundColor: colorScheme.error),
             );
          }
        },
        builder: (context, state) {
          if (state is RecipeLoading) {
            return const Center(child: CircularProgressIndicator());
          } 
          
          Recipe? recipeToShow;
          bool isSaved = false;
          Recipe? parentRecipe;
          List<Recipe> forks = [];
          
          if (state is RecipeDetailLoaded) {
            recipeToShow = state.recipe;
            isSaved = state.isSaved; 
            parentRecipe = state.parentRecipe;
            forks = state.forks;
          } else if (state is RecipeForked) {
            recipeToShow = state.originalRecipe;
            // RecipeForked doesn't track Saved yet, default false or fetch?
            // Usually forks are NEW, so not saved. Originals viewed? 
            // For now default false.
            isSaved = false; 
          }

          if (recipeToShow != null) {
            final currentLocale = Localizations.localeOf(context);
            final fullRecipe = recipeToShow.localize(currentLocale);
            
            // Filter Ingredients based on Family Profile
            final Set<String> familyTags = {};
            for (final member in _familyMembers) {
              familyTags.add(member.primaryDiet.key);
              for (final condition in member.medicalConditions) {
                familyTags.add(condition.key);
              }
            }
            final filteredIngredients = fullRecipe.getIngredientsForProfile(familyTags.toList());
            
            return DefaultTabController(
              length: 2,
              child: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  SliverAppBar(
                    expandedHeight: 200.0,
                    pinned: true,
                    forceElevated: innerBoxIsScrolled,
                    scrolledUnderElevation: 4.0,
                    backgroundColor: colorScheme.surface,
                    surfaceTintColor: colorScheme.surfaceTint,
                    flexibleSpace: FlexibleSpaceBar(
                      titlePadding: const EdgeInsetsDirectional.only(start: 72, end: 96, bottom: 48), // Added bottom padding for TabBar
                      expandedTitleScale: 1.3,
                      title: Text(
                        fullRecipe.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      centerTitle: true,
                      background: fullRecipe.coverPhotoUrl != null 
                          ? Image.network(
                              fullRecipe.coverPhotoUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: colorScheme.surfaceContainerHighest,
                                child: Center(child: Icon(Icons.broken_image, color: colorScheme.error)),
                              ),
                            )
                          : Container(
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
                    bottom: TabBar(
                      labelColor: colorScheme.primary,
                      unselectedLabelColor: colorScheme.onSurfaceVariant,
                      indicatorColor: colorScheme.primary,
                      tabs: [
                        Tab(text: l10n.recipeIngredientsTitle), // Use localized "Ingredients"
                        Tab(text: l10n.recipeInstructionsTitle), // Use localized "Instructions"
                      ],
                    ),
                    actions: [
                       IconButton(
                         icon: const Icon(Icons.calendar_today),
                         tooltip: l10n.recipeAddToPlanTooltip,
                         onPressed: () => _showAddToPlanDialog(context, fullRecipe),
                       ),
                       IconButton(
                         icon: const Icon(Icons.playlist_add),
                         tooltip: 'Add to Collection',
                         onPressed: () {
                           showModalBottomSheet(
                             context: context,
                             builder: (ctx) => AddToCollectionSheet(recipeId: fullRecipe.id),
                             isScrollControlled: true,
                           );
                         },
                       ),
                       IconButton(
                         icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border),
                         color: isSaved ? colorScheme.primary : null,
                         tooltip: isSaved ? 'Unsave Recipe' : 'Save Recipe',
                         onPressed: () {
                           context.read<RecipeBloc>().add(ToggleSaveRecipe(fullRecipe.id));
                         },
                       ),
                       IconButton(
                         icon: const Icon(Icons.fork_right),
                         tooltip: l10n.recipeForkTooltip,
                         onPressed: () async {
                           final newTitle = await showDialog<String>(
                             context: context,
                             builder: (_) => SmartForkDialog(originalTitle: fullRecipe.title),
                           );

                           if (newTitle != null && context.mounted) {
                              context.read<RecipeBloc>().add(ForkRecipe(
                                originalRecipeId: fullRecipe.id,
                                newTitle: newTitle,
                              ));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(l10n.recipeForking)),
                              );
                           }
                         },
                       ),
                       // Edit/Delete Menu (only if author)
                       // Assuming simplistic "Show Always" for MVP phase or check ID
                       if (fullRecipe.authorId == Supabase.instance.client.auth.currentUser?.id)
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'delete') {
                                _showDeleteConfirmation(context, fullRecipe.id);
                              } else if (value == 'edit') {
                                // Navigate to Edit
                                final recipeBloc = context.read<RecipeBloc>();
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => BlocProvider.value(
                                      value: recipeBloc,
                                      child: RecipeEditorPage(initialRecipe: fullRecipe),
                                    ),
                                  ),
                                );
                              }
                            },
                            itemBuilder: (BuildContext context) {
                              return [
                                PopupMenuItem<String>(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, color: colorScheme.onSurface),
                                      const SizedBox(width: 8),
                                      const Text('Edit'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem<String>(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, color: colorScheme.error),
                                      const SizedBox(width: 8),
                                      Text('Delete', style: TextStyle(color: colorScheme.error)),
                                    ],
                                  ),
                                ),
                              ];
                            },
                          ),
                    ],
                  ),
                ],
                body: TabBarView(
                  children: [
                    // Tab 1: Ingredients
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(AppDimens.paddingPage),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (fullRecipe.description != null) ...[
                            FormattedRecipeText(
                              text: fullRecipe.description!,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: AppDimens.spaceL),
                          ],
                          
                          RecipeTreeWidget(
                            currentRecipe: fullRecipe,
                            parentRecipe: parentRecipe,
                            forks: forks,
                            onRecipeTap: (id) {
                               context.read<RecipeBloc>().add(LoadRecipeDetails(id));
                            },
                          ),
                          const SizedBox(height: AppDimens.space2XL),
                          
                          if (fullRecipe.tags.isNotEmpty) ...[
                             _buildTagsSection(context, fullRecipe.tags),
                             const SizedBox(height: 32),
                          ],
                         
                          SectionHeader(title: l10n.recipeIngredientsTitle, subtitle: l10n.recipeIngredientsCount(filteredIngredients.length)),
                          const SizedBox(height: AppDimens.spaceL),
                          _buildIngredientsList(context, filteredIngredients),
                          const SizedBox(height: 80), // Bottom padding
                        ],
                      ),
                    ),

                    // Tab 2: Instructions (Grouped)
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(AppDimens.paddingPage),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           _buildStepsTimeline(context, fullRecipe.steps), // We pass steps but use _resolvedSteps internally
                           const SizedBox(height: 80), // Bottom padding
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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
      children: ingredients.map((ingredient) {
         return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.check_circle_outline, size: 20, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(child: Text(ingredient, style: Theme.of(context).textTheme.bodyMedium)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStepsTimeline(BuildContext context, List<RecipeStep> steps) {
    if (_isResolvingSteps) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_resolvedSteps == null || _resolvedSteps!.isEmpty) {
      return Text(AppLocalizations.of(context)!.recipeInstructionsEmpty);
    }

    // GROUPING LOGIC: Group ResolvedSteps by their 'index' (Master Step Number)
    final Map<int, List<ResolvedStep>> groupedSteps = {};
    for (var step in _resolvedSteps!) {
      if (!groupedSteps.containsKey(step.index)) {
        groupedSteps[step.index] = [];
      }
      groupedSteps[step.index]!.add(step);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: groupedSteps.entries.map((groupEntry) {
        final stepIndex = groupEntry.key;
        final variants = groupEntry.value;
        final isLast = stepIndex == groupedSteps.keys.last;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline Column (Simplified: One number per GROUP)
              Column(
                children: [
                   Container(
                     width: 32,
                     height: 32,
                     decoration: BoxDecoration(
                       color: Theme.of(context).colorScheme.primaryContainer,
                       shape: BoxShape.circle,
                       border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
                     ),
                     child: Center(
                       child: Text(
                         '$stepIndex',
                         style: TextStyle(
                           fontWeight: FontWeight.bold,
                           color: Theme.of(context).colorScheme.primary,
                           fontSize: 14,
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
              
              // Content Column (Display all variants for this step)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 32.0),
                  child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: variants.map((resolvedStep) {
                       // Visual Separation for each variant
                       return Container(
                         margin: const EdgeInsets.only(bottom: 12),
                         padding: const EdgeInsets.all(12),
                         decoration: BoxDecoration(
                           color: resolvedStep.isUniversal 
                               ? Theme.of(context).colorScheme.surface 
                               : Theme.of(context).colorScheme.surfaceContainerLow,
                           borderRadius: BorderRadius.circular(12),
                           border: Border.all(
                             color: resolvedStep.isUniversal 
                                 ? Colors.transparent 
                                 : Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
                           ),
                         ),
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             // Badges Row
                             Wrap(
                               spacing: 8,
                               runSpacing: 4,
                               children: [
                                 // Target Group Badge
                                   Container(
                                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                     decoration: BoxDecoration(
                                       color: Theme.of(context).colorScheme.tertiaryContainer,
                                       borderRadius: BorderRadius.circular(20), // Pill shape for avatars
                                     ),
                                     child: Row(
                                       mainAxisSize: MainAxisSize.min,
                                       children: [
                                         // Micro Avatars for Target Members
                                         if (resolvedStep.targetMembers.isNotEmpty)
                                           ...resolvedStep.targetMembers.map((member) => Padding(
                                             padding: const EdgeInsets.only(right: 6),
                                             child: _buildMicroAvatar(context, member, 20),
                                           )),
                                         
                                         if (resolvedStep.targetMembers.isEmpty) 
                                            Icon(Icons.person, size: 16, color: Theme.of(context).colorScheme.onTertiaryContainer),

                                         const SizedBox(width: 4),
                                         Text(
                                           resolvedStep.targetGroupLabel,
                                           style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                             color: Theme.of(context).colorScheme.onTertiaryContainer,
                                           ),
                                         ),
                                       ],
                                     ),
                                   ),

                                 // Reason Badge
                                 if (resolvedStep.substitutionReason != null)
                                   Container(
                                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                     decoration: BoxDecoration(
                                       color: Theme.of(context).colorScheme.secondaryContainer,
                                       borderRadius: BorderRadius.circular(6),
                                     ),
                                     child: Text(
                                       resolvedStep.substitutionReason!,
                                       style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                         color: Theme.of(context).colorScheme.onSecondaryContainer,
                                         fontWeight: FontWeight.bold,
                                       ),
                                     ),
                                   ),
                               ],
                             ),
                             
                             if (!resolvedStep.isUniversal) const SizedBox(height: 8),

                             // Instruction Text
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
                                  border: Border.all(color: Theme.of(context).colorScheme.error.withOpacity(0.3)),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                       );
                     }).toList(),
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

  Future<void> _showDeleteConfirmation(BuildContext context, String recipeId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Recipe?'),
        content: const Text('This action cannot be undone. Are you sure you want to delete this recipe?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<RecipeBloc>().add(DeleteRecipe(recipeId));
    }
  }

  Widget _buildMicroAvatar(BuildContext context, FamilyMember member, double size) {
    final path = member.avatarPath;
    Color color = Theme.of(context).colorScheme.primary;
    Widget? content;

    if (path != null) {
      if (path.startsWith('preset_')) {
        IconData icon;
        switch(path) {
          case 'preset_dad': icon = Icons.man; color = Colors.blue.shade200; break;
          case 'preset_mom': icon = Icons.woman; color = Colors.pink.shade200; break;
          case 'preset_boy': icon = Icons.boy; color = Colors.blue.shade100; break;
          case 'preset_girl': icon = Icons.girl; color = Colors.pink.shade100; break;
          case 'preset_grandpa': icon = Icons.elderly; color = Colors.grey.shade400; break;
          case 'preset_grandma': icon = Icons.elderly_woman; color = Colors.purple.shade200; break;
          default: icon = Icons.face; color = Colors.grey;
        }
        content = Icon(icon, size: size * 0.7, color: Colors.white);
      } else {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(image: FileImage(File(path)), fit: BoxFit.cover),
            border: Border.all(color: Colors.white, width: 1.5),
          ),
        );
      }
    } else {
       // Fallback for no avatar
       content = Text(
         member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
         style: TextStyle(
           fontSize: size * 0.5,
           fontWeight: FontWeight.bold,
           color: Colors.white,
         ),
       );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: Center(child: content),
    );
  }
}
