import 'package:flutter/material.dart';
import 'constants/index.dart';
import 'features/onboarding/index.dart';
import 'features/location/index.dart';

void main() {
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
      home: const OnboardingPage(),
    );
  }
}

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  bool _onboardingComplete = false;
  bool _locationAccessComplete = false;

  void _handleOnboardingComplete() {
    setState(() {
      _onboardingComplete = true;
    });
  }

  void _handleLocationAccessComplete() {
    setState(() {
      _locationAccessComplete = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_onboardingComplete) {
      return OnboardingFlowScreen(
        onOnboardingComplete: _handleOnboardingComplete,
      );
    }

    if (!_locationAccessComplete) {
      return LocationAccessScreen(
        onLocationAccessComplete: _handleLocationAccessComplete,
      );
    }

    // TODO: Implement home screen after location access
    return Scaffold(
      appBar: AppBar(title: const Text('Home'), elevation: 0),
      body: const Center(child: Text('App Setup Complete!')),
    );
  }
}
