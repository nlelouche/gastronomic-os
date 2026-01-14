import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gastronomic_os/core/util/app_logger.dart';
import 'package:gastronomic_os/features/recipes/domain/usecases/manage_collections.dart';
import 'collections_event.dart';
import 'collections_state.dart';

class CollectionsBloc extends Bloc<CollectionsEvent, CollectionsState> {
  final GetUserCollections getUserCollections;
  final CreateCollection createCollection;
  final AddToCollection addToCollection;
  final RemoveFromCollection removeFromCollection;
  final DeleteCollection deleteCollection;

  CollectionsBloc({
    required this.getUserCollections,
    required this.createCollection,
    required this.addToCollection,
    required this.removeFromCollection,
    required this.deleteCollection,
  }) : super(CollectionsInitial()) {
    on<LoadCollections>(_onLoadCollections);
    on<CreateCollectionEvent>(_onCreateCollection);
    on<AddRecipeToCollectionEvent>(_onAddRecipeToCollection);
    on<RemoveRecipeFromCollectionEvent>(_onRemoveRecipeFromCollection);
    on<DeleteCollectionEvent>(_onDeleteCollection);
  }

  Future<void> _onLoadCollections(LoadCollections event, Emitter<CollectionsState> emit) async {
    emit(CollectionsLoading());
    final (failure, collections) = await getUserCollections();
    if (failure != null) {
      emit(CollectionsError(failure.message));
    } else {
      emit(CollectionsLoaded(collections ?? []));
    }
  }

  Future<void> _onCreateCollection(CreateCollectionEvent event, Emitter<CollectionsState> emit) async {
    final (failure, _) = await createCollection(event.name);
    if (failure != null) {
      emit(CollectionsError(failure.message));
    } else {
      add(LoadCollections()); // Reload
      emit(const CollectionActionSuccess('Collection created'));
    }
  }

  Future<void> _onAddRecipeToCollection(AddRecipeToCollectionEvent event, Emitter<CollectionsState> emit) async {
    final (failure, _) = await addToCollection(event.recipeId, event.collectionId);
    if (failure != null) {
      emit(CollectionsError(failure.message));
    } else {
      add(LoadCollections());
      emit(const CollectionActionSuccess('Recipe added to collection'));
    }
  }

  Future<void> _onRemoveRecipeFromCollection(RemoveRecipeFromCollectionEvent event, Emitter<CollectionsState> emit) async {
    final (failure, _) = await removeFromCollection(event.recipeId, event.collectionId);
    if (failure != null) {
      emit(CollectionsError(failure.message));
    } else {
      add(LoadCollections());
      emit(const CollectionActionSuccess('Recipe removed from collection'));
    }
  }

  Future<void> _onDeleteCollection(DeleteCollectionEvent event, Emitter<CollectionsState> emit) async {
     final (failure, _) = await deleteCollection(event.collectionId);
    if (failure != null) {
      emit(CollectionsError(failure.message));
    } else {
      add(LoadCollections());
      emit(const CollectionActionSuccess('Collection deleted'));
    }
  }
}
