import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../utils/app_logger.dart';

/// Service for handling local notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Initialize notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Android initialization settings
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings
      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // macOS initialization settings
      const DarwinInitializationSettings initializationSettingsMacOS =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
        macOS: initializationSettingsMacOS,
      );

      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
      );

      _isInitialized = true;
      AppLogger.info('Notification service initialized successfully');
    } catch (e) {
      AppLogger.error('Failed to initialize notification service: $e');
    }
  }

  /// Handle notification tap
  void _onDidReceiveNotificationResponse(NotificationResponse response) {
    AppLogger.info('Notification tapped: ${response.payload}');
    // Handle notification tap if needed
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    if (!_isInitialized) await initialize();

    try {
      final bool? result = await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      
      return result ?? true;
    } catch (e) {
      AppLogger.error('Failed to request notification permissions: $e');
      return false;
    }
  }

  /// Show notification that image is being saved
  Future<void> showSavingNotification(String title) async {
    if (!_isInitialized) await initialize();

    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'save_channel',
        'Image Save Notifications',
        channelDescription: 'Notifications for image save operations',
        importance: Importance.low,
        priority: Priority.low,
        showProgress: true,
        indeterminate: true,
        ongoing: true,
        autoCancel: false,
      );

      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      await _flutterLocalNotificationsPlugin.show(
        1001,
        'Menyimpan Gambar',
        'Sedang menyimpan "$title" ke galeri...',
        platformChannelSpecifics,
      );
    } catch (e) {
      AppLogger.error('Failed to show saving notification: $e');
    }
  }

  /// Show notification that image was saved successfully
  Future<void> showSaveSuccessNotification(String title) async {
    if (!_isInitialized) await initialize();

    try {
      // Cancel the saving notification
      await _flutterLocalNotificationsPlugin.cancel(1001);

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'save_channel',
        'Image Save Notifications',
        channelDescription: 'Notifications for image save operations',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        icon: '@drawable/ic_check',
      );

      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      await _flutterLocalNotificationsPlugin.show(
        1002,
        'Gambar Tersimpan',
        '"$title" berhasil disimpan ke galeri',
        platformChannelSpecifics,
      );
    } catch (e) {
      AppLogger.error('Failed to show save success notification: $e');
    }
  }

  /// Show notification that image save failed
  Future<void> showSaveFailedNotification(String title) async {
    if (!_isInitialized) await initialize();

    try {
      // Cancel the saving notification
      await _flutterLocalNotificationsPlugin.cancel(1001);

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'save_channel',
        'Image Save Notifications',
        channelDescription: 'Notifications for image save operations',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        icon: '@drawable/ic_error',
      );

      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      await _flutterLocalNotificationsPlugin.show(
        1003,
        'Gagal Menyimpan',
        'Gagal menyimpan "$title" ke galeri',
        platformChannelSpecifics,
      );
    } catch (e) {
      AppLogger.error('Failed to show save failed notification: $e');
    }
  }

  /// Show daily APOD notification
  Future<void> showDailyApodNotification(String title, String explanation) async {
    if (!_isInitialized) await initialize();

    try {
      final AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'daily_apod_channel',
        'Daily APOD Notifications',
        channelDescription: 'Daily notifications for new APOD content',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        icon: '@mipmap/ic_launcher',
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        styleInformation: BigTextStyleInformation(
          explanation.length > 100 
              ? '${explanation.substring(0, 100)}...'
              : explanation,
        ),
      );

      final NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      await _flutterLocalNotificationsPlugin.show(
        2001,
        '🌌 NASA APOD Hari Ini',
        title,
        platformChannelSpecifics,
        payload: 'daily_apod',
      );
    } catch (e) {
      AppLogger.error('Failed to show daily APOD notification: $e');
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
    } catch (e) {
      AppLogger.error('Failed to cancel notifications: $e');
    }
  }

  /// Cancel specific notification
  Future<void> cancelNotification(int id) async {
    try {
      await _flutterLocalNotificationsPlugin.cancel(id);
    } catch (e) {
      AppLogger.error('Failed to cancel notification $id: $e');
    }
  }
}