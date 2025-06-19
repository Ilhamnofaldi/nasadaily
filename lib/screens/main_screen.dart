import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nasa_daily_snapshot/providers/index.dart';
import 'package:nasa_daily_snapshot/screens/index.dart';
import 'package:nasa_daily_snapshot/utils/index.dart';

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
    final authProvider = Provider.of<AuthProvider>(context);

    // Show login screen if not authenticated
    if (!authProvider.isAuthenticated) {
      return const LoginScreen();
    }

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