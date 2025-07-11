import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nasa_daily_snapshot/models/apod_model.dart';
import 'package:nasa_daily_snapshot/providers/favorites_provider.dart';
import 'package:nasa_daily_snapshot/widgets/zoomable_image.dart';
import 'package:nasa_daily_snapshot/widgets/image_loader.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nasa_daily_snapshot/utils/color_utils.dart';

class DetailScreen extends StatefulWidget {
  final ApodModel apod;
  final FavoritesProvider favoritesProvider;
  final String? heroTagPrefix; // Add this

  const DetailScreen({
    Key? key, 
    required this.apod,
    required this.favoritesProvider,
    this.heroTagPrefix, // Add this
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
        onPressed: () => (context),
        tooltip: 'Share',
        child: const Icon(Icons.share),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: MediaQuery.of(context).size.height * 0.5,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: widget.heroTagPrefix != null 
              ? '${widget.heroTagPrefix}apod_image_${widget.apod.date}' 
              : 'apod_image_${widget.apod.date}',
          child: GestureDetector(
            onTap: () => _openFullScreenImage(context),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (widget.apod.mediaType == 'image')
                  ImprovedImageLoader(
                    imageUrl: widget.apod.displayUrl,
                    mediaType: widget.apod.mediaType, // Added mediaType
                    fit: BoxFit.cover,
                    width: double.infinity, // Ensure it takes full width
                    height: MediaQuery.of(context).size.height * 0.5, // Match expandedHeight
                  ),
                if (widget.apod.mediaType == 'video')
                  Center(
                    child: IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(ColorUtils.safeAlpha(0.6)),
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

  void _openFullScreenImage(BuildContext context) {
    if (widget.apod.mediaType == 'image') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ZoomableImage(imageUrl: widget.apod.displayUrl),
        ),
      );
    }
    // Jika video, mungkin tidak melakukan apa-apa atau membuka pemutar video kustom jika ada
  }

  Future<void> _openVideo(String url) async {
    final Uri videoUrl = Uri.parse(url);
    if (await canLaunchUrl(videoUrl)) {
      await launchUrl(videoUrl, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Padding(
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


}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
