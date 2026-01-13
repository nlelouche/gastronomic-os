import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gastronomic_os/core/widgets/ui_kit.dart';
import 'package:gastronomic_os/features/inventory/presentation/bloc/inventory_bloc.dart';
import 'package:gastronomic_os/init/injection_container.dart';
import 'package:gastronomic_os/features/inventory/domain/entities/inventory_item.dart';
import 'package:gastronomic_os/features/inventory/presentation/widgets/inventory_item_card.dart';
import 'package:gastronomic_os/features/recipes/presentation/pages/recipes_page.dart';
import 'package:gastronomic_os/features/settings/presentation/pages/settings_page.dart';
import 'package:google_fonts/google_fonts.dart';

class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<InventoryBloc>(
      create: (_) => sl<InventoryBloc>()..add(LoadInventory()),
      child: const InventoryView(),
    );
  }
}

class InventoryView extends StatelessWidget {
  const InventoryView({super.key});

  @override
  Widget build(BuildContext context) {
    // Access theme data
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // Custom concise app bar
      appBar: AppBar(
        title: Text(
          'My Fridge', 
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 24)
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_book_rounded),
            tooltip: 'Recipes',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const RecipesPage()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            tooltip: 'Settings',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const SettingsPage()),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<InventoryBloc, InventoryState>(
        builder: (context, state) {
          if (state is InventoryLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is InventoryLoaded) {
            if (state.items.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.kitchen_outlined, size: 64, color: theme.colorScheme.outline),
                    const SizedBox(height: 16),
                    Text(
                      'Fridge is empty!',
                      style: theme.textTheme.headlineSmall?.copyWith(color: theme.colorScheme.outline),
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      label: 'Add First Item',
                      icon: Icons.add,
                      onPressed: () => _showItemDialog(context, null),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 500.ms);
            }
            
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.items.length + 1, // Add space at bottom for FAB
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index == state.items.length) {
                  return const SizedBox(height: 80); // Bottom padding
                }
                
                final item = state.items[index];
                return InventoryItemCard(
                  item: item,
                  onTap: () => _showItemDialog(context, item),
                  onEdit: () => _showItemDialog(context, item),
                );
              },
            );
          } else if (state is InventoryError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${state.message}'),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showItemDialog(context, null),
        label: Text('Add Item', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
        icon: const Icon(Icons.add_rounded),
        elevation: 4,
        highlightElevation: 8,
      ).animate().scale(delay: 500.ms, duration: 300.ms, curve: Curves.easeOutBack),
    );
  }

  void _showItemDialog(BuildContext context, InventoryItem? item) {
    // We need to access the bloc from the context ABOVE the dialog
    // But since context inside showDialog is different, we must capture it or pass it.
    // Actually, we can just use the provided context if we are careful, 
    // or wrap the dialog content in a BlocProvider.value if strictly needed.
    // However, since we provided InventoryBloc at the top of this page, 
    // we can access it via 'context.read<InventoryBloc>()' IF the context passed to _showItemDialog
    // is a child of the provider. Yes, it is (from build method).
    
    // BUT common pitfall: showDialog creates a new root, so we need to pass the bloc explicitly
    // or wrap the dialog content.
    final bloc = context.read<InventoryBloc>();

    final nameController = TextEditingController(text: item?.name ?? '');
    final quantityController = TextEditingController(text: item?.quantity.toString() ?? '');
    final isEditing = item != null;

    String selectedUnit = item?.unit ?? 'unit';
    // Validate unit exists in list, else default to 'unit' or add it?
    // For MVP, lets ensure we support the common ones.
    final units = ['unit', 'kg', 'g', 'L', 'ml', 'cup', 'tbsp', 'tsp'];
    if (!units.contains(selectedUnit)) {
      selectedUnit = 'unit'; // Fallback
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text(isEditing ? 'Edit Item' : 'Add Item', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.label_outline),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: quantityController,
                          decoration: InputDecoration(
                            labelText: 'Quantity',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.numbers),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedUnit,
                            icon: const Icon(Icons.arrow_drop_down_rounded),
                            items: units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => selectedUnit = val);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actionsPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              actions: [
                if (isEditing)
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    onPressed: () {
                      bloc.add(DeleteInventoryItem(item.id));
                      Navigator.pop(dialogContext);
                    },
                    child: const Text('Delete'),
                  ),
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                     final name = nameController.text;
                     final quantity = double.tryParse(quantityController.text) ?? 1.0;
                     if (name.isNotEmpty) {
                       if (isEditing) {
                         final updatedItem = InventoryItem(
                           id: item!.id,
                           name: name,
                           quantity: quantity,
                           unit: selectedUnit,
                           expirationDate: item.expirationDate,
                           category: item.category,
                           metadata: item.metadata,
                         );
                         bloc.add(UpdateInventoryItem(updatedItem));
                       } else {
                         bloc.add(AddInventoryItem(
                           InventoryItem(id: '', name: name, quantity: quantity, unit: selectedUnit)
                         ));
                       }
                       Navigator.pop(dialogContext);
                     }
                  }, 
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text(isEditing ? 'Update' : 'Add')
                ),
              ],
            ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack);
          }
        );
      },
    );
  }
}
