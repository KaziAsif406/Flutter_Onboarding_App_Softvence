import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants/index.dart';
import 'features/onboarding/index.dart';
import 'features/location/index.dart';
import 'features/alarm/index.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Onboarding App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.dark(
          primary: AppColors.primaryPurple,
          surface: AppColors.primaryDark,
        ),
        scaffoldBackgroundColor: AppColors.primaryDark,
      ),
      home: const SplashScreen(),
      routes: {
        '/onboarding': (context) => const OnboardingPage(isFirstLaunch: true),
        '/home': (context) => const OnboardingPage(isFirstLaunch: false),
      },
    );
  }
}

class OnboardingPage extends StatefulWidget {
  final bool isFirstLaunch;

  const OnboardingPage({super.key, required this.isFirstLaunch});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late bool _onboardingComplete;
  late bool _locationAccessComplete;
  LocationModel? _selectedLocation;

  @override
  void initState() {
    super.initState();
    // If not first launch, skip onboarding and load saved location
    _onboardingComplete = !widget.isFirstLaunch;
    _locationAccessComplete = false;

    // Load saved location if available
    _loadSavedLocation();
  }

  Future<void> _loadSavedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLocation = prefs.getString('selectedLocation');

      if (savedLocation != null) {
        final locationJson = jsonDecode(savedLocation) as Map<String, dynamic>;
        setState(() {
          _selectedLocation = LocationModel.fromJson(locationJson);
          // If location was previously saved, skip location screen
          _locationAccessComplete = true;
        });
      }
    } catch (e) {
      // Silently fail if location cannot be loaded
      debugPrint('Error loading saved location: $e');
    }
  }

  Future<void> _markOnboardingComplete() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isFirstLaunch', false);
      setState(() {
        _onboardingComplete = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _handleOnboardingComplete() {
    _markOnboardingComplete();
  }

  void _handleLocationAccessComplete(LocationModel? location) {
    setState(() {
      _locationAccessComplete = true;
      _selectedLocation = location;
    });
  }

  void _goBackToLocationScreen() {
    setState(() {
      _locationAccessComplete = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // First launch flow: Onboarding -> Location -> Home
    if (!_onboardingComplete) {
      return OnboardingFlowScreen(
        onOnboardingComplete: _handleOnboardingComplete,
      );
    }

    // Show location screen if not completed
    if (!_locationAccessComplete) {
      return LocationAccessScreen(
        onLocationAccessComplete: _handleLocationAccessComplete,
      );
    }

    // Show home screen with alarm management
    return HomeScreen(
      selectedLocation: _selectedLocation,
      onBackPressed: _goBackToLocationScreen,
    );
  }
}
