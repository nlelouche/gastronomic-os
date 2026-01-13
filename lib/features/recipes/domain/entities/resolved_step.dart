import 'package:equatable/equatable.dart';

/// Represents a resolved step in a recipe for a specific group of family members.
/// After resolution, branch points are transformed into linear instructions
/// with clear indication of who should follow each step.
class ResolvedStep extends Equatable {
  final int index;
  final String instruction;
  final List<String> targetMembers; // Names of family members this step applies to
  final bool isUniversal; // True if applies to everyone
  final String? crossContaminationAlert;
  final String? substitutionReason; // e.g., "Keto", "Celiac"
  
  const ResolvedStep({
    required this.index,
    required this.instruction,
    required this.targetMembers,
    this.isUniversal = false,
    this.crossContaminationAlert,
    this.substitutionReason,
  });

  /// Formatted string for display: "For Juan, María and Pedro"
  String get targetGroupLabel {
    if (isUniversal || targetMembers.isEmpty) {
      return 'For Everyone';
    }
    
    if (targetMembers.length == 1) {
      return 'For ${targetMembers[0]}';
    }
    
    if (targetMembers.length == 2) {
      return 'For ${targetMembers[0]} and ${targetMembers[1]}';
    }
    
    // For 3+ members: "For Juan, María and Pedro"
    final allButLast = targetMembers.sublist(0, targetMembers.length - 1).join(', ');
    final last = targetMembers.last;
    return 'For $allButLast and $last';
  }
  
  @override
  List<Object?> get props => [index, instruction, targetMembers, isUniversal, crossContaminationAlert, substitutionReason];
}
