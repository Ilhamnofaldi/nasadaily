import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nasa_daily_snapshot/providers/index.dart';
import 'package:nasa_daily_snapshot/screens/index.dart';
import 'package:nasa_daily_snapshot/utils/index.dart';
import 'package:nasa_daily_snapshot/themes/app_colors.dart';
import 'dart:ui';

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

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late AnimationController _navAnimationController;
  late PageController _pageController;
  late List<Animation<double>> _navItemAnimations;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _navAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _pageController = PageController(initialPage: _selectedIndex);
    
    // Initialize navigation item animations
    _navItemAnimations = List.generate(4, (index) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _navAnimationController,
        curve: Interval(
          index * 0.1,
          0.5 + index * 0.1,
          curve: Curves.elasticOut,
        ),
      ));
    });
    
    _navAnimationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _navAnimationController.dispose();
    _pageController.dispose();
    super.dispose();
  }
  
  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    // Check if PageController is attached to a PageView before animating
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }

    if (index == 0) {
      _animationController.forward(from: 0.0);
    }
  }

  Widget _buildNavigationRail() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: 240,
      decoration: BoxDecoration(
        gradient: isDark 
          ? LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1a1a2e),
                Color(0xFF16213e),
                Color(0xFF0f172a),
              ],
            )
          : null, // No gradient for light mode
        color: isDark ? null : Colors.white, // White background for light mode
        boxShadow: [
          BoxShadow(
            color: isDark 
              ? Colors.black.withOpacity(0.3)
              : Colors.black.withOpacity(0.05),
            blurRadius: 30,
            offset: const Offset(5, 0),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Modern header with logo
            Container(
              padding: const EdgeInsets.all(32),
      child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                  // NASA logo badge
          Container(
                    padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                        width: 1,
            ),
                    ),
              child: Icon(
                      Icons.rocket_launch_rounded,
                      size: 28,
                      color: AppColors.primary,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // App title
                  Text(
                    'Nasa\nDaily\nSnapshot',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.getTextColor(isDark),
                      letterSpacing: -0.5,
                      height: 1.1,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    'Discover the universe',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.getSecondaryTextColor(isDark),
                      letterSpacing: 0.5,
              ),
            ),
                ],
          ),
            ),
            
            const SizedBox(height: 32),
            
            // Navigation items with text labels
          Expanded(
              child: Column(
              children: [
                  _buildModernNavItem(
                  index: 0,
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home_rounded,
                    label: 'Home',
                ),
                  const SizedBox(height: 8),
                  _buildModernNavItem(
                  index: 1,
                  icon: Icons.search_outlined,
                  selectedIcon: Icons.search_rounded,
                    label: 'Search',
                ),
                  const SizedBox(height: 8),
                  _buildModernNavItem(
                  index: 2,
                  icon: Icons.favorite_outline_rounded,
                  selectedIcon: Icons.favorite_rounded,
                    label: 'Favourites',
                ),
                  const SizedBox(height: 8),
                  _buildModernNavItem(
                  index: 3,
                    icon: Icons.person_outline_rounded,
                    selectedIcon: Icons.person_rounded,
                    label: 'Profile',
                ),
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }
  
  Widget _buildModernNavItem({
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
  }) {
    final isSelected = _selectedIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AnimatedBuilder(
      animation: _navItemAnimations[index],
      builder: (context, child) {
        return Transform.scale(
          scale: _navItemAnimations[index].value,
          child: GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: isSelected 
                  ? AppColors.primary.withOpacity(0.15)
                  : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: isSelected
                  ? Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                      width: 1,
                    )
                  : null,
              ),
              child: Row(
                children: [
                  Icon(
          isSelected ? selectedIcon : icon,
                    color: isSelected 
                      ? AppColors.primary 
                      : AppColors.getSecondaryTextColor(isDark),
          size: 24,
        ),
                  const SizedBox(width: 16),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected 
                        ? AppColors.getTextColor(isDark) 
                        : AppColors.getSecondaryTextColor(isDark),
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNavigationBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: 90,
      decoration: BoxDecoration(
        gradient: isDark 
          ? LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1a1a2e).withOpacity(0.95),
                Color(0xFF0f172a),
              ],
            )
          : null, // No gradient for light mode
        color: isDark ? null : Colors.white, // White background for light mode
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark 
              ? Colors.black.withOpacity(0.3)
              : Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
              _buildModernBottomNavItem(
            index: 0,
            icon: Icons.home_outlined,
            selectedIcon: Icons.home_rounded,
                label: 'Home',
          ),
              _buildModernBottomNavItem(
            index: 1,
            icon: Icons.search_outlined,
            selectedIcon: Icons.search_rounded,
                label: 'Search',
          ),
              _buildModernBottomNavItem(
            index: 2,
            icon: Icons.favorite_outline_rounded,
            selectedIcon: Icons.favorite_rounded,
                label: 'Favourites',
              ),
              _buildModernBottomNavItem(
                index: 3,
                icon: Icons.person_outline_rounded,
                selectedIcon: Icons.person_rounded,
                label: 'Profile',
          ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildModernBottomNavItem({
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
  }) {
    final isSelected = _selectedIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AnimatedBuilder(
      animation: _navItemAnimations[index],
      builder: (context, child) {
        return Transform.scale(
          scale: _navItemAnimations[index].value,
          child: GestureDetector(
            onTap: () => _onItemTapped(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected 
                  ? AppColors.primary.withOpacity(0.15)
                  : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: isSelected
                  ? Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                      width: 1,
                    )
                  : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isSelected ? selectedIcon : icon,
                    color: isSelected 
                      ? AppColors.primary 
                      : AppColors.getSecondaryTextColor(isDark),
                    size: 24,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected 
                        ? AppColors.primary 
                        : AppColors.getSecondaryTextColor(isDark),
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompactNavigationRail() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: 80,
      decoration: BoxDecoration(
        gradient: isDark 
          ? LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1a1a2e),
                Color(0xFF16213e),
                Color(0xFF0f172a),
              ],
            )
          : null,
        color: isDark ? null : Colors.white,
        boxShadow: [
          BoxShadow(
            color: isDark 
              ? Colors.black.withOpacity(0.3)
              : Colors.black.withOpacity(0.05),
            blurRadius: 30,
            offset: const Offset(5, 0),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Compact header with logo
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.rocket_launch_rounded,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Compact navigation items
            Expanded(
              child: Column(
                children: [
                  _buildCompactNavItem(
                    index: 0,
                    icon: Icons.home_outlined,
                    selectedIcon: Icons.home_rounded,
                  ),
                  const SizedBox(height: 12),
                  _buildCompactNavItem(
                    index: 1,
                    icon: Icons.search_outlined,
                    selectedIcon: Icons.search_rounded,
                  ),
                  const SizedBox(height: 12),
                  _buildCompactNavItem(
                    index: 2,
                    icon: Icons.favorite_outline_rounded,
                    selectedIcon: Icons.favorite_rounded,
                  ),
                  const SizedBox(height: 12),
                  _buildCompactNavItem(
                    index: 3,
                    icon: Icons.person_outline_rounded,
                    selectedIcon: Icons.person_rounded,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCompactNavItem({
    required int index,
    required IconData icon,
    required IconData selectedIcon,
  }) {
    final isSelected = _selectedIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AnimatedBuilder(
      animation: _navItemAnimations[index],
      builder: (context, child) {
        return Transform.scale(
          scale: _navItemAnimations[index].value,
          child: GestureDetector(
            onTap: () => _onItemTapped(index),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected 
                  ? AppColors.primary.withOpacity(0.15)
                  : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: isSelected
                  ? Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                      width: 1,
                    )
                  : null,
              ),
              child: Icon(
                isSelected ? selectedIcon : icon,
                color: isSelected 
                  ? AppColors.primary 
                  : AppColors.getSecondaryTextColor(isDark),
                size: 22,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Show login screen if not authenticated
    if (!authProvider.isAuthenticated) {
      return const LoginScreen();
    }

    // Responsive navigation logic with 3 breakpoints:
    // 1. Large screens (>1200px): Full NavigationRail with labels
    // 2. Medium screens (700-1200px): Compact NavigationRail icons only  
    // 3. Small screens (<700px): Bottom Navigation
    
    late Widget navigationWidget;
    late bool useNavigationRail;
    late bool useCompactRail;
    
    if (screenWidth >= 1200) {
      // Large screens: Full NavigationRail
      useNavigationRail = true;
      useCompactRail = false;
      navigationWidget = _buildNavigationRail();
    } else if (screenWidth >= 700 && isLandscape) {
      // Medium screens in landscape: Compact NavigationRail
      useNavigationRail = true;
      useCompactRail = true;
      navigationWidget = _buildCompactNavigationRail();
    } else {
      // Small screens or portrait: Bottom Navigation
      useNavigationRail = false;
      useCompactRail = false;
      navigationWidget = _buildBottomNavigationBar();
    }

    final screens = [
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
    ];

    if (useNavigationRail) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.getBackgroundColor(isDark) : Colors.white,
        body: SafeArea(
          child: Row(
            children: [
              navigationWidget, // Either full or compact rail
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.1, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                child: IndexedStack(
                    key: ValueKey(_selectedIndex),
                  index: _selectedIndex,
                  children: screens,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Use bottom navigation for small screens
    return Scaffold(
      extendBody: true,
      backgroundColor: isDark ? AppColors.getBackgroundColor(isDark) : Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark 
            ? RadialGradient(
                center: Alignment.topRight,
                radius: 1.5,
                colors: [
                  Color(0xFF1a1a2e),
                  Color(0xFF16213e),
                  Color(0xFF0f172a),
                ],
              )
            : null, // No gradient for light mode, just white
        ),
        child: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const PageScrollPhysics(),
        children: screens,
      ),
      ),
      bottomNavigationBar: navigationWidget,
    );
  }
}
