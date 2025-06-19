import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/apod_model.dart';

class FavoritesRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final SharedPreferences _prefs;
  static const String _localStorageKey = 'favorites';

  FavoritesRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    required SharedPreferences prefs,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _prefs = prefs;

  // Get favorites from local storage
  List<ApodModel> getLocalFavorites() {
    final favoritesJson = _prefs.getStringList(_localStorageKey) ?? [];
    final favorites = favoritesJson
        .map((item) => ApodModel.fromJson(json.decode(item)))
        .toList();
    // Sort by date, newest first
    favorites.sort((a, b) => b.date.compareTo(a.date));
    return favorites;
  }

  // Save favorites to local storage
  Future<void> saveFavoritesToLocal(List<ApodModel> favorites) async {
    final favoritesJson = favorites
        .map((item) => json.encode(item.toJson()))
        .toList();
    await _prefs.setStringList(_localStorageKey, favoritesJson);
  }

  // Get favorites from Firestore
  Future<List<ApodModel>> getFavoritesFromFirestore() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .get();

      final favorites = snapshot.docs
          .map((doc) => ApodModel.fromJson(doc.data()))
          .toList();
      
      // Sort by date, newest first
      favorites.sort((a, b) => b.date.compareTo(a.date));
      
      // Save to local storage
      await saveFavoritesToLocal(favorites);
      
      return favorites;
    } catch (e) {
      // If there's an error, return local favorites
      return getLocalFavorites();
    }
  }

  // Stream favorites from Firestore
  Stream<List<ApodModel>> streamFavorites() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value(getLocalFavorites());
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .snapshots()
        .map((snapshot) {
      final favorites = snapshot.docs
          .map((doc) => ApodModel.fromJson(doc.data()))
          .toList();
      // Sort by date, newest first
      favorites.sort((a, b) => b.date.compareTo(a.date));
      // Save to local storage
      saveFavoritesToLocal(favorites);
      return favorites;
    }).handleError((error) {
      // If there's an error, return local favorites
      return getLocalFavorites();
    });
  }

  // Add favorite to Firestore and local storage
  Future<void> addFavorite(ApodModel apod) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('favorites')
            .doc(apod.date)
            .set(apod.toJson());
      }
    } catch (e) {
      // If Firestore fails, at least save to local storage
      final favorites = getLocalFavorites();
      if (!favorites.any((item) => item.date == apod.date)) {
        favorites.add(apod);
        favorites.sort((a, b) => b.date.compareTo(a.date));
        await saveFavoritesToLocal(favorites);
      }
      rethrow;
    }
  }

  // Remove favorite from Firestore and local storage
  Future<void> removeFavorite(String date) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('favorites')
            .doc(date)
            .delete();
      }
    } catch (e) {
      // If Firestore fails, at least update local storage
      final favorites = getLocalFavorites();
      favorites.removeWhere((item) => item.date == date);
      await saveFavoritesToLocal(favorites);
      rethrow;
    }
  }

  // Check if an APOD is in favorites
  bool isFavorite(String date) {
    return getLocalFavorites().any((item) => item.date == date);
  }
} 