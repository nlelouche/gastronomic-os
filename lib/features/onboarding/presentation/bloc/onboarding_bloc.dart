import 'package:bloc/bloc.dart';
import 'package:gastronomic_os/features/onboarding/domain/entities/family_member.dart';
import 'package:gastronomic_os/features/onboarding/domain/repositories/i_onboarding_repository.dart';
import 'package:gastronomic_os/features/onboarding/presentation/bloc/onboarding_state_event.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final IOnboardingRepository repository;

  OnboardingBloc({required this.repository}) : super(OnboardingInitial()) {
    on<LoadFamilyMembers>((event, emit) async {
      emit(OnboardingLoading(members: state.members));
      final result = await repository.getFamilyMembers();
      
      if (result.$1 != null) {
        emit(OnboardingError(result.$1!.message, members: state.members));
      } else {
        emit(OnboardingUpdated(members: result.$2 ?? []));
      }
    });

    on<AddFamilyMember>((event, emit) {
      final updatedMembers = List<FamilyMember>.from(state.members)..add(event.member);
      emit(OnboardingUpdated(members: updatedMembers));
    });

    on<UpdateFamilyMember>((event, emit) {
      final updatedMembers = state.members.map((m) {
        return m.id == event.member.id ? event.member : m;
      }).toList();
      emit(OnboardingUpdated(members: updatedMembers));
    });

    on<RemoveFamilyMember>((event, emit) {
      final updatedMembers = state.members.where((m) => m.id != event.id).toList();
      emit(OnboardingUpdated(members: updatedMembers));
    });



    on<SetPrimaryCookEvent>((event, emit) async {
       emit(OnboardingLoading(members: state.members));
       final result = await repository.setPrimaryCook(event.memberId);
       
       if (result.$1 != null) {
         emit(OnboardingError(result.$1!.message, members: state.members));
       } else {
         add(LoadFamilyMembers()); 
       }
    });

    on<SubmitOnboarding>((event, emit) async {
      emit(OnboardingLoading(members: state.members));
      final result = await repository.saveFamilyConfig(members: state.members);
      
      if (result.$1 != null) {
        emit(OnboardingError(result.$1!.message, members: state.members));
      } else {
        emit(OnboardingSuccess(members: state.members));
      }
    });

    on<ResetOnboarding>((event, emit) async {
      emit(OnboardingLoading(members: state.members));
      final result = await repository.resetOnboarding();
      if (result.$1 != null) {
        emit(OnboardingError(result.$1!.message, members: state.members));
      } else {
        emit(const OnboardingInitial());
      }
    });
  } // Close Constructor
} // Close Class
