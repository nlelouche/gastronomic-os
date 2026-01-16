import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gastronomic_os/core/theme/app_dimens.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gastronomic_os/l10n/generated/app_localizations.dart';
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
import 'package:gastronomic_os/core/widgets/action_guard.dart';
import 'package:gastronomic_os/features/recipes/presentation/pages/recipe_editor_page.dart';
import 'package:gastronomic_os/features/recipes/presentation/bloc/recipe_bloc.dart';
import 'package:gastronomic_os/features/recipes/presentation/bloc/recipe_event.dart';

class MyRecipesPage extends StatelessWidget {
  const MyRecipesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
              l10n.recipesTitle, 
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            ),
            bottom: TabBar(
              isScrollable: true,
              tabs: [
                Tab(text: l10n.tabCreated),
                Tab(text: l10n.tabForked),
                Tab(text: l10n.tabSaved),
                Tab(text: l10n.tabCollections),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              // Created
              // Created
              Scaffold(
                backgroundColor: Colors.transparent,
                floatingActionButton: Padding(
                  padding: const EdgeInsets.only(bottom: 100),
                  child: FloatingActionButton.extended(
                    heroTag: 'new_recipe_fab',
                    onPressed: () {
                      ActionGuard.guard(
                        context,
                        title: l10n.recipesNewRecipeButton,
                        message: 'Watch a short video to create a new recipe, or Upgrade to PRO.',
                        onAction: () => _navigateToEditor(context),
                      );
                    },
                    label: Text(l10n.recipesNewRecipeButton, style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                    icon: const Icon(Icons.add),
                  ).animate().scale(delay: 500.ms, curve: Curves.easeOutBack),
                ),
                body: BlocBuilder<MyRecipesCubit, MyRecipesState>(
                  builder: (context, state) => state is MyRecipesLoaded 
                    ? _RecipeList(recipes: state.createdRecipes, emptyMessage: l10n.myRecipesEmptyCreated)
                    : const Center(child: CircularProgressIndicator()),
                ),
              ),
              // Forked
              BlocBuilder<MyRecipesCubit, MyRecipesState>(
                builder: (context, state) => state is MyRecipesLoaded 
                  ? _RecipeList(recipes: state.forkedRecipes, emptyMessage: l10n.myRecipesEmptyForked)
                  : const Center(child: CircularProgressIndicator()),
              ),
              // Saved
              BlocBuilder<MyRecipesCubit, MyRecipesState>(
                builder: (context, state) => state is MyRecipesLoaded 
                  ? _RecipeList(recipes: state.savedRecipes, emptyMessage: l10n.myRecipesEmptySaved)
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


  void _navigateToEditor(BuildContext context) {
    // We need to provide a fresh RecipeBloc for the editor since MyRecipesCubit doesn't handle creation details
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => BlocProvider<RecipeBloc>(
          create: (_) => sl<RecipeBloc>(), // Fresh bloc
          child: const RecipeEditorPage(),
        ),
      ),
    ).then((_) {
      if (context.mounted) {
         context.read<MyRecipesCubit>().loadMyRecipes(); // Reload to see new recipe
      }
    });
  }
}

class _CollectionsView extends StatelessWidget {
  const _CollectionsView();

  void _showCreateDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    showDialog(
      context: context, 
      builder: (ctx) => AlertDialog(
        title: Text(l10n.collectionDialogTitle),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: l10n.collectionDialogLabel),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.btnCancel)),
          PrimaryButton(
            label: l10n.btnCreate, 
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
    final l10n = AppLocalizations.of(context)!;
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
                   Text(l10n.collectionsEmpty),
                   const SizedBox(height: 16),
                   PrimaryButton(
                     label: l10n.btnNewCollection, 
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
               padding: const EdgeInsets.all(AppDimens.paddingPage),
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
                             l10n.recipesCount(collection.recipeCount),
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
          return Center(child: Text(l10n.commonError(state.message)));
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
      padding: const EdgeInsets.all(AppDimens.paddingCard),
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
                MaterialPageRoute(builder: (_) => RecipeDetailPage(recipeId: recipe.id, recipe: recipe)),
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
