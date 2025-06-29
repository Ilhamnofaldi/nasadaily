import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../utils/color_utils.dart';
import '../themes/app_colors.dart';

class ZoomableImage extends StatefulWidget {
  final String imageUrl;

  const ZoomableImage({
    Key? key,
    required this.imageUrl,
  }) : super(key: key);

  @override
  State<ZoomableImage> createState() => _ZoomableImageState();
}

class _ZoomableImageState extends State<ZoomableImage> with SingleTickerProviderStateMixin {
  final TransformationController _controller = TransformationController();
  TapDownDetails? _doubleTapDetails;
  bool _showControls = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapDetails = details;
  }

  void _handleDoubleTap() {
    if (_controller.value != Matrix4.identity()) {
      // If zoomed in, zoom out
      _controller.value = Matrix4.identity();
    } else {
      // If zoomed out, zoom in
      if (_doubleTapDetails != null) {
        final position = _doubleTapDetails!.localPosition;
        // Zoom to the point that was tapped
        _controller.value = Matrix4.identity()
          ..translate(-position.dx * 2, -position.dy * 2)
          ..scale(3.0);
      }
    }
  }
  
  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: _showControls ? _buildAppBar() : null,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              AppColors.primaryBlue.withOpacity(0.3),
              Colors.black,
            ],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: GestureDetector(
        onDoubleTapDown: _handleDoubleTapDown,
        onDoubleTap: _handleDoubleTap,
        onTap: _toggleControls,
        child: Stack(
          children: [
            InteractiveViewer(
              transformationController: _controller,
              minScale: 0.5,
              maxScale: 5.0,
              child: Center(
                child: CachedNetworkImage(
                  imageUrl: widget.imageUrl,
                  fit: BoxFit.contain,
                  progressIndicatorBuilder: (context, url, downloadProgress) {
                    return Center(
                          child: _buildProgressIndicator(downloadProgress.progress),
                    );
                  },
                  errorWidget: (context, url, error) {
                        return Center(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.error.withOpacity(0.5),
                                width: 1,
                              ),
                            ),
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                                Icon(Icons.error_outline, color: AppColors.error, size: 50),
                                SizedBox(height: 12),
                                Text(
                                  'Failed to load image',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                          SizedBox(height: 8),
                                Text(
                                  'Tap to retry',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                        ],
                            ),
                      ),
                    );
                  },
                ),
              ),
            ),
                if (_showControls) _buildZoomControls(),
                if (_showControls) _buildInfoOverlay(),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.black.withAlpha(ColorUtils.safeAlpha(0.6)),
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      title: const Text(
        'Cosmic Explorer',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryBlue.withOpacity(0.7),
              Colors.black.withOpacity(0.5),
            ],
          ),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              // Share image
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Sharing image...'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.primaryBlue.withOpacity(0.8),
                ),
              );
            },
            tooltip: 'Share',
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 8, left: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: () {
              // Download image
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Image saved to gallery'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.success.withOpacity(0.8),
                ),
              );
            },
            tooltip: 'Download',
          ),
        ),
      ],
    );
  }
  
  Widget _buildZoomControls() {
    return Positioned(
      bottom: 24,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      decoration: BoxDecoration(
              color: Colors.black.withAlpha(ColorUtils.safeAlpha(0.7)),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: AppColors.primaryPurple.withOpacity(0.5),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryPurple.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                _buildControlButton(
                  icon: Icons.zoom_out,
                  tooltip: 'Zoom Out',
                            onPressed: () {
                              final scale = _controller.value.getMaxScaleOnAxis();
                              if (scale > 0.8) {
                                _controller.value = Matrix4.identity()
                                  ..scale(scale - 0.5);
                              }
                            },
                          ),
                          const SizedBox(width: 16),
                _buildControlButton(
                  icon: Icons.zoom_in,
                  tooltip: 'Zoom In',
                            onPressed: () {
                              final scale = _controller.value.getMaxScaleOnAxis();
                              if (scale < 5.0) {
                                _controller.value = Matrix4.identity()
                                  ..scale(scale + 0.5);
                              }
                            },
                          ),
                          const SizedBox(width: 16),
                _buildControlButton(
                  icon: Icons.refresh,
                  tooltip: 'Reset',
                            onPressed: () {
                              _controller.value = Matrix4.identity();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
  
  Widget _buildInfoOverlay() {
    return Positioned(
      top: 100,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(ColorUtils.safeAlpha(0.7)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.secondaryTeal.withOpacity(0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondaryTeal.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.touch_app,
                  color: AppColors.secondaryTeal,
                  size: 16,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Double tap to zoom',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.pinch,
                  color: AppColors.secondaryTeal,
                  size: 16,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Pinch to zoom in/out',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildControlButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Tooltip(
          message: tooltip,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryPurple.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildProgressIndicator(double? progress) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: Stack(
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 4,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primaryBlue,
                  ),
                ),
                if (progress != null)
                  Center(
                    child: Text(
                      '${(progress * 100).toInt()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Loading cosmic image...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
