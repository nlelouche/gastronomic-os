import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gastronomic_os/core/error/failures.dart';
import 'package:gastronomic_os/core/error/exception_handler.dart';
import 'package:gastronomic_os/core/error/error_context.dart';
import 'package:gastronomic_os/core/error/error_reporter.dart';
import 'package:gastronomic_os/features/auth/domain/repositories/i_auth_repository.dart';

import 'package:gastronomic_os/core/config/feature_flags.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final SupabaseClient supabase;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // scopes: ['email', 'profile'], // Add scopes if needed later
    // serverClientId: 'YOUR_SERVER_CLIENT_ID', // If needed for Android backend verification
  );

  AuthRepositoryImpl({required this.supabase});

  @override
  Stream<AuthState> get authStateChanges => supabase.auth.onAuthStateChange;

  @override
  User? get currentUser => supabase.auth.currentUser;
  
  @override
  Session? get currentSession => supabase.auth.currentSession;

  @override
  bool get isGuest => currentUser?.isAnonymous ?? true;

  @override
  Future<(Failure?, User?)> signInAnonymously() async {
    try {
      final response = await supabase.auth.signInAnonymously();
      return (null, response.user);
    } catch (e, stackTrace) {
      final failure = ExceptionHandler.handle(
        e, 
        stackTrace: stackTrace,
        context: ErrorContext.repository('signInAnonymously')
      );
      await ErrorReporter.instance.reportError(failure);
      return (failure, null);
    }
  }

  @override
  Future<(Failure?, User?)> signInWithGoogle() async {
    if (!FeatureFlags.useGoogleAuth) {
       return (AuthFailure('Google Auth is disabled', context: ErrorContext.repository('signInWithGoogle')), null);
    }
    try {
      // 1. Native Sign In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User canceled
        return (null, null); // Or specific Failure("Canceled")
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null) {
         return (AuthFailure('Google Access Token is null', context: ErrorContext.repository('signInWithGoogle')), null);
      }
      if (idToken == null) {
         return (AuthFailure('Google ID Token is null', context: ErrorContext.repository('signInWithGoogle')), null);
      }

      // 2. Supabase Sign In
      final response = await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      return (null, response.user);
    } catch (e, stackTrace) {
      final failure = ExceptionHandler.handle(
        e, 
        stackTrace: stackTrace,
        context: ErrorContext.repository('signInWithGoogle')
      );
      await ErrorReporter.instance.reportError(failure);
      return (failure, null);
    }
  }

  @override
  Future<(Failure?, User?)> signInWithApple() async {
    // TODO: Implement Apple Sign In using sign_in_with_apple package
    // For now returning error as placeholder
    return (AuthFailure('Apple Sign In not implemented yet', context: ErrorContext.repository('signInWithApple')), null);
  }

  @override
  Future<(Failure?, void)> signOut() async {
    try {
      await _googleSignIn.signOut(); // Ensure native session is killed too
      await supabase.auth.signOut();
      return (null, null);
    } catch (e, stackTrace) {
      final failure = ExceptionHandler.handle(
        e, 
        stackTrace: stackTrace,
        context: ErrorContext.repository('signOut')
      );
      return (failure, null);
    }
  }

  @override
  Future<(Failure?, User?)> linkGoogleIdentity() async {
    if (!FeatureFlags.useGoogleAuth) {
       return (AuthFailure('Google Auth is disabled', context: ErrorContext.repository('linkGoogleIdentity')), null);
    }
     try {
      // 1. Native Sign In to get credentials
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User canceled
        return (null, null);
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;
      
      if (accessToken == null) {
         return (AuthFailure('Google Access Token is null', context: ErrorContext.repository('linkGoogleIdentity')), null);
      }
      if (idToken == null) {
         return (AuthFailure('Google ID Token is null', context: ErrorContext.repository('linkGoogleIdentity')), null);
      }

      // 2. Link Identity via signInWithIdToken
      // In Supabase, signing in with an OAuth provider while authenticated attempts to link the identity.
      final response = await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
      
      // Check if we stayed as the same user (Linked) or switched (Login)
      // Ideally we want to ensure we linked. 
      // If response.user.id == currentUser.id, it was a link.
      
      return (null, response.user);
    } catch (e, stackTrace) {
       final failure = ExceptionHandler.handle(
         e, 
         stackTrace: stackTrace, 
         context: ErrorContext.repository('linkGoogleIdentity')
       );
       await ErrorReporter.instance.reportError(failure);
       return (failure, null);
    }
  }
}
