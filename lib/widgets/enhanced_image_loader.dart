import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../themes/app_colors.dart';
import '../themes/app_typography.dart';
import '../utils/extensions.dart';
import '../utils/color_utils.dart';
import '../core/app_exceptions.dart';
import '../core/error_handler.dart';
import 'common_widgets.dart';

/// Enhanced image loader with video support and error handling
class EnhancedImageLoader extends StatefulWidget {
  final String imageUrl;
  final String? videoUrl;
  final String mediaType;
  final String title;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final String? heroTag;
  final bool showVideoOverlay;
  final bool enableZoom;
  final VoidCallback? onImageTap;
  final VoidCallback? onVideoTap;
  
  const EnhancedImageLoader({
    Key? key,
    required this.imageUrl,
    this.videoUrl,
    this.mediaType = 'image',
    this.title = '',
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.heroTag,
    this.showVideoOverlay = true,
    this.enableZoom = false,
    this.onImageTap,
    this.onVideoTap,
  }) : super(key: key);
  
  @override
  State<EnhancedImageLoader> createState() => _EnhancedImageLoaderState();
}

class _EnhancedImageLoaderState extends State<EnhancedImageLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    Widget imageWidget = _buildImageWidget();
    
    if (widget.borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: widget.borderRadius!,
        child: imageWidget,
      );
    }
    
    if (widget.heroTag != null) {
      imageWidget = Hero(
        tag: widget.heroTag!,
        child: imageWidget,
      );
    }
    
    if (widget.enableZoom) {
      imageWidget = _buildZoomableImage(imageWidget);
    }
    
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: imageWidget,
        );
      },
    );
  }
  
  Widget _buildImageWidget() {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Main image
          _buildCachedImage(),
          
          // Video overlay
          if (widget.mediaType == 'video' && widget.showVideoOverlay)
            _buildVideoOverlay(),
          
          // Loading indicator
          if (_isLoading)
            _buildLoadingIndicator(),
          
          // Error display
          if (_hasError)
            _buildErrorDisplay(),
        ],
      ),
    );
  }
  
  Widget _buildCachedImage() {
    return CachedNetworkImage(
      imageUrl: widget.imageUrl,
      fit: widget.fit,
      placeholder: (context, url) => _buildPlaceholder(),
      errorWidget: (context, url, error) => _buildErrorWidget(error),
      imageBuilder: (context, imageProvider) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _isLoading = false;
              _hasError = false;
            });
          }
        });
        
        return GestureDetector(
          onTap: widget.onImageTap ?? _handleImageTap,
          onTapDown: (_) => _animationController.forward(),
          onTapUp: (_) => _animationController.reverse(),
          onTapCancel: () => _animationController.reverse(),
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: imageProvider,
                fit: widget.fit,
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildVideoOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withAlpha(ColorUtils.safeAlpha(0.3)),
            ],
          ),
        ),
        child: Center(
          child: GestureDetector(
            onTap: widget.onVideoTap ?? _handleVideoTap,
            onTapDown: (_) => _animationController.forward(),
            onTapUp: (_) => _animationController.reverse(),
            onTapCancel: () => _animationController.reverse(),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(ColorUtils.safeAlpha(0.7)),
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
      ),
    );
  }
  
  Widget _buildLoadingIndicator() {
    return Container(
      color: AppColors.getBackgroundColor(Theme.of(context).brightness == Brightness.dark).withAlpha(ColorUtils.safeAlpha(0.8)),
      child: const Center(
        child: LoadingIndicator(),
      ),
    );
  }
  
  Widget _buildErrorDisplay() {
    return Container(
      color: AppColors.getBackgroundColor(Theme.of(context).brightness == Brightness.dark),
      child: ErrorDisplay(
        message: _errorMessage ?? 'Gagal memuat gambar',
        onRetry: _retryLoadImage,
      ),
    );
  }
  
  Widget _buildPlaceholder() {
    final shimmerColors = AppColors.getShimmerColors(Theme.of(context).brightness == Brightness.dark);
    return Container(
      color: shimmerColors.first,
      child: ShimmerLoading(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: shimmerColors.first,
        ),
      ),
    );
  }
  
  Widget _buildErrorWidget(dynamic error) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final appException = ErrorHandler().handleError(error);
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = ErrorHandler().getUserFriendlyMessage(appException);
        });
      }
    });
    
    return Container(
      color: AppColors.getBackgroundColor(Theme.of(context).brightness == Brightness.dark),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image_outlined,
            size: 48,
            color: AppColors.getSecondaryTextColor(Theme.of(context).brightness == Brightness.dark),
          ),
          const SizedBox(height: 8),
          Text(
            'Gagal memuat gambar',
            style: AppTypography.bodySmall(context).copyWith(
              color: AppColors.getSecondaryTextColor(Theme.of(context).brightness == Brightness.dark),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildZoomableImage(Widget imageWidget) {
    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 3.0,
      child: imageWidget,
    );
  }
  
  void _handleImageTap() {
    if (widget.mediaType == 'video') {
      _handleVideoTap();
    } else {
      _showImageDialog();
    }
  }
  
  void _handleVideoTap() {
    if (widget.videoUrl != null) {
      _launchVideo(widget.videoUrl!);
    } else {
      context.showSnackBar('URL video tidak tersedia');
    }
  }
  
  void _showImageDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            // Background
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                color: Colors.black.withAlpha(ColorUtils.safeAlpha(0.8)),
              ),
            ),
            
            // Image
            Center(
              child: Container(
                margin: const EdgeInsets.all(20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 3.0,
                    child: CachedNetworkImage(
                      imageUrl: widget.imageUrl,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const LoadingIndicator(),
                      errorWidget: (context, url, error) => const ErrorDisplay(
                        message: 'Gagal memuat gambar',
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Close button
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 30,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withAlpha(ColorUtils.safeAlpha(0.5)),
                ),
              ),
            ),
            
            // Title
            if (widget.title.isNotEmpty)
              Positioned(
                bottom: 40,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(ColorUtils.safeAlpha(0.7)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.title,
                    style: AppTypography.headline6(context).copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _launchVideo(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw VideoException.playbackFailed(url);
      }
    } catch (e) {
      final appException = ErrorHandler().handleError(e);
      final message = ErrorHandler().getUserFriendlyMessage(appException);
      
      if (mounted) {
        context.showSnackBar(message);
      }
    }
  }
  
  void _retryLoadImage() {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });
  }
}

