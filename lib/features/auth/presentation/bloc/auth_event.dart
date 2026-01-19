import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthSignInAnonymously extends AuthEvent {}

class AuthSignInGoogle extends AuthEvent {}

class AuthLinkGoogle extends AuthEvent {}

class AuthSignOut extends AuthEvent {}
