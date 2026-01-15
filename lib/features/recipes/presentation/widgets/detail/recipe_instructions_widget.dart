import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gastronomic_os/core/theme/app_dimens.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gastronomic_os/features/onboarding/domain/entities/family_member.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/resolved_step.dart';
import 'package:gastronomic_os/features/recipes/presentation/widgets/formatted_recipe_text.dart';
import 'package:gastronomic_os/l10n/generated/app_localizations.dart';
import 'package:gastronomic_os/features/recipes/domain/entities/recipe_step.dart';

class RecipeInstructionsWidget extends StatelessWidget {
  final List<ResolvedStep>? resolvedSteps;
  final bool isResolving;

  const RecipeInstructionsWidget({
    super.key, 
    required this.resolvedSteps,
    required this.isResolving,
  });

  @override
  Widget build(BuildContext context) {
    // ... (Loading and Empty checks remain same)
    if (isResolving) return const Center(child: CircularProgressIndicator());
    if (resolvedSteps == null || resolvedSteps!.isEmpty) {
      return Text(AppLocalizations.of(context)!.recipeInstructionsEmpty);
    }

    final Map<int, List<ResolvedStep>> groupedSteps = {};
    for (var step in resolvedSteps!) {
      if (!groupedSteps.containsKey(step.index)) groupedSteps[step.index] = [];
      groupedSteps[step.index]!.add(step);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: groupedSteps.entries.map((groupEntry) {
        final stepIndex = groupEntry.key;
        final variants = groupEntry.value;
        final isSplit = variants.length == 2;
        final isCarousel = variants.length > 2;

        return Padding(
          padding: const EdgeInsets.only(bottom: 32.0),
          child: Column(
            children: [
              // Step Header / Connector Point
              if (stepIndex > 1) 
                Container(width: 2, height: 20, color: Theme.of(context).colorScheme.outlineVariant),
              
              _buildStepNumberNode(context, stepIndex),
              
              if (isSplit) ...[
                // Split Connectors (Only for exactly 2 variants)
                CustomPaint(
                  size: const Size(double.infinity, 30),
                  painter: SplitLinePainter(color: Theme.of(context).colorScheme.outlineVariant),
                ),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: variants.asMap().entries.map((entry) {
                      final variant = entry.value;
                      final isFirst = entry.key == 0;
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: isFirst ? 8.0 : 0, 
                            left: !isFirst ? 8.0 : 0
                          ),
                          child: _buildVariantCard(context, variant),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ] else if (isCarousel) ...[
                // Carousel Mode for 3+ variants
                Container(
                  width: 2, 
                  height: 20, 
                  color: Theme.of(context).colorScheme.outlineVariant
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: variants.map((variant) {
                        return Container(
                          width: MediaQuery.of(context).size.width * 0.85,
                          padding: const EdgeInsets.only(right: 16),
                          child: _buildVariantCard(context, variant),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ] else ...[
                 const SizedBox(height: 16),
                 _buildVariantCard(context, variants.first, isUniversal: true),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStepNumberNode(BuildContext context, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Text(
        'Step $index',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildVariantCard(BuildContext context, ResolvedStep step, {bool isUniversal = false}) {
    return InstructionStepCard(step: step, isUniversal: isUniversal);
  }
}

class InstructionStepCard extends StatefulWidget {
  final ResolvedStep step;
  final bool isUniversal;

  const InstructionStepCard({
    super.key,
    required this.step,
    required this.isUniversal,
  });

  @override
  State<InstructionStepCard> createState() => _InstructionStepCardState();
}

class _InstructionStepCardState extends State<InstructionStepCard> {
  bool _isCompleted = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Determine color based on target (Mock logic for colors)
    Color accentColor = colorScheme.secondary;
    if (widget.step.targetGroupLabel.toLowerCase().contains('dad')) accentColor = Colors.orange;
    else if (widget.step.targetGroupLabel.toLowerCase().contains('mom')) accentColor = Colors.green;

    final cardColor = widget.isUniversal 
        ? colorScheme.surfaceContainer 
        : (_isCompleted ? accentColor.withOpacity(0.1) : colorScheme.surfaceContainerLow);

    return AnimatedContainer(
      duration: 300.ms,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: widget.isUniversal 
            ? null 
            : Border.all(
                color: _isCompleted ? accentColor : accentColor.withOpacity(0.5), 
                width: _isCompleted ? 2 : 1
              ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!widget.isUniversal)
            Row(
              children: [
                if (widget.step.targetMembers.isNotEmpty)
                  _buildMicroAvatar(context, widget.step.targetMembers.first, 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.step.targetGroupLabel.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10, 
                      fontWeight: FontWeight.bold, 
                      color: accentColor
                    ),
                  ),
                ),
                if (_isCompleted)
                  Icon(Icons.check_circle, color: accentColor, size: 16).animate().scale(),
              ],
            ),
          if (!widget.isUniversal) const SizedBox(height: 8),
          
          Text(
            widget.step.instruction,
            style: theme.textTheme.bodyMedium?.copyWith(
              decoration: _isCompleted ? TextDecoration.lineThrough : null,
              color: _isCompleted ? theme.textTheme.bodyMedium?.color?.withOpacity(0.6) : null,
            ),
          ),
          
          if (widget.step.crossContaminationAlert != null)
            Padding(
               padding: const EdgeInsets.only(top: 8),
               child: Row(
                 children: [
                   Icon(Icons.warning_amber_rounded, color: colorScheme.error, size: 16),
                   const SizedBox(width: 4),
                   Expanded(
                     child: Text(
                       widget.step.crossContaminationAlert!, 
                       style: TextStyle(color: colorScheme.error, fontSize: 10, fontWeight: FontWeight.bold)
                     ),
                   ),
                 ],
               ),
            ),

          const SizedBox(height: 16),
          // Functional Buttons
          SizedBox(
            width: double.infinity,
            child: FilledButton(
               style: FilledButton.styleFrom(
                 backgroundColor: _isCompleted ? Colors.green.withOpacity(0.2) : colorScheme.primary.withOpacity(0.2),
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                 padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8), // Compact
                 visualDensity: VisualDensity.compact,
               ),
               onPressed: () {
                  setState(() {
                    _isCompleted = !_isCompleted;
                  });
               },
               child: Text(
                 _isCompleted ? 'Completed' : 'Mark Complete',
                 style: TextStyle(
                   color: _isCompleted ? Colors.green : colorScheme.primary, 
                   fontSize: 11, 
                   fontWeight: FontWeight.bold
                 ),
               ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMicroAvatar(BuildContext context, FamilyMember member, double size) {
    return Container(
      width: size, 
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: CircleAvatar(
        radius: size / 2,
        backgroundColor: Colors.primaries[member.name.length % Colors.primaries.length], // Deterministic color
        backgroundImage: (member.avatarPath != null && member.avatarPath!.startsWith('http')) 
            ? NetworkImage(member.avatarPath!) 
            : null,
        child: (member.avatarPath == null || !member.avatarPath!.startsWith('http'))
            ? Text(
                member.name.substring(0, 1).toUpperCase(),
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: size * 0.5,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
      ),
    );
  }
}

class SplitLinePainter extends CustomPainter {
  final Color color;
  SplitLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    // Center top
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width / 2, size.height * 0.5);
    
    // Branch Left
    path.moveTo(size.width / 2, size.height * 0.5);
    path.quadraticBezierTo(
      size.width * 0.25, size.height * 0.5, 
      size.width * 0.25, size.height
    );

    // Branch Right
    path.moveTo(size.width / 2, size.height * 0.5);
    path.quadraticBezierTo(
      size.width * 0.75, size.height * 0.5, 
      size.width * 0.75, size.height
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
