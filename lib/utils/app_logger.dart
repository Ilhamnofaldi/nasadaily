import 'package:flutter/foundation.dart';
import '../core/app_config.dart';

/// Application logging utility
class AppLogger {
  static const String _tag = 'NASA_DAILY';
  
  // Log levels
  static const int _levelDebug = 0;
  static const int _levelInfo = 1;
  static const int _levelWarning = 2;
  static const int _levelError = 3;
  
  /// Debug log - only shown in debug mode
  static void debug(String message, [String? tag]) {
    if (AppConfig.enableLogging && AppConfig.isDebugMode) {
      _log(_levelDebug, message, tag);
    }
  }
  
  /// Info log
  static void info(String message, [String? tag]) {
    if (AppConfig.enableLogging) {
      _log(_levelInfo, message, tag);
    }
  }
  
  /// Warning log
  static void warning(String message, [String? tag]) {
    if (AppConfig.enableLogging) {
      _log(_levelWarning, message, tag);
    }
  }
  
  /// Error log
  static void error(String message, [String? tag, dynamic error, StackTrace? stackTrace]) {
    if (AppConfig.enableLogging) {
      _log(_levelError, message, tag);
      if (error != null) {
        debugPrint('[$_tag] Error details: $error');
      }
      if (stackTrace != null) {
        debugPrint('[$_tag] Stack trace: $stackTrace');
      }
    }
  }
  
  /// Network request log
  static void network(String method, String url, {int? statusCode, String? response}) {
    if (AppConfig.enableLogging && AppConfig.isDebugMode) {
      debugPrint('[$_tag][NETWORK] $method $url');
      if (statusCode != null) {
        debugPrint('[$_tag][NETWORK] Status: $statusCode');
      }
      if (response != null && response.length < 500) {
        debugPrint('[$_tag][NETWORK] Response: $response');
      }
    }
  }
  
  /// Cache operation log
  static void cache(String operation, String key, {bool hit = false}) {
    if (AppConfig.enableLogging && AppConfig.isDebugMode) {
      debugPrint('[$_tag][CACHE] $operation: $key ${hit ? '(HIT)' : '(MISS)'}');
    }
  }
  
  /// Performance log
  static void performance(String operation, Duration duration) {
    if (AppConfig.enableLogging && AppConfig.isDebugMode) {
      debugPrint('[$_tag][PERF] $operation took ${duration.inMilliseconds}ms');
    }
  }
  
  /// User action log
  static void userAction(String action, {Map<String, dynamic>? data}) {
    if (AppConfig.enableLogging) {
      debugPrint('[$_tag][USER] $action');
      if (data != null && AppConfig.isDebugMode) {
        debugPrint('[$_tag][USER] Data: $data');
      }
    }
  }
  
  static void _log(int level, String message, String? tag) {
    final levelStr = _getLevelString(level);
    final tagStr = tag ?? _tag;
    debugPrint('[$tagStr][$levelStr] $message');
  }
  
  static String _getLevelString(int level) {
    switch (level) {
      case _levelDebug:
        return 'DEBUG';
      case _levelInfo:
        return 'INFO';
      case _levelWarning:
        return 'WARN';
      case _levelError:
        return 'ERROR';
      default:
        return 'UNKNOWN';
    }
  }
}