part of 'social_bloc.dart';

abstract class SocialEvent extends Equatable {
  const SocialEvent();

  @override
  List<Object> get props => [];
}

class LoadFeed extends SocialEvent {
  final bool refresh;

  const LoadFeed({this.refresh = false});
}

class ToggleLikeEvent extends SocialEvent {
  final String recipeId;

  const ToggleLikeEvent(this.recipeId);

  @override
  List<Object> get props => [recipeId];
}
