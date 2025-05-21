import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nasa_daily_snapshot/models/apod_model.dart';

class FavoritesProvider extends ChangeNotifier {
  SharedPreferences? _prefs;
  List<ApodModel> _favorites = [];

  List<ApodModel> get favorites => _favorites;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _loadFavorites();
  }

  void _loadFavorites() {
    final favoritesJson = _prefs?.getStringList('favorites') ?? [];
    _favorites = favoritesJson
        .map((item) => ApodModel.fromJson(json.decode(item)))
        .toList();
    // Sort by date, newest first
    _favorites.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  void _saveFavorites() {
    final favoritesJson = _favorites
        .map((item) => json.encode(item.toJson()))
        .toList();
    _prefs?.setStringList('favorites', favoritesJson);
  }

  bool isFavorite(String date) {
    return _favorites.any((item) => item.date == date);
  }

  void toggleFavorite(ApodModel apod) {
    if (isFavorite(apod.date)) {
      _favorites.removeWhere((item) => item.date == apod.date);
    } else {
      _favorites.add(apod);
    }
    // Sort by date, newest first
    _favorites.sort((a, b) => b.date.compareTo(a.date));
    _saveFavorites();
    notifyListeners();
  }

  void removeFavorite(String date) {
    _favorites.removeWhere((item) => item.date == date);
    _saveFavorites();
    notifyListeners();
  }
}
