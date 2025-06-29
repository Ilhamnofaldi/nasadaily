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
  FirebaseFirestore? _firestore;
  FirebaseAuth? _auth;
  StreamSubscription? _favoritesSubscription;
  bool _isLoading = false;
  bool _hasFirebase = false;

  List<ApodModel> get favorites => _favorites;
  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Check if Firebase is available
      try {
        _firestore = FirebaseFirestore.instance;
        _auth = FirebaseAuth.instance;
        _hasFirebase = true;
        print('Firebase available for favorites');
      } catch (e) {
        _hasFirebase = false;
        print('Firebase not available, using local storage only');
      }
      
      _repository = FavoritesRepository(
        firestore: _firestore,
        auth: _auth,
        prefs: prefs,
      );
      
      if (_hasFirebase) {
        // First try to get from Firestore
        _favorites = await _repository.getFavoritesFromFirestore();
        // Then set up stream for real-time updates
        _setupFavoritesStream();
      } else {
        // Use local data only
        _favorites = _repository.getLocalFavorites();
      }
    } catch (e) {
      print('Error initializing favorites: $e');
      // If everything fails, use local data
      final prefs = await SharedPreferences.getInstance();
      _repository = FavoritesRepository(prefs: prefs);
      _favorites = _repository.getLocalFavorites();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _setupFavoritesStream() {
    if (!_hasFirebase) return;
    
    _favoritesSubscription?.cancel();
    _favoritesSubscription = _repository.streamFavorites().listen(
      (favorites) {
        _favorites = favorites;
        notifyListeners();
      },
      onError: (error) {
        print('Favorites stream error: $error');
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
      // Update local state immediately for responsive UI
      _favorites.removeWhere((item) => item.date == date);
      notifyListeners();
      
      // Then update repository (Firestore/local storage)
      await _repository.removeFavorite(date);
    } catch (e) {
      // If repository update fails, revert local state
      print('Error removing favorite: $e');
      // Reload favorites from repository to revert
      if (_hasFirebase) {
        try {
          _favorites = await _repository.getFavoritesFromFirestore();
        } catch (e2) {
          _favorites = _repository.getLocalFavorites();
        }
      } else {
        _favorites = _repository.getLocalFavorites();
      }
      notifyListeners();
      rethrow;
    }
  }

  Future<void> addFavorite(ApodModel apod) async {
    try {
      // Update local state immediately for responsive UI
      if (!_favorites.any((item) => item.date == apod.date)) {
        _favorites.add(apod);
        _favorites.sort((a, b) => b.date.compareTo(a.date));
        notifyListeners();
      }
      
      // Then update repository (Firestore/local storage)
      await _repository.addFavorite(apod);
    } catch (e) {
      // If repository update fails, revert local state
      print('Error adding favorite: $e');
      // Reload favorites from repository to revert
      if (_hasFirebase) {
        try {
          _favorites = await _repository.getFavoritesFromFirestore();
        } catch (e2) {
          _favorites = _repository.getLocalFavorites();
        }
      } else {
        _favorites = _repository.getLocalFavorites();
      }
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    _favoritesSubscription?.cancel();
    super.dispose();
  }
}
