import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gastronomic_os/core/error/failures.dart';

abstract class IAuthRepository {
  /// Stream of user state changes (Signed In, Signed Out, etc.)
  Stream<AuthState> get authStateChanges;

  /// Returns the current user (if any)
  User? get currentUser;
  
  /// Returns existing session
  Session? get currentSession;

  /// Checks if the current user is an anonymous guest
  bool get isGuest;

  /// Sign In Anonymously (Guest Mode)
  Future<(Failure?, User?)> signInAnonymously();

  /// Sign In with Google (returns User on success)
  Future<(Failure?, User?)> signInWithGoogle();
  
  /// Sign In with Apple
  Future<(Failure?, User?)> signInWithApple();

  /// Sign Out
  Future<(Failure?, void)> signOut();

  /// Link Google Identity to current Guest User (Upgrade Account)
  Future<(Failure?, User?)> linkGoogleIdentity();
}
