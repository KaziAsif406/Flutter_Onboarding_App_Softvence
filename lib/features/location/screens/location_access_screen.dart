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
  LocationModel? _currentLocation;
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
        _currentLocation = location;
        _isLoading = false;
      });
    } on Exception catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _continueToNext() {
    if (_currentLocation != null) {
      widget.onLocationAccessComplete(_currentLocation);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        leading: null,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.paddingLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon or illustration
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  size: 50,
                  color: AppColors.primaryPurple,
                ),
              ),

              SizedBox(height: AppDimensions.paddingXLarge),

              // Title
              Text(
                AppStrings.requestLocation,
                style: TextStyle(
                  fontSize: isMobile
                      ? AppDimensions.fontSizeXXLarge
                      : AppDimensions.fontSizeXXXLarge,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textWhite,
                  height: AppDimensions.lineHeightLarge,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: AppDimensions.paddingLarge),

              // Description
              Text(
                'We need your location to automatically sync your alarms with your environment.',
                style: TextStyle(
                  fontSize: AppDimensions.fontSizeLarge,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textGrey,
                  height: AppDimensions.lineHeightLarge,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: AppDimensions.paddingXLarge),

              // Location Display or Loading
              if (_currentLocation != null) ...[
                Container(
                  padding: EdgeInsets.all(AppDimensions.paddingLarge),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDarkSecondary,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.borderRadiusLarge,
                    ),
                    border: Border.all(
                      color: AppColors.primaryPurple.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.primaryPurple,
                            size: 24,
                          ),
                          SizedBox(width: AppDimensions.paddingMedium),
                          Text(
                            AppStrings.selectedLocation,
                            style: const TextStyle(
                              fontSize: AppDimensions.fontSizeLarge,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textWhite,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppDimensions.paddingMedium),
                      Text(
                        _currentLocation!.displayName,
                        style: const TextStyle(
                          fontSize: AppDimensions.fontSizeMedium,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppDimensions.paddingXLarge),
              ] else if (_errorMessage != null) ...[
                Container(
                  padding: EdgeInsets.all(AppDimensions.paddingLarge),
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
                SizedBox(height: AppDimensions.paddingXLarge),
              ] else if (_isLoading) ...[
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
                SizedBox(height: AppDimensions.paddingXLarge),
              ],

              // Spacer
              const Spacer(),

              // Button
              if (_currentLocation != null)
                PrimaryButton(label: 'Continue', onPressed: _continueToNext)
              else
                PrimaryButton(
                  label: AppStrings.allowLocation,
                  onPressed: _requestLocationPermission,
                  isLoading: _isLoading,
                ),

              SizedBox(height: AppDimensions.paddingLarge),

              // Skip for now button
              if (_currentLocation == null)
                TextButton(
                  onPressed: () => widget.onLocationAccessComplete(null),
                  child: const Text(
                    'Skip for now',
                    style: TextStyle(
                      fontSize: AppDimensions.fontSizeLarge,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textGreySecondary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
