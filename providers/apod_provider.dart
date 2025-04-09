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

  ApodModel? get apod => _apod;
  List<ApodModel> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  String? get error => _error;

  Future<void> fetchApod({String? date}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final apodData = await _apiService.getApod(date: date);
      _apod = apodData;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> searchApods(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }
    
    _isSearching = true;
    _error = null;
    notifyListeners();

    try {
      final results = await _apiService.searchApod(query: query);
      _searchResults = results;
      _error = null;
    } catch (e) {
      _error = e.toString();
      _searchResults = [];
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }
  
  void clearSearch() {
    _searchResults = [];
    notifyListeners();
  }
}
