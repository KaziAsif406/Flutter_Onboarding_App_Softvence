import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../constants/index.dart';
import '../../../commmon_widgets/index.dart';
import '../models/location_model.dart';
import '../services/location_service.dart';

class LocationAccessScreen extends StatefulWidget {
  final Function(LocationModel?) onLocationAccessComplete;

  const LocationAccessScreen({
    super.key,
    required this.onLocationAccessComplete,
  });

  @override
  State<LocationAccessScreen> createState() => _LocationAccessScreenState();
}

class _LocationAccessScreenState extends State<LocationAccessScreen> {
  bool _isLoading = false;
  bool _isLocationServiceEnabled = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkLocationServiceEnabled();
  }

  Future<void> _checkLocationServiceEnabled() async {
    final enabled = await LocationService.isLocationServiceEnabled();
    setState(() {
      _isLocationServiceEnabled = enabled;
    });
  }

  Future<void> _requestLocationPermission() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Check if location service is enabled
      if (!_isLocationServiceEnabled) {
        setState(() {
          _errorMessage = 'Location service is disabled. Please enable it.';
          _isLoading = false;
        });
        return;
      }

      // Request permission
      final hasPermission = await LocationService.requestLocationPermission();

      if (!hasPermission) {
        setState(() {
          _errorMessage =
              'Location permission is required to use this feature.';
          _isLoading = false;
        });
        return;
      }

      // Get current location
      final location = await LocationService.getCurrentLocation();

      // Save location to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selectedLocation', jsonEncode(location.toJson()));
      await prefs.setBool('locationPermissionGranted', true);

      setState(() {
        _isLoading = false;
      });

      // Navigate to next screen with location
      if (mounted) {
        widget.onLocationAccessComplete(location);
      }
    } on Exception catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        leading: null,
        automaticallyImplyLeading: false,
        title: const Text(
          'Location',
          style: TextStyle(
            fontSize: AppDimensions.fontSizeLarge,
            fontWeight: FontWeight.w500,
            color: AppColors.textGreySecondary,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingLarge,
                  vertical: AppDimensions.paddingMedium,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      'Welcome to Your Smart Nature Alarm',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textWhite,
                        height: 1.3,
                      ),
                    ),

                    SizedBox(height: AppDimensions.paddingMedium),

                    // Subtitle
                    Text(
                      'Sync with your surroundings and let your alarms adjust to your environment automatically.',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Color(0xB3FFFFFF), // White with 70% opacity
                        height: 1.6,
                      ),
                    ),

                    SizedBox(height: AppDimensions.paddingXLarge),

                    // Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/images/location1.jpg',
                        width: double.infinity,
                        height: 300,
                        fit: BoxFit.cover,
                      ),
                    ),

                    SizedBox(height: AppDimensions.paddingXLarge),

                    // Error Message Display
                    if (_errorMessage != null) ...[
                      Container(
                        padding: EdgeInsets.all(AppDimensions.paddingMedium),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7F1D1D).withOpacity(0.3),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.borderRadiusLarge,
                          ),
                          border: Border.all(
                            color: const Color(0xFFFCA5A5).withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              color: Color(0xFFDC2626),
                              size: 24,
                            ),
                            SizedBox(width: AppDimensions.paddingMedium),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  fontSize: AppDimensions.fontSizeMedium,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFFDC2626),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: AppDimensions.paddingLarge),
                    ],

                    // Loading State
                    if (_isLoading) ...[
                      Center(
                        child: Column(
                          children: [
                            const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primaryPurple,
                              ),
                            ),
                            SizedBox(height: AppDimensions.paddingLarge),
                            const Text(
                              'Fetching your location...',
                              style: TextStyle(
                                fontSize: AppDimensions.fontSizeLarge,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Bottom Buttons Section
            Container(
              color: AppColors.primaryDark,
              padding: EdgeInsets.only(
                left: AppDimensions.paddingLarge,
                right: AppDimensions.paddingLarge,
                top: AppDimensions.paddingMedium,
                bottom: AppDimensions.paddingXLarge,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Use Current Location Button (Outlined)
                  if (!_isLoading)
                    OutlinedButton(
                      onPressed: _requestLocationPermission,
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size(
                          double.infinity,
                          AppDimensions.buttonHeight,
                        ),
                        side: const BorderSide(
                          color: AppColors.primaryPurple,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            color: AppColors.primaryPurple,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Use Current Location',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryPurple,
                            ),
                          ),
                        ],
                      ),
                    ),

                  SizedBox(height: AppDimensions.paddingMedium),

                  // Home Button (Filled)
                  PrimaryButton(
                    label: 'Home',
                    onPressed: () => widget.onLocationAccessComplete(null),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
