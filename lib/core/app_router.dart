import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/detail_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/search_screen.dart';
import '../screens/settings_screen.dart';
import '../models/apod_model.dart';
import '../providers/apod_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/theme_provider.dart';

/// Application route names
class AppRoutes {
  static const String home = '/';
  static const String detail = '/detail';
  static const String favorites = '/favorites';
  static const String search = '/search';
  static const String settings = '/settings';
  
  /// Get all route names
  static List<String> get allRoutes => [
    home,
    detail,
    favorites,
    search,
    settings,
  ];
}

/// Route arguments for passing data between screens
class RouteArguments {
  /// Arguments for detail screen
  static const String apodData = 'apod_data';
  static const String heroTag = 'hero_tag';
  static const String date = 'date';
  
  /// Arguments for search screen
  static const String initialQuery = 'initial_query';
  static const String searchType = 'search_type';
  
  /// Arguments for favorites screen
  static const String showFavoritesOnly = 'show_favorites_only';
}

/// Custom route transitions
enum RouteTransition {
  slide,
  fade,
  scale,
  rotation,
  slideFromBottom,
  slideFromTop,
  none,
}

/// Application router configuration
class AppRouter {
  static final AppRouter _instance = AppRouter._internal();
  factory AppRouter() => _instance;
  AppRouter._internal();

  /// Generate routes for the application
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        final args = settings.arguments as Map<String, dynamic>?;
        final apodProvider = args?['apodProvider'] as ApodProvider?;
        final favoritesProvider = args?['favoritesProvider'] as FavoritesProvider?;
        
        if (apodProvider == null || favoritesProvider == null) {
          return _buildErrorRoute('Home screen requires provider arguments', settings);
        }
        
        return _buildRoute(
          HomeScreen(
            apodProvider: apodProvider,
            favoritesProvider: favoritesProvider,
          ),
          settings,
          RouteTransition.fade,
        );
        
      case AppRoutes.detail:
        final args = settings.arguments as Map<String, dynamic>?;
        final apodData = args?[RouteArguments.apodData] as ApodModel?;
        final heroTag = args?[RouteArguments.heroTag] as String?;
        
        if (apodData == null) {
          return _buildErrorRoute('Detail screen requires APOD data', settings);
        }
        
        final favoritesProvider = args?['favoritesProvider'] as FavoritesProvider?;
        
        if (favoritesProvider == null) {
          return _buildErrorRoute('Detail screen requires favoritesProvider', settings);
        }
        
        return _buildRoute(
          DetailScreen(
            apod: apodData,
            favoritesProvider: favoritesProvider,
            heroTagPrefix: heroTag ?? 'detail_${apodData.date}',
          ),
          settings,
          RouteTransition.slide,
        );
        
      case AppRoutes.favorites:
        final args = settings.arguments as Map<String, dynamic>?;
        final apodProvider = args?['apodProvider'] as ApodProvider?;
        final favoritesProvider = args?['favoritesProvider'] as FavoritesProvider?;
        
        if (apodProvider == null || favoritesProvider == null) {
          return _buildErrorRoute('Favorites screen requires provider arguments', settings);
        }
        
        return _buildRoute(
          FavoritesScreen(
            apodProvider: apodProvider,
            favoritesProvider: favoritesProvider,
          ),
          settings,
          RouteTransition.slideFromBottom,
        );
        
      case AppRoutes.search:
        final args = settings.arguments as Map<String, dynamic>?;
        final apodProvider = args?['apodProvider'] as ApodProvider?;
        final favoritesProvider = args?['favoritesProvider'] as FavoritesProvider?;
        
        if (apodProvider == null || favoritesProvider == null) {
          return _buildErrorRoute('Search screen requires provider arguments', settings);
        }
        
        return _buildRoute(
          SearchScreen(
            apodProvider: apodProvider,
            favoritesProvider: favoritesProvider,
          ),
          settings,
          RouteTransition.slideFromTop,
        );
        
      case AppRoutes.settings:
        final args = settings.arguments as Map<String, dynamic>?;
        final themeProvider = args?['themeProvider'] as ThemeProvider?;
        
        if (themeProvider == null) {
          return _buildErrorRoute('Settings screen requires themeProvider', settings);
        }
        
