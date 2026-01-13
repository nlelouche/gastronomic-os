import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe_step.dart';
import 'package:gastronomic_os/features/recipes/data/models/recipe_step_model.dart';
import 'package:gastronomic_os/features/recipes/presentation/bloc/recipe_bloc.dart';
import 'package:gastronomic_os/features/recipes/presentation/bloc/recipe_event.dart';
import 'package:gastronomic_os/l10n/generated/app_localizations.dart';

class RecipeEditorPage extends StatefulWidget {
  final Recipe? initialRecipe; // If null, creating new

  const RecipeEditorPage({super.key, this.initialRecipe});

  @override
  State<RecipeEditorPage> createState() => _RecipeEditorPageState();
}

class _RecipeEditorPageState extends State<RecipeEditorPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  
  final List<TextEditingController> _ingredientsControllers = [];
  final List<TextEditingController> _stepsControllers = [];

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
      _ingredientsControllers.add(TextEditingController()); // Start with one empty
    }

    // Initialize steps
    if (widget.initialRecipe != null && widget.initialRecipe!.steps.isNotEmpty) {
      for (var step in widget.initialRecipe!.steps) {
        _stepsControllers.add(TextEditingController(text: step.instruction));
      }
    } else {
      _stepsControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    for (var c in _ingredientsControllers) c.dispose();
    for (var c in _stepsControllers) c.dispose();
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
      _stepsControllers.add(TextEditingController());
    });
  }

  void _removeStep(int index) {
    if (_stepsControllers.length > 1) {
      setState(() {
        _stepsControllers[index].dispose();
        _stepsControllers.removeAt(index);
      });
    }
  }

  void _saveRecipe() {
    if (_formKey.currentState!.validate()) {
      final ingredients = _ingredientsControllers
          .map((c) => c.text.trim())
          .where((t) => t.isNotEmpty)
          .toList();
      
      final steps = _stepsControllers
          .map((c) => RecipeStepModel(instruction: c.text.trim()))
          .where((s) => s.instruction.isNotEmpty)
          .toList();

      final newRecipe = Recipe(
        id: widget.initialRecipe?.id ?? '', // Will be ignored by DB or generated
        authorId: '', // Handled by datasource
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        createdAt: widget.initialRecipe?.createdAt ?? DateTime.now(),
        ingredients: ingredients,
        steps: steps,
      );

      // We only support creating new recipes for now via this UI
      // Updating would require a different event or logic (create Commit)
      context.read<RecipeBloc>().add(CreateRecipe(newRecipe));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Meta Info
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.editorTitleLabel, border: const OutlineInputBorder()),
                validator: (v) => v == null || v.isEmpty ? AppLocalizations.of(context)!.editorTitleRequired : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.editorDescriptionLabel, border: const OutlineInputBorder()),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              
              // Ingredients Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppLocalizations.of(context)!.editorIngredientsSection, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.add_circle, color: Colors.green), onPressed: _addIngredient),
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
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                        onPressed: () => _removeIngredient(index),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 24),

              // Steps Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppLocalizations.of(context)!.editorInstructionsSection, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.add_circle, color: Colors.green), onPressed: _addStep),
                ],
              ),
              ..._stepsControllers.asMap().entries.map((entry) {
                final index = entry.key;
                final controller = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0, right: 8.0),
                        child: Text('${index + 1}.', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: controller,
                          maxLines: null,
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!.editorInstructionsHint,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                        onPressed: () => _removeStep(index),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
