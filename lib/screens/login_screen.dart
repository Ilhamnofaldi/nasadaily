import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nasa_daily_snapshot/providers/auth_provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.brightness == Brightness.dark
                  ? const Color(0xFF1A1B3A)
                  : theme.colorScheme.primary,
              theme.brightness == Brightness.dark
                  ? const Color(0xFF0F0F23)
                  : theme.colorScheme.primary.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo or Icon
                Icon(
                  Icons.rocket_launch,
                  size: 100,
                  color: theme.brightness == Brightness.dark
                      ? const Color(0xFF6366F1)
                      : Colors.white,
                ),
                const SizedBox(height: 24),
                // App Name
                Text(
                  'NASA Daily Snapshot',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                // App Description
                Text(
                  'Discover the cosmos every day',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 48),
                // Google Sign In Button or Offline Notice
                if (authProvider.isLoading)
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                else if (!authProvider.hasFirebase)
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.symmetric(horizontal: 32),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.cloud_off_rounded,
                              color: Colors.white.withOpacity(0.8),
                              size: 32,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Firebase Offline',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Login unavailable. Continue without login to use app with local storage.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => authProvider.continueWithoutLogin(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.9),
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        icon: Icon(Icons.arrow_forward_rounded, size: 20),
                        label: const Text(
                          'Continue Without Login',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  ElevatedButton.icon(
                    onPressed: () => authProvider.signInWithGoogle(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    icon: Image.network(
                      'https://www.google.com/favicon.ico',
                      height: 24,
                    ),
                    label: const Text(
                      'Sign in with Google',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 