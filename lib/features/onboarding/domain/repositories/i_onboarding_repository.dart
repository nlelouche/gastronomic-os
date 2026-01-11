import 'package:gastronomic_os/core/error/failures.dart';

import 'package:gastronomic_os/features/onboarding/domain/entities/family_member.dart';

abstract class IOnboardingRepository {
  Future<(Failure?, void)> saveFamilyConfig({required List<FamilyMember> members});
  Future<(Failure?, bool)> hasCompletedOnboarding();
  Future<(Failure?, void)> resetOnboarding();
  Future<(Failure?, List<FamilyMember>?)> getFamilyMembers();
}
