import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gastronomic_os/core/widgets/ui_kit.dart';
import 'package:gastronomic_os/features/planner/presentation/bloc/planner_bloc.dart';
import 'package:gastronomic_os/features/planner/presentation/bloc/planner_state.dart';
import 'package:gastronomic_os/features/planner/presentation/bloc/planner_event.dart';
import 'package:gastronomic_os/features/recipes/presentation/pages/recipe_detail_page.dart';
import 'package:gastronomic_os/init/injection_container.dart';
import 'package:google_fonts/google_fonts.dart';

class ChefsSuggestions extends StatelessWidget {
  const ChefsSuggestions({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ChefsSuggestionsView();
  }
}

class _ChefsSuggestionsView extends StatelessWidget {
  const _ChefsSuggestionsView();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: "Chef's Suggestions", 
          subtitle: "Optimized for your fridge & family"
        ),
        const SizedBox(height: 16),
        BlocBuilder<PlannerBloc, PlannerState>(
          builder: (context, state) {
            if (state is PlannerLoading) {
              return const Center(child: Padding(
                padding: EdgeInsets.all(24.0),
                child: CircularProgressIndicator(),
              ));
            } else if (state is PlannerError) {
              final isDbError = state.message.contains('PGRST205') || state.message.contains('meal_plans');
              return AppCard(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(isDbError ? Icons.table_chart_outlined : Icons.error_outline, 
                           color: isDbError ? Colors.orange : Colors.red),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          isDbError 
                            ? "Setup Required: Database table 'meal_plans' missing."
                            : "Couldn't generate plan: ${state.message}",
                          style: TextStyle(color: isDbError ? Colors.orange[800] : Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else if (state is PlannerLoaded) {
              return SizedBox(
                height: 280, // Fixed height for horizontal list
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: state.suggestions.length,
                  itemBuilder: (context, index) {
                    final suggestion = state.suggestions[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: _SuggestionCard(suggestion: suggestion, index: index),
                    );
                  },
                ),
              );
            }
            return const SizedBox.shrink(); 
          },
        ),
      ],
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final dynamic suggestion; // To avoid import cycle if needed, but we imported UseCase
  final int index;

  const _SuggestionCard({required this.suggestion, required this.index});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recipe = suggestion.recipe;
    final score = suggestion.score;
    final reasons = suggestion.matchingReasons as List<String>;

    return SizedBox(
      width: 200,
      child: AppCard(
        padding: EdgeInsets.zero,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => RecipeDetailPage(recipe: recipe)),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Placeholder / Header
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Center(
                child: Icon(Icons.restaurant_menu, size: 48, color: theme.colorScheme.primary),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title.replaceAll(RegExp(r'\[GOS-\d+\]\s*'), ''),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Score Badge
                  if (score > 10)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.stars, size: 12, color: Colors.green),
                          const SizedBox(width: 4),
                          Text(
                            score > 40 ? "Great Value" : "Good Match", 
                            style: const TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)
                          ),
                        ],
                      ),
                    ),
                  
                  const SizedBox(height: 8),
                  
                  // Clinical Tags
                  if (recipe.tags.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: (recipe.tags as List).take(3).map<Widget>((tag) {
                           final isClinical = ['renal', 'keto', 'diabetes', 'celiac', 'aplv', 'histamine', 'low fodmap']
                              .contains(tag.toString().toLowerCase());
                           if (!isClinical) return const SizedBox.shrink();

                           return Container(
                             padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                             decoration: BoxDecoration(
                               color: theme.colorScheme.secondaryContainer,
                               borderRadius: BorderRadius.circular(4),
                             ),
                             child: Text(
                               tag.toString(),
                               style: theme.textTheme.labelSmall?.copyWith(
                                 color: theme.colorScheme.onSecondaryContainer,
                                 fontWeight: FontWeight.bold,
                                 fontSize: 10,
                               ),
                             ),
                           );
                        }).toList(),
                      ),
                    ),

                  // Reasons
                  if (reasons.isNotEmpty)
                    Text(
                      reasons.first,
                      style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (100 * index).ms).slideX();
  }
}
