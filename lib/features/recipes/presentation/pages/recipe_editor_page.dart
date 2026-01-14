import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe.dart';
import 'package:gastronomic_os/features/recipes/data/models/recipe_step_model.dart';
import 'package:gastronomic_os/features/recipes/presentation/bloc/recipe_bloc.dart';
import 'package:gastronomic_os/features/recipes/presentation/bloc/recipe_event.dart';
import 'package:gastronomic_os/l10n/generated/app_localizations.dart';
import 'package:gastronomic_os/core/theme/app_dimens.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gastronomic_os/features/recipes/presentation/widgets/editor/steps_editor.dart';

class RecipeEditorPage extends StatefulWidget {
  final Recipe? initialRecipe; 

  const RecipeEditorPage({super.key, this.initialRecipe});

  @override
  State<RecipeEditorPage> createState() => _RecipeEditorPageState();
}

class _RecipeEditorPageState extends State<RecipeEditorPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  
  final List<TextEditingController> _ingredientsControllers = [];
  final List<StepEditorItem> _stepsItems = []; // Changed to StepEditorItem

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialRecipe?.title ?? '');
    _descController = TextEditingController(text: widget.initialRecipe?.description ?? '');
    
    // Initialize ingredients
    if (widget.initialRecipe != null && widget.initialRecipe!.ingredients.isNotEmpty) {
      for (var ing in widget.initialRecipe!.ingredients) {
        _ingredientsControllers.add(TextEditingController(text: ing));
      }
    } else {
      _ingredientsControllers.add(TextEditingController()); 
    }

    // Initialize steps with full variant logic
    if (widget.initialRecipe != null && widget.initialRecipe!.steps.isNotEmpty) {
      for (var step in widget.initialRecipe!.steps) {
        final item = StepEditorItem(
          controller: TextEditingController(text: step.instruction),
          isBranchPoint: step.isBranchPoint,
          variantControllers: step.variantLogic?.map((k, v) => MapEntry(k, TextEditingController(text: v)))
        );
        _stepsItems.add(item);
      }
    } else {
      _stepsItems.add(StepEditorItem(controller: TextEditingController()));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    for (var c in _ingredientsControllers) c.dispose();
    for (var item in _stepsItems) item.dispose();
    super.dispose();
  }

  void _addIngredient() {
    setState(() {
      _ingredientsControllers.add(TextEditingController());
    });
  }

  void _removeIngredient(int index) {
    if (_ingredientsControllers.length > 1) {
      setState(() {
        _ingredientsControllers[index].dispose();
        _ingredientsControllers.removeAt(index);
      });
    }
  }

  void _addStep() {
    setState(() {
      _stepsItems.add(StepEditorItem(controller: TextEditingController()));
    });
  }

  void _removeStep(int index) {
    if (_stepsItems.length > 1) {
      setState(() {
        _stepsItems[index].dispose();
        _stepsItems.removeAt(index);
      });
    }
  }

  void _onReorderSteps(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final item = _stepsItems.removeAt(oldIndex);
      _stepsItems.insert(newIndex, item);
    });
  }

  void _saveRecipe() {
    if (_formKey.currentState!.validate()) {
      final ingredients = _ingredientsControllers
          .map((c) => c.text.trim())
          .where((t) => t.isNotEmpty)
          .toList();
      
      final steps = _stepsItems
          .map((item) {
             final instruction = item.controller.text.trim();
             if (instruction.isEmpty) return null;
             
             // Serialize Variants
             Map<String, String>? variants;
             if (item.isBranchPoint && item.variantControllers.isNotEmpty) {
               variants = {};
               for (var entry in item.variantControllers.entries) {
                 if (entry.value.text.isNotEmpty) {
                   variants[entry.key] = entry.value.text.trim();
                 }
               }
             }

             return RecipeStepModel(
               instruction: instruction,
               isBranchPoint: item.isBranchPoint,
               variantLogic: variants,
             );
          })
          .whereType<RecipeStepModel>() // Filter nulls
          .toList();

      if (widget.initialRecipe != null) {
          final updatedRecipe = widget.initialRecipe!.copyWith(
            title: _titleController.text.trim(),
            description: _descController.text.trim(),
            ingredients: ingredients,
            steps: steps,
          );
          context.read<RecipeBloc>().add(UpdateRecipe(updatedRecipe));
      } else {
        // Create Logic
        final newRecipe = Recipe(
          id: '', 
          authorId: '', 
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
          createdAt: DateTime.now(),
          ingredients: ingredients,
          steps: steps,
        );
        context.read<RecipeBloc>().add(CreateRecipe(newRecipe));
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialRecipe == null ? AppLocalizations.of(context)!.editorNewTitle : AppLocalizations.of(context)!.editorEditTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveRecipe,
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.paddingPage),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Meta Info
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.editorTitleLabel, border: const OutlineInputBorder()),
                validator: (v) => v == null || v.isEmpty ? AppLocalizations.of(context)!.editorTitleRequired : null,
              ),
              const SizedBox(height: AppDimens.spaceL),
              TextFormField(
                controller: _descController,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.editorDescriptionLabel, border: const OutlineInputBorder()),
                maxLines: 3,
              ),
              const SizedBox(height: AppDimens.spaceXL),
              
              // Ingredients Section (Legacy List)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppLocalizations.of(context)!.editorIngredientsSection, style: GoogleFonts.outfit(fontSize: AppDimens.fontSizeHeader, fontWeight: FontWeight.bold)),
                  IconButton(icon: Icon(Icons.add_circle, color: colorScheme.primary), onPressed: _addIngredient),
                ],
              ),
              ..._ingredientsControllers.asMap().entries.map((entry) {
                final index = entry.key;
                final controller = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: controller,
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!.editorIngredientsHint,
                            prefixIcon: const Icon(Icons.restaurant, size: 16),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.remove_circle_outline, color: colorScheme.error),
                        onPressed: () => _removeIngredient(index),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: AppDimens.spaceXL),

              // Steps Section (New Widget)
              StepsEditor(
                items: _stepsItems,
                onAddStep: _addStep,
                onRemoveStep: _removeStep,
                onReorder: _onReorderSteps,
              ),
              
              const SizedBox(height: AppDimens.space3XL),
            ],
          ),
        ),
      ),
    );
  }
}

