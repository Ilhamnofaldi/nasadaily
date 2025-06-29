import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/apod_model.dart';
import '../providers/favorites_provider.dart';
import '../screens/detail_screen.dart';
import '../services/media_service.dart';
import '../core/app_router.dart';
import '../themes/app_colors.dart';
import '../themes/app_typography.dart';
import '../utils/color_utils.dart';
import '../utils/extensions.dart';
import '../utils/formatters.dart';
import '../utils/responsive.dart';
import 'common_widgets.dart';
import 'enhanced_image_loader.dart';
import 'dart:ui';

/// APOD card widget for displaying astronomy picture of the day
class ApodCard extends StatefulWidget {
  final ApodModel apod;
  final VoidCallback? onTap;
  final bool showFavoriteButton;
  final bool showDate;
  final bool showExplanation;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  
  const ApodCard({
    Key? key,
    required this.apod,
    this.onTap,
    this.showFavoriteButton = true,
    this.showDate = true,
    this.showExplanation = true,
    this.width,
    this.height,
    this.margin,
    this.borderRadius,
  }) : super(key: key);
  
  @override
  State<ApodCard> createState() => _ApodCardState();
}

class _ApodCardState extends State<ApodCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.03,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  void _handleHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
      if (isHovered) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final heroTag = 'apod_${widget.apod.date}_${DateTime.now().millisecondsSinceEpoch}';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: widget.width,
      height: widget.height,
      margin: widget.margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: MouseRegion(
        onEnter: (_) => _handleHover(true),
        onExit: (_) => _handleHover(false),
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: widget.borderRadius ?? BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(_isHovered ? 0.15 : 0.05),
                      blurRadius: _isHovered ? 25 : 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: widget.borderRadius ?? BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: widget.borderRadius ?? BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            (isDark ? AppColors.surfaceDark : Colors.white).withOpacity(0.9),
                            (isDark ? AppColors.neutralMedium : Colors.white).withOpacity(0.8),
                          ],
                        ),
                        border: Border.all(
                          color: AppColors.neutralLight.withOpacity(_isHovered ? 0.3 : 0.1),
                          width: 1,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
        child: InkWell(
                          onTap: widget.onTap ?? () => _navigateToDetail(context),
                          borderRadius: widget.borderRadius ?? BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image section
              _buildImageSection(context, heroTag),
              
              // Content section
              _buildContentSection(context),
            ],
          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildImageSection(BuildContext context, String heroTag) {
    return Stack(
      children: [
        // Main image with futuristic overlay
        ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(widget.borderRadius?.topLeft.x ?? 20),
            topRight: Radius.circular(widget.borderRadius?.topRight.x ?? 20),
          ),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CustomNetworkImage(
                  imageUrl: widget.apod.url,
              fit: BoxFit.cover,
              heroTag: heroTag,
              placeholder: const ShimmerImagePlaceholder(
                width: double.infinity,
                height: double.infinity,
              ),
                ),
                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        AppColors.neutralDark.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Media type indicator with minimal design
        if (widget.apod.mediaType == 'video')
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.play_circle_outline_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Video',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        
        // Favorite button with glow effect
        if (widget.showFavoriteButton)
          Positioned(
            top: 12,
            right: 12,
            child: _buildFavoriteButton(context),
          ),
        
        // Date overlay with futuristic design
        if (widget.showDate)
          Positioned(
            bottom: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.neutralDark.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.5),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 14,
                    color: AppColors.primary,
              ),
                  const SizedBox(width: 6),
                  Text(
                    Formatters.formatDisplayDate(DateTime.parse(widget.apod.date)),
                    style: const TextStyle(
                  color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                ),
                ],
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildContentSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Clean title
          Text(
            widget.apod.title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: _isHovered 
                ? AppColors.primary 
                : AppColors.getTextColor(isDark),
              letterSpacing: 0.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 12),
          
          // Explanation with improved styling
          if (widget.showExplanation && widget.apod.explanation.isNotEmpty)
            Text(
              widget.apod.explanation.truncate(120),
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black87,
                fontSize: 14,
                height: 1.5,
                letterSpacing: 0.3,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          
          const SizedBox(height: 16),
          
          // Action buttons with futuristic design
          _buildActionButtons(context),
        ],
      ),
    );
  }
  
  Widget _buildFavoriteButton(BuildContext context) {
    return Consumer<FavoritesProvider>(
      builder: (context, favoritesProvider, child) {
        final isFavorite = favoritesProvider.isFavorite(widget.apod.date);
        
        return GestureDetector(
          onTap: () => _toggleFavorite(context, favoritesProvider),
          child: Container(
            padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
            shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
          ),
            child: Icon(
              isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: isFavorite ? AppColors.error : Colors.white,
              size: 18,
            ),
          ),
        );
      },
    );
  }
  
  Future<void> _toggleFavorite(BuildContext context, FavoritesProvider provider) async {
    try {
      await provider.toggleFavorite(widget.apod);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update favorite: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
  
  Widget _buildActionButtons(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      children: [
        // Media type chip with minimal design
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.neutralLight.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.neutralLight.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.apod.mediaType == 'video' 
                  ? Icons.play_circle_rounded 
                  : Icons.image_rounded,
                size: 14,
                color: AppColors.neutralLight,
              ),
              const SizedBox(width: 6),
              Text(
                widget.apod.mediaType == 'video' ? 'Video' : 'Image',
                style: TextStyle(
                  color: AppColors.neutralLight,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
        
        const Spacer(),
        
        // Minimal action buttons
        Row(
          children: [
            _buildMinimalIconButton(
              icon: Icons.share_rounded,
          onPressed: () => _shareApod(context),
              tooltip: 'Share',
        ),
            if (widget.apod.mediaType == 'image')
              _buildMinimalIconButton(
                icon: Icons.download_rounded,
            onPressed: () => _saveImage(context),
                tooltip: 'Download',
              ),
            const SizedBox(width: 12),
            // Clean action button
            GestureDetector(
              onTap: () => _navigateToDetail(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
                  children: const [
              Text(
                      'View Details',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                ),
              ),
                    SizedBox(width: 6),
              Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 14,
              ),
            ],
          ),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildMinimalIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.neutralLight.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        color: AppColors.neutralLight,
        tooltip: tooltip,
        padding: const EdgeInsets.all(6),
        constraints: const BoxConstraints(
          minWidth: 32,
          minHeight: 32,
        ),
      ),
    );
  }
  
  void _navigateToDetail(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => DetailScreen(
          apod: widget.apod,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  Future<void> _shareApod(BuildContext context) async {
    try {
      await MediaService().shareApod(widget.apod);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _saveImage(BuildContext context) async {
    if (widget.apod.mediaType != 'image') return;
    
    try {
      final success = await MediaService().saveImageToGallery(widget.apod);
      
      if (context.mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Image saved to gallery'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save image: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

/// Compact APOD card for list views
class CompactApodCard extends StatelessWidget {
  final ApodModel apod;
  final VoidCallback? onTap;
  final bool showFavoriteButton;
  
  const CompactApodCard({
    Key? key,
    required this.apod,
    this.onTap,
    this.showFavoriteButton = true,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final heroTag = 'compact_apod_${apod.date}_${DateTime.now().millisecondsSinceEpoch}';
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        onTap: onTap ?? () => AppRouter.goToDetail(context, apod, heroTag: heroTag),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: AspectRatio(
            aspectRatio: 1,
            child: CustomNetworkImage(
              imageUrl: apod.url,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              heroTag: heroTag,
            ),
          ),
        ),
        title: Text(
          apod.title,
          style: AppTypography.bodyLarge(context).copyWith(
            color: AppColors.getTextColor(Theme.of(context).brightness == Brightness.dark),
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              Formatters.formatDisplayDate(DateTime.parse(apod.date)),
              style: AppTypography.bodySmall(context).copyWith(
                color: AppColors.getSecondaryTextColor(Theme.of(context).brightness == Brightness.dark),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              apod.explanation.truncate(60),
              style: AppTypography.bodySmall(context).copyWith(
                color: AppColors.getSecondaryTextColor(Theme.of(context).brightness == Brightness.dark),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: showFavoriteButton
            ? Consumer<FavoritesProvider>(
                builder: (context, favoritesProvider, child) {
                  final isFavorite = favoritesProvider.isFavorite(apod.date);
                  
                  return IconButton(
                    onPressed: () => _toggleFavorite(context, favoritesProvider),
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? AppColors.error : AppColors.getSecondaryTextColor(Theme.of(context).brightness == Brightness.dark),
                    ),
                  );
                },
              )
            : Icon(
                apod.mediaType == 'video' 
                    ? Icons.play_circle_outline 
                    : Icons.image_outlined,
                color: AppColors.getSecondaryTextColor(Theme.of(context).brightness == Brightness.dark),
              ),
        isThreeLine: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
  
  void _toggleFavorite(BuildContext context, FavoritesProvider provider) {
    if (provider.isFavorite(apod.date)) {
      provider.removeFavorite(apod.date);
      ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(
           content: Text('Removed from favorites'),
           duration: Duration(seconds: 2),
         ),
       );
    } else {
      provider.addFavorite(apod);
      ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(
           content: Text('Added to favorites'),
           duration: Duration(seconds: 2),
         ),
       );
    }
  }
}

/// Grid APOD card for grid views
class GridApodCard extends StatelessWidget {
  final ApodModel apod;
  final VoidCallback? onTap;
  final bool showFavoriteButton;
  
  const GridApodCard({
    Key? key,
    required this.apod,
    this.onTap,
    this.showFavoriteButton = true,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final heroTag = 'grid_apod_${apod.date}_${DateTime.now().millisecondsSinceEpoch}';
    
    return Card(
      margin: const EdgeInsets.all(4),
      child: InkWell(
        onTap: onTap ?? () => AppRouter.goToDetail(context, apod, heroTag: heroTag),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: CustomNetworkImage(
                      imageUrl: apod.url,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      heroTag: heroTag,
                    ),
                  ),
                  
                  // Media type indicator
                  if (apod.mediaType == 'video')
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(ColorUtils.safeAlpha(0.7)),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  
                  // Favorite button
                  if (showFavoriteButton)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Consumer<FavoritesProvider>(
                        builder: (context, favoritesProvider, child) {
                          final isFavorite = favoritesProvider.isFavorite(apod.date);
                          
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(ColorUtils.safeAlpha(0.5)),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              onPressed: () => _toggleFavorite(context, favoritesProvider),
                              icon: Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: isFavorite ? AppColors.error : Colors.white,
                                size: 16,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 28,
                                minHeight: 28,
                              ),
                              padding: EdgeInsets.zero,
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
            
            // Content section
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      apod.title,
                      style: AppTypography.bodyMedium(context).copyWith(
                        color: AppColors.getTextColor(Theme.of(context).brightness == Brightness.dark),
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                        Formatters.formatDisplayDate(DateTime.parse(apod.date)),
                      style: AppTypography.bodySmall(context).copyWith(
                        color: AppColors.getSecondaryTextColor(Theme.of(context).brightness == Brightness.dark),
                      ),
                    ),
                    
                    const Spacer(),
                    
                    Text(
                      apod.explanation.truncate(50),
                      style: AppTypography.bodySmall(context).copyWith(
                        color: AppColors.getSecondaryTextColor(Theme.of(context).brightness == Brightness.dark),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
  
  void _toggleFavorite(BuildContext context, FavoritesProvider provider) {
    if (provider.isFavorite(apod.date)) {
      provider.removeFavorite(apod.date);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dihapus dari favorit'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      provider.addFavorite(apod);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ditambahkan ke favorit'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}