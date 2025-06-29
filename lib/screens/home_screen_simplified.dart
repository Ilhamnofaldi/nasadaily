import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nasa_daily_snapshot/models/apod_model.dart';
import 'package:nasa_daily_snapshot/providers/apod_provider.dart';
import 'package:nasa_daily_snapshot/providers/favorites_provider.dart';
import 'package:nasa_daily_snapshot/screens/detail_screen.dart';
import 'package:nasa_daily_snapshot/widgets/error_view.dart';
import 'package:nasa_daily_snapshot/widgets/shimmer_loading.dart';
import 'package:nasa_daily_snapshot/utils/color_utils.dart';
import 'package:nasa_daily_snapshot/themes/app_colors.dart';
import 'package:nasa_daily_snapshot/widgets/enhanced_image_loader.dart';

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

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    
    // Fetch today's APOD when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fetchApod();
      }
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchApod() async {
    await widget.apodProvider.fetchApod();
    if (mounted && !widget.apodProvider.isLoading && widget.apodProvider.error == null) {
      _animationController.forward();
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1995, 6, 16), // NASA APOD started on June 16, 1995
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      final dateStr = DateFormat('yyyy-MM-dd').format(picked);
      await widget.apodProvider.fetchApodByDate(dateStr);
      if (mounted && !widget.apodProvider.isLoading && widget.apodProvider.error == null) {
        _animationController.reset();
        _animationController.forward();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('NASA Daily Snapshot'),
        backgroundColor: isDark ? Colors.black : AppColors.primaryBlue,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shimmerColors = AppColors.getShimmerColors(isDark);
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ShimmerLoading(
            height: MediaQuery.of(context).size.height * 0.4,
            baseColor: shimmerColors[0],
            highlightColor: shimmerColors[1],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerLoading(
                  height: 24,
                  width: MediaQuery.of(context).size.width * 0.7,
                  baseColor: shimmerColors[0],
                  highlightColor: shimmerColors[1],
                  borderRadius: 4,
                ),
                const SizedBox(height: 8),
                ShimmerLoading(
                  height: 16,
                  width: MediaQuery.of(context).size.width * 0.4,
                  baseColor: shimmerColors[0],
                  highlightColor: shimmerColors[1],
                  borderRadius: 4,
                ),
                const SizedBox(height: 16),
                ShimmerLoading(
                  height: 16,
                  width: MediaQuery.of(context).size.width,
                  baseColor: shimmerColors[0],
                  highlightColor: shimmerColors[1],
                  borderRadius: 4,
                ),
                const SizedBox(height: 8),
                ShimmerLoading(
                  height: 16,
                  width: MediaQuery.of(context).size.width,
                  baseColor: shimmerColors[0],
                  highlightColor: shimmerColors[1],
                  borderRadius: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApodContent(ApodModel apod) {
    final isFavorite = widget.favoritesProvider.isFavorite(apod.date);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return RefreshIndicator(
      onRefresh: _fetchApod,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with favorite button
            Stack(
              children: [
                // Hero image
                Hero(
                  tag: 'apod_image_${apod.date}',
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailScreen(
                          apod: apod,
                          favoritesProvider: widget.favoritesProvider,
                        ),
                      ),
                    ),
                    child: SizedBox(
                      height: 300,
                      width: double.infinity,
                      child: EnhancedImageLoader(
                        imageUrl: apod.displayUrl,
                        mediaType: apod.mediaType,
                        title: apod.title,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                
                // Video indicator
                if (apod.mediaType == 'video')
                  const Positioned.fill(
                    child: Center(
                      child: Icon(
                        Icons.play_circle_outline,
                        color: Colors.white,
                        size: 64,
                      ),
                    ),
                  ),
                
                // Favorite button
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.white,
                      ),
                      onPressed: () {
                        if (isFavorite) {
                          widget.favoritesProvider.removeFavorite(apod.date);
                        } else {
                          widget.favoritesProvider.addFavorite(apod);
                        }
                      },
                    ),
                  ),
                ),
                
                // Date badge
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      DateFormat.yMMMd().format(DateTime.parse(apod.date)),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      apod.title,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    
                    if (apod.copyright != null && apod.copyright!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '© ${apod.copyright}',
                          style: TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ),
                    
                    const SizedBox(height: 16),
                    
                    Text(
                      apod.explanation,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Center(
                      child: ElevatedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailScreen(
                              apod: apod,
                              favoritesProvider: widget.favoritesProvider,
                            ),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? AppColors.primaryBlue : AppColors.primaryBlue,
                          minimumSize: const Size(120, 36),
                        ),
                        child: const Text('View Details'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
