import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../utils/color_utils.dart';

class ZoomableImage extends StatefulWidget {
  final String imageUrl;

  const ZoomableImage({
    Key? key,
    required this.imageUrl,
  }) : super(key: key);

  @override
  State<ZoomableImage> createState() => _ZoomableImageState();
}

class _ZoomableImageState extends State<ZoomableImage> {
  final TransformationController _controller = TransformationController();
  TapDownDetails? _doubleTapDetails;
  bool _showControls = true;

  @override
  void dispose() {
    _controller.dispose();
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
      appBar: _showControls ? AppBar(
        backgroundColor: Colors.black.withAlpha(ColorUtils.safeAlpha(0.5)),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Image Viewer', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Share image
            },
            tooltip: 'Share',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              // Download image
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Image saved to gallery'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            tooltip: 'Download',
          ),
        ],
      ) : null,
      body: GestureDetector(
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
                      child: CircularProgressIndicator(
                        value: downloadProgress.progress,
                        color: Colors.white, // Added color for visibility on black background
                      ),
                    );
                  },
                  errorWidget: (context, url, error) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, color: Colors.red, size: 50),
                          SizedBox(height: 8),
                          Text('Failed to load image.', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            if (_showControls)
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(ColorUtils.safeAlpha(0.5)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.zoom_out, color: Colors.white),
                            onPressed: () {
                              final scale = _controller.value.getMaxScaleOnAxis();
                              if (scale > 0.8) {
                                _controller.value = Matrix4.identity()
                                  ..scale(scale - 0.5);
                              }
                            },
                            tooltip: 'Zoom Out',
                          ),
                          const SizedBox(width: 16),
                          IconButton(
                            icon: const Icon(Icons.zoom_in, color: Colors.white),
                            onPressed: () {
                              final scale = _controller.value.getMaxScaleOnAxis();
                              if (scale < 5.0) {
                                _controller.value = Matrix4.identity()
                                  ..scale(scale + 0.5);
                              }
                            },
                            tooltip: 'Zoom In',
                          ),
                          const SizedBox(width: 16),
                          IconButton(
                            icon: const Icon(Icons.refresh, color: Colors.white),
                            onPressed: () {
                              _controller.value = Matrix4.identity();
                            },
                            tooltip: 'Reset',
                          ),
                        ],
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
}
