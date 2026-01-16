import 'package:flutter/material.dart';
import 'package:gastronomic_os/core/theme/app_dimens.dart';
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

class CollectionDetailPage extends StatefulWidget {
  final RecipeCollection collection;

  const CollectionDetailPage({super.key, required this.collection});

  @override
  State<CollectionDetailPage> createState() => _CollectionDetailPageState();
}

class _CollectionDetailPageState extends State<CollectionDetailPage> {
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Safety check: only load if not already loading/loaded? 
    // Actually, create implies new bloc, so we always want to load.
    // context.read is safe here.
    final locale = Localizations.localeOf(context).languageCode;
    // We access the bloc provided by BlocProvider below?
    // Wait, the BlocProvider is inside build? 
    // NO. If I put BlocProvider in build, I can't read it in didChangeDependencies of THIS widget.
    // The BlocProvider must be up the tree or I must use a child wrapper.
  }
  
  @override
  Widget build(BuildContext context) {
    // To solve the "access bloc created in same build" issue with lifecycle:
    // We can use a Builder/wrapper or keep BlocProvider here and put the logic in a child.
    // BUT simpler: Use BlocProvider(create: (_) => sl<RecipeBloc>()) and then
    // utilize a "InitWidget" or simply separate the View.
    
    return BlocProvider(
      create: (_) => sl<RecipeBloc>(),
      child: _CollectionDetailView(collection: widget.collection),
    );
  }
}

class _CollectionDetailView extends StatefulWidget {
   final RecipeCollection collection;
   const _CollectionDetailView({required this.collection});
   
   @override
   State<_CollectionDetailView> createState() => _CollectionDetailViewState();
}

class _CollectionDetailViewState extends State<_CollectionDetailView> {
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context).languageCode;
    
    // Dispatch event only once or when locale changes? 
    // Bloc is fresh, so just dispatch.
    context.read<RecipeBloc>().add(LoadRecipes(
       collectionId: widget.collection.id,
       languageCode: locale
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.collection.name),
          actions: [
             // TODO: Edit/Delete Collection Menu
          ],
        ),
        body: BlocBuilder<RecipeBloc, RecipeState>(
          builder: (context, state) {
            if (state is RecipeLoading || state is RecipeInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is RecipeLoaded) {
              final recipes = state.recipes;
              
              if (recipes.isEmpty) {
                 return Center(child: Text(l10n.collectionEmptyDetail));
              }

              return GridView.builder(
                padding: const EdgeInsets.all(AppDimens.paddingCard),
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
                          MaterialPageRoute(builder: (_) => RecipeDetailPage(recipeId: recipes[index].id, recipe: recipes[index])),
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
      );
  }
}
