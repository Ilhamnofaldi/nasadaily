import '../constants/app_constants.dart';

/// Application configuration class
class AppConfig {
  static const bool isDebugMode = true; // Set to false for production
  static const bool enableLogging = true;
  static const bool enableAnalytics = false;
  
  // API Configuration
  static String get apiBaseUrl => AppConstants.nasaApiBaseUrl;
  static String get apiKey => AppConstants.nasaApiKey;
  
  // Feature Flags
  static const bool enableOfflineMode = true;
  static const bool enableImageCaching = true;
  static const bool enableVideoSupport = true;
  static const bool enableNotifications = true;
  static const bool enableSharing = true;
  static const bool enableDownload = true;
  
  // Performance Settings
  static const int maxConcurrentImageLoads = 3;
  static const int imageMemoryCacheSize = 50; // MB
  static const int imageDiskCacheSize = 200; // MB
  
  // UI Settings
  static const bool enableAnimations = true;
  static const bool enableHapticFeedback = true;
  static const bool enableDynamicColors = true;
  
  // Network Settings
  static const Duration networkTimeout = Duration(seconds: 30);
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  
  // Cache Settings
  static Duration get cacheExpiration => AppConstants.cacheExpiration;
  static int get maxCacheSize => AppConstants.maxCacheSize;
  
  // Validation
  static bool get isValidConfig {
    return apiKey.isNotEmpty && apiBaseUrl.isNotEmpty;
  }
  
  // Environment-specific configurations
  static Map<String, dynamic> get environmentConfig {
    return {
      'debug': isDebugMode,
      'logging': enableLogging,
      'analytics': enableAnalytics,
      'api_base_url': apiBaseUrl,
      'features': {
        'offline_mode': enableOfflineMode,
        'image_caching': enableImageCaching,
        'video_support': enableVideoSupport,
        'notifications': enableNotifications,
        'sharing': enableSharing,
        'download': enableDownload,
      },
    };
  }
}