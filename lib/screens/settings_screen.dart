import 'package:flutter/material.dart';
import 'package:nasa_daily_snapshot/providers/theme_provider.dart';
import 'package:nasa_daily_snapshot/providers/auth_provider.dart';
import 'package:nasa_daily_snapshot/themes/app_colors.dart';
import 'package:nasa_daily_snapshot/utils/extensions.dart';
import 'package:nasa_daily_snapshot/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  final ThemeProvider themeProvider;

  const SettingsScreen({
    Key? key, 
    required this.themeProvider,
  }) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with AutomaticKeepAliveClientMixin {
  bool _notificationsEnabled = false;
  bool _saveToGallery = true;
  
  @override
  bool get wantKeepAlive => true;
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? false;
      _saveToGallery = prefs.getBool('saveToGallery') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);
    await prefs.setBool('saveToGallery', _saveToGallery);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.getBackgroundColor(isDark) : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: AppColors.getTextColor(isDark)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.getTextColor(isDark),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            // Appearance Section
          _buildSectionHeader('Appearance'),
            const SizedBox(height: 12),
            _buildModernToggle(
              title: 'Dark Theme',
              subtitle: 'Enable dark mode for a more comfortable\nviewing experience in low-light conditions.',
              value: widget.themeProvider.isDarkMode,
              onChanged: (value) => widget.themeProvider.toggleTheme(),
            ),
            
            const SizedBox(height: 32),
            
            // Notifications Section
          _buildSectionHeader('Notifications'),
            const SizedBox(height: 12),
            _buildModernToggle(
              title: 'Daily Notifications',
              subtitle: 'Receive a daily notification when a new\nimage is available.',
              value: _notificationsEnabled,
              onChanged: (value) async {
                setState(() {
                  _notificationsEnabled = value;
                });
                await _saveSettings();
              },
            ),
            
            const SizedBox(height: 32),
            
            // Storage Section
          _buildSectionHeader('Storage'),
            const SizedBox(height: 12),
            _buildModernToggle(
              title: 'Save to Gallery',
              subtitle: 'Automatically save images to your\ndevice\'s gallery.',
              value: _saveToGallery,
              onChanged: (value) async {
                setState(() {
                  _saveToGallery = value;
                });
                await _saveSettings();
              },
            ),
            
            const SizedBox(height: 32),
            
            // About Section
          _buildSectionHeader('About'),
            const SizedBox(height: 12),
            _buildModernMenuItem(
              icon: Icons.info_outline_rounded,
              title: 'About',
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'NASA Daily Snapshot',
                  applicationVersion: '1.0.0',
                  applicationIcon: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.rocket_launch_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  applicationLegalese: '© 2024 NASA Daily Snapshot',
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      'This app uses the NASA Astronomy Picture of the Day (APOD) API to show daily astronomy images and their explanations.',
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Images and content are provided by NASA and are in the public domain.',
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 8),
            _buildModernMenuItem(
               icon: Icons.privacy_tip_outlined,
               title: 'Privacy Policy',
              onTap: () {
                // Implementation for privacy policy
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Privacy Policy - Coming Soon'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            _buildModernMenuItem(
              icon: Icons.star_outline_rounded,
              title: 'Rate the App',
              onTap: () {
                // Implementation for app rating
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Rate the App - Coming Soon'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            
            const SizedBox(height: 40),
            
            // Logout Section
            Center(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        backgroundColor: AppColors.getSurfaceColor(isDark),
                        title: Text(
                          'Logout',
                          style: TextStyle(
                            color: AppColors.getTextColor(isDark),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        content: Text(
                      'Are you sure you want to logout?',
                          style: TextStyle(
                            color: AppColors.getSecondaryTextColor(isDark),
                          ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: AppColors.getSecondaryTextColor(isDark),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                      ),
                      TextButton(
                        onPressed: () async {
                          try {
                            await context.read<AuthProvider>().signOut();
                            if (mounted) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Successfully logged out'),
                                  behavior: SnackBarBehavior.floating,
                                      backgroundColor: AppColors.success,
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error logging out: ${e.toString()}'),
                                  behavior: SnackBarBehavior.floating,
                                      backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          }
                        },
                            child: const Text(
                              'Logout',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                      ),
                    ],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.1),
                    foregroundColor: Colors.red,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Colors.red.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
              ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.logout_rounded,
                        color: Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
            ),
                    ],
          ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Debug Section (Development Only)
            Center(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      // Initialize notification service
                      final notificationService = NotificationService();
                      await notificationService.initialize();
                      
                      // Request permissions first
                      final hasPermission = await notificationService.requestPermissions();
                      if (!hasPermission) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Notification permission denied'),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: AppColors.error,
      ),
    );
  }
                        return;
                      }
                      
                      // Show test notification
                      await notificationService.showDailyApodNotification(
                        'Test: Rubin\'s First Look: A Sagittarius Skyscape',
                        'This is a test notification to verify that daily notifications are working properly. A stunning view of the Sagittarius constellation captured by the Rubin Observatory showing the rich star fields and cosmic dust lanes that make this region so spectacular.',
                      );
                      
                      if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Test notification sent! Check your notification panel.'),
              behavior: SnackBarBehavior.floating,
                            backgroundColor: AppColors.success,
            ),
          );
        }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error sending test notification: ${e.toString()}'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    foregroundColor: AppColors.primary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: AppColors.primary.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bug_report_outlined,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Test Daily Notification',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 100), // Space for bottom navigation
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Text(
      title,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.getTextColor(isDark),
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildModernToggle({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.getTextColor(isDark),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.getSecondaryTextColor(isDark),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
                ),
            const SizedBox(width: 16),
            Transform.scale(
              scale: 0.8,
              child: Switch(
                value: value,
                onChanged: onChanged,
                activeColor: AppColors.primary,
                activeTrackColor: AppColors.primary.withOpacity(0.3),
                inactiveThumbColor: AppColors.getSecondaryTextColor(isDark),
                inactiveTrackColor: AppColors.getSecondaryTextColor(isDark).withOpacity(0.3),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModernMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.getBorderColor(isDark),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.getSurfaceColor(isDark),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppColors.getTextColor(isDark),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.getTextColor(isDark),
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.getSecondaryTextColor(isDark),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
