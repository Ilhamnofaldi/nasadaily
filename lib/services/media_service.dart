import 'dart:io';
import 'dart:typed_data';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import '../models/apod_model.dart';
import '../utils/app_logger.dart';
import 'notification_service.dart';

/// Service for handling media operations like saving and sharing images
class MediaService {
  static final MediaService _instance = MediaService._internal();
  factory MediaService() => _instance;
  MediaService._internal();

  final Dio _dio = Dio();
  final NotificationService _notificationService = NotificationService();

  /// Save image to device gallery
  Future<bool> saveImageToGallery(ApodModel apod) async {
    try {
      // Request storage permission
      final permission = await _requestStoragePermission();
      if (!permission) {
        AppLogger.warning('Storage permission denied');
        return false;
      }

      // Show saving notification
      await _notificationService.showSavingNotification(apod.title);

      // Download image
      final imageData = await _downloadImage(apod.url);
      if (imageData == null) {
        await _notificationService.showSaveFailedNotification(apod.title);
        return false;
      }

      // Save to gallery using gal package
      await Gal.putImageBytes(
        imageData,
        name: 'NASA_APOD_${apod.date}',
      );

      await _notificationService.showSaveSuccessNotification(apod.title);
      AppLogger.info('Image saved successfully: ${apod.title}');
      return true;
    } catch (e) {
      AppLogger.error('Error saving image: $e');
      await _notificationService.showSaveFailedNotification(apod.title);
      return false;
    }
  }

  /// Share APOD content
  Future<void> shareApod(ApodModel apod, {String? imageUrl}) async {
    try {
      final text = '''🌌 ${apod.title}

${apod.explanation.length > 200 ? '${apod.explanation.substring(0, 200)}...' : apod.explanation}

📅 ${apod.date}
🔗 Sumber: NASA APOD''';

      if (imageUrl != null && imageUrl.isNotEmpty) {
        // Share with image
        final imageData = await _downloadImage(imageUrl);
        if (imageData != null) {
          final tempDir = await getTemporaryDirectory();
          final file = File('${tempDir.path}/nasa_apod_${apod.date}.jpg');
          await file.writeAsBytes(imageData);
          
          await Share.shareXFiles(
            [XFile(file.path)],
            text: text,
            subject: 'NASA APOD - ${apod.title}',
          );
          return;
        }
      }

      // Share text only if image sharing fails
      await Share.share(
        text,
        subject: 'NASA APOD - ${apod.title}',
      );
    } catch (e) {
      AppLogger.error('Error sharing APOD: $e');
      // Fallback to text-only sharing
      await Share.share(
        '🌌 ${apod.title}\n\n📅 ${apod.date}\n🔗 Sumber: NASA APOD',
        subject: 'NASA APOD - ${apod.title}',
      );
    }
  }

  /// Download image from URL
  Future<Uint8List?> _downloadImage(String imageUrl) async {
    try {
      final response = await _dio.get(
        imageUrl,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        return Uint8List.fromList(response.data);
      }
      return null;
    } catch (e) {
      AppLogger.error('Error downloading image: $e');
      return null;
    }
  }

  /// Request storage permission
  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt <= 32) {
        // For Android 12 and below
        final status = await Permission.storage.request();
        return status.isGranted;
      } else {
        // For Android 13 and above
        final status = await Permission.photos.request();
        return status.isGranted;
      }
    } else if (Platform.isIOS) {
      final status = await Permission.photos.request();
      return status.isGranted;
    }
    return true; // For other platforms
  }

  /// Check if storage permission is granted
  Future<bool> hasStoragePermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt <= 32) {
        return await Permission.storage.isGranted;
      } else {
        return await Permission.photos.isGranted;
      }
    } else if (Platform.isIOS) {
      return await Permission.photos.isGranted;
    }
    return true;
  }

  /// Show permission dialog
  Future<void> showPermissionDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Izin Diperlukan'),
        content: const Text(
          'Aplikasi memerlukan izin akses penyimpanan untuk menyimpan gambar ke galeri Anda.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('Buka Pengaturan'),
          ),
        ],
      ),
    );
  }
}