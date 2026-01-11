import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gastronomic_os/core/widgets/ui_kit.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe.dart';
import 'package:gastronomic_os/features/recipes/presentation/bloc/recipe_bloc.dart';
import 'package:gastronomic_os/features/recipes/presentation/bloc/recipe_event.dart';
import 'package:gastronomic_os/features/recipes/presentation/bloc/recipe_state.dart';
import 'package:gastronomic_os/init/injection_container.dart';
import 'package:google_fonts/google_fonts.dart';

class RecipeDetailPage extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailPage({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<RecipeBloc>()..add(LoadRecipeDetails(recipe.id)),
      child: RecipeDetailView(recipe: recipe),
    );
  }
}

class RecipeDetailView extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailView({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: BlocBuilder<RecipeBloc, RecipeState>(
        builder: (context, state) {
          if (state is RecipeLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is RecipeDetailLoaded) {
            final fullRecipe = state.recipe;
            return CustomScrollView(
              slivers: [
                // Immersive App Bar with "Header"
                SliverAppBar(
                  expandedHeight: 200.0,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      fullRecipe.title,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    background: Container(
                      color: colorScheme.primaryContainer,
                      child: Center(
                        child: Icon(
                          Icons.restaurant,
                          size: 80,
                          color: colorScheme.onPrimaryContainer.withOpacity(0.2),
                        ),
                      ),
                    ),
                  ),
                  actions: [
                     IconButton(
                       icon: const Icon(Icons.fork_right),
                       tooltip: 'Fork Recipe',
                       onPressed: () {
                         context.read<RecipeBloc>().add(ForkRecipe(
                           originalRecipeId: fullRecipe.id,
                           newTitle: '${fullRecipe.title} (Fork)',
                         ));
                         Navigator.pop(context);
                       },
                     ),
                  ],
                ),
                
                // Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Description
                        if (fullRecipe.description != null) ...[
                          Text(
                            fullRecipe.description!,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],

                        // Ingredients Section
                        SectionHeader(title: 'Ingredients', subtitle: '${fullRecipe.ingredients.length} items'),
                        const SizedBox(height: 16),
                        _buildIngredientsList(context, fullRecipe.ingredients),
                        
                        const SizedBox(height: 32),

                        // Steps Section
                        SectionHeader(title: 'Instructions', subtitle: '${fullRecipe.steps.length} steps'),
                        const SizedBox(height: 16),
                        _buildStepsTimeline(context, fullRecipe.steps),
                        
                        const SizedBox(height: 48),
                        
                        // Metadata Footer
                        Center(
                          child: Chip(
                            label: Text('Recipe ID: ${fullRecipe.id.substring(0, 8)}...'),
                            avatar: const Icon(Icons.fingerprint, size: 16),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, curve: Curves.easeOutQuad),
                ),
              ],
            );
          } else if (state is RecipeError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('Initializing...'));
        },
      ),
    );
  }

  Widget _buildIngredientsList(BuildContext context, List<String> ingredients) {
    if (ingredients.isEmpty) {
      return const Text('No ingredients listed.');
    }
    
    return Column(
      children: ingredients.map((ingredient) => 
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Icon(Icons.check_circle_outline, size: 20, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(child: Text(ingredient, style: Theme.of(context).textTheme.bodyMedium)),
            ],
          ),
        )
      ).toList(),
    );
  }

  Widget _buildStepsTimeline(BuildContext context, List<String> steps) {
     if (steps.isEmpty) {
      return const Text('No instructions listed.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: steps.asMap().entries.map((entry) {
        final index = entry.key + 1;
        final step = entry.value;
        final isLast = index == steps.length;
        
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline Column
              Column(
                children: [
                   Container(
                     width: 28,
                     height: 28,
                     decoration: BoxDecoration(
                       color: Theme.of(context).colorScheme.primaryContainer,
                       shape: BoxShape.circle,
                       border: Border.all(color: Theme.of(context).colorScheme.primary)
                     ),
                     child: Center(
                       child: Text(
                         '$index',
                         style: TextStyle(
                           fontWeight: FontWeight.bold,
                           color: Theme.of(context).colorScheme.primary,
                           fontSize: 12,
                         ),
                       ),
                     ),
                   ),
                   if (!isLast)
                     Expanded(
                       child: Container(
                         width: 2,
                         color: Theme.of(context).colorScheme.outlineVariant,
                         margin: const EdgeInsets.symmetric(vertical: 4),
                       ),
                     ),
                ],
              ),
              const SizedBox(width: 16),
              
              // Content Column
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Text(
                    step,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
