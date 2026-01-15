part of 'social_bloc.dart';

abstract class SocialState extends Equatable {
  const SocialState();
  
  @override
  List<Object> get props => [];
}

class SocialInitial extends SocialState {}

class SocialLoading extends SocialState {}

class SocialLoaded extends SocialState {
  final List<SocialFeedItem> items;
  final bool hasReachedMax;

  const SocialLoaded({
    required this.items,
    this.hasReachedMax = false,
  });

  @override
  List<Object> get props => [items, hasReachedMax];
}

class SocialError extends SocialState {
  final String message;

  const SocialError(this.message);

  @override
  List<Object> get props => [message];
}
