import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Initialize notifications (without requesting permissions)
  static Future<void> initialize() async {
    tz_data.initializeTimeZones();

    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosInitSettings =
        DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: iosInitSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create Android notification channel for alarms
    final androidNotificationChannel = AndroidNotificationChannel(
      'alarm_channel',
      'Alarm Notifications',
      description: 'Notifications for alarm reminders',
      importance: Importance.max,
      enableLights: true,
      enableVibration: true,
      showBadge: true,
      ledColor: Colors.green,
    );

    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    await androidPlugin?.createNotificationChannel(androidNotificationChannel);

    debugPrint('NotificationService initialized');
  }

  /// Request notification permission (call from UI)
  static Future<bool> requestNotificationPermission() async {
    try {
      debugPrint('NotificationService: Requesting notification permissions...');

      // Request Android permissions
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      debugPrint(
        'NotificationService: Android plugin obtained, requesting notification permission...',
      );

      final androidResult =
          await androidPlugin?.requestNotificationsPermission() ?? false;

      debugPrint(
        'NotificationService: Android notification permission result = $androidResult',
      );

      debugPrint(
        'NotificationService: Note: For Android 12+, SCHEDULE_EXACT_ALARM can also be enabled in Settings > Apps > [Your App] > Alarms & reminders',
      );

      // Request iOS permissions
      final iosPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();

      debugPrint(
        'NotificationService: iOS plugin obtained, requesting permission...',
      );

      final iosResult =
          await iosPlugin?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;

      debugPrint('NotificationService: iOS permission result = $iosResult');

      final finalResult = androidResult || iosResult;
      debugPrint(
        'NotificationService: ✅ Permission request completed. Result = $finalResult',
      );
      return finalResult;
    } catch (e) {
      debugPrint(
        'NotificationService: ❌ Error requesting notification permission: $e',
      );
      return false;
    }
  }

  /// Convert alarm ID string to 32-bit notification ID
  static int _getNotificationId(String alarmId) {
    // Use hash of the alarm ID to get a 32-bit safe integer
    final hashCode = alarmId.hashCode;
    // Ensure it's positive and fits in 32-bit range
    return (hashCode.abs() % 0x7FFFFFFF);
  }

  /// Schedule an alarm notification
  static Future<void> scheduleAlarmNotification({
    required String alarmId,
    required DateTime alarmDateTime,
    required String alarmLabel,
  }) async {
    try {
      debugPrint('NotificationService: Scheduling alarm notification');
      debugPrint('  Alarm ID: $alarmId');
      debugPrint('  Alarm Time: $alarmDateTime');
      debugPrint('  Alarm Label: $alarmLabel');

      // Ensure alarm time is in the future
      final now = DateTime.now();
      final timeDifference = alarmDateTime.difference(now);
      final secondsUntilAlarm = timeDifference.inSeconds;

      debugPrint('  Current Time: $now');
      debugPrint(
        '  Time Until Alarm: ${timeDifference.inHours}h ${timeDifference.inMinutes % 60}m ${timeDifference.inSeconds % 60}s',
      );

      if (alarmDateTime.isBefore(now)) {
        final error =
            'Alarm time must be in the future. Current time: $now, Alarm time: $alarmDateTime';
        debugPrint('NotificationService: ❌ $error');
        throw Exception(error);
      }

      final notificationId = _getNotificationId(alarmId);

      // WORKAROUND: For alarms less than 2 minutes away, inexact alarms won't work reliably
      // Instead, schedule the notification to show at the exact time using Future.delayed
      if (secondsUntilAlarm < 120) {
        debugPrint(
          '⚠️  Alarm is less than 2 minutes away ($secondsUntilAlarm seconds)',
        );
        debugPrint(
          'NotificationService: Using immediate delay notification (fallback for near-future alarms)',
        );

        // Schedule notification to show at the exact time using a delay
        Future.delayed(Duration(seconds: secondsUntilAlarm), () async {
          debugPrint(
            'NotificationService: ⏰ Showing immediate alarm notification for "$alarmLabel"',
          );
          try {
            await showInstantNotification(
              title: 'Alarm: $alarmLabel',
              body: 'Time to wake up!',
            );
            debugPrint(
              'NotificationService: ✅ Immediate alarm notification shown - ID=$notificationId',
            );
          } catch (e) {
            debugPrint(
              'NotificationService: ❌ Error showing immediate notification: $e',
            );
          }
        });
        return;
      }

      final tzDateTime = tz.TZDateTime.from(alarmDateTime, tz.local);

      debugPrint('NotificationService: Converted to TZ DateTime: $tzDateTime');
      debugPrint('NotificationService: Notification ID: $notificationId');

      try {
        // Try scheduling with exact alarms first
        debugPrint('NotificationService: Attempting exact alarm schedule...');

        await _notificationsPlugin.zonedSchedule(
          notificationId,
          'Alarm: $alarmLabel',
          'Time to wake up!',
          tzDateTime,
          NotificationDetails(
            android: const AndroidNotificationDetails(
              'alarm_channel',
              'Alarm Notifications',
              channelDescription: 'Notifications for alarm reminders',
              importance: Importance.max,
              priority: Priority.high,
              enableVibration: true,
              fullScreenIntent: true,
              autoCancel: true,
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
              interruptionLevel: InterruptionLevel.critical,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.alarmClock,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );

        debugPrint(
          'NotificationService: ✅ Alarm notification scheduled (EXACT) - ID=$notificationId, Time=$alarmDateTime',
        );
      } catch (e) {
        // Fallback to inexact alarms if exact alarm permission is not granted
        if (e.toString().contains('exact_alarms_not_permitted') ||
            e.toString().contains('SCHEDULE_EXACT_ALARM')) {
          debugPrint(
            'NotificationService: ⚠️  Exact alarms not permitted, falling back to inexact alarms',
          );
          debugPrint(
            'NotificationService: ℹ️  To enable exact alarms: Settings → Apps → [Your App] → Alarms & reminders → Allow setting alarms and reminders',
          );

          await _notificationsPlugin.zonedSchedule(
            notificationId,
            'Alarm: $alarmLabel',
            'Time to wake up!',
            tzDateTime,
            NotificationDetails(
              android: const AndroidNotificationDetails(
                'alarm_channel',
                'Alarm Notifications',
                channelDescription: 'Notifications for alarm reminders',
                importance: Importance.max,
                priority: Priority.high,
                enableVibration: true,
                fullScreenIntent: true,
                autoCancel: true,
              ),
              iOS: const DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
                interruptionLevel: InterruptionLevel.critical,
              ),
            ),
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
          );

          debugPrint(
            'NotificationService: ✅ Alarm notification scheduled (INEXACT) - ID=$notificationId, Time=$alarmDateTime',
          );
          debugPrint(
            'NotificationService: ⚠️  NOTE: Inexact alarms may have ±10-15 minute variance and may not work if device is in deep sleep',
          );
        } else {
          debugPrint('NotificationService: ❌ Error scheduling alarm: $e');
          rethrow;
        }
      }
    } catch (e) {
      debugPrint('NotificationService: ❌ Failed to schedule notification: $e');
      throw Exception('Failed to schedule alarm notification: $e');
    }
  }

  /// Cancel a scheduled notification
  static Future<void> cancelAlarmNotification(String alarmId) async {
    try {
      final notificationId = _getNotificationId(alarmId);
      await _notificationsPlugin.cancel(notificationId);
      debugPrint(
        'Notification cancelled for alarm ID: $alarmId (notificationId: ${_getNotificationId(alarmId)})',
      );
    } catch (e) {
      debugPrint('Error cancelling notification: $e');
    }
  }

  /// Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    try {
      await _notificationsPlugin.cancelAll();
      debugPrint('All notifications cancelled');
    } catch (e) {
      debugPrint('Error cancelling all notifications: $e');
    }
  }

  /// Handle notification tap
  static void _onNotificationTapped(NotificationResponse notificationResponse) {
    debugPrint('Notification tapped: ${notificationResponse.id}');
    // You can add navigation or other actions here when a notification is tapped
  }

  /// Show instant notification (for testing)
  static Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
    try {
      debugPrint('NotificationService: Showing instant test notification');
      debugPrint('  Title: $title');
      debugPrint('  Body: $body');

      await _notificationsPlugin.show(
        999,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'alarm_channel',
            'Alarm Notifications',
            channelDescription: 'Notifications for alarm reminders',
            importance: Importance.max,
            priority: Priority.high,
            enableVibration: true,
            fullScreenIntent: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            interruptionLevel: InterruptionLevel.critical,
          ),
        ),
      );
      debugPrint('✅ Instant notification shown: $title');
    } catch (e) {
      debugPrint('❌ Error showing instant notification: $e');
    }
  }

  /// Test if notifications are working (shows immediately)
  static Future<void> testNotification() async {
    debugPrint('NotificationService: ========================================');
    debugPrint('NotificationService: TESTING NOTIFICATION SYSTEM');
    debugPrint('NotificationService: ========================================');

    try {
      // Check Android notification settings
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      debugPrint(
        'NotificationService: Android plugin available: ${androidPlugin != null}',
      );

      // Show test notification immediately
      debugPrint('NotificationService: Showing test notification NOW...');

      await showInstantNotification(
        title: 'Test Alarm 🔔',
        body: 'If you see this, notifications ARE working!',
      );

      debugPrint('NotificationService: Test notification method completed');
      debugPrint(
        'NotificationService: ========================================',
      );
    } catch (e) {
      debugPrint('NotificationService: ❌ Test failed: $e');
      debugPrint(
        'NotificationService: ========================================',
      );
    }
  }
}
