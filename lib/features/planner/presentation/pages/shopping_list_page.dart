import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gastronomic_os/features/planner/presentation/bloc/planner_bloc.dart';
import 'package:gastronomic_os/features/planner/presentation/bloc/planner_state.dart';
import 'package:gastronomic_os/core/logic/unit_converter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gastronomic_os/l10n/generated/app_localizations.dart';

class ShoppingListPage extends StatelessWidget {
  const ShoppingListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.shoppingListTitle, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: BlocBuilder<PlannerBloc, PlannerState>(
        builder: (context, state) {
          if (state is PlannerLoaded) {
            final items = state.shoppingList;
            if (items.isEmpty) {
              return Center(
                child: Text(AppLocalizations.of(context)!.shoppingListEmpty, style: GoogleFonts.outfit(fontSize: 18)),
              );
            }

            return ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final item = items[index];
                // Use singleton converter for display (or inject it)
                // For MVP, instantiation is fine as it's stateless logic, 
                // but cleaner to get from sl or bloc state if available.
                // Let's instantiate locally for now to fix the UI quickly.
                final converter = UnitConverter(); 
                final (displayQty, displayUnit) = converter.formatForDisplay(item.quantity, item.unit, item.name);
                
                String label;
                if (displayQty == -1.0) {
                  // Smart Purchase: Just the name (e.g. "Olive Oil")
                  label = item.name.trim(); // Capitalize?
                  if (label.isNotEmpty) label = label[0].toUpperCase() + label.substring(1);
                } else {
                  label = '$displayQty $displayUnit ${item.name}'.trim();
                }

                return ListTile(
                  leading: Checkbox(value: false, onChanged: (v) {}),
                  title: Text(
                    label,
                    style: GoogleFonts.outfit(fontSize: 16),
                  ),
                  trailing: item.isVariant 
                      ? Chip(label: Text(AppLocalizations.of(context)!.shoppingListVariant), backgroundColor: Colors.greenAccent)
                      : null,
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
