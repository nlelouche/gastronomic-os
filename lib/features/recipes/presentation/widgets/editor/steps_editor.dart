import 'package:flutter/material.dart';
import 'package:gastronomic_os/l10n/generated/app_localizations.dart';
import 'package:gastronomic_os/core/enums/diet_enums.dart'; // Import Enums
import 'package:gastronomic_os/features/recipes/domain/entities/recipe_step.dart';
import 'package:gastronomic_os/features/recipes/data/models/recipe_step_model.dart'; // Use Model? Or just Step?
import 'package:uuid/uuid.dart';

class StepEditorItem {
  final String id;
  final TextEditingController controller;
  bool isBranchPoint;
  final Map<String, TextEditingController> variantControllers; // Edit variants directly

  StepEditorItem({
    String? id,
    required this.controller,
    this.isBranchPoint = false,
    Map<String, TextEditingController>? variantControllers,
  }) : id = id ?? const Uuid().v4(),
       variantControllers = variantControllers ?? {};

  void dispose() {
    controller.dispose();
    for (var c in variantControllers.values) c.dispose();
  }
}

class StepsEditor extends StatefulWidget {
  final List<StepEditorItem> items;
  final VoidCallback onAddStep;
  final Function(int) onRemoveStep;
  final Function(int, int) onReorder;

  const StepsEditor({
    super.key,
    required this.items,
    required this.onAddStep,
    required this.onRemoveStep,
    required this.onReorder,
  });

  @override
  State<StepsEditor> createState() => _StepsEditorState();
}

class _StepsEditorState extends State<StepsEditor> {
  
  void _toggleBranchPoint(int index) {
    setState(() {
      widget.items[index].isBranchPoint = !widget.items[index].isBranchPoint;
    });
  }

  void _addVariant(int index) async {
    final item = widget.items[index];
    
    // Show Dialog to pick Condition
    final selectedKey = await showDialog<String>(
      context: context,
      builder: (context) => _VariantKeyPickerDialog(
        existingKeys: item.variantControllers.keys.toList(),
      ),
    );

    if (selectedKey != null) {
      setState(() {
        item.variantControllers[selectedKey] = TextEditingController();
      });
    }
  }

  void _removeVariant(int index, String key) {
    setState(() {
      widget.items[index].variantControllers[key]?.dispose();
      widget.items[index].variantControllers.remove(key);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
             Text('Instructions', style: Theme.of(context).textTheme.titleLarge),
             IconButton(
               onPressed: widget.onAddStep, 
               icon: Icon(Icons.add_circle, color: Theme.of(context).colorScheme.primary)
             ),
           ],
        ),
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.items.length,
          onReorder: widget.onReorder,
          itemBuilder: (context, index) {
            final item = widget.items[index];
            return Card(
              key: ValueKey(item.id),
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  ListTile(
                    leading: ReorderableDragStartListener(
                      index: index,
                      child: const Icon(Icons.drag_handle),
                    ),
                    title: TextField(
                      controller: item.controller,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.recipeStepPrefix(index + 1),
                        border: InputBorder.none,
                      ),
                      maxLines: null,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Toggle Branch Point
                        IconButton(
                          icon: Icon(
                            Icons.fork_right,
                            color: item.isBranchPoint ? Colors.orange : Colors.grey,
                          ),
                          tooltip: 'Make Branch Point',
                          onPressed: () => _toggleBranchPoint(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => widget.onRemoveStep(index),
                        ),
                      ],
                    ),
                  ),
                  
                  // Branch Point Variants Section
                  if (item.isBranchPoint)
                    Padding(
                      padding: const EdgeInsets.only(left: 32.0, right: 16.0, bottom: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(),
                          Row(
                            children: [
                              Text('Substitutions:', style: Theme.of(context).textTheme.labelLarge),
                              const Spacer(),
                              TextButton.icon(
                                onPressed: () => _addVariant(index),
                                icon: const Icon(Icons.add, size: 16),
                                label: const Text('Add Variant'),
                              ),
                            ],
                          ),
                          ...item.variantControllers.entries.map((entry) {
                            return Padding(
                               padding: const EdgeInsets.only(bottom: 8.0),
                               child: TextField(
                                 controller: entry.value,
                                 decoration: InputDecoration(
                                   labelText: 'For ${entry.key}',
                                   suffixIcon: IconButton(
                                      icon: const Icon(Icons.close, size: 16),
                                      onPressed: () => _removeVariant(index, entry.key),
                                   ),
                                   border: const OutlineInputBorder(),
                                   contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                 ),
                               ),
                            );
                          }),
                          if (item.variantControllers.isEmpty)
                             const Text('No variations yet. Everyone sees the standard step.', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _VariantKeyPickerDialog extends StatelessWidget {
  final List<String> existingKeys;

  const _VariantKeyPickerDialog({required this.existingKeys});

  @override
  Widget build(BuildContext context) {
    // Combine all Diets and Conditions
    final conditions = [
      ...MedicalCondition.values.map((e) => {'label': e.displayName, 'key': e.key, 'type': 'Medical'}),
      ...DietLifestyle.values.map((e) => {'label': e.displayName, 'key': e.key, 'type': 'Diet'}),
    ];

    // Filter out already used
    final available = conditions.where((c) => !existingKeys.contains(c['key'])).toList();

    return AlertDialog(
      title: const Text('Add Logic for...'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: available.length,
          itemBuilder: (context, index) {
             final item = available[index];
             final isMedical = item['type'] == 'Medical';
             return ListTile(
               leading: Icon(
                 isMedical ? Icons.medical_services : Icons.restaurant_menu,
                 color: isMedical ? Colors.red : Colors.green,
               ),
               title: Text(item['label'] as String),
               subtitle: Text(item['type'] as String),
               onTap: () => Navigator.pop(context, item['key']),
             );
          },
        ),
      ),
    );
  }
}
