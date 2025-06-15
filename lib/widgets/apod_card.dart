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

/// APOD card widget for displaying astronomy picture of the day
class ApodCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final heroTag = 'apod_${apod.date}_${DateTime.now().millisecondsSinceEpoch}';
    
    return Container(
      width: width,
      height: height,
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 2,
        shadowColor: AppColors.shadowLight,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: onTap ?? () => _navigateToDetail(context),
          borderRadius: borderRadius ?? BorderRadius.circular(12),
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
    );
  }
  
  Widget _buildImageSection(BuildContext context, String heroTag) {
    return Stack(
      children: [
        // Main image
        ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(borderRadius?.topLeft.x ?? 12),
            topRight: Radius.circular(borderRadius?.topRight.x ?? 12),
          ),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: CustomNetworkImage(
              imageUrl: apod.url,
              fit: BoxFit.cover,
              heroTag: heroTag,
              placeholder: const ShimmerImagePlaceholder(
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
        ),
        
        // Media type indicator
        if (apod.mediaType == 'video')
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(ColorUtils.safeAlpha(0.7)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.play_circle_outline,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Video',
                    style: AppTypography.labelSmall(context).copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        
        // Favorite button
        if (showFavoriteButton)
          Positioned(
            top: 8,
            right: 8,
            child: _buildFavoriteButton(context),
          ),
        
        // Date overlay
        if (showDate)
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(ColorUtils.safeAlpha(0.7)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                Formatters.formatDisplayDate(DateTime.parse(apod.date)),
                style: AppTypography.labelSmall(context).copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildContentSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            apod.title,
            style: AppTypography.headline6(context).copyWith(
              color: AppColors.getTextColor(Theme.of(context).brightness == Brightness.dark),
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 8),
          
          // Date (if not shown as overlay)
          if (!showDate)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                Formatters.formatDisplayDate(DateTime.parse(apod.date)),
                style: AppTypography.bodySmall(context).copyWith(
                  color: AppColors.getSecondaryTextColor(Theme.of(context).brightness == Brightness.dark),
                ),
              ),
            ),
          
          // Explanation
          if (showExplanation && apod.explanation.isNotEmpty)
            Text(
              apod.explanation.truncate(120),
              style: AppTypography.bodyMedium(context).copyWith(
                color: AppColors.getSecondaryTextColor(Theme.of(context).brightness == Brightness.dark),
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          
          const SizedBox(height: 12),
          
          // Action buttons
          _buildActionButtons(context),
        ],
      ),
    );
  }
  
  Widget _buildFavoriteButton(BuildContext context) {
    return Consumer<FavoritesProvider>(
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
              size: 20,
            ),
            constraints: const BoxConstraints(
              minWidth: 36,
              minHeight: 36,
            ),
            padding: EdgeInsets.zero,
          ),
        );
      },
    );
  }
  
  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        // Media type chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: apod.mediaType == 'video'
                ? AppColors.accentViolet.withOpacity(0.1)
                : AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                apod.mediaType == 'video' ? Icons.play_circle : Icons.image,
                size: 14,
                color: apod.mediaType == 'video'
                    ? AppColors.accentViolet
                    : AppColors.primary,
              ),
              const SizedBox(width: 4),
              Text(
                apod.mediaType == 'video' ? 'Video' : 'Gambar',
                style: AppTypography.caption(context).copyWith(
                  color: apod.mediaType == 'video'
                      ? AppColors.accentViolet
                      : AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        // Share button
        IconButton(
          onPressed: () => _shareApod(context),
          icon: const Icon(Icons.share, size: 18),
          style: IconButton.styleFrom(
            padding: const EdgeInsets.all(8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          tooltip: 'Bagikan',
        ),
        // Save button (only for images)
        if (apod.mediaType == 'image')
          IconButton(
            onPressed: () => _saveImage(context),
            icon: const Icon(Icons.download, size: 18),
            style: IconButton.styleFrom(
              padding: const EdgeInsets.all(8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            tooltip: 'Simpan Gambar',
          ),
        // View detail button
        TextButton(
          onPressed: () => _navigateToDetail(context),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Lihat Detail',
                style: AppTypography.caption(context).copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_forward_ios,
                size: 12,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  void _navigateToDetail(BuildContext context) {
    AppRouter.goToDetail(context, apod);
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

  Future<void> _shareApod(BuildContext context) async {
    try {
      await MediaService().shareApod(apod);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membagikan: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _saveImage(BuildContext context) async {
    if (apod.mediaType != 'image') return;
    
    try {
      final success = await MediaService().saveImageToGallery(apod);
      
      if (context.mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gambar berhasil disimpan ke galeri'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan gambar: $e'),
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