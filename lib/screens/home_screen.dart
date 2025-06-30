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
import 'dart:ui';

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
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
      ),
    );
    
    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.primary,
              secondary: AppColors.secondaryTeal,
              surface: AppColors.neutralMedium,
            ),
          ),
          child: child!,
        );
      },
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
      extendBodyBehindAppBar: true,
      backgroundColor: isDark ? null : Colors.white,
      appBar: AppBar(
        title: Text(
          'NASA Daily Snapshot',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
            color: AppColors.getTextColor(isDark),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,

        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: const Icon(Icons.calendar_today, size: 16),
            onPressed: () => _selectDate(context),
              color: AppColors.getTextColor(isDark),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark 
            ? RadialGradient(
                center: Alignment.topRight,
                radius: 1.5,
                colors: [
                  Color(0xFF1a1a2e),
                  Color(0xFF16213e),
                  Color(0xFF0f172a),
                ],
              )
            : null, // No gradient for light mode
        ),
        child: _buildBody(),
      ),
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
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    
    // Dynamic values for portrait vs landscape
    final imageHeight = isPortrait 
        ? MediaQuery.of(context).size.height * 0.45
        : MediaQuery.of(context).size.height * 0.6;
    
    final horizontalMargin = isPortrait ? 20.0 : 32.0;
    final topSpacing = isPortrait ? 100.0 : 120.0;
    
    final shimmerColors = AppColors.getShimmerColors(isDark);
    final dividerColor = isDark 
        ? Colors.white.withOpacity(0.1)
        : Colors.black.withOpacity(0.1);
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: topSpacing),
          
          // Image shimmer
          Container(
            height: imageHeight,
            margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isPortrait ? 20 : 24),
              color: shimmerColors[0],
            ),
            child: ShimmerLoading(
              height: double.infinity,
            baseColor: shimmerColors[0],
            highlightColor: shimmerColors[1],
              borderRadius: isPortrait ? 20 : 24,
            ),
          ),
          
          SizedBox(height: isPortrait ? 24 : 32),
          
          // Content shimmer
          Container(
            margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
            padding: isDark ? EdgeInsets.zero : EdgeInsets.all(20),
            decoration: isDark ? null : BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title shimmer
                ShimmerLoading(
                  height: isPortrait ? 28 : 32,
                  width: MediaQuery.of(context).size.width * 0.7,
                  baseColor: shimmerColors[0],
                  highlightColor: shimmerColors[1],
                  borderRadius: 8,
                ),
                
                SizedBox(height: isPortrait ? 16 : 20),
                
                // Metadata shimmer (Date row)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerLoading(
                      height: 16,
                      width: 60,
                      baseColor: shimmerColors[0],
                      highlightColor: shimmerColors[1],
                      borderRadius: 4,
                    ),
                    ShimmerLoading(
                      height: 16,
                      width: 120,
                  baseColor: shimmerColors[0],
                  highlightColor: shimmerColors[1],
                  borderRadius: 4,
                ),
                  ],
                ),
                
                // Divider
                Container(
                  margin: EdgeInsets.symmetric(vertical: 12),
                  height: 1,
                  color: dividerColor,
                ),
                
                // Copyright row shimmer
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                ShimmerLoading(
                  height: 16,
                      width: 80,
                  baseColor: shimmerColors[0],
                  highlightColor: shimmerColors[1],
                  borderRadius: 4,
                ),
                ShimmerLoading(
                  height: 16,
                      width: 140,
                  baseColor: shimmerColors[0],
                  highlightColor: shimmerColors[1],
                  borderRadius: 4,
                ),
                  ],
                ),
                
                Container(
                  margin: EdgeInsets.symmetric(vertical: 12),
                  height: 1,
                  color: dividerColor,
                ),
                
                SizedBox(height: isPortrait ? 16 : 20),
                
                // Description shimmer
                Column(
                  children: [
                    ShimmerLoading(
                      height: 16,
                      width: double.infinity,
                      baseColor: shimmerColors[0],
                      highlightColor: shimmerColors[1],
                      borderRadius: 4,
                      margin: const EdgeInsets.only(bottom: 8),
                    ),
                    ShimmerLoading(
                      height: 16,
                      width: MediaQuery.of(context).size.width * 0.9,
                      baseColor: shimmerColors[0],
                      highlightColor: shimmerColors[1],
                      borderRadius: 4,
                      margin: const EdgeInsets.only(bottom: 8),
                    ),
                ShimmerLoading(
                  height: 16,
                      width: MediaQuery.of(context).size.width * 0.8,
                  baseColor: shimmerColors[0],
                  highlightColor: shimmerColors[1],
                  borderRadius: 4,
                ),
                  ],
                ),
                
                SizedBox(height: isPortrait ? 32 : 40),
                
                // Button shimmer
                Center(
                  child: ShimmerLoading(
                    height: isPortrait ? 52 : 56,
                    width: isPortrait ? 200 : 250,
                    baseColor: shimmerColors[0],
                    highlightColor: shimmerColors[1],
                    borderRadius: 30,
                  ),
                ),
                
                SizedBox(height: isPortrait ? 120 : 40),
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
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Different layout for portrait vs landscape
    final imageHeight = isPortrait 
        ? MediaQuery.of(context).size.height * 0.45  // Smaller for portrait
        : MediaQuery.of(context).size.height * 0.6;
    
    final horizontalMargin = isPortrait ? 20.0 : 32.0;
    final titleFontSize = isPortrait ? 24.0 : 28.0;
    final topSpacing = isPortrait ? 100.0 : 120.0;
    
    return RefreshIndicator(
      onRefresh: _fetchApod,
      color: AppColors.primary,
      backgroundColor: AppColors.getBackgroundColor(isDark),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _slideAnimation.value),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
        child: Column(
          children: [
                      SizedBox(height: topSpacing), // Dynamic spacing for app bar
                      
                      // Clean hero image without overlays
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(isPortrait ? 20 : 24),
                          child: Stack(
              children: [
                              // Main image
                Hero(
                  tag: 'apod_image_${apod.date}',
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation, secondaryAnimation) => DetailScreen(
                          apod: apod,
                          favoritesProvider: widget.favoritesProvider,
                        ),
                                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                        return FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        );
                                      },
                      ),
                    ),
                                  child: Container(
                                    height: imageHeight,
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
                
                              // Video indicator (simple)
                if (apod.mediaType == 'video')
                                Positioned.fill(
                    child: Center(
                                    child: Container(
                                      padding: EdgeInsets.all(isPortrait ? 16 : 20),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.black.withOpacity(1),
                                      ),
                      child: Icon(
                                        Icons.play_arrow_rounded,
                        color: Colors.white,
                                        size: isPortrait ? 32 : 40,
                                      ),
                      ),
                    ),
                  ),
                
                              // Floating favorite button
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    decoration: BoxDecoration(
                                    color: AppColors.primary,
                      shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withOpacity(0.3),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ],
                    ),
                    child: IconButton(
                      onPressed: () {
                        if (isFavorite) {
                          widget.favoritesProvider.removeFavorite(apod.date);
                        } else {
                          widget.favoritesProvider.addFavorite(apod);
                        }
                      },
                                    icon: Icon(
                                      isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: Colors.white,
                                      size: isPortrait ? 20 : 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),
                        ),
                      ),
                      
                      SizedBox(height: isPortrait ? 24 : 32),
                      
                      // Title section (separated from image)
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
                        padding: isDark ? EdgeInsets.zero : EdgeInsets.all(20),
                        decoration: isDark ? null : BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                            // Main title
                    Text(
                      apod.title,
                      style: TextStyle(
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.w700,
                                color: AppColors.getTextColor(isDark),
                                letterSpacing: -0.5,
                                height: 1.2,
                              ),
                            ),
                            
                            SizedBox(height: isPortrait ? 16 : 20),
                            
                            // Metadata section with dividers
                            Column(
                              children: [
                                // Date row
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Date',
                                      style: TextStyle(
                                        fontSize: isPortrait ? 14 : 16,
                                        color: AppColors.getSecondaryTextColor(isDark),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      DateFormat.yMMMd().format(DateTime.parse(apod.date)),
                                      style: TextStyle(
                                        fontSize: isPortrait ? 14 : 16,
                                        color: AppColors.getTextColor(isDark),
                                        fontWeight: FontWeight.w600,
                      ),
                    ),
                                  ],
                                ),
                                
                                // Divider
                                Container(
                                  margin: EdgeInsets.symmetric(vertical: 12),
                                  height: 1,
                                  color: AppColors.getBorderColor(isDark),
                                ),
                                
                                // Copyright row (if exists)
                    if (apod.copyright != null && apod.copyright!.isNotEmpty)
                                  Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Copyright',
                                            style: TextStyle(
                                              fontSize: isPortrait ? 14 : 16,
                                              color: AppColors.getSecondaryTextColor(isDark),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Flexible(
                        child: Text(
                                              apod.copyright!,
                          style: TextStyle(
                                                fontSize: isPortrait ? 14 : 16,
                                                color: AppColors.getTextColor(isDark),
                                                fontWeight: FontWeight.w600,
                                              ),
                                              textAlign: TextAlign.right,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        margin: EdgeInsets.symmetric(vertical: 12),
                                        height: 1,
                                        color: AppColors.getBorderColor(isDark),
                          ),
                                    ],
                        ),
                              ],
                      ),
                    
                            SizedBox(height: isPortrait ? 16 : 20),
                    
                            // Description text
                    Text(
                      apod.explanation,
                      style: TextStyle(
                                fontSize: isPortrait ? 15 : 16,
                                height: 1.6,
                                color: AppColors.getTextColor(isDark),
                                letterSpacing: 0.2,
                      ),
                    ),
                    
                            SizedBox(height: isPortrait ? 32 : 40),
                    
                            // Action button
                    Center(
                              child: GestureDetector(
                                onTap: () => Navigator.push(
                          context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation, secondaryAnimation) => DetailScreen(
                              apod: apod,
                              favoritesProvider: widget.favoritesProvider,
                                    ),
                                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      );
                                    },
                                  ),
                                ),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isPortrait ? 40 : 50, 
                                    vertical: isPortrait ? 16 : 18
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(30),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withOpacity(0.3),
                                        blurRadius: 15,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    'View Full Details',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isPortrait ? 16 : 18,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                            ),
                          ),
                        ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: isPortrait ? 100 : 40), // Extra space for bottom nav in portrait
                    ],
                    ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
