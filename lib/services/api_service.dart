import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nasa_daily_snapshot/models/apod_model.dart';

class ApiService {
  static const String _baseUrl = 'https://api.nasa.gov/planetary/apod';
  
  // 🔥 SOLUSI 1: Dapatkan API key gratis di https://api.nasa.gov/
  // Rate limit: 1000 requests per hour (vs 30 untuk DEMO_KEY)
  static const String _apiKey = 'mwZuRR6wRouxLfiuMqjDscMYWAQixaHGFkQIExbj'; // Ganti dengan API key asli
  
  // Cache untuk mengurangi API calls
  static const String _cacheKeyPrefix = 'apod_cache_';
  static const Duration _cacheExpiry = Duration(hours: 6);
  
  Future<ApodModel> getApod({String? date}) async {
    // 🔥 SOLUSI 2: Implementasi caching
    final cacheKey = '${_cacheKeyPrefix}${date ?? 'today'}';
    final cachedData = await _getCachedData(cacheKey);
    
    if (cachedData != null) {
      if (kDebugMode) print('Loading from cache: $cacheKey');
      return ApodModel.fromJson(cachedData);
    }
    
    final url = Uri.parse('$_baseUrl?api_key=$_apiKey${date != null ? '&date=$date' : ''}');
    
    try {
      if (kDebugMode) print('API Request: $url');
      
      final response = await http.get(url).timeout(
        const Duration(seconds: 30), // 🔥 SOLUSI 3: Timeout untuk mencegah hanging
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Cache data untuk penggunaan selanjutnya
        await _cacheData(cacheKey, data);
        
        return ApodModel.fromJson(data);
      } else if (response.statusCode == 429) {
        // 🔥 SOLUSI 4: Handle rate limit error
        throw Exception('Rate limit exceeded. Please try again later.');
      } else {
        throw Exception('Failed to load APOD: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) print('API Error: $e');
      
      // Jika gagal dan ada cache lama, gunakan cache
      final oldCachedData = await _getCachedData(cacheKey, ignoreExpiry: true);
      if (oldCachedData != null) {
        if (kDebugMode) print('Using expired cache due to error');
        return ApodModel.fromJson(oldCachedData);
      }
      
      throw Exception('Error fetching APOD: $e');
    }
  }
  
  // 🔥 SOLUSI 5: Search yang lebih efisien - cari di cache lokal dulu
  Future<List<ApodModel>> searchApod({required String query}) async {
    try {
      // Coba cari di cache terlebih dahulu
      final cachedResults = await _searchInCache(query);
      if (cachedResults.isNotEmpty) {
        return cachedResults;
      }
      
      // Jika tidak ada di cache, ambil data minimal (7 hari terakhir)
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 7)); // Kurangi dari 50 ke 7 hari
      
      final formattedEndDate = _formatDate(endDate);
      final formattedStartDate = _formatDate(startDate);
      
      final apods = await getApodRange(startDate: formattedStartDate, endDate: formattedEndDate);
      
      // Filter results
      final lowercaseQuery = query.toLowerCase();
      return apods.where((apod) {
        return apod.title.toLowerCase().contains(lowercaseQuery) || 
               apod.explanation.toLowerCase().contains(lowercaseQuery);
      }).toList();
    } catch (e) {
      throw Exception('Error searching APOD: $e');
    }
  }
  
  Future<List<ApodModel>> getApodRange({required String startDate, required String endDate}) async {
    final url = Uri.parse('$_baseUrl?api_key=$_apiKey&start_date=$startDate&end_date=$endDate');
    
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 45));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final results = data.map((item) => ApodModel.fromJson(item)).toList();
        
        // Cache individual items
        for (final apod in results) {
          final cacheKey = '${_cacheKeyPrefix}${apod.date}';
          await _cacheData(cacheKey, apod.toJson());
        }
        
        return results;
      } else if (response.statusCode == 429) {
        throw Exception('Rate limit exceeded. Please try again later.');
      } else {
        throw Exception('Failed to load APOD range: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching APOD range: $e');
    }
  }
  
  // Helper methods untuk caching
  Future<Map<String, dynamic>?> _getCachedData(String key, {bool ignoreExpiry = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(key);
      final timestampKey = '${key}_timestamp';
      final timestamp = prefs.getInt(timestampKey);
      
      if (cachedJson != null && timestamp != null) {
        if (ignoreExpiry || DateTime.now().millisecondsSinceEpoch - timestamp < _cacheExpiry.inMilliseconds) {
          return json.decode(cachedJson);
        }
      }
    } catch (e) {
      if (kDebugMode) print('Cache read error: $e');
    }
    return null;
  }
  
  Future<void> _cacheData(String key, Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, json.encode(data));
      await prefs.setInt('${key}_timestamp', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      if (kDebugMode) print('Cache write error: $e');
    }
  }
  
  Future<List<ApodModel>> _searchInCache(String query) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith(_cacheKeyPrefix)).toList();
      final results = <ApodModel>[];
      final lowercaseQuery = query.toLowerCase();
      
      for (final key in keys) {
        final cachedData = await _getCachedData(key);
        if (cachedData != null) {
          final apod = ApodModel.fromJson(cachedData);
          if (apod.title.toLowerCase().contains(lowercaseQuery) || 
              apod.explanation.toLowerCase().contains(lowercaseQuery)) {
            results.add(apod);
          }
        }
      }
      
      return results;
    } catch (e) {
      if (kDebugMode) print('Cache search error: $e');
      return [];
    }
  }
  
  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
  
  // Method untuk clear cache jika diperlukan
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith(_cacheKeyPrefix)).toList();
      for (final key in keys) {
        await prefs.remove(key);
        await prefs.remove('${key}_timestamp');
      }
    } catch (e) {
      if (kDebugMode) print('Cache clear error: $e');
    }
  }
}