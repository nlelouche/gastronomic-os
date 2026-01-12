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
import 'package:gastronomic_os/init/injection_container.dart';
import 'package:google_fonts/google_fonts.dart';

class RecipesPage extends StatelessWidget {
  const RecipesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<RecipeBloc>()..add(LoadRecipes()),
      child: const RecipesView(),
    );
  }
}

class RecipesView extends StatefulWidget {
  const RecipesView({super.key});

  @override
  State<RecipesView> createState() => _RecipesViewState();
}

class _RecipesViewState extends State<RecipesView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        title: const Text('Add Ingredient'),
        content: AppTextField(
          controller: controller,
          hint: 'E.g., Chicken',
          label: 'Ingredient',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                final newIngredients = List<String>.from(state.requiredIngredients)..add(controller.text.trim());
                _dispatchFilter(context, state, requiredIngredients: newIngredients);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
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
          'Recipes',
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      // Search
                      AppTextField(
                        controller: _searchController,
                        hint: 'Search recipes...',
                        prefixIcon: Icons.search,
                        onChanged: (val) {
                          _dispatchFilter(context, state, query: val);
                        },
                      ),
                      const SizedBox(height: 12),
                      
                      // Filter Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            // Family Safe Toggle
                            FilterChip(
                              label: const Text('Family Safe'),
                              selected: state.isFamilySafe,
                              avatar: const Icon(Icons.people_outline, size: 18),
                              onSelected: (val) => _dispatchFilter(context, state, isFamilySafe: val),
                            ),
                            const SizedBox(width: 8),

                            // Best Match Toggle
                            FilterChip(
                              label: const Text('Best Match (Available)'),
                              selected: state.isPantryReady,
                              avatar: const Icon(Icons.kitchen, size: 18),
                              onSelected: (val) => _dispatchFilter(context, state, isPantryReady: val),
                            ),
                            const SizedBox(width: 8),

                            // Add Ingredient Button
                            ActionChip(
                               label: const Text('Add Ingredient'),
                               avatar: const Icon(Icons.add_circle_outline, size: 18),
                               onPressed: () => _showAddIngredientDialog(context, state),
                            ),
                            const SizedBox(width: 12),
                            
                            // Active Ingredient Filters
                            ...state.requiredIngredients.map((ing) => Padding(
                              padding: const EdgeInsets.only(right: 8.0),
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
                            const SizedBox(height: 16),
                            Text('No matching recipes found', style: theme.textTheme.titleMedium),
                            if (state.allRecipes.isNotEmpty)
                              TextButton(
                                onPressed: () {
                                  // Clear filters
                                  context.read<RecipeBloc>().add(const FilterRecipes());
                                  _searchController.clear();
                                }, 
                                child: const Text('Clear Filters')
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
                               padding: const EdgeInsets.all(16),
                               itemCount: state.recipes.length + 1,
                               separatorBuilder: (_, __) => const SizedBox(height: 16),
                               itemBuilder: (context, index) {
                                 if (index == state.recipes.length) return const SizedBox(height: 80);
                                 final recipe = state.recipes[index];
                                 return RecipeCard(
                                   recipe: recipe,
                                   onTap: () => _navigateToDetail(context, recipe),
                                 );
                               },
                             );
                          }

                          return GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              childAspectRatio: 0.8,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: state.recipes.length,
                            itemBuilder: (context, index) {
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
        onPressed: () => _navigateToEditor(context),
        label: Text('New Recipe', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
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
        builder: (context) => RecipeDetailPage(recipe: recipe),
      ),
    );
    // Removed .then(LoadRecipes) because generally we don't need to reload unless edit happened.
    // If edit happened... we might need to Refresh.
    // But RecipeDetails is read-only unless we go to valid Edit.
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
