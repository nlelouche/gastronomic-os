import 'package:flutter/material.dart';
import 'package:gastronomic_os/core/theme/app_dimens.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gastronomic_os/core/theme/app_dimens.dart';
import 'package:gastronomic_os/core/util/app_logger.dart';
import 'package:gastronomic_os/features/onboarding/domain/repositories/i_onboarding_repository.dart';
import 'package:gastronomic_os/features/onboarding/domain/entities/family_member.dart';
import 'package:gastronomic_os/init/injection_container.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/resolved_step.dart';
import 'package:gastronomic_os/features/recipes/domain/logic/recipe_resolver.dart';
import 'package:gastronomic_os/features/recipes/presentation/bloc/recipe_bloc.dart';
import 'package:gastronomic_os/features/recipes/presentation/bloc/recipe_event.dart';
import 'package:gastronomic_os/features/recipes/presentation/bloc/recipe_state.dart';
import 'package:gastronomic_os/features/recipes/presentation/widgets/formatted_recipe_text.dart';
import 'package:gastronomic_os/features/recipes/presentation/widgets/recipe_tree_widget.dart';
import 'package:gastronomic_os/l10n/generated/app_localizations.dart';
import 'package:gastronomic_os/features/social/presentation/bloc/recipe_social/recipe_social_bloc.dart';
import 'package:gastronomic_os/features/social/presentation/bloc/recipe_social/recipe_social_event.dart';
import 'package:gastronomic_os/features/social/presentation/widgets/recipe_social_tab.dart';
import 'package:gastronomic_os/features/recipes/presentation/widgets/detail/recipe_ingredients_widget.dart';
import 'package:gastronomic_os/features/recipes/presentation/widgets/detail/recipe_instructions_widget.dart';
import 'package:gastronomic_os/features/recipes/presentation/widgets/detail/recipe_detail_app_bar.dart'; // Extracted AppBar
import 'package:gastronomic_os/core/widgets/ui_kit.dart';

class RecipeDetailPage extends StatelessWidget {
  final String recipeId;
  final Recipe? recipe;
  final bool isModal;

  const RecipeDetailPage({
    super.key,
    required this.recipeId,
    this.recipe,
    this.isModal = false,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => sl<RecipeBloc>()..add(LoadRecipeDetails(recipeId)),
        ),
        BlocProvider(
          create: (context) => sl<RecipeSocialBloc>()..add(LoadRecipeSocialData(recipeId)),
        ),
      ],
      child: RecipeDetailView(recipeId: recipeId, initialRecipe: recipe, isModal: isModal),
    );
  }
}

class RecipeDetailView extends StatefulWidget {
  final String recipeId;
  final Recipe? initialRecipe;
  final bool isModal;

  const RecipeDetailView({
    super.key,
    required this.recipeId,
    this.initialRecipe,
    this.isModal = false,
  });

  @override
  State<RecipeDetailView> createState() => _RecipeDetailViewState();
}

class _RecipeDetailViewState extends State<RecipeDetailView> {
  List<ResolvedStep>? _resolvedSteps;
  List<FamilyMember> _familyMembers = [];
  bool _isResolvingSteps = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final blocState = context.read<RecipeBloc>().state;
    if (blocState is RecipeDetailLoaded) {
      _resolveSteps(blocState.recipe);
    } else if (widget.initialRecipe != null) {
      _resolveSteps(widget.initialRecipe!);
    }
  }

  Future<void> _resolveSteps([Recipe? recipe]) async {
    if (mounted && SchedulerBinding.instance.schedulerPhase == SchedulerPhase.idle) {
      setState(() => _isResolvingSteps = true);
    }

    try {
      final rawRecipe = recipe ??
          (context.read<RecipeBloc>().state is RecipeDetailLoaded
              ? (context.read<RecipeBloc>().state as RecipeDetailLoaded).recipe
              : widget.initialRecipe);

      if (rawRecipe == null) return;

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
          _familyMembers = family;
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
            Navigator.of(context).pop(true);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Recipe deleted successfully')),
            );
          } else if (state is RecipeForked) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => RecipeDetailPage(recipeId: state.newRecipe.id, recipe: state.newRecipe)),
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
            isSaved = false;
          } else if (widget.initialRecipe != null) {
              recipeToShow = widget.initialRecipe;
          }

          if (recipeToShow != null) {
            final currentLocale = Localizations.localeOf(context);
            final fullRecipe = recipeToShow.localize(currentLocale);

            final Set<String> familyTags = {};
            for (final member in _familyMembers) {
              familyTags.add(member.primaryDiet.key);
              for (final condition in member.medicalConditions) {
                familyTags.add(condition.key);
              }
            }
            final filteredIngredients = fullRecipe.getIngredientsForProfile(familyTags.toList());

            return DefaultTabController(
              length: 3,
              child: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  // Use Extracted Widget
                  RecipeDetailAppBar(
                    recipe: fullRecipe,
                    isSaved: isSaved,
                    onDelete: _showDeleteConfirmation,
                  ),
                ],
                body: TabBarView(
                  children: [
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
                          if (parentRecipe != null || forks.isNotEmpty)
                            ExpansionTile(
                              title: Text(l10n.recipeLineageTitle,
                                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                              leading: const Icon(Icons.account_tree_outlined),
                              childrenPadding: const EdgeInsets.all(AppDimens.paddingCard),
                              initiallyExpanded: false,
                              children: [
                                RecipeTreeWidget(
                                  currentRecipe: fullRecipe,
                                  parentRecipe: parentRecipe,
                                  forks: forks,
                                  onRecipeTap: (id) {
                                    context.read<RecipeBloc>().add(LoadRecipeDetails(id));
                                  },
                                ),
                              ],
                            ),
                          if (parentRecipe != null || forks.isNotEmpty) const SizedBox(height: AppDimens.spaceL),
                          if (fullRecipe.tags.isNotEmpty) ...[
                            _buildTagsSection(context, fullRecipe.tags),
                            const SizedBox(height: 32),
                          ],
                          RecipeIngredientsWidget(ingredients: filteredIngredients),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(AppDimens.paddingPage),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RecipeInstructionsWidget(
                              resolvedSteps: _resolvedSteps, 
                              isResolving: _isResolvingSteps
                          ),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                    RecipeSocialTab(recipeId: fullRecipe.id),
                  ],
                ),
              ),
            );
          } else if (state is RecipeError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildTagsSection(BuildContext context, List<String> tags) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: tags.map((tag) {
        final isClinical = ['renal', 'keto', 'diabetes', 'celiac', 'aplv', 'histamine', 'low fodmap']
            .contains(tag.toLowerCase());
        final isLifestyle = ['vegan', 'paleo', 'vegetarian'].contains(tag.toLowerCase());
        
        PillType type = PillType.neutral;
        IconData? icon;

        if (isClinical) {
          type = PillType.allergy;
          icon = Icons.medical_services_outlined;
        } else if (isLifestyle) {
          type = PillType.lifestyle;
          icon = Icons.eco_outlined;
        }

        return SemanticPill(
          label: tag,
          type: type,
          icon: icon,
        );
      }).toList(),
    );
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
}