/// Simple image loader for basic use cases
class SimpleImageLoader extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final String? heroTag;
  
  const SimpleImageLoader({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.heroTag,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    Widget imageWidget = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => ShimmerImagePlaceholder(
        width: width,
        height: height,
        borderRadius: borderRadius,
      ),
      errorWidget: (context, url, error) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.getBackgroundColor(Theme.of(context).brightness == Brightness.dark),
          borderRadius: borderRadius,
          border: Border.all(
            color: AppColors.getBorderColor(Theme.of(context).brightness == Brightness.dark),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image_outlined,
              size: 32,
              color: AppColors.getSecondaryTextColor(Theme.of(context).brightness == Brightness.dark),
            ),
            const SizedBox(height: 8),
            Text(
              'Gagal memuat',
              style: AppTypography.bodySmall(context).copyWith(
                color: AppColors.getSecondaryTextColor(Theme.of(context).brightness == Brightness.dark),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
    
    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }
    
    if (heroTag != null) {
      imageWidget = Hero(
        tag: heroTag!,
        child: imageWidget,
      );
    }
    
    return imageWidget;
  }
}

/// Avatar image loader for profile pictures
class AvatarImageLoader extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double size;
  final Color? backgroundColor;
  final Color? textColor;
  
  const AvatarImageLoader({
    Key? key,
    this.imageUrl,
    this.name,
    this.size = 40,
    this.backgroundColor,
    this.textColor,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: imageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (context, url) => _buildPlaceholder(context),
          errorWidget: (context, url, error) => _buildPlaceholder(context),
        ),
      );
    }
    
    return _buildPlaceholder(context);
  }
  
  Widget _buildPlaceholder(BuildContext context) {
    final initials = _getInitials();
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: AppTypography.bodyMedium(context).copyWith(
            color: textColor ?? AppColors.onPrimary,
            fontWeight: FontWeight.w600,
            fontSize: size * 0.4,
          ),
        ),
      ),
    );
  }
  
  String _getInitials() {
    if (name == null || name!.isEmpty) {
      return '?';
    }
    
    final words = name!.trim().split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else {
      return words[0][0].toUpperCase();
    }
  }
}