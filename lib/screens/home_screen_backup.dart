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
  late Animation<double> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    
    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
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
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primaryBlue,
              onPrimary: Colors.white,
              surface: Theme.of(context).colorScheme.surface,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
            dialogBackgroundColor: Theme.of(context).colorScheme.surface,
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
      appBar: AppBar(
        title: Text(
          'NASA Daily Snapshot',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                isDark ? Colors.black.withOpacity(0.7) : AppColors.primaryBlue.withOpacity(0.7),
                Colors.transparent,
              ],
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.1) : AppColors.primaryBlue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: Icon(
                Icons.calendar_today,
                color: Colors.white,
              ),
              onPressed: () => _selectDate(context),
              tooltip: 'Select Date',
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppColors.getSpaceGradient()
              : AppColors.getBlueGradient(),
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
    final shimmerColors = AppColors.getShimmerColors(isDark);
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ShimmerLoading(
            height: MediaQuery.of(context).size.height * 0.5,
            baseColor: shimmerColors[0],
            highlightColor: shimmerColors[1],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerLoading(
                  height: 32,
                  width: MediaQuery.of(context).size.width * 0.7,
                  baseColor: shimmerColors[0],
                  highlightColor: shimmerColors[1],
                  borderRadius: 16,
                ),
                const SizedBox(height: 12),
                ShimmerLoading(
                  height: 20,
                  width: MediaQuery.of(context).size.width * 0.4,
                  baseColor: shimmerColors[0],
                  highlightColor: shimmerColors[1],
                  borderRadius: 10,
                ),
                const SizedBox(height: 24),
                ShimmerLoading(
                  height: 16,
                  width: MediaQuery.of(context).size.width,
                  baseColor: shimmerColors[0],
                  highlightColor: shimmerColors[1],
                  borderRadius: 8,
                ),
                const SizedBox(height: 8),
                ShimmerLoading(
                  height: 16,
                  width: MediaQuery.of(context).size.width,
                  baseColor: shimmerColors[0],
                  highlightColor: shimmerColors[1],
                  borderRadius: 8,
                ),
                const SizedBox(height: 8),
                ShimmerLoading(
                  height: 16,
                  width: MediaQuery.of(context).size.width * 0.8,
                  baseColor: shimmerColors[0],
                  highlightColor: shimmerColors[1],
                  borderRadius: 8,
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
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return RefreshIndicator(
      onRefresh: _fetchApod,
      color: AppColors.primaryBlue,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: isLandscape
            ? _buildLandscapeLayout(apod, isFavorite, isDark)
            : _buildPortraitLayout(apod, isFavorite, isDark),
      ),
    );
  }
  
  Widget _buildLandscapeLayout(ApodModel apod, bool isFavorite, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image on the left in landscape
        Expanded(
          flex: 1,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: Transform.translate(
                  offset: Offset(-_slideAnimation.value, 0),
                  child: child,
                ),
              );
            },
            child: Container(
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(ColorUtils.safeAlpha(0.3)),
                    blurRadius: 15,
                    offset: const Offset(5, 0),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                child: Stack(
                  fit: StackFit.expand,
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
                            ),
                          ),
                        ),
                        child: EnhancedImageLoader(
                          imageUrl: apod.displayUrl,
                          mediaType: apod.mediaType,
                          title: apod.title,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // Gradient overlay for better text readability
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.black.withAlpha(ColorUtils.safeAlpha(0.5)),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Media type indicator
                    if (apod.mediaType == 'video')
                      Positioned(
                        bottom: 20,
                        left: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(ColorUtils.safeAlpha(0.6)),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.secondaryPink.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.play_circle_outline,
                                color: AppColors.secondaryPink,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Video',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    // Favorite button with improved design
                    Positioned(
                      top: 100,
                      right: 20,
                      child: _buildFavoriteButton(isFavorite, apod, isDark),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Content on the right in landscape
        Expanded(
          flex: 1,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: Transform.translate(
                  offset: Offset(_slideAnimation.value, 0),
                  child: child,
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: _buildContentSection(apod, isDark),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildPortraitLayout(ApodModel apod, bool isFavorite, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hero image with improved design
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: child,
            );
          },
          child: Stack(
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
                      ),
                    ),
                  ),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.5,
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
              // Gradient overlay for better text readability
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withAlpha(ColorUtils.safeAlpha(0.7)),
                      ],
                    ),
                  ),
                ),
              ),
              // Date badge
              Positioned(
                bottom: 20,
                left: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat.yMMMMd().format(DateTime.parse(apod.date)),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Media type indicator
              if (apod.mediaType == 'video')
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(ColorUtils.safeAlpha(0.6)),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.secondaryPink.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.play_circle_outline,
                          color: AppColors.secondaryPink,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Video',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              // Favorite button with improved design
              Positioned(
                top: 20,
                right: 20,
                child: _buildFavoriteButton(isFavorite, apod, isDark),
              ),
            ],
          ),
        ),
        // Content section with animation
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: child,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: _buildContentSection(apod, isDark),
          ),
        ),
      ],
    );
  }
  
  Widget _buildContentSection(ApodModel apod, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          apod.title,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 24),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceDark.withOpacity(0.5)
                  : Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark
                    ? AppColors.primaryPurple.withOpacity(0.3)
                    : AppColors.primaryBlue.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? AppColors.primaryPurple.withOpacity(0.2)
                      : AppColors.primaryBlue.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        AppColors.primaryPurple.withOpacity(0.1),
                        AppColors.accentViolet.withOpacity(0.05),
                      ]
                    : [
                        Colors.white.withOpacity(0.9),
                        AppColors.primaryBlue.withOpacity(0.05),
                      ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.primaryPurple.withOpacity(0.2)
                            : AppColors.primaryBlue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? AppColors.primaryPurple.withOpacity(0.5)
                              : AppColors.primaryBlue.withOpacity(0.5),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? AppColors.primaryPurple.withOpacity(0.3)
                                : AppColors.primaryBlue.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.auto_awesome,
                        color: isDark ? AppColors.primaryPurple : AppColors.primaryBlue,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Cosmic Insights',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.primaryPurple : AppColors.primaryBlue,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  apod.explanation,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.6,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    letterSpacing: 0.3,
                  ),
                ),
                if (apod.copyright != null && apod.copyright!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.primaryPurple.withOpacity(0.2)
                          : AppColors.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? AppColors.primaryPurple.withOpacity(0.3)
                            : AppColors.primaryBlue.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.copyright,
                          size: 16,
                          color: isDark ? AppColors.primaryPurple : AppColors.primaryBlue,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            apod.copyright!,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark
                                  ? Colors.white.withOpacity(0.9)
                                  : AppColors.textPrimaryLight.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
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
              icon: const Icon(Icons.explore),
              label: const Text('Explore Full Details'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? AppColors.primaryPurple : AppColors.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 5,
                shadowColor: isDark
                    ? AppColors.primaryPurple.withOpacity(0.5)
                    : AppColors.primaryBlue.withOpacity(0.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildFavoriteButton(bool isFavorite, ApodModel apod, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(ColorUtils.safeAlpha(0.3)),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isFavorite
              ? AppColors.accentRose.withOpacity(0.7)
              : Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(ColorUtils.safeAlpha(0.3)),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_outline,
          color: isFavorite ? AppColors.accentRose : Colors.white,
          size: 24,
        ),
        onPressed: () {
          if (isFavorite) {
            widget.favoritesProvider.removeFavorite(apod.date);
          } else {
            widget.favoritesProvider.addFavorite(apod);
          }
        },
        tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
      ),
    );
  }
}
