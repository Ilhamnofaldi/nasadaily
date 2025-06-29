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
import '../services/media_service.dart';
import '../themes/app_colors.dart';
import 'package:intl/intl.dart';

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
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _downloadImage() async {
    if (widget.apod.mediaType != 'image') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Hanya gambar yang bisa diunduh'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final success = await _mediaService.saveImageToGallery(widget.apod);
    
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Gambar berhasil disimpan ke galeri'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        // Check if permission is denied
        final hasPermission = await _mediaService.hasStoragePermission();
        if (!hasPermission) {
          _mediaService.showPermissionDialog(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Gagal menyimpan gambar'),
              backgroundColor: Theme.of(context).colorScheme.error,
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
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Untuk landscape dan layar lebar, gunakan layout side-by-side
    if (isLandscape && screenWidth > 600) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.apod.title),
          backgroundColor: Theme.of(context).colorScheme.surface,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          elevation: 0,
          actions: _buildAppBarActions(),
        ),
        body: Row(
          children: [
            // Left side - Image
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: widget.heroTagPrefix != null 
                        ? '${widget.heroTagPrefix}apod_image_${widget.apod.date}' 
                        : 'apod_image_${widget.apod.date}',
                    child: InkWell(
                      onTap: () => _openFullScreenImage(context),
                      child: Container(
                        margin: const EdgeInsets.all(16),
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
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Video play button overlay
                  if (widget.apod.mediaType == 'video')
                    Positioned.fill(
                      child: Container(
                        margin: const EdgeInsets.all(16),
                        child: Center(
                          child: GestureDetector(
                            onTap: () => _openVideo(widget.apod.url),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.black.withAlpha(ColorUtils.safeAlpha(0.6)),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(ColorUtils.safeAlpha(0.3)),
                                    blurRadius: 25,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.play_arrow,
                                color: Colors.white,
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
            // Right side - Content
            Expanded(
              flex: 3,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.apod.title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.getTextColor(isDark),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Metadata section (date & copyright) - vertical layout
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date row
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 18,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              DateFormat.yMMMMd().format(DateTime.parse(widget.apod.date)),
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                        
                        // Copyright row - only if copyright exists
                        if (widget.apod.copyright != null && widget.apod.copyright!.trim().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: _buildCopyrightInfo(widget.apod.copyright!, isDark),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                          ],
                          stops: const [0.0, 1.0],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  Icons.description,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Description',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.getTextColor(isDark),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.apod.explanation,
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              color: AppColors.getTextColor(isDark),
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
      );
    }
    
    // Untuk portrait atau layar kecil, gunakan layout vertikal
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.apod.title),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        actions: _buildAppBarActions(),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero image with improved design
            Stack(
              children: [
                Hero(
                  tag: widget.heroTagPrefix != null 
                      ? '${widget.heroTagPrefix}apod_image_${widget.apod.date}' 
                      : 'apod_image_${widget.apod.date}',
                  child: InkWell(
                    onTap: () => _openFullScreenImage(context),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.4,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(ColorUtils.safeAlpha(0.3)),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: EnhancedImageLoader(
                        imageUrl: widget.apod.displayUrl,
                        mediaType: widget.apod.mediaType,
                        title: widget.apod.title,
                        fit: BoxFit.cover,
                      ),
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
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(ColorUtils.safeAlpha(0.6)),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(ColorUtils.safeAlpha(0.3)),
                                blurRadius: 25,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 56,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Content with improved design
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.apod.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.getTextColor(isDark),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Metadata section (date & copyright) - vertical layout
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date row
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 18,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat.yMMMMd().format(DateTime.parse(widget.apod.date)),
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                      
                      // Copyright row - only if copyright exists
                      if (widget.apod.copyright != null && widget.apod.copyright!.trim().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: _buildCopyrightInfo(widget.apod.copyright!, isDark),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                        ],
                        stops: const [0.0, 1.0],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                Icons.description,
                                color: Theme.of(context).colorScheme.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Description',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.getTextColor(isDark),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.apod.explanation,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: AppColors.getTextColor(isDark),
                          ),
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

  List<Widget> _buildAppBarActions() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      Container(
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: AppColors.getSurfaceColor(isDark).withAlpha(ColorUtils.safeAlpha(0.9)),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowMedium,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          icon: Icon(
            _isFavorite ? Icons.favorite : Icons.favorite_outline,
            color: _isFavorite ? AppColors.error : AppColors.getSecondaryTextColor(isDark),
            size: 24,
          ),
          onPressed: _toggleFavorite,
          tooltip: _isFavorite ? 'Remove from favorites' : 'Add to favorites',
        ),
      ),
      Container(
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: AppColors.getSurfaceColor(isDark).withAlpha(ColorUtils.safeAlpha(0.9)),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowMedium,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          icon: Icon(
            Icons.download,
            color: AppColors.getSecondaryTextColor(isDark),
            size: 24,
          ),
          onPressed: _downloadImage,
          tooltip: 'Download',
        ),
      ),
      Container(
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: AppColors.getSurfaceColor(isDark).withAlpha(ColorUtils.safeAlpha(0.9)),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowMedium,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          icon: Icon(
            Icons.share,
            color: AppColors.getSecondaryTextColor(isDark),
            size: 24,
          ),
          onPressed: () => _shareApod(),
          tooltip: 'Share',
        ),
      ),
    ];
  }

  void _openFullScreenImage(BuildContext context) {
    print("di klik coy>>>>>>>>>>>>>>>>>>>>>>>>>>>");
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

  // Custom widget untuk menampilkan copyright dengan cara yang pasti bekerja
  Widget _buildCopyrightInfo(String copyright, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.copyright,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              copyright,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
