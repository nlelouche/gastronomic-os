import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gastronomic_os/features/planner/presentation/bloc/planner_bloc.dart';
import 'package:gastronomic_os/features/planner/presentation/bloc/planner_event.dart';
import 'package:gastronomic_os/features/planner/presentation/bloc/planner_state.dart';
import 'package:gastronomic_os/features/planner/presentation/widgets/meal_plan_card.dart';
import 'package:gastronomic_os/features/planner/presentation/pages/shopping_list_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gastronomic_os/features/recipes/presentation/pages/recipe_detail_page.dart';
import 'package:gastronomic_os/l10n/generated/app_localizations.dart';

class PlannerPage extends StatefulWidget {
  const PlannerPage({super.key});

  @override
  State<PlannerPage> createState() => _PlannerPageState();
}

class _PlannerPageState extends State<PlannerPage> {
  @override
  void initState() {
    super.initState();
    // Load next 7 days by default
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 7));
    context.read<PlannerBloc>().add(LoadScheduledMeals(start, end));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.dashboardPlannerTitle,
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {
               Navigator.of(context).push(
                 MaterialPageRoute(
                   builder: (ctx) => BlocProvider.value(
                     value: context.read<PlannerBloc>()..add(GenerateShoppingList()),
                     child: const ShoppingListPage(),
                   ),
                 ),
               );
            },
          ),
        ],
      ),
      body: BlocBuilder<PlannerBloc, PlannerState>(
        builder: (context, state) {
          if (state is PlannerLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is PlannerError) {
             final isDbError = state.message.contains('PGRST205') || state.message.contains('meal_plans');
             return Center(
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   Icon(isDbError ? Icons.table_view : Icons.error_outline, size: 60, color: Colors.orange),
                   const SizedBox(height: 16),
                   Text(isDbError ? 'Database Setup Required' : 'Something went wrong', 
                        style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
                   const SizedBox(height: 8),
                   Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 32),
                     child: Text(
                       isDbError 
                         ? "The 'meal_plans' table is missing. Please execute the SQL migration script." 
                         : state.message,
                       textAlign: TextAlign.center,
                       style: theme.textTheme.bodyMedium,
                     ),
                   ),
                 ],
               ),
             );
          }
          if (state is PlannerLoaded) {
            final plans = state.scheduledMeals;
            
            if (plans.isEmpty) {
               return Center(
                 child: Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     Icon(Icons.calendar_today_outlined, size: 64, color: theme.colorScheme.outline),
                     const SizedBox(height: 16),
                     Text(AppLocalizations.of(context)!.plannerEmptyTitle, style: GoogleFonts.outfit(fontSize: 18)),
                     Text(AppLocalizations.of(context)!.plannerEmptySubtitle, style: theme.textTheme.bodyMedium),
                   ],
                 ),
               );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(AppDimens.paddingCard),
              itemCount: plans.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final plan = plans[index];
                return MealPlanCard(
                  plan: plan,
                  onDateTap: () async {
                    // Reschedule Feature
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: plan.scheduledDate,
                      firstDate: DateTime.now().subtract(const Duration(days: 1)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      context.read<PlannerBloc>().add(UpdateMealPlan(plan.copyWith(scheduledDate: picked)));
                    } 
                  },
                  onContentTap: () {
                    if (plan.recipe != null) {
                      // Quick Review Modal
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        useSafeArea: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (ctx) => DraggableScrollableSheet(
                          initialChildSize: 0.85,
                          minChildSize: 0.5,
                          maxChildSize: 0.95,
                          expand: false,
                          builder: (_, scrollController) => ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                            child: Scaffold(
                              appBar: AppBar(
                                centerTitle: true,
                                title: Text('Quick Review', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                                automaticallyImplyLeading: false,
                                actions: [
                                  IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close))
                                ],
                              ),
                              body: RecipeDetailPage(
                                recipeId: plan.recipe!.id,
                                recipe: plan.recipe!,
                                isModal: true, // Optional: Pass flag if we want slight UI variations for modal
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                  },
                  onDelete: () {
                     context.read<PlannerBloc>().add(DeleteMealPlan(plan.id));
                  },
                ).animate().fadeIn(delay: (index * 50).ms).slideY(begin: 0.1);
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
           Navigator.of(context).push(
             MaterialPageRoute(
               builder: (ctx) => BlocProvider.value(
                 value: context.read<PlannerBloc>()..add(GenerateShoppingList()),
                 child: const ShoppingListPage(),
               ),
             ),
           );
        },
        label: Text(AppLocalizations.of(context)!.shoppingListButton),
        icon: const Icon(Icons.list_alt),
      ),
    );
  }
}
