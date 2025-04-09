import 'package:flutter/material.dart';

class ImageLoader extends StatefulWidget {
  final String imageUrl;
  final double? height;
  final double? width;
  final BoxFit fit;

  const ImageLoader({
    Key? key,
    required this.imageUrl,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  @override
  State<ImageLoader> createState() => _ImageLoaderState();
}

class _ImageLoaderState extends State<ImageLoader> with SingleTickerProviderStateMixin {
  late Image _image;
  bool _isLoading = true;
  bool _hasError = false;
  late AnimationController _controller;
  late Animation<double> _animation;

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
    
    _controller.forward();
    
    _image = Image.network(
      widget.imageUrl,
      fit: widget.fit,
      height: widget.height,
      width: widget.width,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          _isLoading = false;
          return FadeTransition(
            opacity: _animation,
            child: child,
          );
        }
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded / 
                  loadingProgress.expectedTotalBytes!
                : null,
            color: Theme.of(context).colorScheme.primary,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        _hasError = true;
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 40, color: Colors.red),
              const SizedBox(height: 8),
              Text(
                'Failed to load image',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        );
      },
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
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
      child: _image,
    );
  }
}
