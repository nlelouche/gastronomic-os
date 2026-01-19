import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gastronomic_os/core/enums/family_role.dart';
import 'package:gastronomic_os/features/onboarding/domain/entities/family_member.dart';
import 'package:gastronomic_os/features/onboarding/domain/repositories/i_onboarding_repository.dart';

// State
abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final FamilyMember primaryMember;
  final bool isSaving;

  const ProfileLoaded({required this.primaryMember, this.isSaving = false});

  @override
  List<Object?> get props => [primaryMember, isSaving];
  
  ProfileLoaded copyWith({FamilyMember? primaryMember, bool? isSaving}) {
    return ProfileLoaded(
      primaryMember: primaryMember ?? this.primaryMember,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class ProfileCubit extends Cubit<ProfileState> {
  final IOnboardingRepository _repository;

  ProfileCubit(this._repository) : super(ProfileInitial());

  Future<void> loadProfile() async {
    emit(ProfileLoading());

    final result = await _repository.getFamilyMembers();
    result.$1 != null
      ? emit(ProfileError(result.$1!.message))
      : _handleMembersLoaded(result.$2);
  }
  
  void _handleMembersLoaded(List<FamilyMember>? members) {
    if (members == null || members.isEmpty) {
      // Edge Case: No members found? This shouldn't happen for authenticated users who finished onboarding.
      // But if it does, we can handle it or show error.
      emit(const ProfileError("Profile not found. Please complete onboarding."));
      return;
    }

    // Find Primary Cook
    final primary = members.firstWhere(
      (m) => m.isPrimaryCook,
      orElse: () => members.first, // Fallback to first member if no primary marked
    );
    
    emit(ProfileLoaded(primaryMember: primary));
  }

  Future<void> updateBio(String newBio) async {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;
      final updatedMember = currentState.primaryMember.copyWith(bio: newBio);
      
      // Optimistic Update
      emit(currentState.copyWith(primaryMember: updatedMember));
      
      // We don't save on every keystroke, user must click Save.
      // Or we can implement auto-save debounce here. 
      // For V1, we'll adhere to explicit "Save" action usually, 
      // but if the UI calls this on "Save", then we persist.
    }
  }

  Future<void> updateName(String newName) async {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;
      final updatedMember = currentState.primaryMember.copyWith(name: newName);
      emit(currentState.copyWith(primaryMember: updatedMember));
    }
  }

  Future<void> saveProfile() async {
    if (state is! ProfileLoaded) return;
    final currentState = state as ProfileLoaded;

    emit(currentState.copyWith(isSaving: true));

    final result = await _repository.updateFamilyMember(currentState.primaryMember);

    result.$1 != null
        ? emit(ProfileError(result.$1!.message))
        : emit(currentState.copyWith(isSaving: false));
  }

  Future<void> uploadAvatar(String path) async {
    if (state is! ProfileLoaded) return;
    final currentState = state as ProfileLoaded;

    emit(currentState.copyWith(isSaving: true));

    final result = await _repository.uploadAvatar(path);

    if (result.$1 != null) {
      emit(ProfileError(result.$1!.message));
      // Revert to loaded state gracefully?
      emit(currentState.copyWith(isSaving: false)); 
    } else {
      // Success: Update local state with new URL
      final updatedMember = currentState.primaryMember.copyWith(avatarPath: result.$2);
      emit(currentState.copyWith(primaryMember: updatedMember, isSaving: false));
      // Trigger save immediately or wait? 
      // Usually upload is independent, but we need to SAVE the profile config with the new URL?
      // Wait, upload just gives URL. We need to persist it in the Member record database.
      // So we should call updateFamilyMember as well.
      // BUT `uploadAvatar` returns the URL. `updateFamilyMember` saves the full object.
      // We should probably chain them.
      await _repository.updateFamilyMember(updatedMember); 
    }
  }
}
