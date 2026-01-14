import 'package:equatable/equatable.dart';
import 'package:gastronomic_os/features/onboarding/domain/entities/family_member.dart';

/// Represents a resolved step in a recipe for a specific group of family members.
/// After resolution, branch points are transformed into linear instructions
/// with clear indication of who should follow each step.
class ResolvedStep extends Equatable {
  final int index;
  final String instruction;
  final List<FamilyMember> targetMembers; // Full Member objects for Avatar display
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
    
    final names = targetMembers.map((m) => m.name).toList();
    
    if (names.length == 1) {
      return 'For ${names[0]}';
    }
    
    if (names.length == 2) {
      return 'For ${names[0]} and ${names[1]}';
    }
    
    // For 3+ members: "For Juan, María and Pedro"
    final allButLast = names.sublist(0, names.length - 1).join(', ');
    final last = names.last;
    return 'For $allButLast and $last';
  }
  
  @override
  List<Object?> get props => [index, instruction, targetMembers, isUniversal, crossContaminationAlert, substitutionReason];
}
