import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tubeorbit/core/constants.dart';
import 'package:tubeorbit/core/theme.dart';
import 'package:tubeorbit/features/feed/feed_provider.dart';
import 'package:tubeorbit/features/feed/video_card.dart';

class FeedScreen extends ConsumerStatefulWidget {
  final TubeCategory category;
  const FeedScreen({super.key, required this.category});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  bool _isShorts = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _isShorts = _tabController.index == 1);
      }
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      ref
          .read(feedProvider((
            category: widget.category,
            isShorts: _isShorts,
          )).notifier)
          .loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedKey = (category: widget.category, isShorts: _isShorts);
    final feedAsync = ref.watch(feedProvider(feedKey));

    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            snap: true,
            pinned: false,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding:
                  const EdgeInsets.only(left: 16, bottom: 52),
              title: Hero(
                tag: 'category_${widget.category.name}',
                child: Material(
                  color: Colors.transparent,
                  child: Text(
                    widget.category.displayName,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                    ),
                  ),
                ),
              ),
              background: Container(color: AppTheme.surface),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: ColoredBox(
                color: AppTheme.background,
                child: TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Video'),
                    Tab(text: 'Shorts'),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildFeed(feedAsync, isShorts: false),
            _buildFeed(feedAsync, isShorts: true),
          ],
        ),
      ),
    );
  }

  Widget _buildFeed(
    AsyncValue<FeedState> feedAsync, {
    required bool isShorts,
  }) {
    return feedAsync.when(
      loading: () => _buildShimmer(),
      error: (e, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, color: AppTheme.textSecondary, size: 48),
            const SizedBox(height: 12),
            Text('Errore: $e',
                style: const TextStyle(color: AppTheme.textSecondary)),
          ],
        ),
      ),
      data: (state) {
        if (state.videos.isEmpty) {
          return const Center(
            child: Text('Nessun video trovato',
                style: TextStyle(color: AppTheme.textSecondary)),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 24),
          itemCount: state.videos.length + (state.isLoadingMore ? 1 : 0),
          itemBuilder: (context, i) {
            if (i == state.videos.length) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: CircularProgressIndicator(color: AppTheme.accent),
                ),
              );
            }
            return VideoCard(
              video: state.videos[i],
              category: widget.category,
            );
          },
        );
      },
    );
  }

  Widget _buildShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: 5,
      itemBuilder: (_, x) => Shimmer.fromColors(
        baseColor: AppTheme.surfaceVariant,
        highlightColor: AppTheme.surface,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          height: 280,
          decoration: BoxDecoration(
            color: AppTheme.surfaceVariant,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
