import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nasa_daily_snapshot/providers/theme_provider.dart';
import 'package:nasa_daily_snapshot/providers/apod_provider.dart';
import 'package:nasa_daily_snapshot/providers/favorites_provider.dart';
import 'package:nasa_daily_snapshot/screens/home_screen.dart';
import 'package:nasa_daily_snapshot/screens/favorites_screen.dart';
import 'package:nasa_daily_snapshot/screens/settings_screen.dart';
import 'package:nasa_daily_snapshot/screens/search_screen.dart';
import 'package:nasa_daily_snapshot/utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);Hey, Cortana. Hey, Cortana. Hey, Cortana. Hey, Cortana. My city neighbor. Hey, Cortana. Hey, Cortana. Hey, Cortana. Play my music. Hey, Cortana. 
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );
  
  // Load preferences
  final themeProvider = ThemeProvider();
  await themeProvider.initialize();
  
  final favoritesProvider = FavoritesProvider();
  await favoritesProvider.initialize();
  
  runApp(
    MyApp(
      themeProvider: themeProvider,
      favoritesProvider: favoritesProvider,
    ),
  );
}

class MyApp extends StatefulWidget {
  final ThemeProvider themeProvider;
  final FavoritesProvider favoritesProvider;

  const MyApp({
    Key? key, 
    required this.themeProvider, 
    required this.favoritesProvider,
  }) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ApodProvider _apodProvider;

  @override
  void initState() {
    super.initState();
    _apodProvider = ApodProvider();
    
    // Listen to theme changes
    widget.themeProvider.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    widget.themeProvider.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NASA Daily Snapshot',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: widget.themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: MainScreen(
        apodProvider: _apodProvider,
        favoritesProvider: widget.favoritesProvider,
        themeProvider: widget.themeProvider,
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  final ApodProvider apodProvider;
  final FavoritesProvider favoritesProvider;
  final ThemeProvider themeProvider;

  const MainScreen({
    Key? key, 
    required this.apodProvider, 
    required this.favoritesProvider,
    required this.themeProvider,
  }) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          HomeScreen(
            apodProvider: widget.apodProvider,
            favoritesProvider: widget.favoritesProvider,
          ),
          SearchScreen(
            apodProvider: widget.apodProvider,
            favoritesProvider: widget.favoritesProvider,
          ),
          FavoritesScreen(
            favoritesProvider: widget.favoritesProvider,
            apodProvider: widget.apodProvider,
          ),
          SettingsScreen(
            themeProvider: widget.themeProvider,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          labelTextStyle: WidgetStateProperty.all(
            TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
            
            if (index == 0) {
              _animationController.forward(from: 0.0);
            }
          },
          animationDuration: const Duration(milliseconds: 500),
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.search_outlined),
              selectedIcon: Icon(Icons.search),
              label: 'Search',
            ),
            NavigationDestination(
              icon: Icon(Icons.favorite_outline),
              selectedIcon: Icon(Icons.favorite),
              label: 'Favorites',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
