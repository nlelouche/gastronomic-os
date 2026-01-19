import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gastronomic_os/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:gastronomic_os/features/auth/presentation/bloc/auth_event.dart';
import 'package:gastronomic_os/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final IAuthRepository _authRepository;
  StreamSubscription? _authSubscription;

  AuthBloc({required IAuthRepository authRepository}) 
      : _authRepository = authRepository, 
        super(AuthInitial()) {
    
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignInAnonymously>(_onSignInAnonymously);
    on<AuthSignInGoogle>(_onSignInGoogle);
    on<AuthLinkGoogle>(_onLinkGoogle);
    on<AuthSignOut>(_onSignOut);

    // Listen to stream for external changes (like session expiration)
    _authSubscription = _authRepository.authStateChanges.listen((data) {
       // We can dispatch CheckRequested or handle directly. 
       // For robust sync, we'll re-check state on changes.
       // add(AuthCheckRequested()); 
       // Careful of loops.
    });
  }

  Future<void> _onAuthCheckRequested(AuthCheckRequested event, Emitter<AuthState> emit) async {
    final user = _authRepository.currentUser;
    if (user != null) {
      if (_authRepository.isGuest) {
        emit(AuthGuest(user));
      } else {
        emit(AuthAuthenticated(user));
      }
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onSignInAnonymously(AuthSignInAnonymously event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _authRepository.signInAnonymously();
    result.$1 != null 
        ? emit(AuthError(result.$1!.message)) 
        : add(AuthCheckRequested());
  }

  Future<void> _onSignInGoogle(AuthSignInGoogle event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _authRepository.signInWithGoogle();
     result.$1 != null 
        ? emit(AuthError(result.$1!.message)) 
        : add(AuthCheckRequested());
  }

  Future<void> _onSignOut(AuthSignOut event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await _authRepository.signOut();
    emit(AuthUnauthenticated());
  }

  Future<void> _onLinkGoogle(AuthLinkGoogle event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _authRepository.linkGoogleIdentity();
    result.$1 != null 
        ? emit(AuthError(result.$1!.message)) 
        : add(AuthCheckRequested());
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
