import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/apod_model.dart';
import '../repositories/favorites_repository.dart';

class FavoritesProvider extends ChangeNotifier {
  late final FavoritesRepository _repository;
  List<ApodModel> _favorites = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription? _favoritesSubscription;
  bool _isLoading = false;

  List<ApodModel> get favorites => _favorites;
  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      _repository = FavoritesRepository(prefs: prefs);
      
      // First try to get from Firestore
      _favorites = await _repository.getFavoritesFromFirestore();
      
      // Then set up stream for real-time updates
      _setupFavoritesStream();
    } catch (e) {
      // If Firestore fails, use local data
      _favorites = _repository.getLocalFavorites();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _setupFavoritesStream() {
    _favoritesSubscription?.cancel();
    _favoritesSubscription = _repository.streamFavorites().listen(
      (favorites) {
        _favorites = favorites;
        notifyListeners();
      },
      onError: (error) {
        // If stream fails, use local data
        _favorites = _repository.getLocalFavorites();
        notifyListeners();
      },
    );
  }

  bool isFavorite(String date) {
    return _repository.isFavorite(date);
  }

  Future<void> toggleFavorite(ApodModel apod) async {
    if (isFavorite(apod.date)) {
      await removeFavorite(apod.date);
    } else {
      await addFavorite(apod);
    }
  }

  Future<void> removeFavorite(String date) async {
    try {
      await _repository.removeFavorite(date);
      // The stream will update the favorites list
    } catch (e) {
      // If Firestore fails, update local state
      _favorites.removeWhere((item) => item.date == date);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> addFavorite(ApodModel apod) async {
    try {
      await _repository.addFavorite(apod);
      // The stream will update the favorites list
    } catch (e) {
      // If Firestore fails, update local state
      if (!_favorites.any((item) => item.date == apod.date)) {
        _favorites.add(apod);
        _favorites.sort((a, b) => b.date.compareTo(a.date));
        notifyListeners();
      }
      rethrow;
    }
  }

  @override
  void dispose() {
    _favoritesSubscription?.cancel();
    super.dispose();
  }
}
