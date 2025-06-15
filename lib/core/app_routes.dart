import 'package:flutter/material.dart';
import '../screens/detail_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/search_screen.dart';
import '../screens/settings_screen.dart';
import '../models/apod_model.dart';
import '../providers/apod_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/theme_provider.dart';

/// Application routes configuration
class AppRoutes {
  // Route names
  static const String home = '/';
  static const String detail = '/detail';
  static const String favorites = '/favorites';
  static const String search = '/search';
  static const String settings = '/settings';
  static const String imageViewer = '/image-viewer';
  
  // Route generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return _createRoute(const HomeWrapper());
        
      case AppRoutes.detail:
        final args = settings.arguments as DetailScreenArguments?;
        if (args != null) {
          return _createRoute(
            DetailScreen(
              apod: args.apod,
              favoritesProvider: args.favoritesProvider,
              heroTagPrefix: args.heroTagPrefix,
            ),
          );
        }
        return _errorRoute('Detail screen requires arguments');
        
      case AppRoutes.favorites:
        final args = settings.arguments as FavoritesScreenArguments?;
        if (args != null) {
          return _createRoute(
            FavoritesScreen(
              favoritesProvider: args.favoritesProvider,
              apodProvider: args.apodProvider,
            ),
          );
        }
        return _errorRoute('Favorites screen requires arguments');
        
      case AppRoutes.search:
        final args = settings.arguments as SearchScreenArguments?;
        if (args != null) {
          return _createRoute(
            SearchScreen(
              apodProvider: args.apodProvider,
              favoritesProvider: args.favoritesProvider,
            ),
          );
        }
        return _errorRoute('Search screen requires arguments');
        
      case AppRoutes.settings:
        final args = settings.arguments as SettingsScreenArguments?;
        if (args != null) {
          return _createRoute(
            SettingsScreen(
              themeProvider: args.themeProvider,
            ),
          );
        }
        return _errorRoute('Settings screen requires arguments');
        
      default:
        return _errorRoute('Route not found: ${settings.name}');
    }
  }
  
  // Create route with custom transition
  static PageRoute _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;
        
        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );
        
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
  
  // Error route
  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Route Error',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Route arguments classes
class DetailScreenArguments {
  final ApodModel apod;
  final FavoritesProvider favoritesProvider;
  final String? heroTagPrefix;
  
  DetailScreenArguments({
    required this.apod,
    required this.favoritesProvider,
    this.heroTagPrefix,
  });
}

class FavoritesScreenArguments {
  final FavoritesProvider favoritesProvider;
  final ApodProvider apodProvider;
  
  FavoritesScreenArguments({
    required this.favoritesProvider,
    required this.apodProvider,
  });
}

class SearchScreenArguments {
  final ApodProvider apodProvider;
  final FavoritesProvider favoritesProvider;
  
  SearchScreenArguments({
    required this.apodProvider,
    required this.favoritesProvider,
  });
}

class SettingsScreenArguments {
  final ThemeProvider themeProvider;
  
  SettingsScreenArguments({
    required this.themeProvider,
  });
}

// Wrapper for home screen (placeholder)
class HomeWrapper extends StatelessWidget {
  const HomeWrapper({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // This would typically be handled by the main navigation
    return const Scaffold(
      body: Center(
        child: Text('Home Screen Wrapper'),
      ),
    );
  }
}