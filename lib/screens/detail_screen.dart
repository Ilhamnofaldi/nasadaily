import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/apod_model.dart';
import '../providers/favorites_provider.dart';
import '../widgets/enhanced_image_loader.dart';
import '../widgets/zoomable_image.dart';
import '../utils/color_utils.dart';
import '../utils/formatters.dart';

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

  void _toggleFavorite() {
    final favoritesProvider = Provider.of<FavoritesProvider>(context, listen: false);
    if (_isFavorite) {
      favoritesProvider.removeFavorite(widget.apod.date);
    } else {
      favoritesProvider.addFavorite(widget.apod);
    }
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  void _shareApod() {
    final text = '${widget.apod.title}\n\n${widget.apod.explanation}\n\nImage: ${widget.apod.url}';
    Share.share(text, subject: 'NASA Astronomy Picture of the Day');
  }

  void _openVideo(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          Formatters.formatDisplayDate(widget.apod.date),
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Title
                  Text(
                    widget.apod.title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                                  // Copyright info
                  if (widget.apod.copyright != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.red.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.copyright,
                            size: 16,
                            color: Colors.red[700],
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.apod.copyright!,
                              style: TextStyle(
                                color: Colors.red[700],
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Description section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).shadowColor.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.description,
                                color: Theme.of(context).primaryColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Description',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.apod.explanation,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            height: 1.6,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Media info
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          widget.apod.mediaType == 'video' ? Icons.videocam : Icons.image,
                          color: Theme.of(context).colorScheme.onSecondaryContainer,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Media Type: ${widget.apod.mediaType.toUpperCase()}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _shareApod(),
        tooltip: 'Share',
        child: const Icon(Icons.share),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: MediaQuery.of(context).size.height * 0.4,
      floating: false,
      pinned: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + kToolbarHeight,
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Hero(
                tag: widget.heroTagPrefix != null 
                    ? '${widget.heroTagPrefix}apod_image_${widget.apod.date}' 
                    : 'apod_image_${widget.apod.date}',
                child: GestureDetector(
                  onTap: () => _openFullScreenImage(context),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(ColorUtils.safeAlpha(0.3)),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: EnhancedImageLoader(
                        imageUrl: widget.apod.displayUrl,
                        mediaType: widget.apod.mediaType,
                        title: widget.apod.title,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              // Gradient overlay for better readability
              Positioned(
                left: 16,
                right: 16,
                top: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withAlpha(ColorUtils.safeAlpha(0.2)),
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black.withAlpha(ColorUtils.safeAlpha(0.5)),
                      ],
                      stops: const [0.0, 0.3, 0.7, 1.0],
                    ),
                  ),
                ),
              ),
              // Video play button overlay
              if (widget.apod.mediaType == 'video')
                Positioned.fill(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: Center(
                      child: GestureDetector(
                        onTap: () => _openVideo(widget.apod.url),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(ColorUtils.safeAlpha(0.95)),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(ColorUtils.safeAlpha(0.4)),
                                blurRadius: 25,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.play_arrow,
                            color: Theme.of(context).primaryColor,
                            size: 56,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(ColorUtils.safeAlpha(0.9)),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(ColorUtils.safeAlpha(0.2)),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_outline,
              color: _isFavorite ? Colors.red : Colors.grey[600],
              size: 24,
            ),
            onPressed: _toggleFavorite,
            tooltip: _isFavorite ? 'Remove from favorites' : 'Add to favorites',
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(ColorUtils.safeAlpha(0.9)),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(ColorUtils.safeAlpha(0.2)),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              Icons.share,
              color: Colors.grey[600],
              size: 24,
            ),
            onPressed: () => _shareApod(),
            tooltip: 'Share',
          ),
        ),
      ],
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
