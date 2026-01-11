import 'package:equatable/equatable.dart';
import 'package:gastronomic_os/features/onboarding/domain/entities/family_member.dart';

abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();
  @override
  List<Object> get props => [];
}

class LoadFamilyMembers extends OnboardingEvent {} // NEW EVENT

class AddFamilyMember extends OnboardingEvent {
  final FamilyMember member;
  const AddFamilyMember(this.member);
  @override
  List<Object> get props => [member];
}

class UpdateFamilyMember extends OnboardingEvent {
  final FamilyMember member;
  const UpdateFamilyMember(this.member);
  @override
  List<Object> get props => [member];
}

class RemoveFamilyMember extends OnboardingEvent {
  final String id;
  const RemoveFamilyMember(this.id);
  @override
  List<Object> get props => [id];
}

class SubmitOnboarding extends OnboardingEvent {}

class ResetOnboarding extends OnboardingEvent {}

abstract class OnboardingState extends Equatable {
  final List<FamilyMember> members;

  const OnboardingState({this.members = const []});
  
  @override
  List<Object> get props => [members];
}

class OnboardingInitial extends OnboardingState {
  const OnboardingInitial();
}

class OnboardingUpdated extends OnboardingState {
  const OnboardingUpdated({super.members});
}

class OnboardingLoading extends OnboardingState {
   const OnboardingLoading({super.members});
}

class OnboardingSuccess extends OnboardingState {
  const OnboardingSuccess({super.members});
}

class OnboardingError extends OnboardingState {
  final String message;
  const OnboardingError(this.message, {super.members});
  @override
  List<Object> get props => [message, members];
}
