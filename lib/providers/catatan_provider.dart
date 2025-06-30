import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/catatan_model.dart';
import '../models/apod_model.dart';
import '../repositories/catatan_repository.dart';
import '../utils/app_logger.dart';

class CatatanProvider with ChangeNotifier {
  late final CatatanRepository _repository;
  
  List<CatatanModel> _catatanList = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<CatatanModel>>? _catatanStreamSubscription;
  FirebaseFirestore? _firestore;
  FirebaseAuth? _auth;
  bool _hasFirebase = false;

  // Getters
  List<CatatanModel> get catatanList => _catatanList;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasCatatan => _catatanList.isNotEmpty;
  int get catatanCount => _catatanList.length;

  /// Mendapatkan catatan berdasarkan tanggal APOD
  CatatanModel? getCatatanByApodDate(String apodDate) {
    return _repository.getCatatanByApodDate(apodDate);
  }

  /// Mengecek apakah APOD sudah memiliki catatan
  bool hasExistingCatatan(String apodDate) {
    return _repository.hasExistingCatatan(apodDate);
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error state
  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Initialize provider
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
        print('Firebase available for catatan');
      } catch (e) {
        _hasFirebase = false;
        print('Firebase not available, using local storage only');
      }
      
      _repository = CatatanRepository(
        firestore: _firestore,
        auth: _auth,
        prefs: prefs,
      );
      
      if (_hasFirebase) {
        // First try to get from Firestore
        _catatanList = await _repository.getCatatanFromFirestore();
        // Then set up stream for real-time updates
        _setupCatatanStream();
      } else {
        // Use local data only
        _catatanList = _repository.getLocalCatatan();
      }
    } catch (e) {
      print('Error initializing catatan: $e');
      // If everything fails, use local data
      final prefs = await SharedPreferences.getInstance();
      _repository = CatatanRepository(prefs: prefs);
      _catatanList = _repository.getLocalCatatan();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _setupCatatanStream() {
    if (!_hasFirebase) return;
    
    _catatanStreamSubscription?.cancel();
    _catatanStreamSubscription = _repository.streamCatatan().listen(
      (catatan) {
        _catatanList = catatan;
        notifyListeners();
      },
      onError: (error) {
        print('Catatan stream error: $error');
        // If stream fails, use local data
        _catatanList = _repository.getLocalCatatan();
        notifyListeners();
      },
    );
  }

  /// Load semua catatan (for manual refresh)
  Future<void> loadCatatan() async {
    try {
      _setLoading(true);
      _setError(null);
      
      if (_hasFirebase) {
        _catatanList = await _repository.getCatatanFromFirestore();
      } else {
        _catatanList = _repository.getLocalCatatan();
      }
      
      AppLogger.info('Berhasil memuat ${_catatanList.length} catatan');
    } catch (e) {
      AppLogger.error('Error loading catatan: $e');
      _setError('Gagal memuat catatan: ${e.toString().split(':').last.trim()}');
      // If error, try to use local data
      _catatanList = _repository.getLocalCatatan();
    } finally {
      _setLoading(false);
    }
  }

  /// Menambahkan catatan baru
  Future<bool> addCatatan({
    required ApodModel apod,
    required String catatan,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      print('CatatanProvider: Starting addCatatan for APOD ${apod.date}');
      print('CatatanProvider: User signed in: ${_auth?.currentUser != null}');
      print('CatatanProvider: User ID: ${_auth?.currentUser?.uid}');

      // Cek apakah sudah ada catatan untuk APOD ini
      if (hasExistingCatatan(apod.date)) {
        print('CatatanProvider: Catatan already exists for ${apod.date}');
        _setError('Catatan untuk foto ini sudah ada');
        return false;
      }

      print('CatatanProvider: Calling repository.addCatatan...');
      final catatanId = await _repository.addCatatan(
        apod: apod,
        catatan: catatan,
      );

      print('CatatanProvider: Repository returned ID: $catatanId');
      AppLogger.info('Catatan berhasil ditambahkan dengan ID: $catatanId');
      
      // Update local list immediately for responsive UI
      _catatanList = _repository.getLocalCatatan();
      print('CatatanProvider: Updated local list, new count: ${_catatanList.length}');
      notifyListeners();
      
      return true;
    } catch (e) {
      print('CatatanProvider: Error in addCatatan: $e');
      AppLogger.error('Error adding catatan: $e');
      _setError('Gagal menambahkan catatan: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Memperbarui catatan
  Future<bool> updateCatatan({
    required String catatanId,
    required String catatan,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      await _repository.updateCatatan(
        catatanId: catatanId,
        catatan: catatan,
      );

      AppLogger.info('Catatan berhasil diperbarui: $catatanId');
      
      // Update local list immediately for responsive UI
      _catatanList = _repository.getLocalCatatan();
      notifyListeners();
      
      return true;
    } catch (e) {
      AppLogger.error('Error updating catatan: $e');
      _setError('Gagal memperbarui catatan: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Menghapus catatan
  Future<bool> deleteCatatan(String catatanId) async {
    try {
      _setLoading(true);
      _setError(null);

      await _repository.deleteCatatan(catatanId);

      AppLogger.info('Catatan berhasil dihapus: $catatanId');
      
      // Update local list immediately for responsive UI
      _catatanList = _repository.getLocalCatatan();
      notifyListeners();
      
      return true;
    } catch (e) {
      AppLogger.error('Error deleting catatan: $e');
      _setError('Gagal menghapus catatan: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Mencari catatan berdasarkan query
  Future<List<CatatanModel>> searchCatatan(String query) async {
    try {
      _setError(null);
      return _repository.searchCatatan(query);
    } catch (e) {
      AppLogger.error('Error searching catatan: $e');
      _setError('Gagal mencari catatan: $e');
      return [];
    }
  }

  /// Mendapatkan catatan berdasarkan ID
  CatatanModel? getCatatanById(String catatanId) {
    try {
      return _catatanList.firstWhere((catatan) => catatan.id == catatanId);
    } catch (e) {
      return null;
    }
  }

  /// Refresh catatan
  Future<void> refreshCatatan() async {
    await loadCatatan();
  }

  /// Filter catatan berdasarkan rentang tanggal
  List<CatatanModel> getCatatanByDateRange(DateTime startDate, DateTime endDate) {
    return _catatanList.where((catatan) {
      final createdAt = catatan.createdAt;
      return createdAt.isAfter(startDate.subtract(const Duration(days: 1))) &&
             createdAt.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  /// Mendapatkan catatan terbaru
  List<CatatanModel> getRecentCatatan(int limit) {
    if (_catatanList.isEmpty) return [];
    
    final sortedList = List<CatatanModel>.from(_catatanList);
    sortedList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return sortedList.take(limit).toList();
  }

  /// Mendapatkan statistik catatan
  Map<String, int> getCatatanStats() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thisWeek = today.subtract(Duration(days: today.weekday - 1));
    final thisMonth = DateTime(now.year, now.month, 1);

    return {
      'total': _catatanList.length,
      'today': _catatanList.where((c) {
        final createdAt = DateTime(c.createdAt.year, c.createdAt.month, c.createdAt.day);
        return createdAt.isAtSameMomentAs(today);
      }).length,
      'thisWeek': _catatanList.where((c) => c.createdAt.isAfter(thisWeek)).length,
      'thisMonth': _catatanList.where((c) => c.createdAt.isAfter(thisMonth)).length,
    };
  }

  @override
  void dispose() {
    _catatanStreamSubscription?.cancel();
    super.dispose();
  }
} 