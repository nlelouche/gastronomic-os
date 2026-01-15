import 'package:flutter/material.dart';
import 'package:gastronomic_os/core/theme/app_dimens.dart';
import 'package:gastronomic_os/features/social/domain/entities/cook_proof.dart';
import 'package:gastronomic_os/features/social/presentation/pages/cook_proof_viewer_page.dart';

class CookProofGallery extends StatelessWidget {
  final List<CookProof> proofs;

  const CookProofGallery({super.key, required this.proofs});

  @override
  Widget build(BuildContext context) {
    if (proofs.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingPage),
        itemCount: proofs.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppDimens.spaceS),
        itemBuilder: (context, index) {
          final proof = proofs[index];
          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CookProofViewerPage(proof: proof),
                ),
              );
            },
            child: AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppDimens.radiusM),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: 'proof_${proof.id}',
                      child: Image.network(
                        proof.photoUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                    if (proof.caption != null)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black54],
                            ),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: Text(
                            proof.caption!,
                            style: const TextStyle(color: Colors.white, fontSize: 10),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
