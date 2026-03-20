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
  FeedTabType _tabType = FeedTabType.videos;
  ContentLanguage _language = ContentLanguage.all;
  VideoSortOption _sortOption = VideoSortOption.viewCount;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _tabType = FeedTabType.values[_tabController.index]);
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
            tabType: _tabType,
            language: _language,
            sortOption: _sortOption,
          )).notifier)
          .loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            floating: true,
            snap: true,
            pinned: true,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PopupMenuButton<ContentLanguage>(
                  initialValue: _language,
                  onSelected: (val) {
                    setState(() => _language = val);
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: AppTheme.surfaceVariant,
                  itemBuilder: (context) => ContentLanguage.values.map((lang) {
                    return PopupMenuItem(
                      value: lang,
                      child: Text(
                        lang.displayName,
                        style: TextStyle(
                          color: _language == lang ? AppTheme.accent : AppTheme.textPrimary,
                          fontWeight: _language == lang ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    );
                  }).toList(),
                  child: Chip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_language.displayName),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_drop_down, size: 16, color: AppTheme.textSecondary),
                      ],
                    ),
                    backgroundColor: AppTheme.surfaceVariant,
                    side: const BorderSide(color: Colors.transparent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    labelStyle: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<VideoSortOption>(
                  initialValue: _sortOption,
                  onSelected: (val) {
                    setState(() => _sortOption = val);
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: AppTheme.surfaceVariant,
                  itemBuilder: (context) => VideoSortOption.values.map((opt) {
                    return PopupMenuItem(
                      value: opt,
                      child: Text(
                        opt.displayName,
                        style: TextStyle(
                          color: _sortOption == opt ? AppTheme.accent : AppTheme.textPrimary,
                          fontWeight: _sortOption == opt ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    );
                  }).toList(),
                  child: Chip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_sortOption.displayName),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_drop_down, size: 16, color: AppTheme.textSecondary),
                      ],
                    ),
                    backgroundColor: AppTheme.surfaceVariant,
                    side: const BorderSide(color: Colors.transparent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    labelStyle: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
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
                    Tab(text: 'Esterni'),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildFeed(
              ref.watch(feedProvider((category: widget.category, tabType: FeedTabType.videos, language: _language, sortOption: _sortOption))),
              tabType: FeedTabType.videos,
            ),
            _buildFeed(
              ref.watch(feedProvider((category: widget.category, tabType: FeedTabType.shorts, language: _language, sortOption: _sortOption))),
              tabType: FeedTabType.shorts,
            ),
            _buildFeed(
              ref.watch(feedProvider((category: widget.category, tabType: FeedTabType.external, language: _language, sortOption: _sortOption))),
              tabType: FeedTabType.external,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeed(
    AsyncValue<FeedState> feedAsync, {
    required FeedTabType tabType,
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
              openExternal: tabType == FeedTabType.external,
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
