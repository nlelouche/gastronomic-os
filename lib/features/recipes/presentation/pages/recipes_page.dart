import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gastronomic_os/core/widgets/ui_kit.dart';
import 'package:gastronomic_os/features/recipes/presentation/bloc/recipe_bloc.dart';
import 'package:gastronomic_os/features/recipes/presentation/bloc/recipe_event.dart';
import 'package:gastronomic_os/features/recipes/presentation/bloc/recipe_state.dart';
import 'package:gastronomic_os/features/recipes/presentation/pages/recipe_detail_page.dart';
import 'package:gastronomic_os/features/recipes/presentation/pages/recipe_editor_page.dart';
import 'package:gastronomic_os/features/recipes/presentation/widgets/recipe_card.dart';
import 'package:gastronomic_os/features/recipes/presentation/widgets/recipe_filter_sheet.dart'; // NEW
import 'package:gastronomic_os/init/injection_container.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gastronomic_os/l10n/generated/app_localizations.dart';
import 'package:gastronomic_os/core/widgets/action_guard.dart';

class RecipesPage extends StatelessWidget {
  final String? initialQuery;
  final bool autoFocus;

  const RecipesPage({super.key, this.initialQuery, this.autoFocus = false});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RecipeBloc>(
      create: (context) => sl<RecipeBloc>()..add(initialQuery != null 
          ? FilterRecipes(query: initialQuery!) 
          : LoadRecipes()),
      child: RecipesView(initialQuery: initialQuery, autoFocus: autoFocus),
    );
  }
}

class RecipesView extends StatefulWidget {
  final String? initialQuery;
  final bool autoFocus;
  const RecipesView({super.key, this.initialQuery, this.autoFocus = false});

  @override
  State<RecipesView> createState() => _RecipesViewState();
}

