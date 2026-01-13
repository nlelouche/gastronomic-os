import 'package:equatable/equatable.dart';
import 'package:gastronomic_os/core/enums/diet_enums.dart';

class FamilyMember extends Equatable {
  final String id;
  final String name;
  final String role; // 'Dad', 'Mom', 'Son', 'Daughter', 'Roommate', etc.
  final DietLifestyle primaryDiet; 
  final List<MedicalCondition> medicalConditions;

  const FamilyMember({
    required this.id,
    required this.name,
    required this.role,
    this.primaryDiet = DietLifestyle.omnivore,
    this.medicalConditions = const [],
  });

  FamilyMember copyWith({
    String? name,
    String? role,
    DietLifestyle? primaryDiet,
    List<MedicalCondition>? medicalConditions,
  }) {
    return FamilyMember(
      id: id,
      name: name ?? this.name,
      role: role ?? this.role,
      primaryDiet: primaryDiet ?? this.primaryDiet,
      medicalConditions: medicalConditions ?? this.medicalConditions,
    );
  }

  // toJson is moved to Model ideally, but Entity had it. We can keep a basic one or deprecate.
  // Ideally, Clean Architecture prefers Models to handle Json.
  // Removing Entity.toJson to force Model usage is aggressive but correct.
  // However, for safety in this refactor step, I will leave it assuming simple usage,
  // but better to rely on Model. Let's start by modifying the props.

  @override
  List<Object> get props => [id, name, role, primaryDiet, medicalConditions];
}
