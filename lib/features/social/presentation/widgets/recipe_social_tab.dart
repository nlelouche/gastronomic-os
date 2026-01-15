import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gastronomic_os/core/theme/app_dimens.dart';
import 'package:gastronomic_os/core/widgets/ui_kit.dart';
import 'package:gastronomic_os/features/social/presentation/bloc/recipe_social/recipe_social_bloc.dart';
import 'package:gastronomic_os/features/social/presentation/bloc/recipe_social/recipe_social_event.dart';
import 'package:gastronomic_os/features/social/presentation/bloc/recipe_social/recipe_social_state.dart';
import 'package:gastronomic_os/features/social/presentation/widgets/cook_proof_gallery.dart';
import 'package:gastronomic_os/features/social/presentation/widgets/rating_bar.dart';
import 'package:gastronomic_os/features/social/presentation/widgets/review_list_tile.dart';
import 'package:image_picker/image_picker.dart';

class RecipeSocialTab extends StatelessWidget {
  final String recipeId;

  const RecipeSocialTab({super.key, required this.recipeId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return BlocConsumer<RecipeSocialBloc, RecipeSocialState>(
      listener: (context, state) {
        if (state.status == RecipeSocialStatus.error) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorMessage ?? 'Error')));
        }
        if (state.status == RecipeSocialStatus.successReview) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Review Submitted!')));
        }
        if (state.status == RecipeSocialStatus.successProof) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Proof Uploaded!')));
        }
      },
      builder: (context, state) {
        if (state.status == RecipeSocialStatus.loading && state.reviews.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () async {
            context.read<RecipeSocialBloc>().add(LoadRecipeSocialData(recipeId));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 80), // Fab spacing
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppDimens.spaceM),
                
                // --- COOK PROOFS SECTION ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingPage),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Cook Proofs', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.add_a_photo),
                        onPressed: () => _showAddProofDialog(context),
                      ),
                    ],
                  ),
                ),
                if (state.proofs.isNotEmpty)
                  CookProofGallery(proofs: state.proofs)
                else 
                   Padding(
                     padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingPage),
                     child: Text("No proofs yet. Be the first to cook this!", style: theme.textTheme.bodySmall),
                   ),

                const SizedBox(height: AppDimens.spaceXL),

                // --- REVIEWS SECTION ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingPage),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Reviews (${state.reviews.length})', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      TextButton(
                         onPressed: () => _showAddReviewDialog(context),
                         child: const Text('Write Review'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.spaceS),
                
                if (state.reviews.isEmpty)
                  Center(child: Padding(
                    padding: const EdgeInsets.all(AppDimens.spaceXL),
                    child: Text("No reviews yet.", style: theme.textTheme.bodyMedium),
                  ))
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingPage),
                    itemCount: state.reviews.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppDimens.spaceM),
                    itemBuilder: (context, index) {
                      return ReviewListTile(review: state.reviews[index]);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddReviewDialog(BuildContext context) {
    final commentController = TextEditingController();
    int selectedRating = 5;
    final bloc = context.read<RecipeSocialBloc>(); // Capture bloc

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Write a Review"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RatingBar(
                  rating: selectedRating.toDouble(), 
                  size: 32, 
                  onRatingChanged: (val) => setState(() => selectedRating = val),
                ),
                const SizedBox(height: AppDimens.spaceM),
                TextField(
                  controller: commentController,
                  decoration: const InputDecoration(
                    hintText: "How was it?",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text("Cancel")),
              FilledButton(
                onPressed: () {
                  if (commentController.text.isNotEmpty) {
                    bloc.add(SubmitReview(
                      recipeId: recipeId,
                      rating: selectedRating,
                      comment: commentController.text,
                    ));
                    Navigator.pop(dialogCtx);
                  }
                }, 
                child: const Text("Submit"),
              ),
            ],
          );
        }
      ),
    );
  }

  Future<void> _showAddProofDialog(BuildContext context) async {
    final picker = ImagePicker();
    // For MVP, just gallery
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null && context.mounted) {
       final captionController = TextEditingController();
       final bloc = context.read<RecipeSocialBloc>();
       final file = File(image.path);

       await showDialog(
         context: context,
         builder: (dialogCtx) => AlertDialog(
           title: const Text("Upload Cook Proof"),
           content: Column(
             mainAxisSize: MainAxisSize.min,
             children: [
               Image.file(file, height: 150, fit: BoxFit.cover),
               const SizedBox(height: AppDimens.spaceM),
               TextField(
                 controller: captionController,
                 decoration: const InputDecoration(
                   hintText: "Add a caption...",
                 ),
               ),
             ],
           ),
           actions: [
              TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text("Cancel")),
              FilledButton(
                onPressed: () {
                   bloc.add(SubmitCookProof(
                     recipeId: recipeId,
                     photo: file,
                     caption: captionController.text,
                   ));
                   Navigator.pop(dialogCtx);
                }, 
                child: const Text("Upload"),
              ),
           ],
         ),
       );
    }
  }
}
