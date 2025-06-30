import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:nasa_daily_snapshot/models/apod_model.dart';
import 'package:nasa_daily_snapshot/providers/apod_provider.dart';
import 'package:nasa_daily_snapshot/providers/favorites_provider.dart';
import 'package:nasa_daily_snapshot/screens/detail_screen.dart';
import 'package:nasa_daily_snapshot/widgets/image_loader.dart';
import 'package:nasa_daily_snapshot/widgets/shimmer_loading.dart';
import 'package:nasa_daily_snapshot/utils/color_utils.dart';

class SearchScreen extends StatefulWidget {
  final ApodProvider apodProvider;
  final FavoritesProvider favoritesProvider;

  const SearchScreen({
    Key? key, 
    required this.apodProvider, 
    required this.favoritesProvider,
  }) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  bool _hasSearched = false;
  Timer? _debounceTimer;
  
  @override
  bool get wantKeepAlive => true;
  
  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
  }
  
  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _scrollController.removeListener(_onScroll);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  void _onSearchChanged() {
    _debounceTimer?.cancel();
    
    if (_searchController.text.isEmpty) {
      widget.apodProvider.clearSearch();
      setState(() {
        _hasSearched = false;
      });
    } else {
      // Debounce search for 800ms
      _debounceTimer = Timer(const Duration(milliseconds: 800), () {
        _performSearch();
      });
    }
  }
  
  void _performSearch() {
    final query = _searchController.text.trim();
    if (kDebugMode) {
      debugPrint('SearchScreen: _performSearch called with query: "$query"');
    }
    if (query.isNotEmpty) {
      // Clear previous results and reset scroll position before new search
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
      if (kDebugMode) {
        debugPrint('SearchScreen: Calling apodProvider.searchApods with query: "$query"');
      }
      widget.apodProvider.searchApods(query);
      setState(() {
        _hasSearched = true;
      });
      if (kDebugMode) {
        debugPrint('SearchScreen: _hasSearched set to true');
      }
      FocusScope.of(context).unfocus();
    } else {
      if (kDebugMode) {
        debugPrint('SearchScreen: Query is empty, not performing search');
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && // Trigger before reaching the very end
        !widget.apodProvider.isLoadingMoreSearchResults &&
        widget.apodProvider.hasMoreSearchResults &&
        _searchController.text.isNotEmpty) {
      widget.apodProvider.loadMoreSearchResults();
    }
  }

  Future<void> _toggleFavorite(ApodModel apod) async {
    try {
      await widget.favoritesProvider.toggleFavorite(apod);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update favorite: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: 'Search for astronomy pictures...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          widget.apodProvider.clearSearch();
                          setState(() {
                            _hasSearched = false;
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              textInputAction: TextInputAction.search,
              onChanged: (value) {
                setState(() {}); // Trigger rebuild to show/hide clear button
              },
              onSubmitted: (_) => _performSearch(),
            ),
          ),
          Expanded(
            child: _buildSearchResults(),
          ),
        ],
        ),
    );
  }

  Widget _buildSearchResults() {
    if (kDebugMode) {
      debugPrint('SearchScreen: _buildSearchResults called.');
      debugPrint('SearchScreen: _hasSearched: $_hasSearched');
      debugPrint('SearchScreen: apodProvider.isSearching: ${widget.apodProvider.isSearching}');
      debugPrint('SearchScreen: apodProvider.isLoadingMoreSearchResults: ${widget.apodProvider.isLoadingMoreSearchResults}');
      debugPrint('SearchScreen: apodProvider.hasMoreSearchResults: ${widget.apodProvider.hasMoreSearchResults}');
      debugPrint('SearchScreen: apodProvider.error: ${widget.apodProvider.error}');
      debugPrint('SearchScreen: apodProvider.searchResults.length: ${widget.apodProvider.searchResults.length}');
    }

    if (!_hasSearched) {
      return _buildInitialView();
    }
    
    if (widget.apodProvider.isSearching) {
      return _buildLoadingView();
    }
    
    if (widget.apodProvider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error: ${widget.apodProvider.error}',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _performSearch,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    final results = widget.apodProvider.searchResults;
    if (kDebugMode) debugPrint('SearchScreen: results.length: ${results.length}');
    
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Try different keywords',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      );
    }
    
    // Check if landscape mode
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Use grid for landscape on larger screens
    if (isLandscape && screenWidth > 600) {
      return GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.8,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: results.length + (widget.apodProvider.isLoadingMoreSearchResults ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == results.length && widget.apodProvider.isLoadingMoreSearchResults) {
            return const Card(
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (index >= results.length) return const SizedBox.shrink();
          
          final apod = results[index];
          return _buildSearchResultGridItem(apod);
        },
      );
    }
    
    // Portrait mode - use list view
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 100), // Added bottom padding for bottom nav
      itemCount: results.length + (widget.apodProvider.isLoadingMoreSearchResults ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == results.length && widget.apodProvider.isLoadingMoreSearchResults) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (index >= results.length) return const SizedBox.shrink(); // Should not happen
        
        final apod = results[index];
        return _buildSearchResultItem(apod);
      },
    );
  }
  
  Widget _buildInitialView() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 100.0), // Added bottom padding for bottom nav
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withAlpha(ColorUtils.safeAlpha(0.5)),
          ),
          const SizedBox(height: 16),
          Text(
            'Search for astronomy pictures',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching for "galaxy", "nebula", or "mars"',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              _searchFocusNode.requestFocus();
            },
            icon: const Icon(Icons.search),
            label: const Text('Start Searching'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ), // Column
      ), // SingleChildScrollView
    ); // Center
  }
  
  Widget _buildLoadingView() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 100), // Added bottom padding for bottom nav
      itemCount: 5,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            children: [
              const ShimmerLoading(
                height: 100,
                width: 100,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerLoading(
                      height: 20,
                      width: MediaQuery.of(context).size.width * 0.6,
                    ),
                    const SizedBox(height: 8),
                    ShimmerLoading(
                      height: 16,
                      width: MediaQuery.of(context).size.width * 0.3,
                    ),
                    const SizedBox(height: 8),
                    ShimmerLoading(
                      height: 16,
                      width: MediaQuery.of(context).size.width * 0.7,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildSearchResultItem(ApodModel apod) {
    final isFavorite = widget.favoritesProvider.isFavorite(apod.date);
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(
              apod: apod,
              favoritesProvider: widget.favoritesProvider,
              heroTagPrefix: 'search_',
            ),
          ),
        ),
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: Hero(
                tag: 'search_apod_image_${apod.date}',
                child: Stack(
                  children: [
                    ImprovedImageLoader(
                      imageUrl: apod.displayUrl,
                      mediaType: apod.mediaType,
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                    if (apod.mediaType == 'video')
                      Positioned.fill(
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(ColorUtils.safeAlpha(0.6)),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      apod.title,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat.yMMMd().format(DateTime.parse(apod.date)),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      apod.explanation,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_outline,
                color: isFavorite ? Colors.red : null,
              ),
              onPressed: () => _toggleFavorite(apod),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResultGridItem(ApodModel apod) {
    final isFavorite = widget.favoritesProvider.isFavorite(apod.date);
    
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(
              apod: apod,
              favoritesProvider: widget.favoritesProvider,
              heroTagPrefix: 'search_grid_',
            ),
          ),
        ),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: Hero(
                      tag: 'search_grid_apod_image_${apod.date}',
                      child: ImprovedImageLoader(
                        imageUrl: apod.displayUrl,
                        mediaType: apod.mediaType,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  if (apod.mediaType == 'video')
                    Positioned.fill(
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(ColorUtils.safeAlpha(0.7)),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(ColorUtils.safeAlpha(0.9)),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_outline,
                          color: isFavorite ? Colors.red : Colors.grey[600],
                          size: 20,
                        ),
                        onPressed: () => _toggleFavorite(apod),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    apod.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat.yMMMd().format(DateTime.parse(apod.date)),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
