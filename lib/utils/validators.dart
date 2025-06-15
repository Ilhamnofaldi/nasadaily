import '../constants/app_strings.dart';

/// Input validation utilities
class Validators {
  // Date validation
  static bool isValidDate(String date) {
    if (date.isEmpty) return false;
    
    final regex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!regex.hasMatch(date)) return false;
    
    try {
      final parsedDate = DateTime.parse(date);
      final now = DateTime.now();
      final firstApodDate = DateTime(1995, 6, 16); // First APOD date
      
      return parsedDate.isAfter(firstApodDate.subtract(const Duration(days: 1))) &&
             parsedDate.isBefore(now.add(const Duration(days: 1)));
    } catch (e) {
      return false;
    }
  }
  
  // URL validation
  static bool isValidUrl(String url) {
    if (url.isEmpty) return false;
    
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }
  
  // Image URL validation
  static bool isValidImageUrl(String url) {
    if (!isValidUrl(url)) return false;
    
    final uri = Uri.parse(url);
    final path = uri.path.toLowerCase();
    
    return path.endsWith('.jpg') ||
           path.endsWith('.jpeg') ||
           path.endsWith('.png') ||
           path.endsWith('.gif') ||
           path.endsWith('.webp') ||
           path.endsWith('.bmp') ||
           path.contains('image') ||
           uri.scheme == 'data';
  }
  
  // Search query validation
  static bool isValidSearchQuery(String query) {
    if (query.trim().isEmpty) return false;
    if (query.trim().length < 2) return false;
    if (query.trim().length > 100) return false;
    
    // Check if it's a date format
    if (isValidDate(query.trim())) return true;
    
    // Check for valid search terms (alphanumeric, spaces, basic punctuation)
    final regex = RegExp(r'^[a-zA-Z0-9\s\-_.,!?]+$');
    return regex.hasMatch(query.trim());
  }
  
  // API key validation
  static bool isValidApiKey(String apiKey) {
    if (apiKey.isEmpty) return false;
    if (apiKey == 'DEMO_KEY') return true; // Allow demo key
    
    // NASA API keys are typically 40 characters long
    return apiKey.length >= 20 && apiKey.length <= 50;
  }
  
  // Media type validation
  static bool isValidMediaType(String mediaType) {
    return mediaType == AppStrings.mediaTypeImage || 
           mediaType == AppStrings.mediaTypeVideo;
  }
  
  // File size validation (in bytes)
  static bool isValidFileSize(int bytes, {int maxSizeMB = 50}) {
    final maxBytes = maxSizeMB * 1024 * 1024;
    return bytes > 0 && bytes <= maxBytes;
  }
  
  // Cache key validation
  static bool isValidCacheKey(String key) {
    if (key.isEmpty) return false;
    if (key.length > 255) return false;
    
    // Only allow alphanumeric, underscore, hyphen, and dot
    final regex = RegExp(r'^[a-zA-Z0-9_.-]+$');
    return regex.hasMatch(key);
  }
  
  // Date range validation
  static bool isValidDateRange(DateTime startDate, DateTime endDate) {
    if (startDate.isAfter(endDate)) return false;
    
    final now = DateTime.now();
    final firstApodDate = DateTime(1995, 6, 16);
    
    return startDate.isAfter(firstApodDate.subtract(const Duration(days: 1))) &&
           endDate.isBefore(now.add(const Duration(days: 1)));
  }
  
  // Sanitize search query
  static String sanitizeSearchQuery(String query) {
    return query.trim().replaceAll(RegExp(r'[^a-zA-Z0-9\s\-_.,!?]'), '');
  }
  
  // Format date for API
  static String formatDateForApi(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
           '${date.month.toString().padLeft(2, '0')}-'
           '${date.day.toString().padLeft(2, '0')}';
  }
  
  // Validate and parse date string
  static DateTime? parseDate(String dateString) {
    if (!isValidDate(dateString)) return null;
    
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }
}