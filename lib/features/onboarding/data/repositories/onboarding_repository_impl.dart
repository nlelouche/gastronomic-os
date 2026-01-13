import 'package:gastronomic_os/core/error/failures.dart';
import 'package:gastronomic_os/core/error/error_context.dart';
import 'package:gastronomic_os/core/error/exception_handler.dart';
import 'package:gastronomic_os/core/error/error_reporter.dart';
import 'package:gastronomic_os/features/onboarding/data/datasources/onboarding_remote_datasource.dart';
import 'package:gastronomic_os/features/onboarding/domain/repositories/i_onboarding_repository.dart';
import 'package:gastronomic_os/features/onboarding/domain/entities/family_member.dart';
import 'package:gastronomic_os/core/enums/diet_enums.dart';
import 'package:gastronomic_os/core/enums/family_role.dart';

class OnboardingRepositoryImpl implements IOnboardingRepository {
  final OnboardingRemoteDataSource remoteDataSource;

  OnboardingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<(Failure?, void)> saveFamilyConfig({required List<FamilyMember> members}) async {
    try {
      final config = {
        'members': members.map((m) => {
          'id': m.id,
          'name': m.name,
          'role': m.role.name,
          'primary_diet': _dietEnumToString(m.primaryDiet),
          'medical_conditions': m.medicalConditions.map((e) => _conditionEnumToString(e)).toList(),
        }).toList(),
        'onboarding_completed': true,
      };
      await remoteDataSource.updateProfileConfig(config);
      return (null, null);
    } catch (e, stackTrace) {
      final failure = ExceptionHandler.handle(
        e,
        stackTrace: stackTrace,
        context: ErrorContext.repository('saveFamilyConfig', extra: {
          'memberCount': members.length,
        }),
      );
      await ErrorReporter.instance.reportError(failure);
      return (failure, null);
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
      // If error, assume false to be safe (non-critical)
      return (null, false);
    }
  }

  @override
  Future<(Failure?, void)> resetOnboarding() async {
    try {
      await remoteDataSource.resetProfileConfig();
      return (null, null);
    } catch (e, stackTrace) {
      final failure = ExceptionHandler.handle(
        e,
        stackTrace: stackTrace,
        context: ErrorContext.repository('resetOnboarding'),
      );
      await ErrorReporter.instance.reportError(failure);
      return (failure, null);
    }
  }

  @override
  Future<(Failure?, List<FamilyMember>?)> getFamilyMembers() async {
    try {
      final config = await remoteDataSource.getProfileConfig();
      if (config != null && config['members'] != null) {
        final membersList = config['members'] as List;
        final members = membersList.map((m) => FamilyMember(
          id: m['id'] ?? '',
          name: m['name'] ?? '',
          role: _stringToRoleEnum(m['role']),
          primaryDiet: _stringToDietEnum(m['primary_diet']),
          medicalConditions: (m['medical_conditions'] as List?)
              ?.map((e) => _stringToMedicalEnum(e.toString()))
              .whereType<MedicalCondition>()
              .toList() ?? [],
        )).toList();
        return (null, members);
      }
      return (null, <FamilyMember>[]);
    } catch (e, stackTrace) {
      final failure = ExceptionHandler.handle(
        e,
        stackTrace: stackTrace,
        context: ErrorContext.repository('getFamilyMembers'),
      );
      await ErrorReporter.instance.reportError(failure);
      return (failure, null);
    }
  }

  // --- Helper Methods ---

  FamilyRole _stringToRoleEnum(String? value) {
    if (value == null) return FamilyRole.other;
    
    try {
      return FamilyRole.values.firstWhere((e) => e.name.toLowerCase() == value.toLowerCase());
    } catch (_) {
      switch (value) {
        case 'Dad': return FamilyRole.dad;
        case 'Mom': return FamilyRole.mom;
        case 'Son': return FamilyRole.son;
        case 'Daughter': return FamilyRole.daughter;
        case 'Grandparent': return FamilyRole.grandparent;
        case 'Roommate': return FamilyRole.roommate;
        default: return FamilyRole.other;
      }
    }
  }

  String _dietEnumToString(DietLifestyle diet) {
    switch (diet) {
      case DietLifestyle.omnivore: return 'omnivore';
      case DietLifestyle.vegetarian: return 'vegetarian';
      case DietLifestyle.vegan: return 'vegan';
      case DietLifestyle.pescatarian: return 'pescatarian';
      case DietLifestyle.keto: return 'keto';
      case DietLifestyle.paleo: return 'paleo';
      case DietLifestyle.whole30: return 'whole30';
      case DietLifestyle.mediterranean: return 'mediterranean';
      case DietLifestyle.highPerformance: return 'high_performance';
      case DietLifestyle.lowCarb: return 'low_carb';
    }
  }

  DietLifestyle _stringToDietEnum(String? value) {
    switch (value) {
      case 'omnivore': return DietLifestyle.omnivore;
      case 'vegetarian': return DietLifestyle.vegetarian;
      case 'vegan': return DietLifestyle.vegan;
      case 'pescatarian': return DietLifestyle.pescatarian;
      case 'keto': return DietLifestyle.keto;
      case 'paleo': return DietLifestyle.paleo;
      case 'whole30': return DietLifestyle.whole30;
      case 'mediterranean': return DietLifestyle.mediterranean;
      case 'high_performance': return DietLifestyle.highPerformance;
      case 'low_carb': return DietLifestyle.lowCarb;
      default: return DietLifestyle.omnivore;
    }
  }

  String _conditionEnumToString(MedicalCondition condition) {
    switch (condition) {
      case MedicalCondition.aplv: return 'aplv';
      case MedicalCondition.eggAllergy: return 'egg_allergy';
      case MedicalCondition.soyAllergy: return 'soy_allergy';
      case MedicalCondition.nutAllergy: return 'nut_allergy';
      case MedicalCondition.shellfishAllergy: return 'shellfish_allergy';
      case MedicalCondition.celiac: return 'celiac';
      case MedicalCondition.lowFodmap: return 'low_fodmap';
      case MedicalCondition.histamine: return 'histamine';
      case MedicalCondition.diabetes: return 'diabetes';
      case MedicalCondition.renal: return 'renal';
    }
  }

  MedicalCondition? _stringToMedicalEnum(String value) {
    switch (value) {
      case 'aplv': return MedicalCondition.aplv;
      case 'egg_allergy': return MedicalCondition.eggAllergy;
      case 'soy_allergy': return MedicalCondition.soyAllergy;
      case 'nut_allergy': return MedicalCondition.nutAllergy;
      case 'shellfish_allergy': return MedicalCondition.shellfishAllergy;
      case 'celiac': return MedicalCondition.celiac;
      case 'low_fodmap': return MedicalCondition.lowFodmap;
      case 'histamine': return MedicalCondition.histamine;
      case 'diabetes': return MedicalCondition.diabetes;
      case 'renal': return MedicalCondition.renal;
      default: return null;
    }
  }
}
