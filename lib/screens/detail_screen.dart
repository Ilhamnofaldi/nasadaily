import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/apod_model.dart';
import '../models/catatan_model.dart';
import '../providers/favorites_provider.dart';
import '../providers/catatan_provider.dart';
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
  CatatanModel? _existingCatatan;
  final TextEditingController _catatanController = TextEditingController();
  bool _isEditingCatatan = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
    _loadExistingCatatan();
  }

  @override
  void dispose() {
    _catatanController.dispose();
    super.dispose();
  }

  void _checkFavoriteStatus() {
    final favoritesProvider = Provider.of<FavoritesProvider>(context, listen: false);
    setState(() {
      _isFavorite = favoritesProvider.isFavorite(widget.apod.date);
    });
  }

  Future<void> _loadExistingCatatan() async {
    final catatanProvider = Provider.of<CatatanProvider>(context, listen: false);
    final catatan = catatanProvider.getCatatanByApodDate(widget.apod.date);
    setState(() {
      _existingCatatan = catatan;
      if (catatan != null) {
        _catatanController.text = catatan.catatan;
      }
    });
  }

  Future<void> _saveCatatan() async {
    final catatan = _catatanController.text.trim();
    if (catatan.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Catatan tidak boleh kosong'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final catatanProvider = Provider.of<CatatanProvider>(context, listen: false);
    bool success = false;

    if (_existingCatatan != null) {
      // Update existing catatan
      success = await catatanProvider.updateCatatan(
        catatanId: _existingCatatan!.id,
        catatan: catatan,
      );
    } else {
      // Add new catatan
      success = await catatanProvider.addCatatan(
        apod: widget.apod,
        catatan: catatan,
      );
    }

    if (success) {
      setState(() {
        _isEditingCatatan = false;
      });
      await _loadExistingCatatan();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_existingCatatan != null ? 'Catatan berhasil diperbarui' : 'Catatan berhasil ditambahkan'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(catatanProvider.error ?? 'Gagal menyimpan catatan'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _startEditingCatatan() {
    // Check if APOD is favorited before allowing to add/edit note
    if (!_isFavorite && _existingCatatan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.favorite, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text('Favoritkan foto ini terlebih dahulu untuk menambahkan catatan'),
              ),
            ],
          ),
          backgroundColor: Colors.orange[700],
          action: SnackBarAction(
            label: 'Favoritkan',
            textColor: Colors.white,
            onPressed: () async {
              await _toggleFavorite();
              // After favoriting, check status and allow editing
              if (_isFavorite) {
                setState(() {
                  _isEditingCatatan = true;
                });
              }
            },
          ),
        ),
      );
      return;
    }

    setState(() {
      _isEditingCatatan = true;
      if (_existingCatatan != null) {
        _catatanController.text = _existingCatatan!.catatan;
      }
    });
  }

  void _cancelEditingCatatan() {
    setState(() {
      _isEditingCatatan = false;
      if (_existingCatatan != null) {
        _catatanController.text = _existingCatatan!.catatan;
      } else {
        _catatanController.clear();
      }
    });
  }

  Future<void> _deleteCatatan() async {
    if (_existingCatatan == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Catatan'),
        content: const Text('Apakah Anda yakin ingin menghapus catatan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final catatanProvider = Provider.of<CatatanProvider>(context, listen: false);
      final success = await catatanProvider.deleteCatatan(_existingCatatan!.id);
      
      if (success) {
        setState(() {
          _existingCatatan = null;
          _catatanController.clear();
          _isEditingCatatan = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Catatan berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(catatanProvider.error ?? 'Gagal menghapus catatan'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleFavorite() async {
    try {
      if (widget.favoritesProvider != null) {
        await widget.favoritesProvider!.toggleFavorite(widget.apod);
        // Update local state after toggling
        _checkFavoriteStatus();
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
                    // Catatan section
                    _buildCatatanSection(isDark),
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
                  // Catatan section
                  _buildCatatanSection(isDark),
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

  // Widget untuk section catatan
  Widget _buildCatatanSection(bool isDark) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
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
            AppColors.primary.withOpacity(0.1),
            AppColors.secondaryPink.withOpacity(0.1),
          ],
          stops: const [0.0, 1.0],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.note_add,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Catatan Pribadi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getTextColor(isDark),
                  ),
                ),
              ),
              if (_existingCatatan != null && !_isEditingCatatan) ...[
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: _startEditingCatatan,
                  tooltip: 'Edit catatan',
                  color: AppColors.primary,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  onPressed: _deleteCatatan,
                  tooltip: 'Hapus catatan',
                  color: Colors.red,
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          
          // Content
          if (_isEditingCatatan) ...[
            // Edit mode
            TextField(
              controller: _catatanController,
              maxLines: 4,
              style: const TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                hintText: 'Tulis catatan Anda tentang foto NASA ini...',
                hintStyle: TextStyle(color: Colors.grey[600]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _cancelEditingCatatan,
                  child: const Text('Batal'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _saveCatatan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Simpan'),
                ),
              ],
            ),
          ] else if (_existingCatatan != null) ...[
            // Display mode with existing note
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                _existingCatatan!.catatan,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Dibuat: ${_existingCatatan!.formattedCreatedAt}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ] else ...[
            // No note yet
            Column(
              children: [
                Icon(
                  _isFavorite ? Icons.note_add_outlined : Icons.favorite_border,
                  size: 48,
                  color: _isFavorite ? Colors.grey[400] : Colors.orange[300],
                ),
                const SizedBox(height: 8),
                Text(
                  _isFavorite 
                    ? 'Belum ada catatan untuk foto ini'
                    : 'Favoritkan foto ini untuk menambahkan catatan',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                if (_isFavorite) ...[
                  ElevatedButton.icon(
                    onPressed: _startEditingCatatan,
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Catatan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ] else ...[
                  OutlinedButton.icon(
                    onPressed: () async {
                      await _toggleFavorite();
                      if (_isFavorite) {
                        setState(() {
                          _isEditingCatatan = true;
                        });
                      }
                    },
                    icon: const Icon(Icons.favorite),
                    label: const Text('Favoritkan Dulu'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange[700],
                      side: BorderSide(color: Colors.orange[300]!),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}
