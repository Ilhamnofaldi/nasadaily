import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nasa_daily_snapshot/providers/index.dart';
import 'package:nasa_daily_snapshot/screens/index.dart';
import 'package:nasa_daily_snapshot/utils/index.dart';
import 'package:nasa_daily_snapshot/themes/app_colors.dart';

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
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _animationController.dispose();
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
      width: 70, // Narrower width like Disney+ sidebar
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark 
              ? [
                  Colors.black,
                  Colors.black.withOpacity(0.85),
                  AppColors.primaryBlue.withOpacity(0.2),
                ]
              : [
                  AppColors.primaryBlue.withOpacity(0.8),
                  AppColors.primaryBlue.withOpacity(0.6),
                  AppColors.primaryBlue.withOpacity(0.4),
                ],
          stops: const [0.0, 0.7, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.5)
                : AppColors.primaryBlue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile section at top
          const SizedBox(height: 16),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark 
                    ? Colors.white.withOpacity(0.5) 
                    : Colors.white.withOpacity(0.8),
                width: 1
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [AppColors.primaryPurple, AppColors.primaryBlue]
                    : [AppColors.primaryBlue, AppColors.secondaryTeal],
              ),
            ),
            child: Center(
              child: Icon(
                Icons.rocket_launch,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 40),
          // Navigation items
          Expanded(
            child: ListView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildHotstarNavItem(
                  index: 0,
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home_rounded,
                  isSelected: _selectedIndex == 0,
                  isDark: isDark,
                ),
                _buildHotstarNavItem(
                  index: 1,
                  icon: Icons.search_outlined,
                  selectedIcon: Icons.search_rounded,
                  isSelected: _selectedIndex == 1,
                  isDark: isDark,
                ),
                _buildHotstarNavItem(
                  index: 2,
                  icon: Icons.favorite_outline_rounded,
                  selectedIcon: Icons.favorite_rounded,
                  isSelected: _selectedIndex == 2,
                  isDark: isDark,
                ),
                _buildHotstarNavItem(
                  index: 3,
                  icon: Icons.settings_outlined,
                  selectedIcon: Icons.settings_rounded,
                  isSelected: _selectedIndex == 3,
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHotstarNavItem({
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required bool isSelected,
    required bool isDark,
  }) {
    return InkWell(
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 70,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: isSelected
            ? BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: isDark
                      ? [
                          Colors.transparent,
                          AppColors.primaryPurple.withOpacity(0.3),
                          Colors.transparent,
                        ]
                      : [
                          Colors.transparent,
                          Colors.white.withOpacity(0.3),
                          Colors.transparent,
                        ],
                ),
              )
            : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              transform: isSelected
                  ? (Matrix4.identity()..scale(1.2))
                  : Matrix4.identity(),
              transformAlignment: Alignment.center,
              child: Icon(
                isSelected ? selectedIcon : icon,
                color: isSelected
                    ? (isDark ? Colors.white : Colors.white)
                    : (isDark ? Colors.white.withOpacity(0.5) : Colors.white.withOpacity(0.7)),
                size: 26,
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(top: 5),
              width: isSelected ? 5 : 0,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: isDark
                              ? AppColors.primaryPurple.withOpacity(0.6)
                              : Colors.white.withOpacity(0.6),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
                  Colors.black.withOpacity(0.8),
                  Colors.black,
                  AppColors.primaryBlue.withOpacity(0.2),
                ]
              : [
                  AppColors.primaryBlue.withOpacity(0.4),
                  AppColors.primaryBlue.withOpacity(0.6),
                  AppColors.primaryBlue.withOpacity(0.8),
                ],
          stops: const [0.0, 0.7, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.5)
                : AppColors.primaryBlue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      height: 70,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildBottomNavItem(
            index: 0,
            icon: Icons.home_outlined,
            selectedIcon: Icons.home_rounded,
            isSelected: _selectedIndex == 0,
            isDark: isDark,
          ),
          _buildBottomNavItem(
            index: 1,
            icon: Icons.search_outlined,
            selectedIcon: Icons.search_rounded,
            isSelected: _selectedIndex == 1,
            isDark: isDark,
          ),
          _buildBottomNavItem(
            index: 2,
            icon: Icons.favorite_outline_rounded,
            selectedIcon: Icons.favorite_rounded,
            isSelected: _selectedIndex == 2,
            isDark: isDark,
          ),
          _buildBottomNavItem(
            index: 3,
            icon: Icons.settings_outlined,
            selectedIcon: Icons.settings_rounded,
            isSelected: _selectedIndex == 3,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem({
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required bool isSelected,
    required bool isDark,
  }) {
    return InkWell(
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 70,
        alignment: Alignment.center,
        decoration: isSelected
            ? BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark
                      ? [
                          Colors.transparent,
                          AppColors.primaryPurple.withOpacity(0.3),
                          Colors.transparent,
                        ]
                      : [
                          Colors.transparent,
                          Colors.white.withOpacity(0.3),
                          Colors.transparent,
                        ],
                ),
              )
            : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              transform: isSelected
                  ? (Matrix4.identity()..scale(1.2))
                  : Matrix4.identity(),
              transformAlignment: Alignment.center,
              child: Icon(
                isSelected ? selectedIcon : icon,
                color: isSelected
                    ? (isDark ? Colors.white : Colors.white)
                    : (isDark ? Colors.white.withOpacity(0.5) : Colors.white.withOpacity(0.7)),
                size: 26,
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(top: 5),
              width: isSelected ? 5 : 0,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: isDark
                              ? AppColors.primaryPurple.withOpacity(0.6)
                              : Colors.white.withOpacity(0.6),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Show login screen if not authenticated
    if (!authProvider.isAuthenticated) {
      return const LoginScreen();
    }

    // For very wide screens or landscape mode, use NavigationRail
    final useNavigationRail = isLandscape || screenWidth > 800;

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
        body: Container(
          decoration: BoxDecoration(
            gradient: isDark
                ? AppColors.getSpaceGradient()
                : AppColors.getSpaceGradient(isDark: false),
          ),
          child: SafeArea(
            child: Row(
              children: [
                _buildNavigationRail(),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark 
                          ? AppColors.neutralDark
                          : Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        bottomLeft: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withOpacity(0.3)
                              : Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(-3, 0),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        bottomLeft: Radius.circular(24),
                      ),
                      child: IndexedStack(
                        index: _selectedIndex,
                        children: screens,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Portrait mode or narrow screens use bottom navigation
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppColors.getSpaceGradient()
              : AppColors.getSpaceGradient(isDark: false),
        ),
        child: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          physics: const PageScrollPhysics(),
          children: screens,
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
}