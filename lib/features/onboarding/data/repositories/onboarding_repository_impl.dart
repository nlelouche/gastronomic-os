import 'package:gastronomic_os/core/error/failures.dart';
import 'package:gastronomic_os/core/error/error_context.dart';
import 'package:gastronomic_os/core/error/exception_handler.dart';
import 'package:gastronomic_os/core/error/error_reporter.dart';
import 'package:gastronomic_os/features/onboarding/data/datasources/onboarding_remote_datasource.dart';
import 'package:gastronomic_os/features/onboarding/domain/repositories/i_onboarding_repository.dart';
import 'package:gastronomic_os/features/onboarding/domain/entities/family_member.dart';
import 'package:gastronomic_os/core/enums/diet_enums.dart';
import 'package:gastronomic_os/core/enums/family_role.dart';
import 'package:uuid/uuid.dart';

class OnboardingRepositoryImpl implements IOnboardingRepository {
  final OnboardingRemoteDataSource remoteDataSource;

  OnboardingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<(Failure?, void)> saveFamilyConfig({required List<FamilyMember> members}) async {
    try {
      // 1. Prepare Data for Table
      final membersData = members.map((m) {
        // Sanitize ID: If it's a timestamp (legacy bug), generate a new UUID
        String validId = m.id;
        try {
          Uuid.parse(validId);
        } catch (_) {
           // Not a valid UUID (likely a timestamp from previous bug)
           // If it contains "T" and digits, it's definitely the timestamp.
           // Safe fallback: Generate new UUID.
           validId = const Uuid().v4();
        }

        return {
          'id': validId,
          'name': m.name,
          'role': m.role.name,
          'primary_diet': _dietEnumToString(m.primaryDiet),
          'medical_conditions': m.medicalConditions.map((e) => _conditionEnumToString(e)).toList(),
          'avatar_path': m.avatarPath,
          'is_verified_chef': m.isVerifiedChef,
          'is_primary_cook': m.isPrimaryCook,
        };
      }).toList();

      // 2. Sync to Table (Source of Truth)
      await remoteDataSource.syncFamilyMembers(membersData);

      // 3. Keep Legacy JSON in sync (Optional but safer for now)
      final config = {
        'members': membersData,
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
  Future<(Failure?, void)> setPrimaryCook(String memberId) async {
    try {
      await remoteDataSource.setPrimaryCook(memberId);
      return (null, null);
    } catch (e, stackTrace) {
      final failure = ExceptionHandler.handle(
        e,
        stackTrace: stackTrace,
        context: ErrorContext.repository('setPrimaryCook'),
      );
      await ErrorReporter.instance.reportError(failure);
      return (failure, null);
    }
  }

  @override
  Future<(Failure?, List<FamilyMember>?)> getFamilyMembers() async {
    try {
      // 1. Try Table Source (Source of Truth for Social/Primary)
      final tableMembers = await remoteDataSource.getFamilyMembersFromTable();
      if (tableMembers.isNotEmpty) {
        final members = tableMembers.map((m) => FamilyMember(
          id: m['id'] ?? '',
          name: m['name'] ?? '',
          role: _stringToRoleEnum(m['role']),
          primaryDiet: _stringToDietEnum(m['primary_diet']),
          medicalConditions: (m['medical_conditions'] as List?)
              ?.map((e) => _stringToMedicalEnum(e.toString()))
              .whereType<MedicalCondition>()
              .toList() ?? [],
          avatarPath: m['avatar_path'],
          isVerifiedChef: m['is_verified_chef'] ?? false,
          isPrimaryCook: m['is_primary_cook'] ?? false,
        )).toList();
        
        // Sort: Primary Cook first
        members.sort((a, b) => (b.isPrimaryCook ? 1 : 0) - (a.isPrimaryCook ? 1 : 0));
        
        return (null, members);
      }

      // 2. Fallback to JSON Profile Config (Legacy)
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
          avatarPath: m['avatar_path'],
          // Default false for legacy
          isVerifiedChef: false,
          isPrimaryCook: false,
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
      case DietLifestyle.kosher: return 'kosher';
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
      case MedicalCondition.hypertension: return 'hypertension';
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
