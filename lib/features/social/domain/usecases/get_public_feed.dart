import 'package:gastronomic_os/core/error/failures.dart';
import 'package:gastronomic_os/core/usecases/usecase.dart';
import 'package:gastronomic_os/features/recipes/domain/repositories/i_recipe_repository.dart';
import 'package:gastronomic_os/features/social/domain/entities/social_feed_item.dart';

class GetPublicFeed implements Usecase<List<SocialFeedItem>, GetPublicFeedParams> {
  final IRecipeRepository repository;

  GetPublicFeed(this.repository);

  @override
  Future<(Failure?, List<SocialFeedItem>?)> call(GetPublicFeedParams params) async {
    return await repository.getPublicFeed(limit: params.limit, offset: params.offset);
  }
}

class GetPublicFeedParams {
  final int limit;
  final int offset;

  const GetPublicFeedParams({this.limit = 10, this.offset = 0});
}
