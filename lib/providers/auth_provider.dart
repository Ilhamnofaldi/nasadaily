import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider extends ChangeNotifier {
  FirebaseAuth? _auth;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  User? _user;
  bool _isLoading = false;
  bool _hasFirebase = false;
  bool _isLoggedInLocally = false; // For offline mode

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null || _isLoggedInLocally;
  bool get hasFirebase => _hasFirebase;

  AuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() {
    try {
      _auth = FirebaseAuth.instance;
      _hasFirebase = true;
      print('Firebase Auth available');
      
      _auth!.authStateChanges().listen((User? user) {
        _user = user;
        // If user is null (logged out), also clear local login state
        if (user == null) {
          _isLoggedInLocally = false;
        }
        notifyListeners();
      });
    } catch (e) {
      _hasFirebase = false;
      print('Firebase Auth not available: $e');
    }
  }

  Future<void> signInWithGoogle() async {
    if (!_hasFirebase || _auth == null) {
      debugPrint('Firebase Auth not available');
      return;
    }
    
    try {
      _isLoading = true;
      notifyListeners();

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      await _auth!.signInWithCredential(credential);
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // Sign out from all services
      final futures = <Future>[];
      
      if (_hasFirebase && _auth != null) {
        futures.add(_auth!.signOut());
      }
      
      // Always sign out from Google Sign In
      try {
        futures.add(_googleSignIn.signOut());
      } catch (e) {
        debugPrint('Error signing out from Google: $e');
      }
      
      // Wait for all sign out operations to complete
      await Future.wait(futures);
      
      // Force clear all authentication state
      _user = null;
      _isLoggedInLocally = false;
      
      debugPrint('Successfully signed out');
      
    } catch (e) {
      debugPrint('Error signing out: $e');
      // Even if there's an error, clear local state
      _user = null;
      _isLoggedInLocally = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Continue without login when Firebase is not available
  void continueWithoutLogin() {
    if (!_hasFirebase) {
      debugPrint('Continuing without login - Firebase not available');
      _isLoggedInLocally = true;
      notifyListeners();
    }
  }
} 