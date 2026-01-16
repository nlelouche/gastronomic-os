import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe.dart';
import 'package:gastronomic_os/features/recipes/data/models/recipe_step_model.dart';
import 'package:gastronomic_os/features/recipes/presentation/bloc/recipe_bloc.dart';
import 'package:gastronomic_os/features/recipes/presentation/bloc/recipe_event.dart';
import 'package:gastronomic_os/features/recipes/presentation/bloc/recipe_state.dart';
import 'package:gastronomic_os/l10n/generated/app_localizations.dart';
import 'package:gastronomic_os/core/theme/app_dimens.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gastronomic_os/features/recipes/presentation/widgets/editor/steps_editor.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:gastronomic_os/init/injection_container.dart' as di;
import 'package:gastronomic_os/features/recipes/domain/repositories/i_recipe_repository.dart';

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
  final List<StepEditorItem> _stepsItems = []; 
  
  String? _coverPhotoUrl;
  bool _isUploadingImage = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialRecipe?.title ?? '');
    _descController = TextEditingController(text: widget.initialRecipe?.description ?? '');
    _coverPhotoUrl = widget.initialRecipe?.coverPhotoUrl;
    
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

  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      setState(() => _isUploadingImage = true);

      final repo = di.sl<IRecipeRepository>();
      final result = await repo.uploadRecipeImage(File(image.path));
      
      if (result.$1 == null && result.$2 != null) {
        setState(() {
          _coverPhotoUrl = result.$2;
          _isUploadingImage = false;
        });
      } else {
         setState(() => _isUploadingImage = false);
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: ${result.$1?.message}')));
         }
      }
    } catch (e) {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  void _removeCoverPhoto() {
    setState(() {
      _coverPhotoUrl = null;
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
          // Fix: Manually construct if cover photo is null to avoid copyWith(null) ignored behavior
          Recipe updatedRecipe;
          if (_coverPhotoUrl == null) {
             updatedRecipe = Recipe(
                id: widget.initialRecipe!.id,
                authorId: widget.initialRecipe!.authorId,
                originId: widget.initialRecipe!.originId,
                isFork: widget.initialRecipe!.isFork,
                title: _titleController.text.trim(),
                description: _descController.text.trim(),
                coverPhotoUrl: null, // Explicitly Null
                isPublic: widget.initialRecipe!.isPublic,
                createdAt: widget.initialRecipe!.createdAt,
                ingredients: ingredients,
                steps: steps,
                tags: widget.initialRecipe!.tags,
                dietTags: widget.initialRecipe!.dietTags,
             );
          } else {
             updatedRecipe = widget.initialRecipe!.copyWith(
                title: _titleController.text.trim(),
                description: _descController.text.trim(),
                ingredients: ingredients,
                steps: steps,
                coverPhotoUrl: _coverPhotoUrl,
             );
          }
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
          coverPhotoUrl: _coverPhotoUrl, // Set URL
        );
        context.read<RecipeBloc>().add(CreateRecipe(newRecipe));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return BlocListener<RecipeBloc, RecipeState>(
      listener: (context, state) {
        if (state is RecipeLoaded || state is RecipeDetailLoaded) {
          // Success
          Navigator.pop(context, true);
        } else if (state is RecipeError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.initialRecipe == null ? AppLocalizations.of(context)!.editorNewTitle : AppLocalizations.of(context)!.editorEditTitle),
          actions: [
            BlocBuilder<RecipeBloc, RecipeState>(
              builder: (context, state) {
                if (state is RecipeLoading) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                  );
                }
                return IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: _saveRecipe,
                );
              },
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

              // Cover Photo
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                    image: _coverPhotoUrl != null ? DecorationImage(image: NetworkImage(_coverPhotoUrl!), fit: BoxFit.cover) : null,
                  ),
                  child: Stack(
                    children: [
                      if (_isUploadingImage)
                        const Center(child: CircularProgressIndicator()),
                        
                      if (!_isUploadingImage)
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Row(
                            children: [
                               FilledButton.icon(
                                 onPressed: _pickAndUploadImage,
                                 icon: const Icon(Icons.camera_alt, size: 16),
                                 label: Text(_coverPhotoUrl == null ? 'Add Cover' : 'Change'),
                               ),
                               if (_coverPhotoUrl != null) ...[
                                 const SizedBox(width: 8),
                                 IconButton(
                                   onPressed: _removeCoverPhoto,
                                   icon: const Icon(Icons.delete),
                                   style: IconButton.styleFrom(backgroundColor: colorScheme.errorContainer, foregroundColor: colorScheme.onErrorContainer),
                                 ),
                               ]
                            ],
                          ),
                        ),
                        
                      if (_coverPhotoUrl == null && !_isUploadingImage)
                         Center(
                           child: Column(
                             mainAxisAlignment: MainAxisAlignment.center,
                             children: [
                               Icon(Icons.image, size: 48, color: colorScheme.onSurfaceVariant.withOpacity(0.5)),
                               const SizedBox(height: 8),
                               Text('No Cover Photo', style: TextStyle(color: colorScheme.onSurfaceVariant)),
                             ],
                           ),
                         ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppDimens.spaceL),

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
    ));
  }
}

