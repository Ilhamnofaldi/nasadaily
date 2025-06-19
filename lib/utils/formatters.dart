import 'package:intl/intl.dart';
import '../constants/app_strings.dart';

/// Data formatting utilities
class Formatters {
  // Date formatters
  static final DateFormat _fullDateFormat = DateFormat(AppStrings.dateFormat);
  static final DateFormat _shortDateFormat = DateFormat(AppStrings.shortDateFormat);
  static final DateFormat _apiDateFormat = DateFormat(AppStrings.apiDateFormat);
  
  /// Format date for display (e.g., "January 15, 2024")
  static String formatDisplayDate(DateTime date) {
    return _fullDateFormat.format(date);
  }
  
  /// Format date for short display (e.g., "Jan 15, 2024")
  static String formatShortDate(DateTime date) {
    return _shortDateFormat.format(date);
  }
  
  /// Format date for API requests (e.g., "2024-01-15")
  static String formatApiDate(DateTime date) {
    return _apiDateFormat.format(date);
  }
  
  /// Format relative date (e.g., "Today", "Yesterday", "2 days ago")
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);
    
    final difference = today.difference(targetDate).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference == -1) {
      return 'Tomorrow';
    } else if (difference > 1 && difference <= 7) {
      return '$difference days ago';
    } else if (difference < -1 && difference >= -7) {
      return 'In ${-difference} days';
    } else {
      return formatShortDate(date);
    }
  }
  
  // File size formatters
  /// Format bytes to human readable format
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes ${AppStrings.formatBytes}';
    } else if (bytes < 1024 * 1024) {
      final kb = bytes / 1024;
      return '${kb.toStringAsFixed(1)} ${AppStrings.formatKilobytes}';
    } else {
      final mb = bytes / (1024 * 1024);
      return '${mb.toStringAsFixed(1)} ${AppStrings.formatMegabytes}';
    }
  }
  
  /// Format download progress
  static String formatDownloadProgress(int downloaded, int total) {
    final downloadedStr = formatFileSize(downloaded);
    final totalStr = formatFileSize(total);
    return '$downloadedStr / $totalStr';
  }
  
  /// Format percentage
  static String formatPercentage(double value) {
    if (value.isNaN || value.isInfinite) return '0%';
    final percentage = (value * 100).clamp(0, 100).toInt();
    return '$percentage%';
  }
  
  // Text formatters
  /// Capitalize first letter of each word
  static String capitalizeWords(String text) {
    if (text.isEmpty) return text;
    
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
  
  /// Truncate text with ellipsis
  static String truncateText(String text, int maxLength, {String ellipsis = '...'}) {
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength - ellipsis.length) + ellipsis;
  }
  
  /// Format search query for display
  static String formatSearchQuery(String query) {
    return query.trim().replaceAll(RegExp(r'\s+'), ' ');
  }
  
  // Duration formatters
  /// Format duration to human readable format
  static String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} day${duration.inDays == 1 ? '' : 's'}';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hour${duration.inHours == 1 ? '' : 's'}';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} minute${duration.inMinutes == 1 ? '' : 's'}';
    } else {
      return '${duration.inSeconds} second${duration.inSeconds == 1 ? '' : 's'}';
    }
  }
  
  // URL formatters
  /// Extract domain from URL
  static String extractDomain(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host;
    } catch (e) {
      return url;
    }
  }
  
  /// Format URL for display (remove protocol, truncate if needed)
  static String formatUrlForDisplay(String url, {int maxLength = 50}) {
    try {
      final uri = Uri.parse(url);
      final displayUrl = '${uri.host}${uri.path}';
      return truncateText(displayUrl, maxLength);
    } catch (e) {
      return truncateText(url, maxLength);
    }
  }
  
  // Number formatters
  /// Format number with thousand separators
  static String formatNumber(int number) {
    final formatter = NumberFormat('#,###');
    return formatter.format(number);
  }
  
  /// Format decimal number
  static String formatDecimal(double number, {int decimalPlaces = 2}) {
    return number.toStringAsFixed(decimalPlaces);
  }
  
  // Media type formatters
  /// Get media type icon
  static String getMediaTypeIcon(String mediaType) {
    switch (mediaType.toLowerCase()) {
      case 'image':
        return '🖼️';
      case 'video':
        return '🎥';
      default:
        return '📄';
    }
  }
  
  /// Format media type for display
  static String formatMediaType(String mediaType) {
    return capitalizeWords(mediaType);
  }
}