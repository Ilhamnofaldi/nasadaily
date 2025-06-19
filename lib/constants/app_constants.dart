// App Constants
class AppConstants {
  // API Configuration
  static const String nasaApiBaseUrl = 'https://api.nasa.gov/planetary/apod';
  static const String nasaApiKey = 'DEMO_KEY'; // Replace with your actual API key
  
  // App Information
  static const String appName = 'NASA Daily';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Explore the cosmos with NASA\'s Astronomy Picture of the Day';
  
  // Cache Configuration
  static const int maxCacheSize = 100; // Maximum number of cached images
  static const Duration cacheExpiration = Duration(days: 7);
  
  // UI Configuration
  static const double defaultBorderRadius = 8.0;
  static const double defaultPadding = 16.0;
  static const double defaultMargin = 8.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 300);
  static const Duration mediumAnimation = Duration(milliseconds: 500);
  static const Duration longAnimation = Duration(milliseconds: 800);
  
  // Image Configuration
  static const int maxImageCacheWidth = 1000;
  static const int maxImageCacheHeight = 1000;
  static const double imageQualityHigh = 1.0;
  static const double imageQualityMedium = 0.8;
  static const double imageQualityLow = 0.6;
  
  // Error Messages
  static const String networkErrorMessage = 'Network connection failed. Please check your internet connection.';
  static const String apiErrorMessage = 'Failed to fetch data from NASA API.';
  static const String cacheErrorMessage = 'Failed to load cached data.';
  static const String imageLoadErrorMessage = 'Failed to load image.';
  
  // Success Messages
  static const String favoriteAddedMessage = 'Added to favorites';
  static const String favoriteRemovedMessage = 'Removed from favorites';
  static const String imageSavedMessage = 'Image saved to gallery';
  
  // Preferences Keys
  static const String themePreferenceKey = 'theme_preference';
  static const String favoritesPreferenceKey = 'favorites';
  static const String notificationsEnabledKey = 'notifications_enabled';
  static const String imageQualityKey = 'image_quality';
  static const String saveToGalleryKey = 'save_to_gallery';
}