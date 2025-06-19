import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

// Using barrel exports for clean imports
import 'package:nasa_daily_snapshot/providers/index.dart';
import 'package:nasa_daily_snapshot/screens/index.dart';
import 'package:nasa_daily_snapshot/themes/index.dart';
import 'package:nasa_daily_snapshot/utils/index.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
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
      home: MainScreen(
        apodProvider: apodProvider,
        favoritesProvider: favoritesProvider,
        themeProvider: themeProvider,
      ),
    );
  }
}
