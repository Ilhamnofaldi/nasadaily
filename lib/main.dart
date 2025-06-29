import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

// Using barrel exports for clean imports
import 'package:nasa_daily_snapshot/providers/index.dart';
import 'package:nasa_daily_snapshot/screens/index.dart';
import 'package:nasa_daily_snapshot/themes/index.dart';
import 'package:nasa_daily_snapshot/utils/index.dart';
import 'package:nasa_daily_snapshot/services/notification_service.dart';
import 'package:nasa_daily_snapshot/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (with error handling)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization failed: $e');
    print('App will continue without Firebase features');
  }
  
  // Initialize Notification Service
  final notificationService = NotificationService();
  try {
    await notificationService.initialize();
  } catch (e) {
    print('Notification service initialization failed: $e');
  }
  
  // Set preferred orientations - Allow both portrait and landscape
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
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

  final authProvider = AuthProvider();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: favoritesProvider),
        ChangeNotifierProvider.value(value: apodProvider),
        ChangeNotifierProvider.value(value: authProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ThemeProvider _themeProvider;

  @override
  void initState() {
    super.initState();
    _themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    _themeProvider.addListener(_onThemeChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final apodProvider = Provider.of<ApodProvider>(context);
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    
    return MaterialApp(
      title: 'NASA Daily Snapshot',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.isLoading) {
            return Scaffold(
              body: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF1A1B3A),
                      const Color(0xFF0F0F23),
                    ],
                  ),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            );
          }
          
          if (authProvider.isAuthenticated) {
            return MainScreen(
              apodProvider: apodProvider,
              favoritesProvider: favoritesProvider,
              themeProvider: themeProvider,
            );
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}
