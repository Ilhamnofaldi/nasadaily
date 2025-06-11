import 'package:flutter/material.dart';
import 'package:nasa_daily_snapshot/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

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
  String _imageQuality = 'high';
  bool _saveToGallery = true;
  String _appVersion = '';
  
  @override
  bool get wantKeepAlive => true;
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
    _getAppVersion();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? false;
      _imageQuality = prefs.getString('imageQuality') ?? 'high';
      _saveToGallery = prefs.getBool('saveToGallery') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);
    await prefs.setString('imageQuality', _imageQuality);
    await prefs.setBool('saveToGallery', _saveToGallery);
  }
  
  Future<void> _getAppVersion() async {

  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _buildSectionHeader('Appearance'),
          _buildThemeSection(),
          _buildImageQualitySection(),
          
          _buildSectionHeader('Notifications'),
          _buildNotificationSection(),
          
          _buildSectionHeader('Storage'),
          _buildStorageSection(),
          
          _buildSectionHeader('About'),
          _buildAboutSection(),
          
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear All Data'),
                    content: const Text(
                      'This will clear all favorites and settings. This action cannot be undone.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          // Clear all data
                          SharedPreferences.getInstance().then((prefs) {
                            prefs.clear();
                            setState(() {
                              _notificationsEnabled = false;
                              _imageQuality = 'high';
                              _saveToGallery = true;
                            });
                            widget.themeProvider.toggleTheme();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('All data cleared'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            Navigator.of(context).pop();
                          });
                        },
                        child: const Text('Clear All', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Clear All Data'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildThemeSection() {
    return SwitchListTile(
      title: const Text('Dark Theme'),
      subtitle: const Text('Toggle between light and dark mode'),
      secondary: Icon(
        widget.themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
        color: Theme.of(context).colorScheme.primary,
      ),
      value: widget.themeProvider.isDarkMode,
      onChanged: (value) {
        widget.themeProvider.toggleTheme();
      },
    );
  }

  Widget _buildNotificationSection() {
    return SwitchListTile(
      title: const Text('Daily Notifications'),
      subtitle: const Text('Get notified when a new image is available'),
      secondary: Icon(
        _notificationsEnabled ? Icons.notifications_active : Icons.notifications_off,
        color: Theme.of(context).colorScheme.primary,
      ),
      value: _notificationsEnabled,
      onChanged: (value) async {
        setState(() {
          _notificationsEnabled = value;
        });
        await _saveSettings();
        
        // Show a message about notification permissions
        if (value && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enable notifications in your device settings'),
              duration: Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
    );
  }

  Widget _buildImageQualitySection() {
    return ListTile(
      leading: Icon(
        Icons.high_quality,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: const Text('Image Quality'),
      subtitle: const Text('Choose image resolution for viewing and saving'),
      trailing: DropdownButton<String>(
        value: _imageQuality,
        onChanged: (String? newValue) {
          if (newValue != null) {
            setState(() {
              _imageQuality = newValue;
            });
            _saveSettings();
          }
        },
        items: <String>['low', 'medium', 'high']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value.capitalize()),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStorageSection() {
    return SwitchListTile(
      title: const Text('Save to Gallery'),
      subtitle: const Text('Automatically save downloaded images to gallery'),
      secondary: Icon(
        Icons.save_alt,
        color: Theme.of(context).colorScheme.primary,
      ),
      value: _saveToGallery,
      onChanged: (value) async {
        setState(() {
          _saveToGallery = value;
        });
        await _saveSettings();
      },
    );
  }

  Widget _buildAboutSection() {
    return Column(
      children: [
        ListTile(
          leading: Icon(
            Icons.info_outline,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: const Text('About'),
          subtitle: Text('NASA Daily Snapshot $_appVersion'),
          onTap: () {
            showAboutDialog(
              context: context,
              applicationName: 'NASA Daily Snapshot',
              applicationVersion: _appVersion,
              applicationIcon: const FlutterLogo(size: 32),
              applicationLegalese: '© 2023 NASA Daily Snapshot',
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
        ListTile(
          leading: Icon(
            Icons.privacy_tip_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: const Text('Privacy Policy'),
          onTap: () {
            // Open privacy policy
          },
        ),
        ListTile(
          leading: Icon(
            Icons.rate_review_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: const Text('Rate the App'),
          onTap: () {
            // Open app store rating
          },
        ),
      ],
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
