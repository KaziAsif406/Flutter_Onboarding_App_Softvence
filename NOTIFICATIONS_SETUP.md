# Alarm Notifications Setup

This document explains the notification system implementation for the alarm app.

## Features Implemented

✅ **Local Notifications**
- The app now uses `flutter_local_notifications` package for alarm notifications
- Notifications are automatically scheduled when you create or enable an alarm
- Notifications are automatically cancelled when you delete or disable an alarm

✅ **Alarm Scheduling**
- Alarms are integrated with the database (SQLite)
- When an alarm is created, enabled, or updated, a notification is automatically scheduled
- Notifications are timed to go off at the exact alarm time

✅ **Platform-Specific Setup**
- **Android**: Configured with vibration, sound, and full-screen intent
- **iOS**: Configured to show alert, badge, and sound notifications

## How It Works

1. **Create Alarm**: When you add a new alarm via HomeScreen, it's stored in SQLite and a notification is scheduled
2. **Enable/Disable**: Toggle switches automatically schedule or cancel notifications
3. **Update Alarm**: Changing alarm time reschedules the notification
4. **Delete Alarm**: Deleting an alarm cancels its notification

## Android Configuration

The following permissions are required in `android/app/src/main/AndroidManifest.xml`:
- `VIBRATE` - For vibration feedback
- `POST_NOTIFICATIONS` - For sending notifications (Android 13+)
- `SCHEDULE_EXACT_ALARM` - For precise alarm scheduling

These have already been added to your project.

## iOS Configuration

iOS notifications are configured in code via `DarwinInitializationSettings`. The app will request user permission for:
- Alert notifications
- Badge notifications
- Sound notifications

Users will see a permission dialog when the app launches.

## Custom Alarm Sounds (Optional)

To add custom alarm sounds:

**Android:**
1. Add `.mp3` or `.wav` file to `android/app/src/main/res/raw/` directory
2. Update `notification_service.dart`:
   ```dart
   sound: RawResourceAndroidNotificationSound('your_sound_name'),
   ```

**iOS:**
1. Add `.caf` file to iOS project via Xcode
2. Update `notification_service.dart`:
   ```dart
   sound: 'your_sound_name.caf',
   ```

## Testing Notifications

Currently, notifications use system default sounds. You can test by:
1. Creating an alarm with a time close to the current time
2. The notification should trigger at the scheduled time
3. Toggle the alarm switch to test enable/disable functionality

## Important Notes

- Notifications require the app to have permission from the user (will be requested on first launch)
- On Android 13+, users must explicitly grant POST_NOTIFICATIONS permission
- Notifications will work even if the app is closed or in the background
- All notification scheduling is handled automatically by the AlarmService

## Troubleshooting

If notifications aren't appearing:
1. Check that notifications are enabled in your device settings
2. Ensure the app has notification permissions granted
3. For Android, verify the alarm time is in the future
4. Check that the alarm's `isEnabled` flag is set to `true`
