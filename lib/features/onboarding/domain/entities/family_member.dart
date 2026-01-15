import 'package:equatable/equatable.dart';
import 'package:gastronomic_os/core/enums/diet_enums.dart';
import 'package:gastronomic_os/core/enums/family_role.dart';

class FamilyMember extends Equatable {
  final String id;
  final String name;
  final FamilyRole role;
  final DietLifestyle primaryDiet; 
  final List<MedicalCondition> medicalConditions;
  final String? avatarPath;
  final bool isVerifiedChef;
  final bool isPrimaryCook;

  const FamilyMember({
    required this.id,
    required this.name,
    required this.role,
    this.primaryDiet = DietLifestyle.omnivore,
    this.medicalConditions = const [],
    this.avatarPath,
    this.isVerifiedChef = false,
    this.isPrimaryCook = false,
  });

  FamilyMember copyWith({
    String? name,
    FamilyRole? role,
    DietLifestyle? primaryDiet,
    List<MedicalCondition>? medicalConditions,
    String? avatarPath,
    bool? isVerifiedChef,
    bool? isPrimaryCook,
  }) {
    return FamilyMember(
      id: id,
      name: name ?? this.name,
      role: role ?? this.role,
      primaryDiet: primaryDiet ?? this.primaryDiet,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      avatarPath: avatarPath ?? this.avatarPath,
      isVerifiedChef: isVerifiedChef ?? this.isVerifiedChef,
      isPrimaryCook: isPrimaryCook ?? this.isPrimaryCook,
    );
  }

  @override
  List<Object?> get props => [id, name, role, primaryDiet, medicalConditions, avatarPath, isVerifiedChef, isPrimaryCook];
}
