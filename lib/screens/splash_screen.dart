import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/index.dart';
import '../features/alarm/services/notification_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      debugPrint(
        'SplashScreen: Checking first launch and requesting permissions...',
      );

      final prefs = await SharedPreferences.getInstance();

      // Check if notification permission has already been requested
      final notificationPermissionAsked =
          prefs.getBool('notificationPermissionAsked') ?? false;

      debugPrint(
        'SplashScreen: notificationPermissionAsked = $notificationPermissionAsked',
      );

      // Only show notification permission dialog if not asked before
      if (!notificationPermissionAsked && mounted) {
        debugPrint('SplashScreen: Showing notification permission dialog');
        await _requestNotificationPermission();
        debugPrint('SplashScreen: Permission dialog dismissed');

        // Mark that we've asked for notification permission
        await prefs.setBool('notificationPermissionAsked', true);
      }

      final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

      debugPrint('SplashScreen: isFirstLaunch = $isFirstLaunch');

      if (mounted) {
        Navigator.of(
          context,
        ).pushReplacementNamed(isFirstLaunch ? '/onboarding' : '/home');
      }
    } catch (e) {
      debugPrint('SplashScreen Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _requestNotificationPermission() async {
    if (!mounted) return;

    debugPrint('SplashScreen: Building notification permission dialog');

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.primaryDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppDimensions.borderRadiusLarge,
            ),
          ),
          title: Text(
            'Enable Notifications',
            style: Theme.of(dialogContext).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'We need notification permissions to alert you when your alarms go off.',
            style: Theme.of(
              dialogContext,
            ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                debugPrint('SplashScreen: User tapped Skip');
                Navigator.of(dialogContext).pop();
              },
              child: const Text(
                'Skip',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                debugPrint(
                  'SplashScreen: User tapped Allow - requesting permissions',
                );
                try {
                  final result =
                      await NotificationService.requestNotificationPermission();
                  debugPrint(
                    'SplashScreen: Permission request result = $result',
                  );
                } catch (e) {
                  debugPrint('SplashScreen: Permission request error = $e');
                }
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPurple,
              ),
              child: const Text('Allow'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.alarm_rounded,
                size: 40,
                color: AppColors.primaryPurple,
              ),
            ),
            SizedBox(height: AppDimensions.paddingXLarge),
            const Text(
              'Alarm App',
              style: TextStyle(
                fontSize: AppDimensions.fontSizeXXLarge,
                fontWeight: FontWeight.bold,
                color: AppColors.textWhite,
              ),
            ),
            SizedBox(height: AppDimensions.paddingLarge),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.primaryPurple,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
