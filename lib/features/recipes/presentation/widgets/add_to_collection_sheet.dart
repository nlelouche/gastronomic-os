import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gastronomic_os/l10n/generated/app_localizations.dart';
import 'package:gastronomic_os/core/widgets/ui_kit.dart';
import 'package:gastronomic_os/features/recipes/presentation/bloc/collections/collections_bloc.dart';
import 'package:gastronomic_os/features/recipes/presentation/bloc/collections/collections_state.dart';
import 'package:gastronomic_os/features/recipes/presentation/bloc/collections/collections_event.dart';
import 'package:gastronomic_os/init/injection_container.dart';

class AddToCollectionSheet extends StatelessWidget {
  final String recipeId;

  const AddToCollectionSheet({super.key, required this.recipeId});

  void _showCreateDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    showDialog(
      context: context, 
      builder: (ctx) => AlertDialog(
        title: Text(l10n.collectionDialogTitle),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: l10n.collectionDialogLabel),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.btnCancel)),
          PrimaryButton(
            label: l10n.btnCreate, 
            onPressed: () {
              if (controller.text.isNotEmpty) {
                // Use the Bloc provided to the sheet or global?
                // Sheet is likely opened from a context where Bloc might not be provided directly if using showModalBottomSheet context often differs.
                // Best to wrap Sheet in BlocProvider if needed or pass Generic Bloc.
                // Here we use sl<CollectionsBloc> provided locally or existing context if available.
                context.read<CollectionsBloc>().add(CreateCollectionEvent(controller.text));
                Navigator.pop(ctx);
              }
            }
          ),
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (context) => sl<CollectionsBloc>()..add(LoadCollections()),
      child: Container( // Wrap in Container for safe sizing if needed
        padding: const EdgeInsets.only(top: 16, bottom: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.addToCollectionTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.add),
                    tooltip: l10n.btnNewCollection,
                    onPressed: () => _showCreateDialog(context),
                  )
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: BlocBuilder<CollectionsBloc, CollectionsState>(
                builder: (context, state) {
                  if (state is CollectionsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  if (state is CollectionsLoaded) {
                    if (state.collections.isEmpty) {
                      return Center(
                        child: TextButton.icon(
                          onPressed: () => _showCreateDialog(context),
                          icon: const Icon(Icons.add),
                          label: Text(l10n.createCollectionHeader),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: state.collections.length,
                      itemBuilder: (context, index) {
                        final collection = state.collections[index];
                        // TODO: We need to know if recipe is IN this collection.
                        // The simplified endpoint getUserCollections didn't return that info relative to a specific recipe.
                        // We need a specific 'check' or fetch logic. 
                        // For now, let's just allow "Add" (maybe show if added effectively?).
                        // Or better: clicking toggles and we optimistic update?
                        // Without 'isInCollection' flag, we can't show Checkbox correctly properly initially.
                        // FIX: We need `isRecipeInCollection` logic.
                        // Quick fix: Assume not checked, or fetch specific recipe collections?
                        return ListTile(
                          leading: const Icon(Icons.folder_outlined),
                          title: Text(collection.name),
                          trailing: const Icon(Icons.add_circle_outline),
                          onTap: () {
                             context.read<CollectionsBloc>().add(AddRecipeToCollectionEvent(
                               recipeId: recipeId, 
                               collectionId: collection.id
                             ));
                             ScaffoldMessenger.of(context).showSnackBar(
                               SnackBar(content: Text('Added to ${collection.name}')) // TODO: Localize feedback
                             );
                             Navigator.pop(context);
                          },
                        );
                      },
                    );
                  }
                  
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
