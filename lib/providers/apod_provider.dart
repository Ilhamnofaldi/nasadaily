import 'package:flutter/foundation.dart';
import 'package:nasa_daily_snapshot/models/apod_model.dart';
import 'package:nasa_daily_snapshot/services/api_service.dart';

class ApodProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  ApodModel? _apod;
  List<ApodModel> _searchResults = [];
  String _currentSearchQuery = '';
  DateTime _searchEndDate = DateTime.now();
  final int _searchPageSizeInDays = 30; // Fetch 30 days at a time for search
  bool _hasMoreSearchResults = true;

  bool _isLoading = false; // For initial APOD fetch
  bool _isSearching = false; // For the initial search action
  bool _isLoadingMoreSearchResults = false; // For loading more search results
  String? _error;
  
  // 🔥 SOLUSI 11: Tambahan untuk debugging
  DateTime? _lastFetchTime;
  bool _isRetrying = false;

  ApodModel? get apod => _apod;
  List<ApodModel> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  bool get isLoadingMoreSearchResults => _isLoadingMoreSearchResults;
  bool get hasMoreSearchResults => _hasMoreSearchResults;
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
      clearSearch();
      return;
    }

    _isSearching = true;
    _currentSearchQuery = query;
    _searchResults = [];
    _searchEndDate = DateTime.now(); // Start searching from today backwards
    _hasMoreSearchResults = true;
    _error = null;
    notifyListeners();

    if (kDebugMode) print('🔍 Initializing search for: $query');
    await loadMoreSearchResults(isInitialSearch: true);

    _isSearching = false;
    notifyListeners();
  }

  Future<void> loadMoreSearchResults({bool isInitialSearch = false}) async {
    if (_isLoadingMoreSearchResults && !isInitialSearch) return;
    if (!_hasMoreSearchResults && !isInitialSearch) return;

    if (isInitialSearch) {
      _isSearching = true;
    } else {
      _isLoadingMoreSearchResults = true;
    }
    _error = null;
    notifyListeners();

    try {
      final DateTime fetchEndDate = _searchEndDate;
      final DateTime fetchStartDate = _searchEndDate.subtract(Duration(days: _searchPageSizeInDays -1)); // -1 because range is inclusive
      
      if (kDebugMode) {
        print('➡️ Fetching search chunk: Query: "$_currentSearchQuery", Start: ${_formatDate(fetchStartDate)}, End: ${_formatDate(fetchEndDate)}');
      }

      final List<ApodModel> fetchedApods = await _apiService.getApodRange(
        startDate: _formatDate(fetchStartDate),
        endDate: _formatDate(fetchEndDate),
      );
      if (kDebugMode) debugPrint('ApodProvider: Fetched ${fetchedApods.length} APODs before filtering.');

      final lowercaseQuery = _currentSearchQuery.toLowerCase();
      if (kDebugMode) debugPrint('ApodProvider: Lowercase query: "$lowercaseQuery"');
      
      final List<ApodModel> filteredResults = fetchedApods.where((apod) {
        return apod.title.toLowerCase().contains(lowercaseQuery) || 
               apod.explanation.toLowerCase().contains(lowercaseQuery);
      }).toList();
      if (kDebugMode) debugPrint('ApodProvider: Filtered to ${filteredResults.length} APODs.');

      _searchResults.addAll(filteredResults);
      _searchEndDate = fetchStartDate.subtract(const Duration(days: 1)); // Move to the day before the start of the current chunk

      if (fetchedApods.length < _searchPageSizeInDays || fetchedApods.isEmpty) {
        // Heuristic: if we fetched less than requested, or nothing, assume no more data for this broad period
        _hasMoreSearchResults = false;
        if (kDebugMode) print('🏁 No more search results presumed.');
      }
      if (kDebugMode) {
        print('✅ Search chunk processed: ${filteredResults.length} new items added. Total: ${_searchResults.length}');
        debugPrint('ApodProvider: _hasMoreSearchResults: $_hasMoreSearchResults');
        debugPrint('ApodProvider: _searchResults.length: ${_searchResults.length}');
      }

    } catch (e) {
      _error = _getFormattedError(e.toString());
      if (kDebugMode) print('❌ Error loading more search results: $e');
      // Optionally set _hasMoreSearchResults = false on error, or allow retry
    } finally {
      if (isInitialSearch) {
        _isSearching = false;
      } else {
        _isLoadingMoreSearchResults = false;
      }
      notifyListeners();
    }
  }
  
  void clearSearch() {
    _searchResults = [];
    _currentSearchQuery = '';
    _searchEndDate = DateTime.now();
    _hasMoreSearchResults = true;
    _isLoadingMoreSearchResults = false;
    _isSearching = false;
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

  // Helper to format date for API
  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
}