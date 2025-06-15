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
import 'package:nasa_daily_snapshot/utils/color_utils.dart';
import 'package:provider/provider.dart'; // Import the provider package

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      // Consider making these adaptive to theme later
      statusBarIconBrightness: Brightness.dark, 
      statusBarBrightness: Brightness.light,
    ),
  );
  
  // Load preferences
  final themeProvider = ThemeProvider();
  await themeProvider.initialize();
  
  final favoritesProvider = FavoritesProvider();
  await favoritesProvider.initialize();

  final apodProvider = ApodProvider();
  // If ApodProvider has an async initialize method that needs to be called,
  // ensure it's defined and uncomment the line below:
  // await apodProvider.initialize(); 
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: favoritesProvider),
        // Assuming ApodProvider is also a ChangeNotifier or can be provided as such.
        // If it's not a ChangeNotifier, you might use Provider.value instead.
        ChangeNotifierProvider.value(value: apodProvider),
      ],
      child: const MyApp(), // MyApp no longer takes providers in constructor
    ),
  );
}

class MyApp extends StatefulWidget {
  // Constructor no longer needs provider arguments
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ThemeProvider _themeProvider; // To manage listener

  @override
  void initState() {
    super.initState();
    // Access ThemeProvider from context for listening
    // Ensure this is done after the first frame if context is needed immediately,
    // or use didChangeDependencies. For addListener, initState is fine if
    // Provider.of is called with listen:false or in a post-frame callback.
    // A safer way is to get it in didChangeDependencies or build.
    // For now, let's get it once and add listener.
    _themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    _themeProvider.addListener(_onThemeChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // If you need to re-obtain providers when dependencies change, do it here.
    // For listeners, often initState with listen:false is sufficient if the instance doesn't change.
  }

  @override
  void dispose() {
    _themeProvider.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Access providers from context
    final themeProvider = Provider.of<ThemeProvider>(context);
    final apodProvider = Provider.of<ApodProvider>(context);
    final favoritesProvider = Provider.of<FavoritesProvider>(context);

    return MaterialApp(
      title: 'NASA Daily Snapshot',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: MainScreen(
        // Pass providers to MainScreen
        apodProvider: apodProvider,
        favoritesProvider: favoritesProvider,
        themeProvider: themeProvider,
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
          indicatorColor: Theme.of(context).colorScheme.primary.withAlpha(ColorUtils.safeAlpha(0.2)), // Replaced .withOpacity(0.2)
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
