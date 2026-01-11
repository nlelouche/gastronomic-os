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
      child: const MacrosPage(),
    );
  }
}

class MacrosPage extends StatelessWidget {
  const MacrosPage({super.key});

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
            if (state.recipes.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.menu_book_rounded, size: 64, color: theme.colorScheme.outline),
                    const SizedBox(height: 16),
                    Text(
                      'No recipes yet',
                      style: theme.textTheme.headlineSmall?.copyWith(color: theme.colorScheme.outline),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start your culinary journey!',
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => _navigateToEditor(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Create Recipe'),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 500.ms);
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                // Responsive Grid
                final crossAxisCount = constraints.maxWidth > 900 
                  ? 4 
                  : constraints.maxWidth > 600 ? 3 : 2;
                
                // For very small screens (phones), maybe list or 1 column grid
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
                    childAspectRatio: 0.8, // Adjust card height
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: state.recipes.length,
                  itemBuilder: (context, index) {
                    final recipe = state.recipes[index];
                    return RecipeCard(
                      recipe: recipe,
                      onTap: () => _navigateToDetail(context, recipe),
                    ).animate().fadeIn(delay: (50 * index).ms).slideY(begin: 0.1, curve: Curves.easeOut);
                  },
                );
              },
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
    final bloc = context.read<RecipeBloc>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeDetailPage(recipe: recipe),
      ),
    ).then((_) {
      if (context.mounted) {
        bloc.add(LoadRecipes());
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
        bloc.add(LoadRecipes());
      }
    });
  }
}
