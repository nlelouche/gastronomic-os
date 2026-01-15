import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gastronomic_os/core/theme/app_dimens.dart';
import 'package:gastronomic_os/features/social/presentation/bloc/social_bloc.dart';
import 'package:gastronomic_os/features/social/presentation/widgets/feed_recipe_card.dart';
import 'package:gastronomic_os/init/injection_container.dart';
import 'package:gastronomic_os/core/services/remote_config_service.dart';
import 'package:gastronomic_os/core/widgets/banner_ad_widget.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<SocialBloc>()..add(const LoadFeed()),
      child: const FeedView(),
    );
  }
}

class FeedView extends StatefulWidget {
  const FeedView({super.key});

  @override
  State<FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<SocialBloc>().add(const LoadFeed());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Feed'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Search TODO
            },
          )
        ],
      ),
      body: BlocBuilder<SocialBloc, SocialState>(
        builder: (context, state) {
          if (state is SocialLoading && (state is! SocialLoaded)) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is SocialError) {
            return Center(child: Text('Failed to load feed: ${state.message}'));
          }
          if (state is SocialLoaded) {
            if (state.items.isEmpty) {
              return const Center(child: Text('No recipes yet. Be the first to share!'));
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<SocialBloc>().add(const LoadFeed(refresh: true));
              },
              child: ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.all(AppDimens.spaceS),
                itemCount: state.hasReachedMax ? state.items.length : state.items.length + 1,
                separatorBuilder: (context, index) {
                  final frequency = sl<RemoteConfigService>().adFrequencyFeed;
                  // debugPrint('Feed Separator: Index $index, Freq $frequency'); 
                  if (frequency > 0 && (index + 1) % frequency == 0) {
                    debugPrint('Injecting Ad at index $index'); // DEBUG
                    return const Column(
                      children: [
                        SizedBox(height: AppDimens.spaceM),
                        BannerAdWidget(),
                        SizedBox(height: AppDimens.spaceM),
                      ],
                    );
                  }
                  return const SizedBox(height: AppDimens.spaceM);
                },
                itemBuilder: (context, index) {
                  if (index >= state.items.length) {
                    return const Center(child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ));
                  }
                  return FeedRecipeCard(item: state.items[index]);
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
