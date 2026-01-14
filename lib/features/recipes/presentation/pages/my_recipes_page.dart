import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gastronomic_os/core/widgets/ui_kit.dart';
import 'package:gastronomic_os/features/recipes/presentation/bloc/my_recipes_cubit.dart';
import 'package:gastronomic_os/features/recipes/presentation/bloc/my_recipes_state.dart';
import 'package:gastronomic_os/features/recipes/presentation/pages/recipe_detail_page.dart';
import 'package:gastronomic_os/features/recipes/presentation/widgets/recipe_card.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe.dart';
import 'package:gastronomic_os/init/injection_container.dart';
import 'package:google_fonts/google_fonts.dart';

class MyRecipesPage extends StatelessWidget {
  const MyRecipesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<MyRecipesCubit>()..loadMyRecipes(),
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              'My Recipes', // TODO: Localize
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            ),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Created'), // TODO: Localize
                Tab(text: 'Forked'),  // TODO: Localize
                Tab(text: 'Saved'),   // TODO: Localize
              ],
            ),
          ),
          body: BlocBuilder<MyRecipesCubit, MyRecipesState>(
            builder: (context, state) {
              if (state is MyRecipesLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is MyRecipesError) {
                return Center(child: Text('Error: ${state.message}'));
              } else if (state is MyRecipesLoaded) {
                return TabBarView(
                  children: [
                    _RecipeList(recipes: state.createdRecipes, emptyMessage: 'No user recipes yet.'),
                    _RecipeList(recipes: state.forkedRecipes, emptyMessage: 'You haven\'t forked any recipes yet.'),
                    _RecipeList(recipes: state.savedRecipes, emptyMessage: 'No saved recipes.'),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}

class _RecipeList extends StatelessWidget {
  final List<Recipe> recipes;
  final String emptyMessage;

  const _RecipeList({required this.recipes, required this.emptyMessage});

  @override
  Widget build(BuildContext context) {
    if (recipes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.kitchen, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(emptyMessage, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      );
    }

    // Reuse similar grid/list logic from RecipesPage
    // For simplicity, using ListView for now
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: RecipeCard(
            recipe: recipe,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => RecipeDetailPage(recipe: recipe)),
              ).then((_) {
                 // Refresh on return (in case of edit/delete/unsave)
                 if (context.mounted) {
                   context.read<MyRecipesCubit>().loadMyRecipes();
                 }
              });
            },
          ),
        );
      },
    );
  }
}
