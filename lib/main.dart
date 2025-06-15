import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// Using barrel exports for clean imports
import 'package:nasa_daily_snapshot/providers/index.dart';
import 'package:nasa_daily_snapshot/screens/index.dart';
import 'package:nasa_daily_snapshot/themes/index.dart';
import 'package:nasa_daily_snapshot/utils/index.dart';

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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: Theme.of(context).brightness == Brightness.dark
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF1A1B3A).withAlpha(ColorUtils.safeAlpha(0.95)),
                    const Color(0xFF0F0F23).withAlpha(ColorUtils.safeAlpha(0.98)),
                  ],
                )
              : null,
          boxShadow: Theme.of(context).brightness == Brightness.dark
              ? [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withAlpha(ColorUtils.safeAlpha(0.1)),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ]
              : null,
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.transparent
                : null,
            indicatorColor: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF6366F1).withAlpha(ColorUtils.safeAlpha(0.3))
                : Theme.of(context).colorScheme.primary.withAlpha(ColorUtils.safeAlpha(0.2)),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF6366F1)
                      : Theme.of(context).colorScheme.primary,
                  letterSpacing: 0.5,
                );
              }
              return TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFFE2E8F0).withAlpha(ColorUtils.safeAlpha(0.7))
                    : Theme.of(context).colorScheme.onSurface.withAlpha(ColorUtils.safeAlpha(0.7)),
              );
            }),
            iconTheme: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return IconThemeData(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF6366F1)
                      : Theme.of(context).colorScheme.primary,
                  size: 26,
                );
              }
              return IconThemeData(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFFE2E8F0).withAlpha(ColorUtils.safeAlpha(0.7))
                    : Theme.of(context).colorScheme.onSurface.withAlpha(ColorUtils.safeAlpha(0.7)),
                size: 24,
              );
            }),
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
            animationDuration: const Duration(milliseconds: 600),
            labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
            destinations: [
              NavigationDestination(
                icon: Icon(
                  Icons.home_outlined,
                  shadows: Theme.of(context).brightness == Brightness.dark
                      ? [
                          Shadow(
                            color: const Color(0xFF6366F1).withAlpha(ColorUtils.safeAlpha(0.3)),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
                selectedIcon: Icon(
                  Icons.home,
                  shadows: Theme.of(context).brightness == Brightness.dark
                      ? [
                          Shadow(
                            color: const Color(0xFF6366F1).withAlpha(ColorUtils.safeAlpha(0.5)),
                            blurRadius: 12,
                          ),
                        ]
                      : null,
                ),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.search_outlined,
                  shadows: Theme.of(context).brightness == Brightness.dark
                      ? [
                          Shadow(
                            color: const Color(0xFF6366F1).withAlpha(ColorUtils.safeAlpha(0.3)),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
                selectedIcon: Icon(
                  Icons.search,
                  shadows: Theme.of(context).brightness == Brightness.dark
                      ? [
                          Shadow(
                            color: const Color(0xFF6366F1).withAlpha(ColorUtils.safeAlpha(0.5)),
                            blurRadius: 12,
                          ),
                        ]
                      : null,
                ),
                label: 'Search',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.favorite_outline,
                  shadows: Theme.of(context).brightness == Brightness.dark
                      ? [
                          Shadow(
                            color: const Color(0xFF6366F1).withAlpha(ColorUtils.safeAlpha(0.3)),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
                selectedIcon: Icon(
                  Icons.favorite,
                  shadows: Theme.of(context).brightness == Brightness.dark
                      ? [
                          Shadow(
                            color: const Color(0xFF6366F1).withAlpha(ColorUtils.safeAlpha(0.5)),
                            blurRadius: 12,
                          ),
                        ]
                      : null,
                ),
                label: 'Favorites',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.settings_outlined,
                  shadows: Theme.of(context).brightness == Brightness.dark
                      ? [
                          Shadow(
                            color: const Color(0xFF6366F1).withAlpha(ColorUtils.safeAlpha(0.3)),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
                selectedIcon: Icon(
                  Icons.settings,
                  shadows: Theme.of(context).brightness == Brightness.dark
                      ? [
                          Shadow(
                            color: const Color(0xFF6366F1).withAlpha(ColorUtils.safeAlpha(0.5)),
                            blurRadius: 12,
                          ),
                        ]
                      : null,
                ),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
