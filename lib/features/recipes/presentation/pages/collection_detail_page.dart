import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gastronomic_os/l10n/generated/app_localizations.dart';
import 'package:gastronomic_os/core/widgets/ui_kit.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe_collection.dart';
import 'package:gastronomic_os/features/recipes/presentation/bloc/recipe_bloc.dart';
import 'package:gastronomic_os/features/recipes/presentation/bloc/recipe_event.dart';
import 'package:gastronomic_os/features/recipes/presentation/bloc/recipe_state.dart';
import 'package:gastronomic_os/features/recipes/presentation/pages/recipe_detail_page.dart';
import 'package:gastronomic_os/features/recipes/presentation/widgets/recipe_card.dart';
import 'package:gastronomic_os/init/injection_container.dart';

class CollectionDetailPage extends StatelessWidget {
  final RecipeCollection collection;

  const CollectionDetailPage({super.key, required this.collection});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (_) => sl<RecipeBloc>()..add(LoadRecipes(collectionId: collection.id)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(collection.name),
          actions: [
             // TODO: Edit/Delete Collection Menu
          ],
        ),
        body: BlocBuilder<RecipeBloc, RecipeState>(
          builder: (context, state) {
            if (state is RecipeLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is RecipeLoaded) {
              final recipes = state.recipes;
              
              if (recipes.isEmpty) {
                 return Center(child: Text(l10n.collectionEmptyDetail));
              }

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: recipes.length,
                itemBuilder: (context, index) {
                   return RecipeCard(
                     recipe: recipes[index],
                     onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => RecipeDetailPage(recipe: recipes[index])),
                        );
                     }
                   );
                },
              );
            }

            if (state is RecipeError) {
              return Center(child: Text(l10n.commonError(state.message)));
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
