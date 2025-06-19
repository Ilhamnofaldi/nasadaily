import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../core/app_config.dart';
import '../utils/app_logger.dart';
import '../utils/validators.dart';

/// Cache service for managing local data storage
class CacheService {
  static CacheService? _instance;
  static CacheService get instance => _instance ??= CacheService._();
  
  CacheService._();
  
  SharedPreferences? _prefs;
  
  /// Initialize cache service
  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      AppLogger.info('Cache service initialized');
    } catch (e) {
      AppLogger.error('Failed to initialize cache service', 'CACHE', e);
      rethrow;
    }
  }
  
  /// Get cached data
  Future<Map<String, dynamic>?> getData(String key, {bool ignoreExpiry = false}) async {
    if (!Validators.isValidCacheKey(key)) {
      AppLogger.warning('Invalid cache key: $key');
      return null;
    }
    
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(key);
      final timestampKey = '${key}_timestamp';
      final timestamp = prefs.getInt(timestampKey);
      
      if (cachedJson != null && timestamp != null) {
        final isExpired = !ignoreExpiry && 
            DateTime.now().millisecondsSinceEpoch - timestamp > 
            AppConfig.cacheExpiration.inMilliseconds;
            
        if (!isExpired) {
          AppLogger.cache('GET', key, hit: true);
          return json.decode(cachedJson);
        } else {
          AppLogger.cache('GET', key, hit: false);
          await _removeData(key); // Clean up expired data
        }
      }
      
      AppLogger.cache('GET', key, hit: false);
      return null;
    } catch (e) {
      AppLogger.error('Failed to get cached data for key: $key', 'CACHE', e);
      return null;
    }
  }
  
  /// Cache data with timestamp
  Future<bool> setData(String key, Map<String, dynamic> data) async {
    if (!Validators.isValidCacheKey(key)) {
      AppLogger.warning('Invalid cache key: $key');
      return false;
    }
    
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      final jsonString = json.encode(data);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      final success = await prefs.setString(key, jsonString) &&
                     await prefs.setInt('${key}_timestamp', timestamp);
      
      if (success) {
        AppLogger.cache('SET', key);
        await _cleanupIfNeeded();
      }
      
      return success;
    } catch (e) {
      AppLogger.error('Failed to cache data for key: $key', 'CACHE', e);
      return false;
    }
  }
  
  /// Remove cached data
  Future<bool> removeData(String key) async {
    return await _removeData(key);
  }
  
  Future<bool> _removeData(String key) async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      final success = await prefs.remove(key) &&
                     await prefs.remove('${key}_timestamp');
      
      if (success) {
        AppLogger.cache('REMOVE', key);
      }
      
      return success;
    } catch (e) {
      AppLogger.error('Failed to remove cached data for key: $key', 'CACHE', e);
      return false;
    }
  }
  
  /// Check if data exists and is not expired
  Future<bool> hasValidData(String key) async {
    final data = await getData(key);
    return data != null;
  }
  
  /// Get cache size (approximate)
  Future<int> getCacheSize() async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      int totalSize = 0;
      
      for (final key in keys) {
        if (!key.endsWith('_timestamp')) {
          final value = prefs.getString(key);
          if (value != null) {
            totalSize += value.length;
          }
        }
      }
      
      return totalSize;
    } catch (e) {
      AppLogger.error('Failed to calculate cache size', 'CACHE', e);
      return 0;
    }
  }
  
  /// Clear all cached data
  Future<bool> clearAll() async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => 
          key.startsWith('apod_') || key.startsWith('search_')).toList();
      
      for (final key in keys) {
        await prefs.remove(key);
      }
      
      AppLogger.info('Cache cleared');
      return true;
    } catch (e) {
      AppLogger.error('Failed to clear cache', 'CACHE', e);
      return false;
    }
  }
  
  /// Clear expired data
  Future<void> clearExpired() async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final now = DateTime.now().millisecondsSinceEpoch;
      final expiration = AppConfig.cacheExpiration.inMilliseconds;
      
      for (final key in keys) {
        if (key.endsWith('_timestamp')) {
          final timestamp = prefs.getInt(key);
          if (timestamp != null && now - timestamp > expiration) {
            final dataKey = key.replaceAll('_timestamp', '');
            await _removeData(dataKey);
          }
        }
      }
      
      AppLogger.info('Expired cache cleared');
    } catch (e) {
      AppLogger.error('Failed to clear expired cache', 'CACHE', e);
    }
  }
  
  /// Cleanup cache if it exceeds size limit
  Future<void> _cleanupIfNeeded() async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => 
          !key.endsWith('_timestamp') && 
          (key.startsWith('apod_') || key.startsWith('search_'))).toList();
      
      if (keys.length > AppConfig.maxCacheSize) {
        // Sort by timestamp and remove oldest entries
        final keyTimestamps = <String, int>{};
        
        for (final key in keys) {
          final timestamp = prefs.getInt('${key}_timestamp') ?? 0;
          keyTimestamps[key] = timestamp;
        }
        
        final sortedKeys = keyTimestamps.entries.toList()
          ..sort((a, b) => a.value.compareTo(b.value));
        
        final keysToRemove = sortedKeys.take(keys.length - AppConfig.maxCacheSize);
        
        for (final entry in keysToRemove) {
          await _removeData(entry.key);
        }
        
        AppLogger.info('Cache cleanup completed, removed ${keysToRemove.length} entries');
      }
    } catch (e) {
      AppLogger.error('Failed to cleanup cache', 'CACHE', e);
    }
  }
  
  /// Get cache statistics
  Future<Map<String, dynamic>> getStats() async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      final apodKeys = keys.where((key) => key.startsWith('apod_') && !key.endsWith('_timestamp'));
      final searchKeys = keys.where((key) => key.startsWith('search_') && !key.endsWith('_timestamp'));
      
      final totalSize = await getCacheSize();
      
      return {
        'total_entries': apodKeys.length + searchKeys.length,
        'apod_entries': apodKeys.length,
        'search_entries': searchKeys.length,
        'total_size_bytes': totalSize,
        'max_entries': AppConfig.maxCacheSize,
        'expiration_hours': AppConfig.cacheExpiration.inHours,
      };
    } catch (e) {
      AppLogger.error('Failed to get cache stats', 'CACHE', e);
      return {};
    }
  }
}