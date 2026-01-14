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
import 'package:gastronomic_os/features/recipes/presentation/bloc/collections/collections_bloc.dart';
import 'package:gastronomic_os/features/recipes/presentation/bloc/collections/collections_event.dart';
import 'package:gastronomic_os/features/recipes/presentation/bloc/collections/collections_state.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe_collection.dart';
import 'package:gastronomic_os/features/recipes/presentation/pages/collection_detail_page.dart';

class MyRecipesPage extends StatelessWidget {
  const MyRecipesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<MyRecipesCubit>()..loadMyRecipes()),
        BlocProvider(create: (context) => sl<CollectionsBloc>()..add(LoadCollections())),
      ],
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              'My Recipes', // TODO: Localize
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            ),
            bottom: const TabBar(
              isScrollable: true,
              tabs: [
                Tab(text: 'Created'), // TODO: Localize
                Tab(text: 'Forked'),  // TODO: Localize
                Tab(text: 'Saved'),   // TODO: Localize
                Tab(text: 'Collections'), // TODO: Localize
              ],
            ),
          ),
          body: TabBarView(
            children: [
              // Created
              BlocBuilder<MyRecipesCubit, MyRecipesState>(
                builder: (context, state) => state is MyRecipesLoaded 
                  ? _RecipeList(recipes: state.createdRecipes, emptyMessage: 'No user recipes yet.')
                  : const Center(child: CircularProgressIndicator()),
              ),
              // Forked
              BlocBuilder<MyRecipesCubit, MyRecipesState>(
                builder: (context, state) => state is MyRecipesLoaded 
                  ? _RecipeList(recipes: state.forkedRecipes, emptyMessage: 'You haven\'t forked any recipes yet.')
                  : const Center(child: CircularProgressIndicator()),
              ),
              // Saved
              BlocBuilder<MyRecipesCubit, MyRecipesState>(
                builder: (context, state) => state is MyRecipesLoaded 
                  ? _RecipeList(recipes: state.savedRecipes, emptyMessage: 'No saved recipes.')
                  : const Center(child: CircularProgressIndicator()),
              ),
              // Collections
              const _CollectionsView(),
            ],
          ),
        ),
      ),
    );
  }
}

class _CollectionsView extends StatelessWidget {
  const _CollectionsView();

  void _showCreateDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context, 
      builder: (ctx) => AlertDialog(
        title: const Text('New Collection'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Collection Name'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          PrimaryButton(
            label: 'Create', 
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context.read<CollectionsBloc>().add(CreateCollectionEvent(controller.text));
                Navigator.pop(ctx);
              }
            }
          ),
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CollectionsBloc, CollectionsState>(
      builder: (context, state) {
        if (state is CollectionsLoading) {
           return const Center(child: CircularProgressIndicator());
        }
        
        if (state is CollectionsLoaded) {
          if (state.collections.isEmpty) {
             return Center(
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   const Icon(Icons.folder_open, size: 64, color: Colors.grey),
                   const SizedBox(height: 16),
                   const Text('No collections yet.'),
                   const SizedBox(height: 16),
                   PrimaryButton(
                     label: 'Create Collection', 
                     onPressed: () => _showCreateDialog(context)
                   ),
                 ],
               ),
             );
          }
          
          return Scaffold(
             floatingActionButton: FloatingActionButton(
               onPressed: () => _showCreateDialog(context),
               child: const Icon(Icons.add),
             ),
             body: GridView.builder(
               padding: const EdgeInsets.all(16),
               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                 crossAxisCount: 2,
                 crossAxisSpacing: 16,
                 mainAxisSpacing: 16,
                 childAspectRatio: 1.2,
               ),
               itemCount: state.collections.length,
               itemBuilder: (context, index) {
                 final collection = state.collections[index];
                 return AppCard(
                   onTap: () {
                     Navigator.push(
                       context,
                       MaterialPageRoute(builder: (_) => CollectionDetailPage(collection: collection)),
                     );
                   },
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       const Icon(Icons.folder, size: 40, color: Colors.amber),
                       Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Text(
                             collection.name, 
                             style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                             maxLines: 1,
                             overflow: TextOverflow.ellipsis,
                           ),
                           Text(
                             '${collection.recipeCount} recipes',
                             style: const TextStyle(color: Colors.grey),
                           ),
                         ],
                       ),
                     ],
                   ),
                 );
               },
             ),
          );
        }
        
        if (state is CollectionsError) {
          return Center(child: Text('Error: ${state.message}'));
        }

        return const SizedBox.shrink();
      },
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
