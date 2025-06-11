import 'package:flutter/foundation.dart';
import 'package:nasa_daily_snapshot/models/apod_model.dart';
import 'package:nasa_daily_snapshot/services/api_service.dart';

class ApodProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  ApodModel? _apod;
  List<ApodModel> _searchResults = [];
  bool _isLoading = false;
  bool _isSearching = false;
  String? _error;
  
  // 🔥 SOLUSI 11: Tambahan untuk debugging
  DateTime? _lastFetchTime;
  bool _isRetrying = false;

  ApodModel? get apod => _apod;
  List<ApodModel> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  String? get error => _error;
  bool get isRetrying => _isRetrying;

  Future<void> fetchApod({String? date}) async {
    if (_isLoading) return; // Prevent multiple simultaneous requests
    
    _isLoading = true;
    _error = null;
    _isRetrying = false;
    _lastFetchTime = DateTime.now();
    
    if (kDebugMode) print('🔄 Fetching APOD for date: ${date ?? 'today'}');
    notifyListeners();

    try {
      final apodData = await _apiService.getApod(date: date);
      _apod = apodData;
      _error = null;
      
      if (kDebugMode) {
        print('✅ APOD fetched successfully: ${apodData.title}');
        print('📅 Date: ${apodData.date}');
        print('🖼️ Image URL: ${apodData.url}');
        print('📐 Media Type: ${apodData.mediaType}');
      }
      
    } catch (e) {
      _error = _getFormattedError(e.toString());
      
      if (kDebugMode) {
        print('❌ Error fetching APOD: $e');
        print('🕐 Last fetch time: $_lastFetchTime');
      }
      
      // Jika error rate limit, beri tahu user untuk tunggu
      if (_error!.contains('Rate limit')) {
        _error = 'Rate limit exceeded. Please wait before trying again.\n\nTip: Get a free NASA API key for higher limits.';
      }
      
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // 🔥 SOLUSI 12: Retry dengan backoff
  Future<void> retryFetch({String? date}) async {
    if (_isRetrying) return;
    
    _isRetrying = true;
    notifyListeners();
    
    // Wait a bit before retrying
    await Future.delayed(const Duration(seconds: 2));
    
    await fetchApod(date: date);
    _isRetrying = false;
  }
  
  Future<void> searchApods(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }
    
    if (_isSearching) return; // Prevent multiple searches
    
    _isSearching = true;
    _error = null;
    
    if (kDebugMode) print('🔍 Searching for: $query');
    notifyListeners();

    try {
      final results = await _apiService.searchApod(query: query);
      _searchResults = results;
      _error = null;
      
      if (kDebugMode) print('✅ Search completed: ${results.length} results found');
      
    } catch (e) {
      _error = _getFormattedError(e.toString());
      _searchResults = [];
      
      if (kDebugMode) print('❌ Search error: $e');
      
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }
  
  void clearSearch() {
    _searchResults = [];
    _error = null;
    notifyListeners();
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  // 🔥 SOLUSI 13: Better error formatting
  String _getFormattedError(String error) {
    if (error.contains('Rate limit')) {
      return 'Too many requests. Please wait a moment before trying again.';
    } else if (error.contains('Failed host lookup')) {
      return 'No internet connection. Please check your network.';
    } else if (error.contains('TimeoutException')) {
      return 'Request timed out. Please try again.';
    } else if (error.contains('404')) {
      return 'No image available for this date.';
    } else if (error.contains('403')) {
      return 'Access denied. Please check your API key.';
    } else {
      return 'Something went wrong. Please try again.';
    }
  }
  
  // 🔥 SOLUSI 14: Force refresh method
  Future<void> forceRefresh({String? date}) async {
    // Clear any existing data
    _apod = null;
    _error = null;
    
    await fetchApod(date: date);
  }
}