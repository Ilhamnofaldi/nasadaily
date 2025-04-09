import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nasa_daily_snapshot/models/apod_model.dart';
import 'package:nasa_daily_snapshot/providers/favorites_provider.dart';
import 'package:nasa_daily_snapshot/widgets/image_loader.dart';
import 'package:nasa_daily_snapshot/widgets/zoomable_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailScreen extends StatefulWidget {
  final ApodModel apod;
  final FavoritesProvider favoritesProvider;

  const DetailScreen({
    Key? key, 
    required this.apod,
    required this.favoritesProvider,
  }) : super(key: key);

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late bool _isFavorite;
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    _isFavorite = widget.favoritesProvider.isFavorite(widget.apod.date);
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: _buildContent(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _shareApod(context),
        child: const Icon(Icons.share),
        tooltip: 'Share',
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: MediaQuery.of(context).size.height * 0.5,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: 'apod_image_${widget.apod.date}',
          child: GestureDetector(
            onTap: () => _openFullScreenImage(context),
            child: Stack(
              fit: StackFit.expand,
              children: [
                ImageLoader(
                  imageUrl: widget.apod.displayUrl,
                  fit: BoxFit.cover,
                ),
                if (widget.apod.mediaType == 'video')
                  Center(
                    child: IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                      onPressed: () => _openVideo(widget.apod.url),
                      tooltip: 'Play Video',
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            _isFavorite ? Icons.favorite : Icons.favorite_outline,
            color: _isFavorite ? Colors.red : null,
          ),
          onPressed: _toggleFavorite,
          tooltip: _isFavorite ? 'Remove from favorites' : 'Add to favorites',
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.apod.title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16),
              const SizedBox(width: 8),
              Text(
                DateFormat.yMMMMd().format(DateTime.parse(widget.apod.date)),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
          ),
          if (widget.apod.copyright != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.copyright, size: 16),
                const SizedBox(width: 8),
                Text(
                  widget.apod.copyright!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Text(
            widget.apod.explanation,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          _buildMetadataSection(),
        ],
      ),
    );
  }

  Widget _buildMetadataSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Image Information',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Divider(),
            if (widget.apod.copyright != null) ...[
              _buildMetadataItem('Copyright', widget.apod.copyright!),
              const SizedBox(height: 8),
            ],
            _buildMetadataItem('Date', widget.apod.date),
            const SizedBox(height: 8),
            _buildMetadataItem('Media Type', widget.apod.mediaType.capitalize()),
            if (widget.apod.mediaType == 'video') ...[
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () => _openVideo(widget.apod.url),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Watch Video'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataItem(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
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
            imageUrl: widget.apod.highResUrl,
          ),
        ),
      );
    } else if (widget.apod.mediaType == 'video') {
      _openVideo(widget.apod.url);
    }
  }
  
  Future<void> _openVideo(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open video'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _toggleFavorite() {
    widget.favoritesProvider.toggleFavorite(widget.apod);
    setState(() {
      _isFavorite = !_isFavorite;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isFavorite 
              ? 'Added to favorites' 
              : 'Removed from favorites'
        ),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _shareApod(BuildContext context) {
    Share.share(
      'Check out this amazing astronomy picture: ${widget.apod.title}\n${widget.apod.url}',
      subject: 'NASA Astronomy Picture of the Day',
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
