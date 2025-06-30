import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:nasa_daily_snapshot/models/apod_model.dart';
import 'package:nasa_daily_snapshot/providers/apod_provider.dart';
import 'package:nasa_daily_snapshot/providers/favorites_provider.dart';
import 'package:nasa_daily_snapshot/screens/detail_screen.dart';
import 'package:nasa_daily_snapshot/widgets/image_loader.dart';
import 'package:nasa_daily_snapshot/widgets/animated_grid_item.dart';
import 'package:nasa_daily_snapshot/utils/color_utils.dart';

class FavoritesScreen extends StatefulWidget {
  final FavoritesProvider favoritesProvider;
  final ApodProvider apodProvider;

  const FavoritesScreen({
    Key? key, 
    required this.favoritesProvider,
    required this.apodProvider,
  }) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: Consumer<FavoritesProvider>(
        builder: (context, favoritesProvider, child) {
          return _buildBody(context, favoritesProvider);
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, FavoritesProvider favoritesProvider) {
    if (favoritesProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final favorites = favoritesProvider.favorites;
    
    if (favorites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_outline,
              size: 64,
              color: Theme.of(context).colorScheme.secondary.withAlpha(ColorUtils.safeAlpha(0.5)),
            ),
            const SizedBox(height: 16),
            Text(
              'No favorites yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Save your favorite astronomy pictures here',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to home tab
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              icon: const Icon(Icons.home),
              label: const Text('Go to Home'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }
    
    // Calculate responsive grid columns
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = 2; // Default for portrait
    double childAspectRatio = 0.75;
    
    if (isLandscape) {
      if (screenWidth > 1200) {
        crossAxisCount = 5;
        childAspectRatio = 0.8;
      } else if (screenWidth > 900) {
        crossAxisCount = 4;
        childAspectRatio = 0.8;
      } else if (screenWidth > 600) {
        crossAxisCount = 3;
        childAspectRatio = 0.85;
      }
    } else {
      // Portrait mode
      if (screenWidth > 600) {
        crossAxisCount = 3;
        childAspectRatio = 0.75;
      }
    }
    
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 100), // Added bottom padding for bottom nav
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final apod = favorites[index];
        return AnimatedGridItem(
          index: index,
          child: _buildFavoriteItem(context, apod, favoritesProvider),
        );
      },
    );
  }

  Widget _buildFavoriteItem(BuildContext context, ApodModel apod, FavoritesProvider favoritesProvider) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(
              apod: apod,
              favoritesProvider: favoritesProvider,
              heroTagPrefix: 'favorite_',
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Hero(
                  tag: 'favorite_apod_image_${apod.date}',
                  child: ImprovedImageLoader(
                    imageUrl: apod.displayUrl,
                    mediaType: apod.mediaType, // Added mediaType
                    height: 150,
                    width: double.infinity,
                  ),
                ),
                if (apod.mediaType == 'video')
                  Positioned.fill(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(ColorUtils.safeAlpha(0.6)),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () async {
                        try {
                          await favoritesProvider.removeFavorite(apod.date);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Removed from favorites'),
                                duration: Duration(seconds: 1),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error removing favorite: ${e.toString()}'),
                                duration: const Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(ColorUtils.safeAlpha(0.5)),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    apod.title,
                    style: Theme.of(context).textTheme.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat.yMMMd().format(DateTime.parse(apod.date)),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
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
