import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gastronomic_os/core/theme/app_dimens.dart';
import 'package:gastronomic_os/core/widgets/ui_kit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gastronomic_os/features/recipes/presentation/bloc/recipe_bloc.dart';
import 'package:gastronomic_os/features/recipes/presentation/bloc/recipe_event.dart';
import 'package:gastronomic_os/features/recipes/presentation/bloc/recipe_state.dart';

class RecipeFilterSheet extends StatefulWidget {
  const RecipeFilterSheet({super.key});

  @override
  State<RecipeFilterSheet> createState() => _RecipeFilterSheetState();
}

class _RecipeFilterSheetState extends State<RecipeFilterSheet> {
  // Local state for filters
  bool _isFamilySafe = false;
  bool _isPantryReady = false;
  // TODO: Add Tag filters logic later
  
  @override
  void initState() {
    super.initState();
    // Initialize from current BLoC state
    final state = context.read<RecipeBloc>().state;
    if (state is RecipeLoaded) {
      _isFamilySafe = state.isFamilySafe;
      _isPantryReady = state.isPantryReady;
    }
  }

  void _applyFilters() {
    final state = context.read<RecipeBloc>().state;
    String currentQuery = '';
    if (state is RecipeLoaded) {
        currentQuery = state.query;
    }

    context.read<RecipeBloc>().add(FilterRecipes(
      isFamilySafe: _isFamilySafe, 
      isPantryReady: _isPantryReady,
      query: currentQuery, // Preserve search query
    ));
    Navigator.pop(context);
  }

  void _resetFilters() {
    setState(() {
      _isFamilySafe = false;
      _isPantryReady = false;
    });
    // Optional: Auto-apply on reset or wait for Apply button?
    // Let's wait for Apply button for consistency.
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppDimens.spaceL),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter Recipes',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              TextButton(
                onPressed: _resetFilters,
                child: const Text('Reset'),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.spaceL),

          // Pantry Toggle
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Pantry Ready',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              'Show recipes you can cook right now',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            value: _isPantryReady,
            activeColor: colorScheme.primary,
            onChanged: (val) => setState(() => _isPantryReady = val),
          ),
          
          Divider(color: colorScheme.outlineVariant.withOpacity(0.5)),

          // Family Safe Toggle
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Family Safe',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              'Exclude allergens defined in Family profiles',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            value: _isFamilySafe,
            activeColor: colorScheme.tertiary,
            onChanged: (val) => setState(() => _isFamilySafe = val),
          ),

          const SizedBox(height: AppDimens.spaceXL),

          // Apply Button
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              label: 'Apply Filters',
              onPressed: _applyFilters,
            ),
          ),
          const SizedBox(height: AppDimens.spaceM),
        ],
      ),
    );
  }
}
