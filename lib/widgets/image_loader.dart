import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/color_utils.dart'; 

// Helper untuk format ukuran file - DIEKSTRAK KE TOP LEVEL
String _formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}

int _safePercentage(double value) {
  if (value.isNaN || value.isInfinite) return 0;
  if (value < 0) return 0;
  if (value > 100) return 100;
  return value.toInt();
}

int? _safeToInt(double? value) {
  if (value == null) return null;
  if (value.isNaN || value.isInfinite) return null;
  return value.toInt();
}

class ImprovedImageLoader extends StatefulWidget {
  final String imageUrl;
  final double? height;
  final double? width;
  final BoxFit fit;
  final String mediaType; // Added mediaType

  const ImprovedImageLoader({
    Key? key,
    required this.imageUrl,
    required this.mediaType, // Added mediaType
    this.height,
    this.width,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  @override
  State<ImprovedImageLoader> createState() => _ImprovedImageLoaderState();
}

class _ImprovedImageLoaderState extends State<ImprovedImageLoader> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  UniqueKey _imageKey = UniqueKey();

  void _retryImageLoad() {
    setState(() {
      _imageKey = UniqueKey();
    });
  }

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _isValidImageUrl(String url) {
    if (url.isEmpty) return false;
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    // Allow data URIs, common image schemes, and common image extensions
    if (uri.scheme == 'data') return true;
    if (uri.scheme != 'http' && uri.scheme != 'https') return false; 

    final path = uri.path.toLowerCase();
    return path.endsWith('.jpeg') ||
           path.endsWith('.jpg') ||
           path.endsWith('.png') ||
           path.endsWith('.gif') ||
           path.endsWith('.webp') ||
           path.endsWith('.bmp');
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrl.isEmpty || !_isValidImageUrl(widget.imageUrl)) {
      return Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(ColorUtils.safeAlpha(0.2)),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.mediaType == 'video'
                ? Icons.ondemand_video_rounded
                : Icons.image_not_supported_outlined,
              size: (widget.height ?? 40) * 0.4, // Relative icon size
              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                widget.mediaType == 'video'
                  ? 'Video preview unavailable'
                  : 'No preview available',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      height: widget.height,
      width: widget.width,
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(ColorUtils.safeAlpha(0.3)),
      child: CachedNetworkImage(
        key: _imageKey,
        imageUrl: widget.imageUrl,
        fit: widget.fit,
        height: widget.height,
        width: widget.width,
        
        // 🔥 SOLUSI 6: Progressive loading dengan thumbnail
        progressIndicatorBuilder: (context, url, downloadProgress) {
          return Container(
            height: widget.height,
            width: widget.width,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(ColorUtils.safeAlpha(0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  value: downloadProgress.progress,
                  color: Theme.of(context).colorScheme.primary,
                  strokeWidth: 3,
                ),
                const SizedBox(height: 12),
                Text(
                  downloadProgress.progress != null 
                    ? '${_safePercentage(downloadProgress.progress! * 100)}%'
                    : 'Loading...',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (downloadProgress.totalSize != null && downloadProgress.downloaded > 0)
                  Text(
                    '${_formatBytes(downloadProgress.downloaded)} / ${_formatBytes(downloadProgress.totalSize!)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
              ],
            ),
          );
        },
        
        // 🔥 SOLUSI 7: Better error handling
        errorWidget: (context, url, error) {
          return GestureDetector(
            onTap: _retryImageLoad,
            child: Container(
              height: widget.height,
              width: widget.width,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer.withAlpha(ColorUtils.safeAlpha(0.3)),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.error.withOpacity(0.3),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 40,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Failed to load image',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap to retry',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        
        // 🔥 SOLUSI 8: Smooth fade-in animation
        fadeInDuration: const Duration(milliseconds: 500),
        fadeOutDuration: const Duration(milliseconds: 200),
        
        // 🔥 SOLUSI 9: Image caching untuk performa
        memCacheHeight: _safeToInt(widget.height),
        memCacheWidth: _safeToInt(widget.width),
        maxHeightDiskCache: 1000, // Resize untuk menghemat storage
        maxWidthDiskCache: 1000,
        
        // Tambahan: Retry on tap jika error
        imageBuilder: (context, imageProvider) {
          _controller.forward();
          return FadeTransition(
            opacity: _animation,
            child: Image(
              image: imageProvider,
              fit: widget.fit,
              height: widget.height,
              width: widget.width,
            ),
          );
        },
      ),
    );
  }
}

// 🔥 SOLUSI 10: Fallback image loader tanpa cached_network_image
class BasicImageLoader extends StatefulWidget {
  final String imageUrl;
  final double? height;
  final double? width;
  final BoxFit fit;

  const BasicImageLoader({
    Key? key,
    required this.imageUrl,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  @override
  State<BasicImageLoader> createState() => _BasicImageLoaderState();
}

class _BasicImageLoaderState extends State<BasicImageLoader> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: widget.width,
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(ColorUtils.safeAlpha(0.3)),
      child: Image.network(
        widget.imageUrl,
        fit: widget.fit,
        height: widget.height,
        width: widget.width,
        
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            _controller.forward();
            return FadeTransition(
              opacity: _animation,
              child: child,
            );
          }
          
          final progress = loadingProgress.expectedTotalBytes != null
              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
              : null;
              
          return Container(
            height: widget.height,
            width: widget.width,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(ColorUtils.safeAlpha(0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  color: Theme.of(context).colorScheme.primary,
                  strokeWidth: 3,
                ),
                const SizedBox(height: 12),
                Text(
                  progress != null 
                    ? '${_safePercentage(progress * 100)}%'
                    : 'Loading...',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (loadingProgress.expectedTotalBytes != null)
                  Text(
                    '${_formatBytes(loadingProgress.cumulativeBytesLoaded)} / ${_formatBytes(loadingProgress.expectedTotalBytes!)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
              ],
            ),
          );
        },
        
        errorBuilder: (context, error, stackTrace) {
          return GestureDetector(
            onTap: () {
              // Retry dengan rebuild
              setState(() {
                _hasError = !_hasError;
              });
            },
            child: Container(
              height: widget.height,
              width: widget.width,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer.withAlpha(ColorUtils.safeAlpha(0.3)),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.error.withOpacity(0.3),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 40,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Failed to load image',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap to retry',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}