import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gastronomic_os/features/planner/presentation/bloc/planner_bloc.dart';
import 'package:gastronomic_os/features/planner/presentation/bloc/planner_state.dart';
import 'package:google_fonts/google_fonts.dart';

class ShoppingListPage extends StatelessWidget {
  const ShoppingListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shopping List', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: BlocBuilder<PlannerBloc, PlannerState>(
        builder: (context, state) {
          if (state is PlannerLoaded) {
            final items = state.shoppingList;
            if (items.isEmpty) {
              return Center(
                child: Text('List is empty. Plan some meals!', style: GoogleFonts.outfit(fontSize: 18)),
              );
            }

            return ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  leading: Checkbox(value: false, onChanged: (v) {}), // Todo: Implement Toggle
                  title: Text(
                    '${item.quantity} ${item.unit} ${item.name}'.trim(),
                    style: GoogleFonts.outfit(fontSize: 16),
                  ),
                  trailing: item.isVariant 
                      ? const Chip(label: Text('Variant'), backgroundColor: Colors.greenAccent)
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
