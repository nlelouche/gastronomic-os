import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gastronomic_os/core/theme/app_dimens.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gastronomic_os/features/planner/domain/entities/meal_plan.dart';
import 'package:gastronomic_os/features/planner/presentation/bloc/planner_bloc.dart';
import 'package:gastronomic_os/features/planner/presentation/bloc/planner_event.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe.dart';
import 'package:gastronomic_os/core/widgets/action_guard.dart';
import 'package:gastronomic_os/features/recipes/presentation/bloc/recipe_bloc.dart';
import 'package:gastronomic_os/features/recipes/presentation/bloc/recipe_event.dart';
import 'package:gastronomic_os/features/recipes/presentation/pages/recipe_editor_page.dart';
import 'package:gastronomic_os/features/recipes/presentation/widgets/add_to_collection_sheet.dart';
import 'package:gastronomic_os/features/recipes/presentation/widgets/smart_fork_dialog.dart';
import 'package:gastronomic_os/l10n/generated/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class RecipeDetailAppBar extends StatelessWidget {
  final Recipe recipe;
  final bool isSaved;
  final Function(BuildContext, String) onDelete;

  const RecipeDetailAppBar({
    super.key,
    required this.recipe,
    required this.isSaved,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return SliverAppBar(
      expandedHeight: 320.0, // Taller header
      pinned: true,
      scrolledUnderElevation: 0, // Keep flat
      backgroundColor: colorScheme.primary, // Immersive Primary Color for collapsed state
      surfaceTintColor: Colors.transparent,
      iconTheme: const IconThemeData(color: Colors.white), // Force white back arrow
      actionsIconTheme: const IconThemeData(color: Colors.white), // Force white action buttons
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsetsDirectional.only(start: 16, end: 220, bottom: 60),
        expandedTitleScale: 1.4,
        title: Text(
          recipe.title,
          style: GoogleFonts.outfit(
            color: Colors.white, // Always White for immersive contrast
            fontWeight: FontWeight.w800,
            fontSize: 20,
            shadows: [
              Shadow(color: Colors.black.withOpacity(0.8), blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          textAlign: TextAlign.start,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: false,
        background: Stack(
          fit: StackFit.expand,
          children: [
            recipe.coverPhotoUrl != null
              ? Hero(
                  tag: 'recipe_${recipe.id}',
                  child: Image(
                    image: ResizeImage(
                      NetworkImage(recipe.coverPhotoUrl!),
                      width: 800, // Optimize decode size for header
                    ),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: colorScheme.surfaceContainerHighest,
                      child: Center(child: Icon(Icons.broken_image, color: colorScheme.error)),
                    ),
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
            // Gradient Overlay
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black45, // For status bar visibility
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black87, // For title readability
                  ],
                  stops: [0.0, 0.2, 0.6, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
      bottom: TabBar(
        // Removed manual overrides to respect AppTheme.tabBarTheme
        // BUT for this specific Immersive Header, we generally want White text 
        // regardless of the theme, because the background is Primary (Dark-ish).
        labelColor: Colors.white, 
        unselectedLabelColor: Colors.white60,
        indicatorColor: Colors.white,
        tabs: [
          Tab(text: l10n.recipeIngredientsTitle),
          Tab(text: l10n.recipeInstructionsTitle),
          Tab(text: l10n.recipeTabSocial),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.calendar_today),
          tooltip: l10n.recipeAddToPlanTooltip,
          onPressed: () => _showAddToPlanDialog(context, recipe),
        ),
        IconButton(
          icon: const Icon(Icons.playlist_add),
          tooltip: 'Add to Collection',
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (ctx) => AddToCollectionSheet(recipeId: recipe.id),
              isScrollControlled: true,
            );
          },
        ),
        IconButton(
          icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border),
          color: isSaved ? colorScheme.primary : null,
          tooltip: isSaved ? 'Unsave Recipe' : 'Save Recipe',
          onPressed: () {
            context.read<RecipeBloc>().add(ToggleSaveRecipe(recipe.id));
          },
        ),
        IconButton(
          icon: const Icon(Icons.fork_right),
          tooltip: l10n.recipeForkTooltip,
          onPressed: () {
            ActionGuard.guard(
              context,
              title: l10n.recipeForkTooltip,
              message: l10n.monetizationWatchAdPrompt,
              onAction: () async {
                final newTitle = await showDialog<String>(
                  context: context,
                  builder: (_) => SmartForkDialog(originalTitle: recipe.title),
                );

                if (newTitle != null && context.mounted) {
                  context.read<RecipeBloc>().add(ForkRecipe(
                        originalRecipeId: recipe.id,
                        newTitle: newTitle,
                      ));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.recipeForking)),
                  );
                }
              },
            );
          },
        ),
        if (recipe.authorId == Supabase.instance.client.auth.currentUser?.id)
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                onDelete(context, recipe.id);
              } else if (value == 'edit') {
                final recipeBloc = context.read<RecipeBloc>();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: recipeBloc,
                      child: RecipeEditorPage(initialRecipe: recipe),
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
        SnackBar(
            content: Text(AppLocalizations.of(context)!
                .recipeAddedToPlan('${date.day}/${date.month}', recipe.title))),
      );
    }
  }
}
