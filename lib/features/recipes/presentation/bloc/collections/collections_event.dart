import 'package:equatable/equatable.dart';

abstract class CollectionsEvent extends Equatable {
  const CollectionsEvent();

  @override
  List<Object> get props => [];
}

class LoadCollections extends CollectionsEvent {}

class CreateCollectionEvent extends CollectionsEvent {
  final String name;

  const CreateCollectionEvent(this.name);

  @override
  List<Object> get props => [name];
}

class AddRecipeToCollectionEvent extends CollectionsEvent {
  final String recipeId;
  final String collectionId;

  const AddRecipeToCollectionEvent({required this.recipeId, required this.collectionId});

  @override
  List<Object> get props => [recipeId, collectionId];
}

class RemoveRecipeFromCollectionEvent extends CollectionsEvent {
  final String recipeId;
  final String collectionId;

  const RemoveRecipeFromCollectionEvent({required this.recipeId, required this.collectionId});

  @override
  List<Object> get props => [recipeId, collectionId];
}

class DeleteCollectionEvent extends CollectionsEvent {
  final String collectionId;

  const DeleteCollectionEvent(this.collectionId);

  @override
  List<Object> get props => [collectionId];
}