class _RecipesViewState extends State<RecipesView> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
    }
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
       context.read<RecipeBloc>().add(LoadMoreRecipes());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _dispatchFilter(BuildContext context, RecipeLoaded state, {
    bool? isFamilySafe,
    bool? isPantryReady,
    String? query,
    List<String>? requiredIngredients,
  }) {
    context.read<RecipeBloc>().add(FilterRecipes(
      isFamilySafe: isFamilySafe ?? state.isFamilySafe,
      isPantryReady: isPantryReady ?? state.isPantryReady,
      query: query ?? state.query,
      requiredIngredients: requiredIngredients ?? state.requiredIngredients,
    ));
  }

  void _showAddIngredientDialog(BuildContext context, RecipeLoaded state) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.dialogAddIngredientTitle),
        content: AppTextField(
          controller: controller,
          hint: AppLocalizations.of(context)!.dialogIngredientHint,
          label: AppLocalizations.of(context)!.dialogIngredientLabel,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(AppLocalizations.of(context)!.dialogCancel)),
          FilledButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                final newIngredients = List<String>.from(state.requiredIngredients)..add(controller.text.trim());
                _dispatchFilter(context, state, requiredIngredients: newIngredients);
                Navigator.pop(ctx);
              }
            },
            child: Text(AppLocalizations.of(context)!.dialogAdd),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.recipesTitle,
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocBuilder<RecipeBloc, RecipeState>(
        builder: (context, state) {
          if (state is RecipeLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is RecipeError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is RecipeLoaded) {
            
            // Sync controller if needed (simplified)
            // if (_searchController.text != state.query) {
            //   _searchController.text = state.query;
            // }

            return Column(
              children: [
                // Filter Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimens.spaceL, vertical: AppDimens.spaceS),
                  child: Column(
                    children: [
                      // Search
                      AppTextField(
                        controller: _searchController,
                        autofocus: widget.autoFocus, // Use the propery
                        hint: AppLocalizations.of(context)!.searchRecipesHint,
                        prefixIcon: Icons.search,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.tune), // Filter icon
                          onPressed: () {
                             // Open Filter Sheet
                             showModalBottomSheet(
                               context: context, 
                               builder: (_) => BlocProvider.value(
                                 value: context.read<RecipeBloc>(),
                                 child: const RecipeFilterSheet(),
                               ),
                               isScrollControlled: true,
                             );
                          },
                        ),
                        onChanged: (val) {
                          _dispatchFilter(context, state, query: val);
                        },
                      ),
                      const SizedBox(height: AppDimens.spaceM),
                      
                      // Filter Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            // Family Safe Toggle
                            FilterChip(
                              label: Text(AppLocalizations.of(context)!.filterFamilySafe),
                              selected: state.isFamilySafe,
                              avatar: const Icon(Icons.people_outline, size: AppDimens.iconSizeS),
                              onSelected: (val) => _dispatchFilter(context, state, isFamilySafe: val),
                            ),
                            const SizedBox(width: AppDimens.spaceS),

                            // Best Match Toggle
                            FilterChip(
                              label: Text(AppLocalizations.of(context)!.filterBestMatch),
                              selected: state.isPantryReady,
                              avatar: const Icon(Icons.kitchen, size: AppDimens.iconSizeS),
                              onSelected: (val) => _dispatchFilter(context, state, isPantryReady: val),
                            ),
                            const SizedBox(width: AppDimens.spaceS),

                            // Add Ingredient Button
                            ActionChip(
                               label: Text(AppLocalizations.of(context)!.filterAddIngredient),
                               avatar: const Icon(Icons.add_circle_outline, size: AppDimens.iconSizeS),
                               onPressed: () => _showAddIngredientDialog(context, state),
                            ),
                            const SizedBox(width: AppDimens.spaceM),
                            
                            // Active Ingredient Filters
                            ...state.requiredIngredients.map((ing) => Padding(
                              padding: const EdgeInsets.only(right: AppDimens.spaceS),
                              child: Chip(
                                label: Text(ing),
                                onDeleted: () {
                                   final newIngredients = List<String>.from(state.requiredIngredients)..remove(ing);
                                   _dispatchFilter(context, state, requiredIngredients: newIngredients);
                                },
                              ),
                            )),
                            
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Divider(),

                // List / Grid
                Expanded(
                  child: state.recipes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 64, color: theme.colorScheme.outline),
                            const SizedBox(height: AppDimens.spaceL),
                            Text(AppLocalizations.of(context)!.recipesEmptyTitle, style: theme.textTheme.titleMedium),
                            if (state.query.isNotEmpty || state.isFamilySafe || state.isPantryReady || state.requiredIngredients.isNotEmpty)
                              TextButton(
                                onPressed: () {
                                  // Clear filters
                                  context.read<RecipeBloc>().add(const FilterRecipes());
                                  _searchController.clear();
                                }, 
                                child: Text(AppLocalizations.of(context)!.recipesClearFilters)
                              ),
                          ],
                        ),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final crossAxisCount = constraints.maxWidth > 900 
                            ? 4 
                            : constraints.maxWidth > 600 ? 3 : 2;
                          
                          if (constraints.maxWidth < 450) {
                             return ListView.separated(
                               controller: _scrollController,
                               padding: const EdgeInsets.all(AppDimens.spaceL),
                               itemCount: state.hasReachedMax 
                                  ? state.recipes.length 
                                  : state.recipes.length + 1,
                               separatorBuilder: (_, __) => const SizedBox(height: AppDimens.spaceL),
                               itemBuilder: (context, index) {
                                  if (index >= state.recipes.length) {
                                     return const Center(
                                       child: Padding(
                                         padding: EdgeInsets.all(AppDimens.spaceL),
                                         child: CircularProgressIndicator(),
                                       )
                                     );
                                  }
                                  final recipe = state.recipes[index];
                                  return RecipeCard(
                                    recipe: recipe,
                                    onTap: () => _navigateToDetail(context, recipe),
                                  );
                               },
                             );
                          }

                          return GridView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(AppDimens.spaceL),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              childAspectRatio: 0.8,
                              crossAxisSpacing: AppDimens.spaceL,
                              mainAxisSpacing: AppDimens.spaceL,
                            ),
                            itemCount: state.hasReachedMax 
                                ? state.recipes.length 
                                : state.recipes.length + 1,
                            itemBuilder: (context, index) {
                              if (index >= state.recipes.length) {
                                 // Loading Indicator for Grid
                                 return const Center(child: CircularProgressIndicator());
                              }
                              final recipe = state.recipes[index];
                              return RecipeCard(
                                recipe: recipe,
                                onTap: () => _navigateToDetail(context, recipe),
                              ).animate().fadeIn(delay: (30 * index).ms).slideY(begin: 0.1, curve: Curves.easeOut);
                            },
                          );
                        },
                      ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ActionGuard.guard(
            context,
            title: AppLocalizations.of(context)!.recipesNewRecipeButton,
            message: 'Watch a short video to create a new recipe, or Upgrade to PRO.',
            onAction: () => _navigateToEditor(context),
          );
        },
        label: Text(AppLocalizations.of(context)!.recipesNewRecipeButton, style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
        icon: const Icon(Icons.add),
      ).animate().scale(delay: 500.ms, curve: Curves.easeOutBack),
    );
  }

  void _navigateToDetail(BuildContext context, dynamic recipe) {
    // Preserve bloc state?
    // The BLoC is provided in build() via BlocProvider(create: ...
    // If we pop, this Bloc dies.
    // Wait, RecipesPage creates the Bloc.
    // If we push a route, the page below stays alive, so Bloc stays alive.
    // So logic holds.
    
    // However, if we want the selection to persist when going back and forth,
    // we need to make sure we don't dispatch LoadRecipes() again on pop, 
    // OR LoadRecipes should NOT clear the state if it's already there?
    // In current implementation: `create: (context) => sl<RecipeBloc>()..add(LoadRecipes())`
    // This creates a NEW Bloc every time RecipesPage is built (e.g. from Dashboard).
    // The state is lost when leaving RecipesPage.
    // This is acceptable for now.
    
    final bloc = context.read<RecipeBloc>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeDetailPage(recipeId: recipe.id, recipe: recipe),
      ),
    ).then((result) {
      if ((result == true) && context.mounted) {
         bloc.add(LoadRecipes()); // Reload if deleted
      }
    });
  }

  void _navigateToEditor(BuildContext context) {
    final bloc = context.read<RecipeBloc>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: bloc,
          child: const RecipeEditorPage(),
        ),
      ),
    ).then((_) {
      if (context.mounted) {
         bloc.add(LoadRecipes()); // Reload to see new recipe
      }
    });
  }
}
