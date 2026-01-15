import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gastronomic_os/core/error/failures.dart';
import 'package:gastronomic_os/features/social/domain/entities/social_feed_item.dart';
import 'package:gastronomic_os/features/social/domain/usecases/get_public_feed.dart';
import 'package:gastronomic_os/features/social/domain/usecases/toggle_like.dart';

part 'social_event.dart';
part 'social_state.dart';

class SocialBloc extends Bloc<SocialEvent, SocialState> {
  final GetPublicFeed getPublicFeed;
  final ToggleLike toggleLike;
  
  static const int _limit = 10;

  SocialBloc({
    required this.getPublicFeed,
    required this.toggleLike,
  }) : super(SocialInitial()) {
    on<LoadFeed>(_onLoadFeed);
    on<ToggleLikeEvent>(_onToggleLike);
  }

  Future<void> _onLoadFeed(LoadFeed event, Emitter<SocialState> emit) async {
    if (state is SocialLoading) return;
    
    final currentState = state;
    var currentItems = <SocialFeedItem>[];
    
    if (currentState is SocialLoaded) {
      if (currentState.hasReachedMax && !event.refresh) return;
      currentItems = event.refresh ? [] : currentState.items;
    } else {
      emit(SocialLoading());
    }

    final offset = event.refresh ? 0 : currentItems.length;

    final (failure, newItems) = await getPublicFeed(GetPublicFeedParams(
      limit: _limit,
      offset: offset,
    ));

    if (failure != null) {
      emit(SocialError(failure.message));
    } else {
      var items = newItems ?? [];
      final hasReachedMax = items.length < _limit;
      
      emit(SocialLoaded(
        items: event.refresh ? items : currentItems + items,
        hasReachedMax: hasReachedMax,
      ));
    }
  }

  Future<void> _onToggleLike(ToggleLikeEvent event, Emitter<SocialState> emit) async {
    // Optimistic Update can be implemented here by modifying the state immediately
    // For now, we just call the API and let the UI stay as is or refresh specific item if we had a way.
    // Better: Update the specific item in the list with +1/-1 and isLiked status.
    
    if (state is SocialLoaded) {
      final loadedState = state as SocialLoaded;
      final index = loadedState.items.indexWhere((i) => i.recipeId == event.recipeId);
      
      if (index != -1) {
        final item = loadedState.items[index];
        final wasLiked = item.isLikedByMe; // We need to assume/track this. Currently API doesn't return it perfectly yet.
        
        // Optimistic toggle
        // Note: Since 'isLikedByMe' isn't fully wired in backend View for "my like", 
        // we might just animate the heart locally. 
        // But let's verify if we can update the list.
        
        // Since FeedItem is immutable, create new list.
        // We actually need to know the CURRENT state to toggle.
        // For MVP, just fire and forget, and maybe re-fetch or let local widget handle state?
        // Let's implement Optimistic update assuming we can track it.
        
        // For now, simple call.
        await toggleLike(event.recipeId);
        
        // To reflect change, we SHOULD update the item.
        // But without knowing if we liked it or unliked it (current state), we risk desync.
        // Best approach for MVP: Local State in Widget handles the animation, 
        // Bloc handles the persistent call.
      }
    }
  }
}
