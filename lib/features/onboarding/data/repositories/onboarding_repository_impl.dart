import 'package:gastronomic_os/core/error/failures.dart';
import 'package:gastronomic_os/features/onboarding/data/datasources/onboarding_remote_datasource.dart';
import 'package:gastronomic_os/features/onboarding/domain/repositories/i_onboarding_repository.dart';
import 'package:gastronomic_os/features/onboarding/domain/entities/family_member.dart';

class OnboardingRepositoryImpl implements IOnboardingRepository {
  final OnboardingRemoteDataSource remoteDataSource;

  OnboardingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<(Failure?, void)> saveFamilyConfig({required List<FamilyMember> members}) async {
    try {
      final config = {
        'members': members.map((m) => m.toJson()).toList(),
        'onboarding_completed': true,
      };
      await remoteDataSource.updateProfileConfig(config);
      return (null, null);
    } catch (e) {
      return (const ServerFailure(), null);
    }
  }

  @override
  Future<(Failure?, bool)> hasCompletedOnboarding() async {
    try {
      final config = await remoteDataSource.getProfileConfig();
      if (config != null && config['onboarding_completed'] == true) {
        return (null, true);
      }
      return (null, false);
    } catch (e) {
      // If error, assume false to be safe
      return (null, false);
    }
  }

  @override
  Future<(Failure?, void)> resetOnboarding() async {
    try {
      await remoteDataSource.resetProfileConfig();
      return (null, null);
    } catch (e) {
      return (const ServerFailure(), null);
    }
  }
}
