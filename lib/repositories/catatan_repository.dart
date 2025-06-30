import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/catatan_model.dart';
import '../models/apod_model.dart';

class CatatanRepository {
  final FirebaseFirestore? _firestore;
  final FirebaseAuth? _auth;
  final SharedPreferences _prefs;
  static const String _localStorageKey = 'catatan';

  CatatanRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    required SharedPreferences prefs,
  })  : _firestore = firestore,
        _auth = auth,
        _prefs = prefs;

  // Get catatan from local storage
  List<CatatanModel> getLocalCatatan() {
    final catatanJson = _prefs.getStringList(_localStorageKey) ?? [];
    final catatan = catatanJson
        .map((item) => CatatanModel.fromJson(json.decode(item)))
        .toList();
    // Sort by created date, newest first
    catatan.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return catatan;
  }

  // Save catatan to local storage
  Future<void> saveCatatanToLocal(List<CatatanModel> catatan) async {
    final catatanJson = catatan
        .map((item) => json.encode(item.toJson()))
        .toList();
    await _prefs.setStringList(_localStorageKey, catatanJson);
  }

  // Get catatan from Firestore
  Future<List<CatatanModel>> getCatatanFromFirestore() async {
    try {
      if (_firestore == null || _auth == null) return getLocalCatatan();
      
      final user = _auth!.currentUser;
      if (user == null) return getLocalCatatan();

      final snapshot = await _firestore!
          .collection('users')
          .doc(user.uid)
          .collection('catatan')
          .orderBy('created_at', descending: true)
          .get();

      final catatan = snapshot.docs
          .map((doc) {
            final data = doc.data();
            data['id'] = doc.id; // Add document ID
            return CatatanModel.fromJson(data);
          })
          .toList();
      
      // Save to local storage
      await saveCatatanToLocal(catatan);
      
      return catatan;
    } catch (e) {
      print('Error getting catatan from Firestore: $e');
      // If there's an error, return local catatan
      return getLocalCatatan();
    }
  }

  // Stream catatan from Firestore
  Stream<List<CatatanModel>> streamCatatan() {
    if (_firestore == null || _auth == null) {
      return Stream.value(getLocalCatatan());
    }
    
    final user = _auth!.currentUser;
    if (user == null) {
      return Stream.value(getLocalCatatan());
    }

    return _firestore!
        .collection('users')
        .doc(user.uid)
        .collection('catatan')
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
      final catatan = snapshot.docs
          .map((doc) {
            final data = doc.data();
            data['id'] = doc.id; // Add document ID
            return CatatanModel.fromJson(data);
          })
          .toList();
      // Save to local storage
      saveCatatanToLocal(catatan);
      return catatan;
    }).handleError((error) {
      print('Error in catatan stream: $error');
      // If there's an error, return local catatan
      return getLocalCatatan();
    });
  }

  // Add catatan to Firestore and local storage
  Future<String> addCatatan({
    required ApodModel apod,
    required String catatan,
  }) async {
    final now = DateTime.now();
    
    // Always update local storage first for responsive UI
    final newCatatan = CatatanModel(
      id: '', // Will be set by Firestore or generated locally
      apodDate: apod.date,
      apodTitle: apod.title,
      apodUrl: apod.url,
      catatan: catatan,
      createdAt: now,
      updatedAt: now,
      userId: _auth?.currentUser?.uid ?? 'local',
    );

    // Try to add to Firestore first
    try {
      if (_firestore != null && _auth != null) {
        final user = _auth!.currentUser;
        if (user != null) {
          print('Adding catatan to Firestore for user: ${user.uid}');
          print('APOD Date: ${apod.date}');
          print('Catatan: $catatan');
          
          final docRef = await _firestore!
              .collection('users')
              .doc(user.uid)
              .collection('catatan')
              .add({
                'apod_date': apod.date,
                'apod_title': apod.title,
                'apod_url': apod.url,
                'catatan': catatan,
                'created_at': Timestamp.fromDate(now),
                'updated_at': Timestamp.fromDate(now),
                'user_id': user.uid,
              });
          
          print('Catatan added to Firestore with ID: ${docRef.id}');
          
          // Update local storage with the new ID
          final catatanWithId = newCatatan.copyWith(id: docRef.id);
          final localCatatan = getLocalCatatan();
          
          // Remove any existing catatan for this APOD date
          localCatatan.removeWhere((c) => c.apodDate == apod.date);
          
          localCatatan.add(catatanWithId);
          localCatatan.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          await saveCatatanToLocal(localCatatan);
          
          return docRef.id;
        }
      }
    } catch (e) {
      print('Failed to sync catatan to Firestore: $e');
      print('Error details: ${e.toString()}');
    }
    
    // If Firestore fails, save to local storage only
    final localId = 'local_${now.millisecondsSinceEpoch}';
    final localCatatan = newCatatan.copyWith(id: localId);
    final allCatatan = getLocalCatatan();
    
    // Remove any existing catatan for this APOD date
    allCatatan.removeWhere((c) => c.apodDate == apod.date);
    
    allCatatan.add(localCatatan);
    allCatatan.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    await saveCatatanToLocal(allCatatan);
    
    print('Catatan saved locally with ID: $localId');
    return localId;
  }

  // Update catatan
  Future<void> updateCatatan({
    required String catatanId,
    required String catatan,
  }) async {
    final now = DateTime.now();
    
    // Update local storage first
    final localCatatan = getLocalCatatan();
    final index = localCatatan.indexWhere((c) => c.id == catatanId);
    if (index != -1) {
      localCatatan[index] = localCatatan[index].copyWith(
        catatan: catatan,
        updatedAt: now,
      );
      await saveCatatanToLocal(localCatatan);
    }
    
    // Try to sync with Firestore
    try {
      if (_firestore != null && _auth != null && !catatanId.startsWith('local_')) {
        final user = _auth!.currentUser;
        if (user != null) {
          await _firestore!
              .collection('users')
              .doc(user.uid)
              .collection('catatan')
              .doc(catatanId)
              .update({
                'catatan': catatan,
                'updated_at': Timestamp.fromDate(now),
              });
        }
      }
    } catch (e) {
      print('Failed to sync catatan update to Firestore: $e');
    }
  }

  // Delete catatan
  Future<void> deleteCatatan(String catatanId) async {
    // Remove from local storage first
    final localCatatan = getLocalCatatan();
    localCatatan.removeWhere((c) => c.id == catatanId);
    await saveCatatanToLocal(localCatatan);
    
    // Try to sync with Firestore
    try {
      if (_firestore != null && _auth != null && !catatanId.startsWith('local_')) {
        final user = _auth!.currentUser;
        if (user != null) {
          await _firestore!
              .collection('users')
              .doc(user.uid)
              .collection('catatan')
              .doc(catatanId)
              .delete();
        }
      }
    } catch (e) {
      print('Failed to sync catatan deletion to Firestore: $e');
    }
  }

  // Get catatan by APOD date
  CatatanModel? getCatatanByApodDate(String apodDate) {
    try {
      return getLocalCatatan().firstWhere((c) => c.apodDate == apodDate);
    } catch (e) {
      return null;
    }
  }

  // Check if APOD has catatan
  bool hasExistingCatatan(String apodDate) {
    return getCatatanByApodDate(apodDate) != null;
  }

  // Search catatan
  List<CatatanModel> searchCatatan(String query) {
    if (query.isEmpty) return getLocalCatatan();
    
    final lowercaseQuery = query.toLowerCase();
    return getLocalCatatan().where((catatan) {
      return catatan.apodTitle.toLowerCase().contains(lowercaseQuery) ||
             catatan.catatan.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }
} 