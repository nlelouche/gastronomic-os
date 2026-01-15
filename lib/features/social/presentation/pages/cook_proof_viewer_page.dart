import 'package:flutter/material.dart';
import 'package:gastronomic_os/core/theme/app_dimens.dart';
import 'package:gastronomic_os/features/social/domain/entities/cook_proof.dart';
import 'package:google_fonts/google_fonts.dart';

class CookProofViewerPage extends StatelessWidget {
  final CookProof proof;

  const CookProofViewerPage({super.key, required this.proof});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Zoomable Image
          Center(
            child: InteractiveViewer(
              minScale: 1.0,
              maxScale: 4.0,
              child: Hero(
                tag: 'proof_${proof.id}',
                child: Image.network(
                  proof.photoUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const CircularProgressIndicator(color: Colors.white);
                  },
                ),
              ),
            ),
          ),

          // 2. Top Bar (Close Button)
          Positioned(
            top: MediaQuery.of(context).padding.top + AppDimens.spaceM,
            left: AppDimens.spaceM,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),

          // 3. Bottom Overlay (Caption & User Info)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                AppDimens.paddingPage,
                AppDimens.paddingPage,
                AppDimens.paddingPage,
                MediaQuery.of(context).padding.bottom + AppDimens.paddingPage,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black87],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Info Row
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: proof.userAvatar != null
                            ? NetworkImage(proof.userAvatar!)
                            : null,
                        backgroundColor: Colors.grey[800],
                        child: proof.userAvatar == null
                            ? const Icon(Icons.person, color: Colors.white, size: 16)
                            : null,
                      ),
                      const SizedBox(width: AppDimens.spaceS),
                      Text(
                        proof.userName,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  
                  if (proof.caption != null && proof.caption!.isNotEmpty) ...[
                    const SizedBox(height: AppDimens.spaceM),
                    Text(
                      proof.caption!,
                      style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