        return _buildRoute(
          SettingsScreen(
            themeProvider: themeProvider,
          ),
          settings,
          RouteTransition.slide,
        );
        
      default:
        return _buildErrorRoute('Route not found: ${settings.name}', settings);
    }
  }

  /// Build route with custom transition
  static Route<dynamic> _buildRoute(
    Widget page,
    RouteSettings settings,
    RouteTransition transition, {
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    switch (transition) {
      case RouteTransition.slide:
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            final tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );
            final offsetAnimation = animation.drive(tween);
            
            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        );
        
      case RouteTransition.fade:
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation.drive(
                CurveTween(curve: curve),
              ),
              child: child,
            );
          },
        );
        
      case RouteTransition.scale:
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return ScaleTransition(
              scale: animation.drive(
                Tween(begin: 0.0, end: 1.0).chain(
                  CurveTween(curve: curve),
                ),
              ),
              child: child,
            );
          },
        );
        
      case RouteTransition.rotation:
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return RotationTransition(
              turns: animation.drive(
                Tween(begin: 0.0, end: 1.0).chain(
                  CurveTween(curve: curve),
                ),
              ),
              child: child,
            );
          },
        );
        
      case RouteTransition.slideFromBottom:
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            final tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );
            final offsetAnimation = animation.drive(tween);
            
            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        );
        
      case RouteTransition.slideFromTop:
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, -1.0);
            const end = Offset.zero;
            final tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );
            final offsetAnimation = animation.drive(tween);
            
            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        );
        
      case RouteTransition.none:
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        );
    }
  }

  /// Build error route
  static Route<dynamic> _buildErrorRoute(String message, RouteSettings settings) {
    return MaterialPageRoute(
      settings: settings,
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  'Route Error',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      AppRoutes.home,
                      (route) => false,
                    );
                  },
                  child: const Text('Go to Home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Navigation helper methods
  static Future<T?> pushNamed<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.of(context).pushNamed<T>(
      routeName,
      arguments: arguments,
    );
  }

  static Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    TO? result,
  }) {
    return Navigator.of(context).pushReplacementNamed<T, TO>(
      routeName,
      arguments: arguments,
      result: result,
    );
  }

  static Future<T?> pushNamedAndRemoveUntil<T extends Object?>(
    BuildContext context,
    String routeName,
    bool Function(Route<dynamic>) predicate, {
    Object? arguments,
  }) {
    return Navigator.of(context).pushNamedAndRemoveUntil<T>(
      routeName,
      predicate,
      arguments: arguments,
    );
  }

  static void pop<T extends Object?>(BuildContext context, [T? result]) {
    Navigator.of(context).pop<T>(result);
  }

  static void popUntil(BuildContext context, bool Function(Route<dynamic>) predicate) {
    Navigator.of(context).popUntil(predicate);
  }

  static bool canPop(BuildContext context) {
    return Navigator.of(context).canPop();
  }

  /// Specific navigation methods for app screens
  static Future<void> goToHome(BuildContext context) {
    return pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
      (route) => false,
    );
  }

  static Future<void> goToDetail(
    BuildContext context,
    ApodModel apod, {
    String? heroTag,
  }) {
    return pushNamed(
      context,
      AppRoutes.detail,
      arguments: {
        RouteArguments.apodData: apod,
        if (heroTag != null) RouteArguments.heroTag: heroTag,
      },
    );
  }

  static Future<void> goToFavorites(
    BuildContext context, {
    bool showFavoritesOnly = true,
  }) {
    return pushNamed(
      context,
      AppRoutes.favorites,
      arguments: {
        RouteArguments.showFavoritesOnly: showFavoritesOnly,
      },
    );
  }

  static Future<void> goToSearch(
    BuildContext context, {
    String? initialQuery,
    String? searchType,
  }) {
    return pushNamed(
      context,
      AppRoutes.search,
      arguments: {
        if (initialQuery != null) RouteArguments.initialQuery: initialQuery,
        if (searchType != null) RouteArguments.searchType: searchType,
      },
    );
  }

  static Future<void> goToSettings(BuildContext context) {
    return pushNamed(context, AppRoutes.settings);
  }
}