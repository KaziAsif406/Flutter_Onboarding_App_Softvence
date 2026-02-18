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
      // Request Android permissions
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      final androidResult =
          await androidPlugin?.requestNotificationsPermission() ?? false;

      // Request iOS permissions
      final iosPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();

      final iosResult =
          await iosPlugin?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;

      final finalResult = androidResult || iosResult;
      return finalResult;
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
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
      // Ensure alarm time is in the future
      final now = DateTime.now();
      final timeDifference = alarmDateTime.difference(now);
      final secondsUntilAlarm = timeDifference.inSeconds;

      if (alarmDateTime.isBefore(now)) {
        throw Exception('Alarm time must be in the future');
      }

      final notificationId = _getNotificationId(alarmId);

      // WORKAROUND: For alarms less than 2 minutes away, use immediate delay notification
      // since inexact alarms won't fire reliably for near-future times
      if (secondsUntilAlarm < 120) {
        Future.delayed(Duration(seconds: secondsUntilAlarm), () async {
          try {
            await showInstantNotification(
              title: 'Alarm: $alarmLabel',
              body: 'Time to wake up!',
            );
          } catch (e) {
            debugPrint('Error showing alarm notification: $e');
          }
        });
        return;
      }

      final tzDateTime = tz.TZDateTime.from(alarmDateTime, tz.local);

      try {
        // Try scheduling with exact alarms first
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
      } catch (e) {
        // Fallback to inexact alarms if exact alarm permission is not granted
        if (e.toString().contains('exact_alarms_not_permitted') ||
            e.toString().contains('SCHEDULE_EXACT_ALARM')) {
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
        } else {
          rethrow;
        }
      }
    } catch (e) {
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

  /// Show instant notification (used internally for immediate alarms)
  static Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
    try {
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
      debugPrint('Notification shown: $title');
    } catch (e) {
      debugPrint('Error showing notification: $e');
    }
  }
}
