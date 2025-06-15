import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nasa_daily_snapshot/models/apod_model.dart';
import 'package:nasa_daily_snapshot/providers/apod_provider.dart';
import 'package:nasa_daily_snapshot/providers/favorites_provider.dart';
import 'package:nasa_daily_snapshot/screens/detail_screen.dart';
import 'package:nasa_daily_snapshot/widgets/image_loader.dart';
import 'package:nasa_daily_snapshot/widgets/error_view.dart';
import 'package:nasa_daily_snapshot/widgets/shimmer_loading.dart';
import 'package:nasa_daily_snapshot/utils/color_utils.dart';

class HomeScreen extends StatefulWidget {
  final ApodProvider apodProvider;
  final FavoritesProvider favoritesProvider;

  const HomeScreen({
    Key? key, 
    required this.apodProvider, 
    required this.favoritesProvider,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  
  @override
  void initState() {
    super.initState();
    // Fetch today's APOD when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fetchApod();
      }
    });
  }

  Future<void> _fetchApod() async {
    await widget.apodProvider.fetchApod();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('NASA Daily Snapshot'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
            tooltip: 'Select Date',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (widget.apodProvider.isLoading) {
      return _buildLoadingView();
    }
    
    if (widget.apodProvider.error != null) {
      return ErrorView(
        error: widget.apodProvider.error!,
        onRetry: _fetchApod,
      );
    }

    final apod = widget.apodProvider.apod;
    if (apod == null) {
      return const Center(child: Text('No data available'));
    }

    return _buildApodContent(apod);
  }

  Widget _buildLoadingView() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ShimmerLoading(
            height: MediaQuery.of(context).size.height * 0.5,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerLoading(height: 24, width: MediaQuery.of(context).size.width * 0.7),
                const SizedBox(height: 8),
                ShimmerLoading(height: 16, width: MediaQuery.of(context).size.width * 0.4),
                const SizedBox(height: 16),
                ShimmerLoading(height: 16, width: MediaQuery.of(context).size.width),
                const SizedBox(height: 8),
                ShimmerLoading(height: 16, width: MediaQuery.of(context).size.width),
                const SizedBox(height: 8),
                ShimmerLoading(height: 16, width: MediaQuery.of(context).size.width * 0.8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApodContent(ApodModel apod) {
    final isFavorite = widget.favoritesProvider.isFavorite(apod.date);
    
    return RefreshIndicator(
      onRefresh: _fetchApod,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                Hero(
                  tag: 'apod_image_${apod.date}',
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailScreen(
                          apod: apod,
                          favoritesProvider: widget.favoritesProvider,
                          // heroTagPrefix is null here, DetailScreen will use default 'apod_image_'
                        ),
                      ),
                    ),
                    child: ImprovedImageLoader(
                      imageUrl: apod.displayUrl,
                      mediaType: apod.mediaType, // Added mediaType
                      height: MediaQuery.of(context).size.height * 0.5,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(ColorUtils.safeAlpha(0.6)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_outline,
                        color: isFavorite ? Colors.red : Colors.white,
                      ),
                      onPressed: () {
                        widget.favoritesProvider.toggleFavorite(apod);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isFavorite 
                                  ? 'Removed from favorites' 
                                  : 'Added to favorites'
                            ),
                            duration: const Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
                    ),
                  ),
                ),
                if (apod.mediaType == 'video')
                  Positioned.fill(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(ColorUtils.safeAlpha(0.6)),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    apod.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat.yMMMMd().format(DateTime.parse(apod.date)),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                  if (apod.copyright != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.copyright, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          apod.copyright!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    _getShortDescription(apod.explanation),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailScreen(
                            apod: apod,
                            favoritesProvider: widget.favoritesProvider,
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.info_outline),
                      label: const Text('View Details'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
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

  String _getShortDescription(String fullDescription) {
    // Limit description to first 150 characters
    if (fullDescription.length <= 150) return fullDescription;
    return '${fullDescription.substring(0, 150)}...';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1995, 6, 16), // APOD started on June 16, 1995
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(picked);
      widget.apodProvider.fetchApod(date: formattedDate);
    }
  }
}
