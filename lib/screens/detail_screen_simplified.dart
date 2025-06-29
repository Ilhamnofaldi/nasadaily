import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../models/apod_model.dart';
import '../providers/favorites_provider.dart';
import '../widgets/enhanced_image_loader.dart';
import '../widgets/zoomable_image.dart';
import '../themes/app_colors.dart';
import '../services/media_service.dart';

class DetailScreen extends StatefulWidget {
  final ApodModel apod;
  final String? heroTagPrefix;
  final FavoritesProvider? favoritesProvider;

  const DetailScreen({
    super.key,
    required this.apod,
    this.heroTagPrefix,
    this.favoritesProvider,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _isFavorite = false;
  final MediaService _mediaService = MediaService();
  
  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  void _checkFavoriteStatus() {
    final favoritesProvider = Provider.of<FavoritesProvider>(context, listen: false);
    setState(() {
      _isFavorite = favoritesProvider.isFavorite(widget.apod.date);
    });
  }

  Future<void> _toggleFavorite() async {
    try {
      if (widget.favoritesProvider != null) {
        await widget.favoritesProvider!.toggleFavorite(widget.apod);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update favorite: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _downloadImage() async {
    if (widget.apod.mediaType != 'image') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only images can be downloaded'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final success = await _mediaService.saveImageToGallery(widget.apod);
    
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image saved to gallery'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Check if permission is denied
        final hasPermission = await _mediaService.hasStoragePermission();
        if (!hasPermission) {
          _mediaService.showPermissionDialog(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to save image'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _shareApod() {
    _mediaService.shareApod(widget.apod, imageUrl: widget.apod.url);
  }

  void _openVideo(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : Colors.white,
            ),
            onPressed: _toggleFavorite,
          ),
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: _downloadImage,
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: _shareApod,
          ),
        ],
      ),
      body: Column(
        children: [
          // Image section
          Expanded(
            flex: 5,
            child: _buildHeroImage(isDark),
          ),
          // Content section
          Expanded(
            flex: 7,
            child: Container(
              color: isDark ? Colors.black : Colors.white,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.apod.title,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    
                    if (widget.apod.copyright != null && widget.apod.copyright!.trim().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '© ${widget.apod.copyright}',
                          style: TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ),
                    
                    const SizedBox(height: 16),
                    
                    Text(
                      widget.apod.explanation,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionButton(
                          icon: Icons.download,
                          label: 'Download',
                          onTap: _downloadImage,
                        ),
                        _buildActionButton(
                          icon: Icons.share,
                          label: 'Share',
                          onTap: _shareApod,
                        ),
                        _buildActionButton(
                          icon: _isFavorite ? Icons.favorite : Icons.favorite_border,
                          label: _isFavorite ? 'Favorited' : 'Favorite',
                          onTap: _toggleFavorite,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHeroImage(bool isDark) {
    return Hero(
      tag: widget.heroTagPrefix != null 
          ? '${widget.heroTagPrefix}apod_image_${widget.apod.date}' 
          : 'apod_image_${widget.apod.date}',
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          GestureDetector(
            onTap: () => _openFullScreenImage(context),
            child: EnhancedImageLoader(
              imageUrl: widget.apod.displayUrl,
              mediaType: widget.apod.mediaType,
              title: widget.apod.title,
              fit: BoxFit.cover,
            ),
          ),
          
          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.0),
                ],
              ),
            ),
          ),
          
          // Video play button overlay
          if (widget.apod.mediaType == 'video')
            Positioned.fill(
              child: Center(
                child: GestureDetector(
                  onTap: () => _openVideo(widget.apod.url),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
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
            
          // Date badge
          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                DateFormat.yMMMd().format(DateTime.parse(widget.apod.date)),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(
            icon,
            color: isDark ? AppColors.primaryBlue : AppColors.primaryBlue,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _openFullScreenImage(BuildContext context) {
    if (widget.apod.mediaType == 'image') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ZoomableImage(
            imageUrl: widget.apod.url,
          ),
        ),
      );
    }
  }
}
